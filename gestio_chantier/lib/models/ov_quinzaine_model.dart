import 'dart:convert';
import 'dart:typed_data';

import '../config/separe_millier.dart';

class WorkersQuinzaine {
  final int id;
  final String idProjet,
      idQuinzaine,
      nom,
      fonction,
      prixJr,
      tel,
      dateAdd,
      mobileMoney,
      ttalJr,
      jrPointage,
      paiement,
      // solder,
      reste,
      statut,
      gainQuinzaine;
  final Uint8List photo;

  WorkersQuinzaine({
    required this.id,
    required this.idProjet,
    required this.idQuinzaine,
    required this.nom,
    required this.fonction,
    required this.prixJr,
    required this.tel,
    required this.dateAdd,
    required this.photo,
    required this.mobileMoney,
    required this.ttalJr,
    required this.jrPointage,
    required this.paiement,
    // required this.solder,
    required this.reste,
    required this.statut,
    required this.gainQuinzaine,
  });

  factory WorkersQuinzaine.fromJson(Map<String, dynamic> e) => WorkersQuinzaine(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    idProjet: e['id_projet'],
    idQuinzaine: e['id_quinzaine'],
    nom: e['nom'],
    fonction: e['fonction'],
    prixJr: e['prix_jr'],
    tel: e['tel'],
    dateAdd: e['date_add'],
    photo: base64Decode(e['photo_base64']),
    mobileMoney: e['mobile_money'],
    ttalJr: e['ttal_jr'],
    jrPointage: e['jr_pointage'],
    paiement: formatNombreStr(e['paiement']),
    statut: e['statut'],

    gainQuinzaine: formatNombreStr(
      ((int.tryParse(e['ttal_jr'].toString()) ?? 0) *
              (int.tryParse(enleverEspaces(e['prix_jr'].toString())) ?? 0))
          .toString(),
    ),
    reste:
        (((int.tryParse(e['ttal_jr'].toString()) ?? 0) *
                    (int.tryParse(enleverEspaces(e['prix_jr'].toString())) ??
                        0)) -
                (int.tryParse(enleverEspaces(e['paiement'].toString())) ?? 0))
            .toString(),
  );
}
