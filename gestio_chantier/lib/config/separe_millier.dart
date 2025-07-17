import 'package:intl/intl.dart';

String formatNombre(int nombre) {
  final formatter = NumberFormat('#,###', 'fr_FR');
  return formatter.format(nombre).replaceAll(',', ' ');
}

String formatNombreStr(String nombreStr) {
  final nombre = int.tryParse(nombreStr) ?? 0;
  return formatNombre(nombre);
}

String enleverEspaces(String nombreAvecEspaces) {
  return nombreAvecEspaces.replaceAll(' ', '');
}

int enleverEspacesInt(String nombreAvecEspaces) {
  final sansEspaces = nombreAvecEspaces.replaceAll(' ', '');
  return int.parse(sansEspaces);
}
