// import 'dart:convert';
// import 'dart:typed_data';

import '../config/separe_millier.dart';

class Projets {
  final int id;
  final String nom, bdgmo, client, ttal, statut, depense, reste;

  Projets({
    required this.id,
    required this.nom,
    required this.bdgmo,
    required this.client,
    required this.ttal,
    required this.statut,
    required this.depense,
    required this.reste,
  });

  factory Projets.fromJson(Map<String, dynamic> e) => Projets(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    nom: e['nom_projet'],
    bdgmo: e['bdg_mo'],
    client: e['client'],
    ttal: e['ttal'],
    statut: e['statut'],
    depense: formatNombreStr(e['montantq']),
    reste: formatNombreStr(
      ((int.parse(e['bdg_mo'].toString())) -
              (int.parse(e['montantq'].toString())))
          .toString(),
    ),
  );
}
