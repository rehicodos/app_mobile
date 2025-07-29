import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'add_livraison_mat_screen.dart';
import '../screens/edit_livraison_mat_screen.dart';
import '../models/livraison_mat_model.dart';
import '../config/internet_verify.dart';
import '../models/projet_model.dart';
import '../config/conn_backend.dart';

class HistoLivraisonMatScreen extends StatefulWidget {
  final Projets projet;
  final List pwd;
  final String typeUser;
  final String pwdUser;

  const HistoLivraisonMatScreen({
    super.key,
    required this.projet,
    required this.pwd,
    required this.typeUser,
    required this.pwdUser,
  });

  @override
  State<HistoLivraisonMatScreen> createState() =>
      _HistoLivraisonMatScreenState();
}

class _HistoLivraisonMatScreenState extends State<HistoLivraisonMatScreen> {
  List<LivraisonMatModel> livraisonMat = [];
  bool _loading = true;
  late List pwd_;

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
    pwd_ = widget.pwd;
    _chargerHistoLivraisonMat();
  }

  Future<void> _chargerHistoLivraisonMat() async {
    final url = ConnBackend.withParams({
      "action": "list_histo_livraisonMat",
      "idP": widget.projet.id.toString(),
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            // straitants = List<Map<String, dynamic>>.from(data);
            livraisonMat = data
                .map((e) => LivraisonMatModel.fromJson(e))
                .toList();
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
              "action": "delete_livraisonMat",
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
          livraisonMat.removeWhere((livraison) => livraison.id == id);
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

  // void _showMessage(String msg, {bool success = false}) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(msg),
  //       backgroundColor: success ? Colors.green : Colors.red,
  //     ),
  //   );
  // }

  void _navigateToNewLivraisonMat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewLivraisonMat(projet: widget.projet),
      ),
    );

    if (result == true) {
      _chargerHistoLivraisonMat(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToEditLivraisonMat(r) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditLivraisonMat(livraison: r)),
    );

    if (result == true) {
      _chargerHistoLivraisonMat(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  Future<void> _confirmSpAdmin({required VoidCallback onConfirmed}) async {
    final ctrl = TextEditingController();
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text == pwd_[1] || ctrl.text == pwd_[2]) {
                Navigator.pop(context, true);
              } else if (ctrl.text == "") {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le champ ne doit pas etre vide !'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mot de passe incorrect'),
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

  Future<void> _confirmAdmins({required VoidCallback onConfirmed}) async {
    final ctrl = TextEditingController();
    // bool verify = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Saisi Mdp'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe ici ...'),
        ),
        actions: [
          TextButton(
            // onPressed: () => Navigator.pop(context, false),
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text == "") {
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
              } else if (widget.typeUser == 'bureau') {
                if (ctrl.text == pwd_[1] || ctrl.text == pwd_[2]) {
                  Navigator.pop(context, true);
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
              } else if (widget.typeUser == 'chantier') {
                if (ctrl.text == widget.pwdUser) {
                  Navigator.pop(context, true);
                } else if (widget.pwdUser == '') {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Une erreur inconnue est survenue !',
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
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionOverlayWatcher(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Histo livraison mat."),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add_circle_rounded),
              onPressed: () {
                if (widget.projet.statut == 'Terminé') {
                  // if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Impossible, le projet est terminé',
                        // style: TextStyle(color: Colors.red),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  _confirmAdmins(
                    onConfirmed: () => _navigateToNewLivraisonMat(),
                  );
                }
                // _navigateToNewLivraisonMat();
              },
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : livraisonMat.isEmpty
            ? const Center(
                child: Text("Aucune livraison trouvée pour ce projet."),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: livraisonMat.length,
                  itemBuilder: (_, i) {
                    final r = livraisonMat[i];
                    return Column(
                      children: [
                        Container(
                          // width: double.infinity,
                          width: MediaQuery.of(context).size.width * 1,
                          padding: const EdgeInsets.only(top: 10),
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Text(
                            "Livraison du ${r.date_}",
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
                                          0.20,
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
                                          0.10,
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
                                              "Unité", // le texte tapé par l'utilisateur
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
                                          0.12,
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
                                          0.13,
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
                                              "Nº BL", // le texte tapé par l'utilisateur
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
                                          0.10,
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
                                              "Qualité", // le texte tapé par l'utilisateur
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
                                          0.15,
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
                                              "Retour Mat", // le texte tapé par l'utilisateur
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
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.12,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,

                                            child: Text(
                                              "Qté retour", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              // softWrap: true,
                                              // overflow: TextOverflow.visible,
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
                                          0.20,
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
                                          0.10,
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
                                              r.unite, // le texte tapé par l'utilisateur
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
                                          0.12,
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
                                          0.13,
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
                                              r.nberBl, // le texte tapé par l'utilisateur
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
                                          0.10,
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
                                              r.qualites, // le texte tapé par l'utilisateur
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
                                          0.15,
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
                                              r.retourMat, // le texte tapé par l'utilisateur
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
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.12,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
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
                                              r.qteRetourMat, // le texte tapé par l'utilisateur
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
                                      if (widget.projet.statut == 'Terminé') {
                                        // if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Impossible, le projet est terminé',
                                              // style: TextStyle(color: Colors.red),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } else {
                                        _confirmAdmins(
                                          onConfirmed: () =>
                                              _navigateToEditLivraisonMat(r),
                                        );
                                      }
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
                                      _confirmSpAdmin(
                                        onConfirmed: () => _deleteRapport(r.id),
                                      );
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
