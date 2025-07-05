import 'package:intl/intl.dart';

String formatNombre(int nombre) {
  final formatter = NumberFormat('#,###', 'fr_FR');
  return formatter.format(nombre).replaceAll(',', ' ');
}

String formatNombreStr(String nombreStr) {
  final nombre = int.tryParse(nombreStr) ?? 0;
  return formatNombre(nombre);
}
