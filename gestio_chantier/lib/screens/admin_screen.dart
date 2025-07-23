import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:io';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/sup_assign_projet_screen.dart';
import '../screens/assign_projet_to_chef_ch_screen.dart';
import '../screens/edit_chef_chantier_screen.dart';
import '../models/chef_chantier_model.dart';
import '../screens/add_chef_chantier_screen.dart';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class AdminScreen extends StatefulWidget {
  final List password;
  const AdminScreen({super.key, required this.password});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<ChefChantierModel> _chefCH = [];
  List _pwdData = [];
  bool _loading = true;
  bool _hasSaved = false;
  bool _siChefCh = true;

  String _newPwdApp = '';
  String _colonneTabDb = '';

  String _entreprise = '';
  String _portail = '';
  String _adm = '';
  String _sAdm = '';

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
    _pwdData = [
      widget.password[0],
      widget.password[1],
      widget.password[2],
      widget.password[3],
    ];
    _entreprise = widget.password[3];
    _portail = widget.password[0];
    _adm = widget.password[1];
    _sAdm = widget.password[2];
    // setState(() => _loading = false);
    _loadChefChantier();
  }

  Future<void> _loadChefChantier() async {
    final url = ConnBackend.withParams({"action": "list_chefChantier"});
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body) as List;
      setState(() {
        // _chefCH = List<Map<String, dynamic>>.from(data);
        _chefCH = data.map((e) => ChefChantierModel.fromJson(e)).toList();
        _loading = false;

        if (_chefCH.isNotEmpty) {
          _siChefCh = false;
        }
      });
      // _pwdData = widget.password;
    } catch (e) {
      // print("Erreur : $e");
      setState(() => _loading = false);
    }
  }

  void _navigateToNewChefChantier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewChefChantier()),
    );

    if (result == true) {
      _loadChefChantier(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToEditeChefCH(id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditeChefChantier(chefCH: id)),
    );

    if (result == true) {
      _loadChefChantier(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToAssignProjetChefCH(id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignProjetToChefChScreen(idChefCh: id),
      ),
    );

    if (result == true) {
      _loadChefChantier(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToSupAssignProjetChefCH(id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupAssignProjetToChefChScreen(idChefCh: id),
      ),
    );

    if (result == true) {
      _loadChefChantier(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  Future<void> _updatePwdsApp({
    required pwdM,
    required VoidCallback onConfirmed,
  }) async {
    final TextEditingController controller = TextEditingController(text: pwdM);
    final ctrl = controller;
    // bool verify = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        scrollable: true, // ✅ ajoute cette ligne
        title: const Text('Modification pwd'),
        content: TextField(
          controller: ctrl,
          // obscureText: true,
          keyboardType: TextInputType.text,

          decoration: const InputDecoration(labelText: 'Saisissez nouveau pwd'),
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
              } else if (ctrl.text.length < 5) {
                // if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le mot de passe doit dépasser 5 caractères'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (ctrl.text != "") {
                FocusScope.of(context).unfocus();
                Navigator.pop(context, true);
                _newPwdApp = ctrl.text;
              }
            },
            // onPressed: () => Navigator.pop(context, ctrl.text == 'admin123'),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirmed();
    }
  }

  Future<void> _logiqUpdatePwdsApp() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final body = {
        "action": "updatePwdApp",
        "colonne": _colonneTabDb,
        "newPwdApp": _newPwdApp,
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
      if (data['success'] == true) {
        _hasSaved = true;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Modification effectuée !',
              // style: TextStyle(color: Colors.red),
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _newPwdApp = '';
          _colonneTabDb = '';
        });
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

  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
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

  Future<void> _deleteChefCH(int id) async {
    try {
      final reponse = await http
          .post(
            connUrl_,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"action": "delete_chefCH", 'id': id.toString()}),
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
          _chefCH.removeWhere((chefCH) => chefCH.id == id);
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

  Future<void> _confirmSup({required VoidCallback onConfirmed}) async {
    // bool verify = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        scrollable: true, // ✅ ajoute cette ligne
        title: const Text('Confirmation'),
        content: Text(
          "Confirmez la suppression",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            // onPressed: () => Navigator.pop(context, false),
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              // Navigator.pop(context);
            },
            // onPressed: () => Navigator.pop(context, ctrl.text == 'admin123'),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirmed();
    }
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
                _navigateToEditeChefCH(c);
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
                _confirmSup(
                  onConfirmed: () {
                    Navigator.of(context).pop();
                    _deleteChefCH(id);
                  },
                );
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

  void _optionAssignProjet(id) {
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
                _navigateToAssignProjetChefCH(id);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Assignation"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToSupAssignProjetChefCH(id);
              },
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text("Suppression"),
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
            title: Text("Zone Admin"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.add_circle_rounded),
                onPressed: () {
                  _navigateToNewChefChantier();
                },
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
                      padding: const EdgeInsets.only(top: 10),
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Text(
                        "Controle des Pwds de l'App",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          // color: Colors.blueGrey,
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
                                      MediaQuery.of(context).size.width * 0.23,
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
                                          "Entreprise", // le texte tapé par l'utilisateur
                                          style: TextStyle(
                                            fontSize: 11,
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
                                      MediaQuery.of(context).size.width * 0.23,
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
                                          "Pwd_portail", // le texte tapé par l'utilisateur
                                          style: TextStyle(
                                            fontSize: 11,
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
                                      MediaQuery.of(context).size.width * 0.19,
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
                                          "Pwd_adm", // le texte tapé par l'utilisateur
                                          style: TextStyle(
                                            fontSize: 11,
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
                                      MediaQuery.of(context).size.width * 0.28,
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
                                          "Pwd_super_adm", // le texte tapé par l'utilisateur
                                          style: TextStyle(
                                            fontSize: 11,
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
                                GestureDetector(
                                  onTap: () {
                                    _colonneTabDb = 'nom_entreprise';
                                    _updatePwdsApp(
                                      pwdM: _pwdData[3],
                                      onConfirmed: () {
                                        setState(() {
                                          _entreprise = _newPwdApp;
                                        });
                                        _logiqUpdatePwdsApp();
                                      },
                                    );
                                    // Place ton action ici
                                  },
                                  child: Container(
                                    // height: 35,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.23,
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
                                            _entreprise, // le texte tapé par l'utilisateur
                                            style: TextStyle(
                                              fontSize: 11,
                                              // color: Color(0xFF0D47A1),
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _colonneTabDb = 'pwd_users';
                                    _updatePwdsApp(
                                      pwdM: _pwdData[0],
                                      onConfirmed: () {
                                        setState(() {
                                          _portail = _newPwdApp;
                                        });
                                        _logiqUpdatePwdsApp();
                                      },
                                    );
                                    // Place ton action ici
                                  },
                                  child: Container(
                                    // height: 35,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.23,
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
                                            _portail, // le texte tapé par l'utilisateur
                                            style: TextStyle(
                                              fontSize: 11,
                                              // color: Color(0xFF0D47A1),
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _colonneTabDb = 'pwd_adm';
                                    _updatePwdsApp(
                                      pwdM: _pwdData[1],
                                      onConfirmed: () {
                                        setState(() {
                                          _adm = _newPwdApp;
                                        });
                                        _logiqUpdatePwdsApp();
                                      },
                                    );
                                    // Place ton action ici
                                  },
                                  child: Container(
                                    // height: 35,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.19,
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
                                            _adm, // le texte tapé par l'utilisateur
                                            style: TextStyle(
                                              fontSize: 11,
                                              // color: Color(0xFF0D47A1),
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _colonneTabDb = 'pwd_super_adm';
                                    _updatePwdsApp(
                                      pwdM: _pwdData[2],
                                      onConfirmed: () {
                                        setState(() {
                                          _sAdm = _newPwdApp;
                                        });
                                        _logiqUpdatePwdsApp();
                                      },
                                    );
                                    // Place ton action ici
                                  },
                                  child: Container(
                                    // height: 35,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.28,
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
                                            _sAdm, // le texte tapé par l'utilisateur
                                            style: TextStyle(
                                              fontSize: 11,
                                              // color: Color(0xFF0D47A1),
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
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
                      // width: double.infinity,
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(top: 10),
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Text(
                        "Controle d'infos chef chantier",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          // color: Colors.blueGrey,
                          // color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                      ),
                      color: Colors.white,
                      child: Container(
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
                              width: MediaQuery.of(context).size.width * 0.25,
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
                                      "Nom", // le texte tapé par l'utilisateur
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              // height: 35,
                              width: MediaQuery.of(context).size.width * 0.20,
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
                                      "Numéro", // le texte tapé par l'utilisateur
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              // height: 35,
                              width: MediaQuery.of(context).size.width * 0.20,
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
                                      "Pwd", // le texte tapé par l'utilisateur
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              // height: 35,
                              width: MediaQuery.of(context).size.width * 0.28,
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
                                      "Chantier gerer", // le texte tapé par l'utilisateur
                                      style: TextStyle(
                                        fontSize: 12,
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
                    ),

                    _siChefCh
                        ? Container(
                            width: MediaQuery.of(context).size.width * 1,
                            padding: const EdgeInsets.all(8),
                            color: Colors.white,
                            child: SizedBox(height: 2),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _chefCH.length,
                              itemBuilder: (_, i) {
                                final r = _chefCH[i];
                                bool lastElmt = false;

                                if (i == _chefCH.length - 1) {
                                  lastElmt = true;
                                }

                                return Column(
                                  children: [
                                    Container(
                                      // width: double.infinity,
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      // padding: const EdgeInsets.all(10),
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        // lastElmt ? bottom: 10 : bottom: 0,
                                        bottom: lastElmt ? 10 : 0,
                                      ),
                                      // color: Colors.grey[200],
                                      color: Colors.white,
                                      // alignment: Alignment.center,
                                      child: Column(
                                        children: [
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
                                                GestureDetector(
                                                  onTap: () {
                                                    _optionAction(r, r.id);
                                                    // Place ton action ici
                                                  },
                                                  child: Container(
                                                    // height: 35,
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.25,
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    // color: Colors.grey[200],
                                                    // alignment: Alignment.center,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          // width: MediaQuery.of(context).size.width * 1,
                                                          padding:
                                                              const EdgeInsets.all(
                                                                2,
                                                              ),
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              right: BorderSide(
                                                                color: Colors
                                                                    .black,
                                                                width: 0.8,
                                                              ),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            r.nom, // le texte tapé par l'utilisateur
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              // color: Color(0xFF0D47A1),
                                                            ),
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                Container(
                                                  // height: 35,
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.20,
                                                  // padding: const EdgeInsets.all(2),
                                                  // color: Colors.grey[200],
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        // width: MediaQuery.of(context).size.width * 1,
                                                        padding:
                                                            const EdgeInsets.all(
                                                              2,
                                                            ),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            right: BorderSide(
                                                              color:
                                                                  Colors.black,
                                                              width: 0.8,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          r.tel, // le texte tapé par l'utilisateur
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            // color: Color(0xFF0D47A1),
                                                          ),
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .visible,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  // height: 35,
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.20,
                                                  // padding: const EdgeInsets.all(2),
                                                  // color: Colors.grey[200],
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        // width: MediaQuery.of(context).size.width * 1,
                                                        padding:
                                                            const EdgeInsets.all(
                                                              2,
                                                            ),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            right: BorderSide(
                                                              color:
                                                                  Colors.black,
                                                              width: 0.8,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          r.pwd, // le texte tapé par l'utilisateur
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            // color: Color(0xFF0D47A1),
                                                          ),
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .visible,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                GestureDetector(
                                                  onTap: () {
                                                    _optionAssignProjet(r.id);
                                                    // Place ton action ici
                                                  },
                                                  child: Container(
                                                    // height: 35,
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.28,

                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          // width: MediaQuery.of(context).size.width * 1,
                                                          color: Colors.white,
                                                          padding:
                                                              const EdgeInsets.all(
                                                                2,
                                                              ),

                                                          child: Column(
                                                            children: [
                                                              ...r.chantier.map(
                                                                (p) => Text(
                                                                  "- $p",
                                                                  style: TextStyle(
                                                                    fontSize: 9,
                                                                    // color: Color(0xFF0D47A1),
                                                                  ),
                                                                  softWrap:
                                                                      true,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                ),
                                                              ),
                                                              if (r
                                                                  .chantier
                                                                  .isEmpty)
                                                                Text(
                                                                  "Aucun projet assigné",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize: 8,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          // Text(
                                                          //   r.chantier, // le texte tapé par l'utilisateur
                                                          //   style: TextStyle(
                                                          //     fontSize: 11,
                                                          //     // color: Color(0xFF0D47A1),
                                                          //   ),
                                                          //   softWrap: true,
                                                          //   overflow:
                                                          //       TextOverflow
                                                          //           .visible,
                                                          // ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: 10),
                                  ],
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
