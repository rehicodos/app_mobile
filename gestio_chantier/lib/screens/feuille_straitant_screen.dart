import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:io';
import 'package:gestio_chantier/screens/edit_straitant_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/straitant_model.dart';
import '../screens/new_straitant_screen.dart';
import '../models/projet_model.dart';
import '../config/conn_backend.dart';
import '../config/separe_millier.dart';

class FeuilleSousTraitant extends StatefulWidget {
  final Projets projet;
  final String typeOffre;

  const FeuilleSousTraitant({
    super.key,
    required this.projet,
    required this.typeOffre,
  });

  @override
  State<FeuilleSousTraitant> createState() => _FeuilleSousTraitantState();
}

class _FeuilleSousTraitantState extends State<FeuilleSousTraitant> {
  List<Straitant> straitants = [];
  bool _loading = true;
  bool colonnesReduites = false;

  String txtShow = '';
  String _typeOffre = '';
  String _ttle = '';

  Uri connUrl_ = ConnBackend.connUrl;

  // List<String> colonnesComplet = [];
  // List<String> clesComplet = [];
  // List<String> colonnesAffichees = [];
  // List<String> clesAffichees = [];

  // Construit les colonnes
  List<String> colonnes = [
    'Designation',
    'Ouvrier',
    'Tel ouvrier',
    'Offre validée',
    'Versement effectué',
    'Reste à solder',
    'Montant demandé',
    'Date offre validée',
  ];

  List<String> cles = [
    'offre',
    'ouvrier',
    'tel',
    'prixOffre',
    'versement',
    'reste',
    'avances',
    'date_',
  ];

  @override
  void initState() {
    super.initState();
    _chargerSTraitant();
  }

  void recupTypeOffre() {
    if (widget.typeOffre == 'straitant') {
      setState(() {
        _typeOffre = 'Point sous-traitants';
        _ttle = 'Sous-traitant';
      });
    } else {
      setState(() {
        _typeOffre = 'Point prestataire';
        _ttle = 'Prestation';
      });
    }
  }

  // void _toggleColonnes() {
  //   setState(() {
  //     colonnesReduites = !colonnesReduites;

  //     if (colonnesReduites) {
  //       colonnesAffichees = [
  //         ...colonnesComplet.take(3),
  //         ...colonnesComplet.skip(colonnesComplet.length - 2),
  //       ];

  //       clesAffichees = [
  //         ...clesComplet.take(3),
  //         ...clesComplet.skip(clesComplet.length - 2),
  //       ];
  //     } else {
  //       colonnesAffichees = List.from(colonnesComplet);
  //       clesAffichees = List.from(clesComplet);
  //     }
  //   });
  // }

  Future<void> _chargerSTraitant() async {
    recupTypeOffre();
    final url = ConnBackend.withParams({
      "action": "list_straitantProjet",
      "idP": widget.projet.id.toString(),
      "typeOffre": widget.typeOffre.toString(),
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            // straitants = List<Map<String, dynamic>>.from(data);
            straitants = data.map((e) => Straitant.fromJson(e)).toList();
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

  void showtexte(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Contenu complet"),
        content: SingleChildScrollView(
          child: Text(msg, style: const TextStyle(fontSize: 13)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              txtShow = '';
            },
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  void _optionAction(c, id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        alignment:
            Alignment.center, // Centrage du dialog lui-même (Flutter 3.7+)
        title: const Center(
          child: Text("Option action", textAlign: TextAlign.center),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                showtexte(txtShow);
              },
              icon: const Icon(Icons.remove_red_eye),
              label: const Text("Afficher le texte"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // _navigateToAddOvQuinzaineListProjet();
              },
              icon: const Icon(Icons.monetization_on),
              label: const Text("Versement"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToEditeOffre(c);
              },
              icon: const Icon(Icons.edit_square),
              label: const Text("Modifier"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // _navigateToAddOvQuinzaineListProjet();
                _deleteContrat(id);
              },
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text("Supprimer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNewOffre() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NewStraitant(projet: widget.projet, typeOffre: widget.typeOffre),
      ),
    );

    if (result == true) {
      _chargerSTraitant(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToEditeOffre(c) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditStraitant(contrat: c)),
    );

    if (result == true) {
      _chargerSTraitant(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  Future<void> _deleteContrat(int id) async {
    try {
      final reponse = await http
          .post(
            connUrl_,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "delete_straitant",
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
          straitants.removeWhere((ouvr) => ouvr.id == id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_ttle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_rounded),
            onPressed: () => _navigateToNewOffre(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  // width: double.infinity,
                  width: MediaQuery.of(context).size.width * 1,
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: Text(
                    _typeOffre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      // color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: SizedBox(
                    // width: 950,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          DataTable(
                            border: TableBorder.all(color: Colors.black),
                            columnSpacing: 3,
                            headingRowColor: WidgetStateProperty.all(
                              Colors.blue[50],
                            ),
                            dataRowColor: WidgetStateColor.resolveWith(
                              (states) => Colors.grey[50]!,
                            ),
                            columns: colonnes.map((col) {
                              return DataColumn(
                                label: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    col,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            rows: [
                              ...straitants.map((Straitant row) {
                                return DataRow(
                                  cells: cles.map((cle) {
                                    int index = cles.indexOf(cle);
                                    String valeur = '';

                                    switch (cle) {
                                      case 'offre':
                                        valeur = row.offre;
                                        break;
                                      case 'ouvrier':
                                        valeur = row.ouvrier;
                                        break;
                                      case 'fonction':
                                        valeur = row.fonction;
                                        break;
                                      case 'tel':
                                        valeur = row.tel;
                                        break;
                                      case 'prixOffre':
                                        valeur = formatNombreStr(
                                          row.prixOffre.toString(),
                                        );
                                        break;
                                      case 'versement':
                                        valeur = formatNombreStr(
                                          row.versement.toString(),
                                        );
                                        break;
                                      case 'reste':
                                        valeur = formatNombreStr(
                                          row.reste.toString(),
                                        );
                                        break;
                                      case 'avances':
                                        valeur = formatNombreStr(
                                          row.avances.toString(),
                                        );
                                        break;
                                      case 'date_':
                                        valeur = row.date_;
                                        break;
                                    }

                                    if (index == 0 && cle == 'offre') {
                                      return DataCell(
                                        Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 170,
                                            ),
                                            child: GestureDetector(
                                              // onDoubleTap: () {
                                              onTap: () {
                                                txtShow = valeur;
                                                _optionAction(row, row.id);
                                              },
                                              child: Text(
                                                valeur,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      if (cle == 'ouvrier') {
                                        String fonction = row.fonction;

                                        return DataCell(
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                                minHeight:
                                                    40, // garantit que la hauteur minimum est suffisante
                                              ),
                                              child: Center(
                                                child: fonction != ''
                                                    ? Text(
                                                        "$valeur\n($fonction)",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .visible,
                                                        textAlign: TextAlign
                                                            .center, // ← Important aussi
                                                      )
                                                    : Text(
                                                        valeur,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .visible,
                                                        textAlign: TextAlign
                                                            .center, // ← Important aussi
                                                      ),
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        // valeur = formatNombreStr(
                                        //   cle.toString(),
                                        // );
                                        return DataCell(
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                                minHeight:
                                                    40, // garantit que la hauteur minimum est suffisante
                                              ),
                                              child: Center(
                                                child: Text(
                                                  valeur,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  textAlign: TextAlign
                                                      .center, // ← Important aussi
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }).toList(),
                                );
                              }),

                              // ✅ Ligne Grand Totaux
                              // DataRow(
                              //   color: WidgetStateProperty.all(
                              //     Colors.grey[300],
                              //   ),
                              //   cells: cles.map((cle) {
                              //     if (cle == 'offre') {
                              //       return const DataCell(
                              //         Padding(
                              //           padding: EdgeInsets.all(5.0),
                              //           child: Text(
                              //             'Grand Totaux',
                              //             style: TextStyle(
                              //               fontWeight: FontWeight.bold,
                              //               fontSize: 12,
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     } else if (cle == 'prixOffre') {
                              //       final totalPaiement = straitants.fold<int>(
                              //         0,
                              //         (sum, row) {
                              //           final int prix =
                              //               int.tryParse(
                              //                 row['prixOffre'].toString(),
                              //               ) ??
                              //               0;
                              //           return sum + prix;
                              //         },
                              //       );
                              //       return DataCell(
                              //         Padding(
                              //           padding: const EdgeInsets.all(5.0),
                              //           child: Center(
                              //             child: Text(
                              //               formatNombreStr(
                              //                 totalPaiement.toString(),
                              //               ),
                              //               style: const TextStyle(
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     } else if (cle == 'versement') {
                              //       final totalPaiement = straitants.fold<int>(
                              //         0,
                              //         (sum, row) {
                              //           final int prix =
                              //               int.tryParse(
                              //                 row['versement'].toString(),
                              //               ) ??
                              //               0;
                              //           return sum + prix;
                              //         },
                              //       );
                              //       return DataCell(
                              //         Padding(
                              //           padding: const EdgeInsets.all(5.0),
                              //           child: Center(
                              //             child: Text(
                              //               formatNombreStr(
                              //                 totalPaiement.toString(),
                              //               ),
                              //               style: const TextStyle(
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     } else if (cle == 'reste') {
                              //       final totalPaiement = straitants.fold<int>(
                              //         0,
                              //         (sum, row) {
                              //           final int prix =
                              //               int.tryParse(
                              //                 row['reste'].toString(),
                              //               ) ??
                              //               0;
                              //           return sum + prix;
                              //         },
                              //       );
                              //       return DataCell(
                              //         Padding(
                              //           padding: const EdgeInsets.all(5.0),
                              //           child: Center(
                              //             child: Text(
                              //               formatNombreStr(
                              //                 totalPaiement.toString(),
                              //               ),
                              //               style: const TextStyle(
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     } else if (cle == 'avances') {
                              //       final totalPaiement = straitants.fold<int>(
                              //         0,
                              //         (sum, row) {
                              //           final int prix =
                              //               int.tryParse(
                              //                 row['avances'].toString(),
                              //               ) ??
                              //               0;
                              //           return sum + prix;
                              //         },
                              //       );
                              //       return DataCell(
                              //         Padding(
                              //           padding: const EdgeInsets.all(5.0),
                              //           child: Center(
                              //             child: Text(
                              //               formatNombreStr(
                              //                 totalPaiement.toString(),
                              //               ),
                              //               style: const TextStyle(
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     } else {
                              //       return const DataCell(Text(''));
                              //     }
                              //   }).toList(),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
