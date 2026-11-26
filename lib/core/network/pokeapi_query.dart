import 'dart:async';

import 'package:graphql/client.dart';

import '../domain/sync_failure.dart';

/// Ejecuta una consulta a PokeAPI sin cache (SQLite es la unica fuente
/// persistida) y traduce cualquier error a [SyncFailure]. Recibe el texto de
/// la consulta: analizarlo cuesta menos de 1 ms y evita depender de `gql`.
Future<Map<String, dynamic>> queryPokeApi(
  GraphQLClient client,
  String query, {
  Map<String, dynamic> variables = const {},
}) async {
  final result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
    ),
  );
  final exception = result.exception;
  if (exception != null) throw graphqlFailure(exception);
  final data = result.data;
  if (data == null) {
    throw const SyncFailure(
      SyncFailureKind.invalidResponse,
      'GraphQL no devolvio datos.',
    );
  }
  return data;
}

/// Mismo criterio para catalogo y detalle: decide si el fallo es temporal
/// (se reintenta) o definitivo.
SyncFailure graphqlFailure(OperationException exception) {
  final linkError = exception.linkException;
  final statusCode = switch (linkError) {
    HttpLinkServerException error => error.statusCode,
    HttpLinkParserException error => error.response.statusCode,
    _ => null,
  };
  if (statusCode == 429) {
    return const SyncFailure(
      SyncFailureKind.rateLimited,
      'Limite de solicitudes de PokeAPI alcanzado.',
    );
  }
  if (linkError?.originalException is TimeoutException) {
    return const SyncFailure(
      SyncFailureKind.timeout,
      'GraphQL excedio el tiempo de espera.',
    );
  }
  if (linkError is NetworkException ||
      (linkError is ServerException &&
          linkError.parsedResponse == null &&
          statusCode == null)) {
    return const SyncFailure(
      SyncFailureKind.network,
      'No se pudo conectar con GraphQL.',
    );
  }
  if (statusCode != null && statusCode >= 300) {
    return const SyncFailure(
      SyncFailureKind.serviceUnavailable,
      'El servicio GraphQL no esta disponible.',
    );
  }
  // Incluso con data, los errores GraphQL invalidan toda la respuesta.
  if (exception.graphqlErrors.isNotEmpty) {
    return const SyncFailure(
      SyncFailureKind.graphql,
      'GraphQL devolvio errores o datos parciales.',
    );
  }
  return const SyncFailure(
    SyncFailureKind.invalidResponse,
    'La respuesta GraphQL no es valida.',
  );
}
