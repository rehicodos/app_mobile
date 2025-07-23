import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/edit_rapport_jr_screen.dart';
import '../screens/add_rapport_jr_screen.dart';
import '../config/internet_verify.dart';
import '../models/rapport_jr_model.dart';
import '../models/projet_model.dart';
import '../config/conn_backend.dart';

class HistoRapportJrScreen extends StatefulWidget {
  final Projets projet;

  const HistoRapportJrScreen({super.key, required this.projet});

  @override
  State<HistoRapportJrScreen> createState() => _HistoRapportJrScreenState();
}

class _HistoRapportJrScreenState extends State<HistoRapportJrScreen> {
  List<RapportJrModel> rapportJr = [];
  bool _loading = true;

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
    _chargerHistoRapportJr();
  }

  Future<void> _chargerHistoRapportJr() async {
    final url = ConnBackend.withParams({
      "action": "list_histo_rapportJr",
      "idP": widget.projet.id.toString(),
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            // straitants = List<Map<String, dynamic>>.from(data);
            rapportJr = data.map((e) => RapportJrModel.fromJson(e)).toList();
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
              "action": "delete_rapportJrlier",
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
          rapportJr.removeWhere((rapport) => rapport.id == id);
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

  void _navigateToNewRapportJr() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewRapport(projet: widget.projet),
      ),
    );

    if (result == true) {
      _chargerHistoRapportJr(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToEditRapportJr(r) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditRapport(rapport: r)),
    );

    if (result == true) {
      _chargerHistoRapportJr(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionOverlayWatcher(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Histo rapport jrlier"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add_circle_rounded),
              onPressed: () {
                _navigateToNewRapportJr();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => NewRapport(projet: widget.projet),
                //     // NewRapport(projet: widget.projet),
                //   ),
                // );
              },
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : rapportJr.isEmpty
            ? const Center(
                child: Text("Aucun rapport journalier trouvé pour ce projet."),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: rapportJr.length,
                  itemBuilder: (_, i) {
                    final r = rapportJr[i];
                    return Column(
                      children: [
                        Container(
                          // width: double.infinity,
                          width: MediaQuery.of(context).size.width * 1,
                          padding: const EdgeInsets.only(top: 10),
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Text(
                            "Rapport du ${r.date_}",
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
                              Text(
                                "Taches prévues",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Container(
                                // width: double.infinity,
                                width: MediaQuery.of(context).size.width * 1,
                                padding: const EdgeInsets.all(10),
                                // color: Colors.grey[200],
                                // alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    // bottom: BorderSide(
                                    color: Colors.black,
                                    width: 0.8,
                                    // ),
                                  ),
                                ),
                                child: Text(
                                  r.rapportJr, // le texte tapé par l'utilisateur
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF0D47A1),
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),

                              SizedBox(height: 5),
                              Text(
                                "Informations sur les activités quotidiennes",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
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
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.11,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Climat", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
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
                                              r.climat, // le texte tapé par l'utilisateur
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
                                          0.28,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Incident chantier", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              // softWrap: true,
                                              // overflow: TextOverflow.visible,
                                            ),
                                          ),
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
                                              r.incident, // le texte tapé par l'utilisateur
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
                                          0.28,
                                      padding: const EdgeInsets.all(2),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Visite personnalité", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              // softWrap: true,
                                              // overflow: TextOverflow.visible,
                                            ),
                                          ),
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
                                              r.visitePerso, // le texte tapé par l'utilisateur
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
                                          0.27,
                                      padding: const EdgeInsets.all(2),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Essaie et opération", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              // softWrap: true,
                                              // overflow: TextOverflow.visible,
                                            ),
                                          ),
                                          Container(
                                            // width: MediaQuery.of(context).size.width * 1,
                                            padding: const EdgeInsets.all(2),
                                            alignment: Alignment.center,

                                            child: Text(
                                              r.essaiOperation, // le texte tapé par l'utilisateur
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
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.39,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Remise de document/courrier", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
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
                                              r.docRecus, // le texte tapé par l'utilisateur
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
                                          0.28,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Reception d'ouvrage", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              // softWrap: true,
                                              // overflow: TextOverflow.visible,
                                            ),
                                          ),
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
                                              r.receptionOv, // le texte tapé par l'utilisateur
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
                                          0.27,
                                      padding: const EdgeInsets.all(2),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.8,
                                                ),
                                                // right: BorderSide(
                                                //   color: Colors.black,
                                                //   width: 0.8,
                                                // ),
                                              ),
                                            ),
                                            child: Text(
                                              "Info/Hse du chantier", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              // softWrap: true,
                                              // overflow: TextOverflow.visible,
                                            ),
                                          ),
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
                                              r.infoHse, // le texte tapé par l'utilisateur
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
                                          0.31,
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
                                              "Appros matériaux", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
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
                                          0.31,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
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
                                              "Personnel employés", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              // softWrap: true,
                                              // overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.31,
                                      padding: const EdgeInsets.all(2),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            // decoration: BoxDecoration(
                                            //   border: Border(
                                            //     bottom: BorderSide(
                                            //       color: Colors.black,
                                            //       width: 0.8,
                                            //     ),
                                            //     // right: BorderSide(
                                            //     //   color: Colors.black,
                                            //     //   width: 0.8,
                                            //     // ),
                                            //   ),
                                            // ),
                                            child: Text(
                                              "Matériaux utilisés", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
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
                                          0.31,
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
                                              r.approsMat, // le texte tapé par l'utilisateur
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
                                          0.31,
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
                                              r.persoEmployer, // le texte tapé par l'utilisateur
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
                                          0.31,
                                      padding: const EdgeInsets.all(2),
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
                                              r.matUse, // le texte tapé par l'utilisateur
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
                                          0.44,
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
                                              "Etape d'evolution des travaux", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
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
                                          0.49,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,

                                            child: Text(
                                              "Etape d'avancement des travaux en %", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
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
                                          0.44,
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
                                              r.travoEvolution, // le texte tapé par l'utilisateur
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
                                          0.49,
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
                                              r.travoPourcntage, // le texte tapé par l'utilisateur
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
                                          0.37,
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
                                              "Matériaux en stoks", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
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
                                          0.56,
                                      padding: const EdgeInsets.all(2),
                                      // color: Colors.grey[200],
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,

                                            child: Text(
                                              "Observation et recommendation fin journée", // le texte tapé par l'utilisateur
                                              style: TextStyle(
                                                fontSize: 9,
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
                                          0.37,
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
                                              r.matEnStocks, // le texte tapé par l'utilisateur
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
                                          0.49,
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
                                              r.observation, // le texte tapé par l'utilisateur
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
                                      _navigateToEditRapportJr(r);
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
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
