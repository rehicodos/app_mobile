import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestio_chantier/screens/histo_paie_screen.dart';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
import '../config/separe_millier.dart';
import '../models/ov_quinzaine_model.dart';
import '../config/internet_verify.dart';
// import '../models/ouvrier_model.dart';
import '../models/quinzaine_model.dart';
import '../config/conn_backend.dart';

class PagePaiementOv extends StatefulWidget {
  final Quinzaine q;
  const PagePaiementOv({super.key, required this.q});

  @override
  State<PagePaiementOv> createState() => _PagePaiementOvStateAdm();
}

class _PagePaiementOvStateAdm extends State<PagePaiementOv> {
  List<WorkersQuinzaine> _workers = [];
  bool _isLoading = true;
  int _ttalOvProjet = 0;
  // final DateTime _date = DateTime.now();
  bool _hasSaved = false;
  String _montantPaie = '';

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({
      "action": "list_ovquinzainePaie",
      "id": widget.q.id.toString(),
    });

    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      // _workers = data.map((e) => WorkersQuinzaine.fromJson(e)).toList();
      _workers = data.map((e) => WorkersQuinzaine.fromJson(e)).toList();
      _ttalOvProjet = _workers.length;
      _isLoading = false;
    });

    // setState(() => _isLoading = true);
    // final url = ConnBackend.withParams({
    //   "action": "list_ovPointage",
    //   "id": widget.q.id.toString(),
    //   "idp": widget.q.idProjet.toString(),
    //   "dateNow": DateFormat('dd-MM-yyyy').format(_date),
    // });
    // final resp = await http.get(url);
    // final data = jsonDecode(resp.body) as List;
    // setState(() {
    //   _workers = data.map((e) => Worker.fromJson(e)).toList();
    //   _ttalOvProjet = _workers.length;
    //   _isLoading = false;
    // });
  }

  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _payerOv({
    required ttalPaie,
    required VoidCallback onConfirmed,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: ttalPaie,
    );
    final ctrl = controller;
    // bool verify = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Paie'),
        content: TextField(
          controller: ctrl,
          // obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
          ],
          decoration: const InputDecoration(
            labelText: 'Renseignez le montant à payer',
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
              if (ctrl.text == "") {
                // if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le champ ne doit pas etre vide !'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (ctrl.text == "0") {
                // if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le contenu du champ ne doit etre 0 !'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (ctrl.text != "") {
                if (int.parse(ctrl.text) <= int.parse(ttalPaie)) {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context, true);
                  _montantPaie = ctrl.text;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Le montant renseigner ne doit pas être supérieur au montant à payer !',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            // onPressed: () => Navigator.pop(context, ctrl.text == 'admin123'),
            child: const Text('Payer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirmed();
    }
  }

  Future<void> _logiqPaieOv(idov, montant) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final body = {
        "action": "paieEspecesOv",
        "idOv": idov,
        "idQ": widget.q.id.toString(),
        "montantPaie": montant,
      };

      final res = await http
          .post(
            ConnBackend.connUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);
      if (!mounted) return;
      // Navigator.pop(context); // Fermer le dialog
      // Navigator.pop(context, true);

      if (res.statusCode == 200 && data['success'] == true) {
        _hasSaved = true;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Paiement effectué !',
              // style: TextStyle(color: Colors.red),
            ),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _workers.removeWhere((worker) => worker.id == int.parse(idov));
          _ttalOvProjet = _workers.length;
          _montantPaie = '';
        });
      } else {
        // if (!mounted) return;
        Navigator.pop(context);
        _showMessage(data['message']);

        // showDialog(
        //   context: context,
        //   builder: (_) => AlertDialog(
        //     title: const Text("Erreur"),
        //     content: const Text(
        //       "Le paiement a échoué, réessayer encore !",
        //       style: TextStyle(color: Colors.red),
        //     ),
        //     actions: [
        //       TextButton(
        //         onPressed: () => Navigator.pop(context),
        //         child: const Text("OK"),
        //       ),
        //     ],
        //   ),
        // );
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
      _showMessage("Erreur lors du traitement ! $e");
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
            title: const Text("Paiement ouvriers"),
            centerTitle: true,
            // backgroundColor: Colors.blue[900],
            actions: [
              IconButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoPagePaiementOv(q: widget.q),
                    ),
                  );
                },
                icon: const Icon(Icons.playlist_add_check_circle_sharp),
              ),
            ],
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
                          // const SizedBox(height: 4),
                          Text(
                            "Nombre d'ouvrier à payer : $_ttalOvProjet",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              // color: Color(0xFF0D47A1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // const Divider(thickness: 2),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _workers.length,
                        itemBuilder: (_, i) {
                          final w = _workers[i];
                          return Container(
                            width: MediaQuery.of(context).size.width * 1,
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            margin: EdgeInsets.only(bottom: 7),
                            decoration: BoxDecoration(
                              // border: Border(
                              //   bottom: BorderSide(
                              //     color: Colors.black,
                              //     width: 0.3,
                              //   ),
                              // ),
                              // color: Colors.blue,
                              color: Colors.white60,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 55,
                                      height: 55,
                                      margin: EdgeInsets.only(right: 6),

                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ), // optionnel
                                        child: Image.memory(
                                          w.photo,
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          w.nom,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        Text(
                                          "Tel: ${w.tel}\nMontant à payer: ${formatNombreStr(w.reste)} f\nPaiement mobile: ${w.mobileMoney}",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                Container(
                                  padding: EdgeInsets.all(0),
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,

                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _payerOv(
                                            ttalPaie: w.reste,
                                            onConfirmed: () {
                                              _logiqPaieOv(
                                                w.id.toString(),
                                                _montantPaie,
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.co_present),
                                        label: const Text(
                                          "Espèces",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF0D47A1),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          minimumSize: const Size(40, 20),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.send_to_mobile_outlined,
                                        ),
                                        label: const Text(
                                          "Mobile",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF0D47A1),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 11,
                                            vertical: 5,
                                          ),
                                          minimumSize: const Size(40, 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Divider(thickness: 1),
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
