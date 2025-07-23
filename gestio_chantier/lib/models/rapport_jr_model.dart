// import 'dart:convert';
// import 'dart:typed_data';
// import '../config/separe_millier.dart';

class RapportJrModel {
  final int id;
  final String idProjet,
      rapportJr,
      incident,
      visitePerso,
      essaiOperation,
      docRecus,
      receptionOv,
      infoHse,
      approsMat,
      matUse,
      persoEmployer,
      travoPourcntage,
      date_,
      climat,
      matEnStocks,
      observation,
      travoEvolution;

  RapportJrModel({
    required this.id,
    required this.idProjet,
    required this.rapportJr,
    required this.incident,
    required this.visitePerso,
    required this.essaiOperation,
    required this.docRecus,
    required this.receptionOv,
    required this.infoHse,
    required this.approsMat,
    required this.matUse,
    required this.persoEmployer,
    required this.travoEvolution,
    required this.travoPourcntage,
    required this.date_,
    required this.climat,
    required this.matEnStocks,
    required this.observation,
  });

  factory RapportJrModel.fromJson(Map<String, dynamic> e) => RapportJrModel(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    idProjet: e['id_projet'],
    rapportJr: e['rapport_jr'],
    incident: e['incident'],
    visitePerso: e['visite_perso'],
    essaiOperation: e['essai_operation'],
    docRecus: e['doc_recus'],
    receptionOv: e['reception_ov'],
    infoHse: e['info_hse'],
    approsMat: e['appros_mat'],
    matUse: e['mat_use'],
    persoEmployer: e['perso_employer'],
    travoEvolution: e['travo_evolution'],
    travoPourcntage: e['travo_pourcntage'],
    date_: e['date_'],
    climat: e['climat'],
    matEnStocks: e['mat_en_stocks'],
    observation: e['observation_fin_jr'],
  );
}
