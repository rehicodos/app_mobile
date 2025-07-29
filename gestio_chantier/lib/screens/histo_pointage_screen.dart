import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config/internet_verify.dart';
import '../config/conn_backend.dart';
import '../models/quinzaine_model.dart';

class HistoPointageScreen extends StatefulWidget {
  final Quinzaine quinzaine;
  final List pwds;
  const HistoPointageScreen({
    super.key,
    required this.quinzaine,
    required this.pwds,
  });

  @override
  State<HistoPointageScreen> createState() => _HistoPointageScreenState();
}

class _HistoPointageScreenState extends State<HistoPointageScreen> {
  Map<String, List<Map<String, dynamic>>> _pointageParJour = {};
  bool _loading = true;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _loadHistorique() async {
    setState(() => _loading = true);

    final url = ConnBackend.withParams({
      "action": "histo_pointage_par_jour",
      "idQ": widget.quinzaine.id.toString(),
    });

    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is List) {
          // tout est ok
          // _showError("HTTP : ${response.body}");
          final data = jsonDecode(response.body) as List;

          Map<String, List<Map<String, dynamic>>> temp = {};
          for (var item in data) {
            // final jour = item['jour'];
            final dateJr = DateTime.parse(item['jour']);
            final jour = DateFormat('dd-MM-yyyy').format(dateJr);
            if (!temp.containsKey(jour)) {
              temp[jour] = [];
            }
            temp[jour]!.add(item);
          }

          setState(() {
            _pointageParJour = temp;
            _loading = false;
          });
        } else if (data is Map && data.containsKey('error')) {
          _showError("Erreur serveur : ${data['error']}");
        }
      } catch (e) {
        _showError("Erreur JSON : ${e.toString()}");

        // if (!mounted) return;
        // _showErrorDialog(context, msg: e.toString());
      }
    } else {
      _showError("Erreur HTTP : ${response.statusCode}");
    }
  }

  Future<void> _supprimerPointage(
    String idPointage,
    String idOuvrier,
    String dateJour,
    String ttalJr,
  ) async {
    try {
      final response = await http
          .post(
            ConnBackend.connUrl,
            body: jsonEncode({
              "action": "sup_pointageOv",
              "id": idPointage,
              "idov": idOuvrier,
              "getDiffDay": getDifference(widget.quinzaine.debut),
              "ttaljrs": ttalJr,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _hasSaved = true;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Suppression réussie"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          // _pointageParJour[dateJour]!.removeWhere((e) => e['id'] == idPointage);
          // // Si plus personne ce jour, on retire la date aussi
          // if (_pointageParJour[dateJour]!.isEmpty) {
          //   _pointageParJour.remove(dateJour);
          // }

          final liste = _pointageParJour[dateJour];
          if (liste != null) {
            liste.removeWhere((e) => e['id'].toString() == idPointage);
            if (liste.isEmpty) {
              _pointageParJour.remove(dateJour);
            }
          }
        });
      } else {
        _showError("Erreur suppression : ${response.body}");
      }
    } catch (e) {
      _showError("Erreur réseau : ${e.toString()}");
    }
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

  Future<void> _confirmAdmins({required VoidCallback onConfirmed}) async {
    final ctrl = TextEditingController();
    // bool verify = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mdp admins'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mot de passe admin ici ...',
          ),
        ),
        actions: [
          TextButton(
            // onPressed: () => Navigator.pop(context, false),
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text == widget.pwds[1] || ctrl.text == widget.pwds[2]
              // ctrl.text == widget.pwds[0]
              ) {
                Navigator.pop(context, true);
              } else if (ctrl.text == "") {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Le champ ne doit pas etre vide !',
                      // style: TextStyle(color: Colors.red),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Mot de passe incorrect',
                      // style: TextStyle(color: Colors.red),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            // onPressed: () => Navigator.pop(context, ctrl.text == 'admin123'),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirmed();
    }
  }

  bool controlAction() {
    final now = DateTime.now();
    final fin = DateFormat('dd-MM-yyyy').parse(widget.quinzaine.fin);

    if (now.isAfter(fin.add(const Duration(days: 1)))) {
      return true;
    } else {
      return false;
    }
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
            centerTitle: true,
            title: const Text("Historique pointage"),
            // actions: [
            //   IconButton(
            //     onPressed: () async {
            //       await generatePointagePdf(ouvriersParJour: _pointageParJour);
            //     },
            //     icon: const Icon(Icons.picture_as_pdf),
            //   ),
            // ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _pointageParJour.isEmpty
              ? const Center(
                  child: Text("Aucun pointage trouvé pour cette période."),
                )
              : ListView(
                  children: _pointageParJour.entries.map((entry) {
                    final date = entry.key;
                    final ouvriers = entry.value;
                    // final ouvriers = List<Map<String, dynamic>>.from(entry.value);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          // color: Colors.blue[100],
                          color: Colors.grey[200],
                          // width: double.infinity,
                          width: MediaQuery.of(context).size.width * 1,
                          // width: MediaQuery.of(context).size,
                          child: Text(
                            "📅   $date",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...ouvriers.map(
                          (o) => Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black, // couleur de la bordure
                                  width: 0.2, // épaisseur
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: MemoryImage(
                                  base64Decode(o['photo']),
                                ),
                              ),
                              title: Text(
                                o['name'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${o['function']}\nà ${o['heure']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),

                              trailing: IconButton(
                                onPressed: () {
                                  final idPointage = o['id'].toString();
                                  final idOuvrier = o['idov'].toString();
                                  final ttalJr = o['ttal_jr'].toString();

                                  if (controlAction()) {
                                    _showError(
                                      "Action impossible, la session est terminée !",
                                    );
                                  } else {
                                    _confirmAdmins(
                                      onConfirmed: () {
                                        _supprimerPointage(
                                          idPointage,
                                          idOuvrier,
                                          date,
                                          ttalJr,
                                        );
                                      },
                                    );
                                  }
                                },
                                icon: const Icon(Icons.delete_forever),
                                // label: const Text(
                                //   "Supprimer",
                                //   style: TextStyle(
                                //     fontSize: 11,
                                //     // fontStyle: FontStyle.italic,
                                //   ),
                                // ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                  // padding: const EdgeInsets.symmetric(
                                  //   horizontal: 15,
                                  //   vertical: 8,
                                  // ),
                                  // minimumSize: const Size(
                                  //   80,
                                  //   36,
                                  // ), // Largeur, Hauteur minimales
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const Divider(),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }
}
