import 'package:flutter_riverpod/flutter_riverpod.dart';

// Hora actual inyectable para probar vigencia y formatos sin depender del reloj real.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
