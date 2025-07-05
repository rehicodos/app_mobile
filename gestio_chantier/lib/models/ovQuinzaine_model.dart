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
    required this.gainQuinzaine,
  });

  factory WorkersQuinzaine.fromJson(Map<String, dynamic> e) => WorkersQuinzaine(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    idProjet: e['id_projet'],
    idQuinzaine: e['id_quinzaine'],
    nom: e['nom'],
    fonction: e['fonction'],
    prixJr: formatNombreStr(e['prix_jr']),
    tel: e['tel'],
    dateAdd: e['date_add'],
    photo: base64Decode(e['photo_base64']),
    mobileMoney: e['mobile_money'],
    ttalJr: e['ttal_jr'],
    jrPointage: e['jr_pointage'],
    // gainQuinzaine: (int.parse(e['ttal_jr']) * int.parse(e['prix_jr'])).toString(),
    gainQuinzaine: formatNombreStr(
      ((int.tryParse(e['ttal_jr'].toString()) ?? 0) *
              (int.tryParse(e['prix_jr'].toString()) ?? 0))
          .toString(),
    ),
  );
}
