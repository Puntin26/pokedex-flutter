import '../../../core/domain/sync_failure.dart';

// Validadores compartidos por los DTO: un dato con forma inesperada invalida
// toda la respuesta (nunca se guarda a medias, OF-04).

Map<String, dynamic> jsonObject(Object? value, {String? context}) {
  if (value is! Map<String, dynamic>) invalidResponse(context);
  return value;
}

List<dynamic> jsonList(Object? value, {String? context}) {
  if (value is! List) invalidResponse(context);
  return value;
}

int positiveInt(Object? value, {String? context}) {
  if (value is! int || value <= 0) invalidResponse(context);
  return value;
}

int nonNegativeInt(Object? value, {String? context}) {
  if (value is! int || value < 0) invalidResponse(context);
  return value;
}

int? optionalNonNegativeInt(Object? value, {String? context}) {
  if (value == null) return null;
  return nonNegativeInt(value, context: context);
}

String trimmedName(Object? value, {String? context}) {
  if (value is! String || value.trim().isEmpty || value != value.trim()) {
    invalidResponse(context);
  }
  return value;
}

String? optionalHttpsUrl(Object? value, {String? context}) {
  if (value == null) return null;
  if (value is! String) invalidResponse(context);
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    invalidResponse(context);
  }
  return value;
}

bool jsonBool(Object? value, {String? context}) {
  if (value is! bool) invalidResponse(context);
  return value;
}

Never invalidResponse([String? context]) => throw SyncFailure(
  SyncFailureKind.invalidResponse,
  context ??
      'La respuesta de PokeAPI esta incompleta o contiene datos invalidos.',
);
