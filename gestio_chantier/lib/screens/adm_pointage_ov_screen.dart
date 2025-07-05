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

class PageOuvrierPointageAdm extends StatefulWidget {
  final Quinzaine q;
  const PageOuvrierPointageAdm({super.key, required this.q});

  @override
  State<PageOuvrierPointageAdm> createState() => _PageOuvrierPointageStateAdm();
}

class _PageOuvrierPointageStateAdm extends State<PageOuvrierPointageAdm> {
  List<Worker> _workers = [];
  bool _isLoading = true;
  int _ttalOvProjet = 0;
  final DateTime _date = DateTime.now();
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({
      "action": "list_ovPointage",
      "id": widget.q.id.toString(),
      "idp": widget.q.idProjet.toString(),
      "dateNow": DateFormat('dd-MM-yyyy').format(_date),
    });
    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      _workers = data.map((e) => Worker.fromJson(e)).toList();
      _ttalOvProjet = _workers.length;
      _isLoading = false;
    });
  }

  Future<void> _captureAndCompare(Worker w) async {
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
              "action": "pointage_worker",
              "id_worker": w.id.toString(),
              "getDiffDay": getDifference(widget.q.debut),
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (!mounted) return;
      if (response.statusCode == 200 && data['success'] == true) {
        _hasSaved = true;
        Navigator.pop(context); // Ferme le loader
        _showMessage("${w.name} pointé avec succès !", success: true);

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
      _showMessage("Erreur lors du traitement : $e");
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
            title: const Text("Pointage des ouvriers"),
            centerTitle: true,
            backgroundColor: Colors.blue[900],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            "Nombre d'ouvrier à pointer : $_ttalOvProjet",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(thickness: 2),
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
                                  w.function,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () => _captureAndCompare(w),
                                  icon: const Icon(Icons.fingerprint),
                                  label: const Text("Pointer"),
                                  style: ElevatedButton.styleFrom(
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
