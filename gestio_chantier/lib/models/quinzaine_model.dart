// import 'dart:convert';
// import 'dart:typed_data';

import '../config/separe_millier.dart';

class Quinzaine {
  final int id, nber;
  final String idProjet, periode, debut, fin, dateCreate, ttal, qRun;

  Quinzaine({
    required this.id,
    required this.idProjet,
    required this.periode,
    required this.debut,
    required this.fin,
    required this.dateCreate,
    required this.ttal,
    required this.nber,
    required this.qRun,
  });

  factory Quinzaine.fromJson(Map<String, dynamic> e) => Quinzaine(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    idProjet: e['id_projet'],
    periode: e['periode'],
    debut: e['debut'],
    fin: e['fin'],
    dateCreate: e['date_create'],
    ttal: formatNombreStr(e['ttal']),
    nber: int.parse(e['nber'].toString()),
    qRun: e['qRun'],
  );
}
