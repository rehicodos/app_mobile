import 'dart:convert';
import 'dart:typed_data';
// import '../config/separe_millier.dart';

class WorkerPaie {
  final int id;
  final String montant, dateHeure, fonction, nomOv;
  final Uint8List photo;

  WorkerPaie({
    required this.id,
    required this.montant,
    required this.dateHeure,
    required this.fonction,
    required this.nomOv,
    required this.photo,
  });

  factory WorkerPaie.fromJson(Map<String, dynamic> e) => WorkerPaie(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    montant: e['montant'],
    dateHeure: e['date_heure'],
    fonction: e['fonction'],
    nomOv: e['nomOv'],
    photo: base64Decode(e['photo']),
  );
}
