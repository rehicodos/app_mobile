import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/internet_verify.dart';
import '../models/ouvrier_model.dart';
import '../models/quinzaine_model.dart';
import '../config/conn_backend.dart';

class PageAssocOvToQuinzListProjet extends StatefulWidget {
  final Quinzaine q;
  const PageAssocOvToQuinzListProjet({super.key, required this.q});

  @override
  State<PageAssocOvToQuinzListProjet> createState() =>
      _PageOuvriAssocOvToQuinzListProjet();
}

class _PageOuvriAssocOvToQuinzListProjet
    extends State<PageAssocOvToQuinzListProjet> {
  List<Worker> _workers = [];
  bool _isLoading = true;
  int _ttalOvProjet = 0;
  bool _hasSaved = false;
  final DateTime _date = DateTime.now();

  // String toutOv = "list_ovProjetNonAssoc";
  String toutOv = "list_ovProjetNonAssocLastQ";
  String txt = "Ouvriers session passée non associé";

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({
      "action": toutOv,
      "id": widget.q.idProjet.toString(),
      "idQ": widget.q.id.toString(),
    });
    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      _workers = data.map((e) => Worker.fromJson(e)).toList();
      _ttalOvProjet = _workers.length;
      _isLoading = false;
    });
  }

  Future<void> _btnAssocOv(Worker w) async {
    // Fermer le clavier si ouvert
    FocusScope.of(context).unfocus();

    // Affiche le loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http
          .post(
            ConnBackend.connUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "assocOvQuinzaine",
              "idProjet": widget.q.idProjet.toString(),
              "idQuinzaine": widget.q.id.toString(),
              "periode": widget.q.periode,
              "idov": w.id.toString(),
              "name": w.name,
              "function": w.function,
              "phone": w.phone,
              "price": w.price,
              "date": DateFormat('yyyy-MM-dd').format(_date),
              "mobileMoney": w.mobileMoney,
              "photo": base64Encode(w.photo),
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (!mounted) return;
      if (response.statusCode == 200 && data['success'] == true) {
        _hasSaved = true;
        Navigator.pop(context); // Ferme le loader
        _showMessage("${w.name} associe avec succès !", success: true);

        setState(() {
          _workers.removeWhere((worker) => worker.id == w.id);
          _ttalOvProjet = _workers.length;
        });
      } else {
        Navigator.pop(context); // Ferme le loader
        _showMessage(data['message']);
      }
    } on TimeoutException {
      if (mounted) {
        Navigator.pop(context);
        _showMessage("Le serveur ne répond pas. Réessaye encore.");
      }
    } on SocketException {
      if (mounted) {
        Navigator.pop(context);
        _showMessage(
          "Pas de connexion Internet ou votre connexion est instable.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Ferme le loader
      _showMessage("Erreur lors du traitement !");
    }
  }

  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  String getDifference(String targetDateStr) {
    try {
      final now = DateTime.now();
      final targetDate = DateFormat('dd-MM-yyyy').parse(targetDateStr);

      final diff = now.difference(targetDate).inDays;

      if (diff == 0) {
        return "${diff + 1}";
      } else if (diff > 0) {
        return "${diff + 1}";
      } else {
        return "Dans ${-diff} jour${diff < -1 ? 's' : ''}";
      }
    } catch (e) {
      return "Date invalide";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _hasSaved);
        }
      },
      child: ConnectionOverlayWatcher(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Associer ouvriers"),
            actions: [
              IconButton(
                onPressed: () {
                  // await generatePointagePdf(ouvriersParJour: _pointageParJour);
                  setState(() {
                    toutOv = "list_ovProjetNonAssoc";
                    txt = "Tous les ouvriers non associé du projet";
                    _loadWorkers();
                  });
                },
                icon: const Icon(Icons.groups_2_rounded),
              ),
            ],
            centerTitle: true,
            backgroundColor: Colors.blue[900],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 0.5),
                        ),
                        color: Colors.grey[200],
                      ),
                      child: Text(
                        "$txt: $_ttalOvProjet",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // const Divider(thickness: 2),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _workers.length,
                        itemBuilder: (_, i) {
                          final w = _workers[i];
                          return Column(
                            children: [
                              ListTile(
                                leading: ClipOval(
                                  child: Image.memory(
                                    w.photo,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  w.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${w.function}\n${w.phone}\nPrix jr_lier: ${w.price}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () => _btnAssocOv(w),
                                  icon: const Icon(Icons.add),
                                  label: const Text("Associer"),
                                  style: ElevatedButton.styleFrom(
                                    // backgroundColor: Colors.green[700],
                                    backgroundColor: Color(0xFF0D47A1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 8,
                                    ),
                                    minimumSize: const Size(80, 36),
                                  ),
                                ),
                              ),
                              const Divider(thickness: 1),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
