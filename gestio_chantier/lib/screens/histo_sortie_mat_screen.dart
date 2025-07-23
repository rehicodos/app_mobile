import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/edit_sortie_mat_screen.dart';
import '../screens/add_sortie_mat_screen.dart';
import '../models/sortie_mat_model.dart';
import '../config/internet_verify.dart';
import '../models/projet_model.dart';
import '../config/conn_backend.dart';

class HistoSortieMatScreen extends StatefulWidget {
  final Projets projet;

  const HistoSortieMatScreen({super.key, required this.projet});

  @override
  State<HistoSortieMatScreen> createState() => _HistoSortieMatScreenState();
}

class _HistoSortieMatScreenState extends State<HistoSortieMatScreen> {
  List<SortieMatModel> sortieMat = [];
  bool _loading = true;

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
    _chargerHistoLivraisonMat();
  }

  Future<void> _chargerHistoLivraisonMat() async {
    final url = ConnBackend.withParams({
      "action": "list_histo_sortieMat",
      "idP": widget.projet.id.toString(),
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            // straitants = List<Map<String, dynamic>>.from(data);
            sortieMat = data.map((e) => SortieMatModel.fromJson(e)).toList();
            _loading = false;
          });
        } else {
          throw Exception("Format de données invalide");
        }
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      // print("Erreur : $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteRapport(int id) async {
    try {
      final reponse = await http
          .post(
            connUrl_,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "delete_sortieMat",
              'id': id.toString(),
            }),
          )
          .timeout(const Duration(seconds: 10)); // ⏱ Timeout;

      final reponseData = jsonDecode(reponse.body);

      if (reponseData['success'] == true) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Info'),
            content: Text(reponseData['message']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() {
          sortieMat.removeWhere((livraison) => livraison.id == id);
        });
      } else {
        _showDialogMessage(reponseData['message']);
      }
    } on TimeoutException {
      if (mounted) {
        Navigator.pop(context);
        _showDialogMessage("La connexion a expiré. Réessayez.");
      }
    } on SocketException {
      if (mounted) {
        Navigator.pop(context);
        _showDialogMessage("Pas de connexion Internet.");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showDialogMessage("Une erreur est survenue !, $e");
      }
    }
  }

  void _showDialogMessage(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        // title: Text(success ? "Succès" : "Erreur"),
        title: Text("Attention ..."),
        content: Text(msg, style: TextStyle(fontSize: 16, color: Colors.red)),
        // backgroundColor: success ? Colors.green[100] : Colors.red[100],
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _navigateToNewLivraisonMat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewSortieMat(projet: widget.projet),
      ),
    );

    if (result == true) {
      _chargerHistoLivraisonMat(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToEditLivraisonMat(r) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditSortieMat(sortieMat: r)),
    );

    if (result == true) {
      _chargerHistoLivraisonMat(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionOverlayWatcher(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Histo sortie mat."),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add_circle_rounded),
              onPressed: () {
                _navigateToNewLivraisonMat();
              },
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : sortieMat.isEmpty
            ? const Center(
                child: Text("Aucune sortie Mat. trouvée pour ce projet."),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: sortieMat.length,
                  itemBuilder: (_, i) {
                    final r = sortieMat[i];
                    return Column(
                      children: [
                        Container(
                          // width: double.infinity,
                          width: MediaQuery.of(context).size.width * 1,
                          padding: const EdgeInsets.only(top: 10),
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Text(
                            "Sortie Mat. du ${r.date_}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              // color: Color(0xFF0D47A1),
                            ),
                          ),
                        ),

                        Container(
                          // width: double.infinity,
                          width: MediaQuery.of(context).size.width * 1,
                          padding: const EdgeInsets.all(10),
                          // color: Colors.grey[200],
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    // bottom: BorderSide(
                                    color: Colors.black,
                                    width: 0.8,

                                    // ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      // height: 35,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.34,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            // height: 10,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                // bottom: BorderSide(
                                                //   color: Colors.black,
                                                //   width: 0.8,
                                                // ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Désignation", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      // height: 35,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.20,
                                      // padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            // height: 10,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                // bottom: BorderSide(
                                                //   color: Colors.black,
                                                //   width: 0.8,
                                                // ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Quantité", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      // height: 35,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.39,
                                      // padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            // height: 10,
                                            alignment: Alignment.center,
                                            // decoration: BoxDecoration(
                                            //   border: Border(
                                            //     // bottom: BorderSide(
                                            //     //   color: Colors.black,
                                            //     //   width: 0.8,
                                            //     // ),
                                            //     right: BorderSide(
                                            //       color: Colors.black,
                                            //       width: 0.8,
                                            //     ),
                                            //   ),
                                            // ),
                                            child: Text(
                                              "Destination", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black,
                                      width: 0.8,
                                    ),
                                    left: BorderSide(
                                      color: Colors.black,
                                      width: 0.8,
                                    ),
                                    right: BorderSide(
                                      color: Colors.black,
                                      width: 0.8,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      // height: 35,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.34,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            // width: MediaQuery.of(context).size.width * 1,
                                            padding: const EdgeInsets.all(2),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              r.design, // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Color(0xFF0D47A1),
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      // height: 35,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.20,
                                      // padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            // width: MediaQuery.of(context).size.width * 1,
                                            padding: const EdgeInsets.all(2),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              r.qte, // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Color(0xFF0D47A1),
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      // height: 35,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.39,
                                      // padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            // width: MediaQuery.of(context).size.width * 1,
                                            padding: const EdgeInsets.all(2),
                                            alignment: Alignment.center,
                                            // decoration: BoxDecoration(
                                            //   border: Border(
                                            //     right: BorderSide(
                                            //       color: Colors.black,
                                            //       width: 0.8,
                                            //     ),
                                            //   ),
                                            // ),
                                            child: Text(
                                              r.lieu, // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Color(0xFF0D47A1),
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,

                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _navigateToEditLivraisonMat(r);
                                    },
                                    icon: const Icon(
                                      Icons.edit_square,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      "Modifier",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF0D47A1),
                                      foregroundColor: Colors.white,

                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ), // Réduction du padding
                                      minimumSize: Size(
                                        0,
                                        0,
                                      ), // Permet une taille très petite
                                      tapTargetSize: MaterialTapTargetSize
                                          .shrinkWrap, // Réduction de la zone tactile
                                      // visualDensity: VisualDensity
                                      //     .compact, // Rend le bouton plus compact
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _deleteRapport(r.id);
                                    },
                                    icon: const Icon(
                                      Icons.delete_forever_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      "Supprimer",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      foregroundColor: Colors.white,

                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ), // Réduction du padding
                                      minimumSize: Size(
                                        0,
                                        0,
                                      ), // Permet une taille très petite
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
