import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../screens/edite_ov_quinz_screen.dart';
import '../screens/feuille_pointage_screen.dart';
import '../config/separe_millier.dart';
import '../screens/paiement_ov_screen.dart';
import '../screens/assoc_ov_quinz_listovprojet_screen.dart';
import '../screens/adm_pointage_ov_screen.dart';
import '../screens/histo_pointage_screen.dart';
import '../models/ov_quinzaine_model.dart';
import '../config/conn_backend.dart';
// import '../models/ouvrier_model.dart';
import '../models/quinzaine_model.dart';
import '../screens/pointage_ov_screen.dart';
import '../screens/add_ouvrier_screen.dart';
import '../config/internet_verify.dart';

class QuinzaineScreen extends StatefulWidget {
  final Quinzaine quinzaine;
  final List pwds;

  const QuinzaineScreen({
    super.key,
    required this.quinzaine,
    required this.pwds,
  });

  @override
  State<QuinzaineScreen> createState() => QuinzaineScreenState();
}

// class QuinzaineScreen extends StatelessWidget {
class QuinzaineScreenState extends State<QuinzaineScreen> {
  List<WorkersQuinzaine> _workers = [];
  bool _isLoading = true;
  late int ttalouvier = 0;

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({
      "action": "list_ovquinzaine",
      "id": widget.quinzaine.id.toString(),
    });

    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      _workers = data.map((e) => WorkersQuinzaine.fromJson(e)).toList();
      ttalouvier = _workers.length;
      _isLoading = false;
    });
  }

  Future<void> _deleteWorker(int id) async {
    try {
      final reponse = await http
          .post(
            connUrl_,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"action": "delete_ovQ", 'id': id.toString()}),
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
          _workers.removeWhere((ouvr) => ouvr.id == id);
          ttalouvier = _workers.length;
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

  void _onDelete(String pointage, int idOv) {
    if (pointage != '0') {
      _showDialogMessage(
        "Cet ouvrier a déjà été pointé, il ne peut donc pas être supprimé.",
      );
    } else {
      // _confirmAdm(onConfirmed: () => _deleteWorker(idOv));
      String verifiAction = controlAction();
      if (verifiAction == '0') {
        _showDialogMessage("La session n'a pas encore commencé !");
      } else if (verifiAction == '1') {
        _showDialogMessage("La session est terminée !");
      } else if (verifiAction == '11') {
        _confirmAdm(onConfirmed: () => _deleteWorker(idOv));
      } else {
        _showDialogMessage(verifiAction);
      }
    }
  }

  void _onEdit(w) {
    String verifiAction = controlAction();
    if (verifiAction == '0') {
      _showDialogMessage("La session n'a pas encore commencé !");
    } else if (verifiAction == '1') {
      _showDialogMessage("La session est terminée !");
    } else if (verifiAction == '11') {
      _confirmAdm(
        onConfirmed: () {
          _navigateToEditeOv(w);
        },
      );
    } else {
      _showDialogMessage(verifiAction);
    }
  }

  // void _showDialogMessage(String msg, {bool success = false}) {
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

  void _optionAddOvQuinzaine() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        alignment:
            Alignment.center, // Centrage du dialog lui-même (Flutter 3.7+)
        title: const Center(
          child: Text("Option d'insertion", textAlign: TextAlign.center),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToAddNewOvQuinzaine();
              },
              icon: const Icon(Icons.new_label_outlined),
              label: const Text("Nouveau ouvrier"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToAddOvQuinzaineListProjet();
              },
              icon: const Icon(Icons.note_add),
              label: const Text("Liste ouvrier"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _optionPointage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        alignment:
            Alignment.center, // Centrage du dialog lui-même (Flutter 3.7+)
        title: const Center(
          child: Text("Méthode pointage", textAlign: TextAlign.center),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToPointageScreen();
              },
              icon: const Icon(Icons.engineering_rounded),
              label: const Text("Chef chantier"),
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.green[700],
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _confirmAdm(
                  onConfirmed: () {
                    Navigator.of(context).pop();
                    _navigateToPointageScreenAdm();
                  },
                );
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text("Administrateurs"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
              label: const Text("Fermer"),
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

  String controlAction() {
    final now = DateTime.now();
    final debut = DateFormat('dd-MM-yyyy').parse(widget.quinzaine.debut);
    final fin = DateFormat('dd-MM-yyyy').parse(widget.quinzaine.fin);

    if (now.isBefore(debut)) {
      return "0";
    } else if (now.isAfter(fin.add(const Duration(days: 1)))) {
      return "1";
    } else if (now.isAtSameMomentAs(debut) ||
        now.isAfter(debut) && now.isBefore(fin.add(const Duration(days: 1)))) {
      // Entre debut inclus et fin inclus
      return "11";
    } else {
      return "Impossible de mener une action.";
    }
  }

  Future<void> _confirmAdm({required VoidCallback onConfirmed}) async {
    final ctrl = TextEditingController();
    // bool verify = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mdp adm'),
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
              if (ctrl.text == widget.pwds[1] ||
                  ctrl.text == widget.pwds[2] ||
                  ctrl.text == widget.pwds[0]) {
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

  void _navigateToAddNewOvQuinzaine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WorkerRegistrationCameraPage(infoQuinzaine: widget.quinzaine),
      ),
    );
    if (result == true) {
      _loadWorkers(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToAddOvQuinzaineListProjet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageAssocOvToQuinzListProjet(q: widget.quinzaine),
      ),
    );
    if (result == true) {
      _loadWorkers(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToPointageScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageOuvrierPointage(q: widget.quinzaine),
      ),
    );
    if (result == true) {
      _loadWorkers(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToPointageScreenAdm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageOuvrierPointageAdm(q: widget.quinzaine),
      ),
    );
    if (result == true) {
      _loadWorkers(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToHistoPointage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HistoPointageScreen(quinzaine: widget.quinzaine, pwds: widget.pwds),
      ),
    );
    if (result == true) {
      _loadWorkers(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToPaieOv() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PagePaiementOv(q: widget.quinzaine),
      ),
    );
    if (result == true) {
      _loadWorkers(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToEditeOv(w) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateOuvrierPageQ(ouvrier: w)),
    );
    if (result == true) {
      _loadWorkers(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  Widget statutText(String statut, String ttalJrs) {
    return Text(
      ttalJrs == '0' ? '...' : statut,
      style: TextStyle(
        color: statut.trim().toLowerCase() == 'solder'
            ? const Color.fromARGB(255, 2, 104, 5)
            : Colors.red,
        fontSize: 8,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionOverlayWatcher(
      child: Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false, // ✅ pas de flèche ni drawer
          centerTitle: true,
          title: const Text(
            'Session',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),

        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadWorkers,
                child: Column(
                  children: [
                    // Row fixé en haut
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                      color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              String verifiAction = controlAction();
                              if (verifiAction == '0') {
                                _showDialogMessage(
                                  "La session n'a pas encore commencé !",
                                );
                              } else if (verifiAction == '1') {
                                _showDialogMessage("La session est terminée !");
                              } else if (verifiAction == '11') {
                                _confirmAdmins(
                                  onConfirmed: () {
                                    _optionAddOvQuinzaine();
                                  },
                                );
                              } else {
                                _showDialogMessage(verifiAction);
                              }
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.engineering,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                Text(
                                  "+_Ouvrier",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              // Action quand on clique sur le tout
                              String verifiAction = controlAction();
                              if (verifiAction == '0') {
                                _showDialogMessage(
                                  "La session n'a pas encore commencé !",
                                );
                              } else if (verifiAction == '1') {
                                _showDialogMessage("La session est terminée !");
                              } else if (verifiAction == '11') {
                                _confirmAdmins(
                                  onConfirmed: () {
                                    _optionPointage();
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         PageOuvrierPointage(
                                    //           q: widget.quinzaine,
                                    //         ),
                                    //   ),
                                    // );
                                  },
                                );
                              } else {
                                _showDialogMessage(verifiAction);
                              }
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  // Icons.now_widgets_outlined,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                // SizedBox(height: 0),
                                Text(
                                  "Pointage",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              // Action quand on clique sur le tout
                              _navigateToHistoPointage();
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => HistoPointageScreen(
                              //       quinzaine: widget.quinzaine,
                              //       pwds: widget.pwds,
                              //     ),
                              //   ),
                              // );
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_note,
                                  // Icons.now_widgets_outlined,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                // SizedBox(height: 0),
                                Text(
                                  "Histo_pointage",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              // Action quand on clique sur le tout
                              _confirmAdm(
                                onConfirmed: () {
                                  _navigateToPaieOv();
                                },
                              );
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.monetization_on_outlined,
                                  // Icons.now_widgets_outlined,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                // SizedBox(height: 0),
                                Text(
                                  "Paiement",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              // Action quand on clique sur le tout

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeuillePointageOv(
                                    quinzaine: widget.quinzaine,
                                  ),
                                ),
                              );
                              // _confirmAdm(
                              //   onConfirmed: () {
                              //     _navigateToPaieOv();
                              //   },
                              // );
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  // Icons.now_widgets_outlined,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                // SizedBox(height: 0),
                                Text(
                                  "Fiche pointage",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      width: MediaQuery.of(context).size.width * 0.97,
                      alignment: Alignment.center, // centre le contenu
                      decoration: BoxDecoration(
                        // color: Colors.amber,
                        color: Colors.white38,
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${widget.quinzaine.periode} #${widget.quinzaine.nber},",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  // fontStyle: FontStyle.italic, // Texte en italique
                                ),
                              ),
                              Text(
                                " MO: ${widget.quinzaine.ttal} f",
                                style: TextStyle(
                                  fontSize: 12,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontStyle:
                                      FontStyle.italic, // Texte en italique
                                ),
                              ),
                            ],
                          ),

                          // SizedBox(height: 1),
                          Text(
                            "${widget.quinzaine.debut} au ${widget.quinzaine.fin}",
                            style: TextStyle(
                              fontSize: 10,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontStyle: FontStyle.italic, // Texte en italique
                            ),
                          ),

                          // SizedBox(height: 1),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      // color: Colors.white,
                      child: Text(
                        "Ouvriers ${widget.quinzaine.periode} #${widget.quinzaine.nber}, ($ttalouvier)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                    // Liste scrollable
                    Expanded(
                      child: ListView.builder(
                        itemCount: _workers.length,
                        itemBuilder: (_, i) {
                          final w = _workers[i];
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    // height: 48,
                                    // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                    // alignment: Alignment.sp,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 5,
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.97,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black,
                                          width: 0.8,
                                        ),
                                      ),
                                      color: Colors.white60,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly, // 👈 ici le spacing !
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.55,
                                          padding: EdgeInsets.only(
                                            top: 3,
                                            right: 10,
                                            left: 10,
                                            bottom: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.black,
                                                width: 0.8,
                                              ),
                                            ),
                                            // color: Colors.blue,
                                            color: Colors.white60,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    margin: EdgeInsets.only(
                                                      right: 6,
                                                    ),

                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ), // optionnel
                                                      child: Image.memory(
                                                        w.photo,
                                                        width: 60,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),

                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        w.nom,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${w.fonction}\nPrix jr: ${formatNombreStr(w.prixJr)} f\nTel: ${w.tel}\nPointage: ${w.ttalJr} jr(s)\nPaie ttal: ${w.gainQuinzaine} f",
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Payé: ${w.paiement} f, Reste: ${formatNombreStr(w.reste)}",
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                      statutText(
                                                        w.statut,
                                                        w.ttalJr,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),

                                              Text(
                                                "Ajouté le ${w.dateAdd}",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  // fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Row(
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                _onEdit(w);
                                              },

                                              label: Icon(
                                                Icons.edit_square,
                                                size: 27,
                                                color: Colors.green,
                                              ),
                                            ),

                                            TextButton.icon(
                                              onPressed: () {
                                                _onDelete(w.ttalJr, w.id);
                                              },
                                              label: Icon(
                                                Icons.delete_forever,
                                                size: 27,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      // ListView(
                      //   // padding: const EdgeInsets.all(),
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 3,
                      //     vertical: 5,
                      //   ),

                      //   children: [],
                      // ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
