// import 'dart:convert';
// import 'dart:typed_data';

class Projets {
  final int id;
  final String nom, bdgmo, client, ttal, statut;

  Projets({
    required this.id,
    required this.nom,
    required this.bdgmo,
    required this.client,
    required this.ttal,
    required this.statut,
  });

  factory Projets.fromJson(Map<String, dynamic> e) => Projets(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    nom: e['nom_projet'],
    bdgmo: e['bdg_mo'],
    client: e['client'],
    ttal: e['ttal'],
    statut: e['statut'],
  );
}
