import 'dart:convert';
import 'dart:typed_data';
import '../config/separe_millier.dart';

class Worker {
  final int id;
  final String idProjet, name, function, phone, price, date, mobileMoney;
  final Uint8List photo;

  Worker({
    required this.id,
    required this.idProjet,
    required this.name,
    required this.function,
    required this.phone,
    required this.price,
    required this.date,
    required this.photo,
    required this.mobileMoney,
  });

  factory Worker.fromJson(Map<String, dynamic> e) => Worker(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    idProjet: e['id_projet'],
    name: e['nom'],
    function: e['fonction'],
    phone: e['tel'],
    price: formatNombreStr(e['prix_jr']),
    date: e['date_add'],
    photo: base64Decode(e['photo_base64']),
    mobileMoney: e['mobile_money'],
  );
}
