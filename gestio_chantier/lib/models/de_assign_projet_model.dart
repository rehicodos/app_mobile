// import 'dart:convert';
// import 'dart:typed_data';
// import '../config/separe_millier.dart';

class DeAssignProjetModel {
  final int id;
  final String idp, idchef, projet;

  DeAssignProjetModel({
    required this.id,
    required this.idp,
    required this.idchef,
    required this.projet,
  });

  factory DeAssignProjetModel.fromJson(Map<String, dynamic> e) =>
      DeAssignProjetModel(
        // id: e['id'],
        id: int.parse(e['id'].toString()),
        idp: e['id_projet'],
        idchef: e['id_chef_ch'],
        projet: e['projet'],
      );
}
