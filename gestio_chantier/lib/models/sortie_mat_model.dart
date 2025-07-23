// import 'dart:convert';
// import 'dart:typed_data';
// import '../config/separe_millier.dart';

class SortieMatModel {
  final int id;
  final String idProjet, design, qte, lieu, date_;

  SortieMatModel({
    required this.id,
    required this.idProjet,
    required this.design,
    required this.qte,
    required this.lieu,
    required this.date_,
  });

  factory SortieMatModel.fromJson(Map<String, dynamic> e) => SortieMatModel(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    idProjet: e['id_projet'],
    design: e['design'],
    qte: e['qte'],
    lieu: e['lieu'],
    date_: e['date_'],
  );
}
