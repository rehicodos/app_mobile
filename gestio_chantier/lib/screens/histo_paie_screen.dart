import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/paie_ov_model.dart';
import '../config/separe_millier.dart';
import '../config/internet_verify.dart';
import '../models/quinzaine_model.dart';
import '../config/conn_backend.dart';

class HistoPagePaiementOv extends StatefulWidget {
  final Quinzaine q;
  const HistoPagePaiementOv({super.key, required this.q});

  @override
  State<HistoPagePaiementOv> createState() => _HistoPagePaiementOvStateAdm();
}

class _HistoPagePaiementOvStateAdm extends State<HistoPagePaiementOv> {
  List<WorkerPaie> _workers = [];
  bool _isLoading = true;
  int _ttalOvProjet = 0;
  final bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({
      "action": "histo_paieOv",
      "idQ": widget.q.id.toString(),
    });

    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      // _workers = data.map((e) => WorkersQuinzaine.fromJson(e)).toList();
      _workers = data.map((e) => WorkerPaie.fromJson(e)).toList();
      _ttalOvProjet = _workers.length;
      _isLoading = false;
    });
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
            title: const Text(" Historique paie ouvriers"),
            centerTitle: true,
            // backgroundColor: Colors.blue[900],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _workers.isEmpty
              ? const Center(
                  child: Text("Aucun paiement trouvé pour cette période."),
                )
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
                            "Nombre de paiement éffectué : $_ttalOvProjet",
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
                            // width: MediaQuery.of(context).size.width * 0.89,
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            margin: EdgeInsets.only(bottom: 4),
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
                                          w.nomOv,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        Text(
                                          "Fonction: ${w.fonction}\nMontant payé: ${formatNombreStr(w.montant)} f\nDate paie: ${w.dateHeure}",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
