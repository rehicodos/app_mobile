import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:io';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/de_assign_projet_model.dart';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class SupAssignProjetToChefChScreen extends StatefulWidget {
  final int idChefCh;
  const SupAssignProjetToChefChScreen({super.key, required this.idChefCh});

  @override
  State<SupAssignProjetToChefChScreen> createState() =>
      _SupAssignProjetToChefChScreenState();
}

class _SupAssignProjetToChefChScreenState
    extends State<SupAssignProjetToChefChScreen> {
  List<DeAssignProjetModel> _projets = [];
  bool _loading = true;
  bool _hasSaved = false;

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
    _loadProjets();
  }

  Future<void> _loadProjets() async {
    setState(() => _loading = true);
    final url = ConnBackend.withParams({
      "action": "list_projetsAssignSup",
      "idp": widget.idChefCh.toString(),
    });
    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      _projets = data.map((e) => DeAssignProjetModel.fromJson(e)).toList();
      _loading = false;
    });
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

  Future<void> _assigner(int idp) async {
    try {
      final reponse = await http
          .post(
            connUrl_,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "assigner_projetSup",
              'id': idp.toString(),
            }),
          )
          .timeout(const Duration(seconds: 10)); // ⏱ Timeout;

      final reponseData = jsonDecode(reponse.body);

      if (reponseData['success'] == true) {
        _hasSaved = true;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reponseData['message']),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _projets.removeWhere((proj) => proj.id == idp);
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
            title: Text("Désassociation projet"),
            centerTitle: true,
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _projets.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun projet trouvé.",
                    style: TextStyle(fontSize: 17),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 10,
                        ),
                        // itemCount: _projets.length,
                        itemCount: _projets.length,
                        itemBuilder: (_, i) {
                          // final w = _projets[i];
                          final w = _projets[i];
                          String nom = w.projet;
                          return Container(
                            // height: 48,

                            // padding: EdgeInsets.only(left: 15),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 0.8,
                                ),
                              ),
                              color: Colors.white,
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 15, top: 6),
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
                                  // color: Colors.blue,
                                  child: Text(
                                    "$nom,",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      // letterSpacing: 1.2,
                                      // fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _assigner(w.id),
                                  label: Icon(
                                    Icons.delete_forever,
                                    size: 28,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          // ),
        ),
      ),
    );
  }
}
