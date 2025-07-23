// import 'dart:convert';
// import 'dart:typed_data';
// import '../config/separe_millier.dart';

class ChefChantierModel {
  final int id;
  final String nom, tel, pwd;
  final List<String> chantier;

  ChefChantierModel({
    required this.id,
    required this.nom,
    required this.tel,
    required this.pwd,
    required this.chantier,
  });

  factory ChefChantierModel.fromJson(Map<String, dynamic> e) =>
      ChefChantierModel(
        // id: e['id'],
        id: int.parse(e['id'].toString()),
        nom: e['nom'],
        tel: e['tel'],
        pwd: e['pwd'],
        // chantier: e['chantier'],
        chantier: List<String>.from(e['projets']),
      );
}
