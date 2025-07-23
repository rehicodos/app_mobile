// import 'dart:convert';
// import 'dart:typed_data';

import '../config/separe_millier.dart';

class Straitant {
  final int id;
  final String offre,
      ouvrier,
      fonction,
      tel,
      idProjet,
      prixOffre,
      versement,
      reste,
      avances,
      date_,
      delaiContrat,
      realisation,
      statut;

  Straitant({
    required this.id,
    required this.idProjet,
    required this.offre,
    required this.fonction,
    required this.tel,
    required this.ouvrier,
    required this.prixOffre,
    required this.versement,
    required this.reste,
    required this.avances,
    required this.date_,
    required this.delaiContrat,
    required this.realisation,
    required this.statut,
  });

  factory Straitant.fromJson(Map<String, dynamic> e) => Straitant(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    idProjet: e['id_projet'],
    offre: e['offre'],
    ouvrier: e['ouvrier'],
    fonction: e['fonction'],
    tel: e['tel_ov'],
    prixOffre: e['prix_offre'],
    versement: e['versement'],
    reste:
        ((int.tryParse(enleverEspaces(e['prix_offre'].toString())) ?? 0) -
                ((int.tryParse(e['versement'].toString()) ?? 0) +
                    (int.tryParse(enleverEspaces(e['avances'].toString())) ??
                        0)))
            .toString(),
    avances: e['avances'],
    date_: e['date_add'],
    delaiContrat: e['delai_contrat'],
    realisation: e['realisation'],
    statut: e['statut'],
  );
}
