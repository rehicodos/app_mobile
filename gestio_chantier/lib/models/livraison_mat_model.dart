// import 'dart:convert';
// import 'dart:typed_data';
// import '../config/separe_millier.dart';

class LivraisonMatModel {
  final int id;
  final String idProjet,
      design,
      unite,
      qte,
      nberBl,
      qualites,
      retourMat,
      qteRetourMat,
      date_;

  LivraisonMatModel({
    required this.id,
    required this.idProjet,
    required this.design,
    required this.unite,
    required this.qte,
    required this.nberBl,
    required this.qualites,
    required this.retourMat,
    required this.qteRetourMat,
    required this.date_,
  });

  factory LivraisonMatModel.fromJson(Map<String, dynamic> e) =>
      LivraisonMatModel(
        // id: e['id'],
        id: int.parse(e['id'].toString()),
        idProjet: e['id_projet'],
        design: e['design'],
        unite: e['unite'],
        qte: e['qte'],
        nberBl: e['nber_bl'],
        qualites: e['qualites'],
        retourMat: e['retour_mat'],
        qteRetourMat: e['qte_retour_mat'],
        date_: e['date_'],
      );
}
