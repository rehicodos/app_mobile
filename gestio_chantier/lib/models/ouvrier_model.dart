import 'dart:convert';
import 'dart:typed_data';

class Worker {
  final int id;
  final String name, function, phone, price, date;
  final Uint8List photo;

  Worker({
    required this.id,
    required this.name,
    required this.function,
    required this.phone,
    required this.price,
    required this.date,
    required this.photo,
  });

  factory Worker.fromJson(Map<String, dynamic> e) => Worker(
    // id: e['id'],
    id: int.parse(e['id'].toString()),
    name: e['nom'],
    function: e['fonction'],
    phone: e['tel'],
    price: e['prix_jr'],
    date: e['date_add'],
    photo: base64Decode(e['photo_base64']),
  );
}
