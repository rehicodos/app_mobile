import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gestio_chantier/config/internet_verify.dart';
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
  bool _hasSaved = false;

  String txtShow = '';
  String _typeOffre = '';
  String _ttle = '';
  String _montantPaie = '';
  String _realiser = '';
  String _statut = 'non';

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
    'Délai contrat',
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
    'delaiContrat',
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

  void _optionAction(c, id, reste, realiser) {
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
                if (realiser == '100' || realiser == 100) {
                  Navigator.of(context).pop();
                  _showMessage("Contrat terminé, le pourcentage est à 100%");
                } else {
                  Navigator.of(context).pop();
                  _realisationContrat(
                    realiser: realiser,
                    onConfirmed: () {
                      _logiqRealisation(id, _realiser);
                    },
                  );
                }
                // Navigator.of(context).pop();
                // _navigateToAddOvQuinzaineListProjet();
              },
              icon: const Icon(Icons.read_more_outlined),
              label: const Text("Réalisation"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (reste == '0' || reste == 0) {
                  Navigator.of(context).pop();
                  _showMessage("Rien à solder, le contrat est soldé");
                } else {
                  Navigator.of(context).pop();
                  _versementContrat(
                    ttalPaie: reste,
                    onConfirmed: () {
                      _logiqVersement(id, _montantPaie);
                    },
                  );
                }
                // Navigator.of(context).pop();
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

  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _realisationContrat({
    required realiser,
    required VoidCallback onConfirmed,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: realiser,
    );
    final ctrl = controller;
    // bool verify = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        scrollable: true, // ✅ ajoute cette ligne
        title: const Text('Progression contrat'),
        content: TextField(
          controller: ctrl,
          // obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // ✅ que des chiffres
            LengthLimitingTextInputFormatter(3), // ✅ max 3 caractères
          ],
          onChanged: (value) {
            if (value.isEmpty) return;

            final intValue = int.tryParse(value);
            if (intValue == null || intValue > 100) {
              // Corrige ou vide la saisie
              ctrl.text = '100';
              ctrl.selection = TextSelection.fromPosition(
                TextPosition(offset: ctrl.text.length),
              );
            }
          },
          decoration: const InputDecoration(
            labelText: 'Renseignez la progression',
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
              } else if ((int.parse(ctrl.text)) == 0) {
                // if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le contenu du champ ne doit pas etre 0 !'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                FocusScope.of(context).unfocus();
                Navigator.pop(context, true);
                _realiser = ctrl.text;
              }
            },
            // onPressed: () => Navigator.pop(context, ctrl.text == 'admin123'),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirmed();
    }
  }

  Future<void> _logiqRealisation(int idC, realisation) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final body = {
        "action": "realisationContrat",
        "idC": idC.toString(),
        "realisation": realisation,
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
              'Action effectué !',
              // style: TextStyle(color: Colors.red),
            ),
            backgroundColor: Colors.green,
          ),
        );

        final index = straitants.indexWhere((straitant) => straitant.id == idC);
        if (index != -1) {
          final ancien = straitants[index];
          final modifie = Straitant(
            id: ancien.id,
            versement: straitants[index].versement,
            idProjet: straitants[index].idProjet,
            offre: straitants[index].offre,
            fonction: straitants[index].fonction,
            tel: straitants[index].tel,
            ouvrier: straitants[index].ouvrier,
            prixOffre: straitants[index].prixOffre,
            reste: straitants[index].reste,
            avances: straitants[index].avances,
            date_: straitants[index].date_,
            delaiContrat: straitants[index].delaiContrat,
            realisation: realisation,
            statut: straitants[index].statut, // la nouvelle valeur
            // ...copier les autres champs nécessaires
          );
          setState(() {
            straitants[index] = modifie;
            _realiser = '';
          });
        }
      } else {
        // if (!mounted) return;
        Navigator.pop(context);
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
      _showMessage("Erreur lors du traitement ! $e");
    }
  }

  Future<void> _versementContrat({
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
        scrollable: true, // ✅ ajoute cette ligne
        title: const Text('Versement'),
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
              } else if ((int.parse(ctrl.text)) == 0) {
                // if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le contenu du champ ne doit pas etre 0 !'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (ctrl.text != "") {
                if (int.parse(ctrl.text) <= int.parse(ttalPaie)) {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context, true);
                  _montantPaie = ctrl.text;

                  if (int.parse(ctrl.text) == int.parse(ttalPaie)) {
                    _statut = 'oui';
                  }
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

  Future<void> _logiqVersement(int idC, montant) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final body = {
        "action": "versementContrat",
        "idC": idC.toString(),
        "montantVerser": montant,
        "statut": _statut.toString(),
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
              'Versement effectué !',
              // style: TextStyle(color: Colors.red),
            ),
            backgroundColor: Colors.green,
          ),
        );

        final index = straitants.indexWhere((straitant) => straitant.id == idC);
        if (index != -1) {
          final ancien = straitants[index];
          final modifie = Straitant(
            id: ancien.id,
            versement:
                (int.parse(montant) + int.parse(straitants[index].versement))
                    .toString(),
            idProjet: straitants[index].idProjet,
            offre: straitants[index].offre,
            fonction: straitants[index].fonction,
            tel: straitants[index].tel,
            ouvrier: straitants[index].ouvrier,
            prixOffre: straitants[index].prixOffre,
            reste:
                (int.parse(straitants[index].prixOffre) -
                        (int.parse(montant) +
                            int.parse(straitants[index].avances) +
                            int.parse(straitants[index].versement)))
                    .toString(),
            avances: straitants[index].avances,
            date_: straitants[index].date_,
            delaiContrat: straitants[index].delaiContrat,
            realisation: straitants[index].realisation,
            statut: straitants[index].statut, // la nouvelle valeur
            // ...copier les autres champs nécessaires
          );
          setState(() {
            straitants[index] = modifie;
            _montantPaie = '';
          });
        }
      } else {
        // if (!mounted) return;
        Navigator.pop(context);
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

                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        //  padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
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
                                          case 'delaiContrat':
                                            valeur = row.delaiContrat;
                                            break;
                                        }

                                        if (index == 0 && cle == 'offre') {
                                          return DataCell(
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 5,
                                                left: 2,
                                                right: 2,
                                                bottom: 2,
                                              ),
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                      maxWidth: 170,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      valeur,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      "Réalisé à ${row.realisation}%",
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Color(
                                                          0xFF0D47A1,
                                                        ),
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        decoration:
                                                            TextDecoration.none,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              txtShow = valeur;
                                              _optionAction(
                                                row,
                                                row.id,
                                                row.reste,
                                                row.realisation,
                                              );
                                            },
                                          );
                                        } else {
                                          if (cle == 'ouvrier') {
                                            String fonction = row.fonction;

                                            return DataCell(
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  5.0,
                                                ),
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
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            textAlign: TextAlign
                                                                .center, // ← Important aussi
                                                          )
                                                        : Text(
                                                            valeur,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 11,
                                                                ),
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
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
                                                padding: const EdgeInsets.all(
                                                  5.0,
                                                ),
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
        ),
      ),
    );
  }
}
