import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'list_ov_projet_screen.dart';
import '../screens/histo_livraison_mat_screen.dart';
import '../screens/histo_sortie_mat_screen.dart';
import '../screens/histo_rapport_jr_screen.dart';
import '../screens/feuille_straitant_screen.dart';
import '../config/internet_verify.dart';
import '../screens/edit_quinzaine_screen.dart';
import '../config/conn_backend.dart';
import '../models/projet_model.dart';
import '../screens/add_quinzaine_screen.dart';
import '../screens/quinzaine_screen.dart';
import '../models/quinzaine_model.dart';

class ChantierScreen extends StatefulWidget {
  final Projets projet;
  final List pwd;
  final String typeUser;
  final String pwdUser;

  const ChantierScreen({
    super.key,
    required this.projet,
    required this.pwd,
    required this.typeUser,
    required this.pwdUser,
  });

  @override
  State<ChantierScreen> createState() => _ChantierScreenState();
}

class _ChantierScreenState extends State<ChantierScreen> {
  List<Quinzaine> _quinzaines = [];
  late List pwd_;
  late int ttalQuinzaine = 0;
  bool _isLoading = true;

  String _statut = '';

  final TextEditingController _searchController = TextEditingController();
  List<Quinzaine> _filteredQuinzaines = []; // Liste filtrée à afficher

  Uri connUrl_ = ConnBackend.connUrl;

  void _navigateToAjoutProjet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewQuinzaine(idProjet: widget.projet.id),
      ),
    );

    if (result == true) {
      _loadQuinzaines(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToEditProjet(Quinzaine w) async {
    final result = await Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => NewProjet()),
      MaterialPageRoute(builder: (_) => EditQuinzaine(quinzaine: w)),
    );
    if (result == true) {
      _loadQuinzaines(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  @override
  void initState() {
    super.initState();
    pwd_ = widget.pwd;
    _statut = widget.projet.statut;
    _loadQuinzaines();
    _searchController.addListener(_filterProjets);
  }

  void _filterProjets() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredQuinzaines = _quinzaines.where((p) {
        return p.periode.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadQuinzaines() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({
      "action": "list_quinzaines",
      "id": widget.projet.id.toString(),
    });
    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      _quinzaines = data.map((e) => Quinzaine.fromJson(e)).toList();
      _filteredQuinzaines = List.from(_quinzaines); // ✅ important
      ttalQuinzaine = _quinzaines.length;
      _isLoading = false;
    });
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

  Future<void> _deleteProjet(int id) async {
    setState(() => _isLoading = true);
    try {
      final reponse = await http.post(
        connUrl_,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "delete_quinzaine", 'id': id.toString()}),
      );

      setState(() => _isLoading = false);
      final data = jsonDecode(reponse.body);
      if (!mounted) return;
      if (data['success'] == true) {
        setState(() {
          _filteredQuinzaines.removeWhere((quinz) => quinz.id == id);
          ttalQuinzaine = _filteredQuinzaines.length;
        });
      } else {
        _showErrorDialog(context, msg: data['message']);
      }
    } on SocketException {
      setState(() => _isLoading = false);
      _showErrorDialog(context);
    } on TimeoutException {
      setState(() => _isLoading = false);
      _showErrorDialog(context, msg: "Une erreur est survenue !");
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(context, msg: "Une erreur est survenue !");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onDelete(Quinzaine w) {
    _confirmSpAdmin(onConfirmed: () => _deleteProjet(w.id));
  }

  void _addNewProjet() {
    _confirmAdmins(
      onConfirmed: () {
        // Redirection vers un formulaire pré-rempli d'édition
        // Navigator.push(context, MaterialPageRoute(builder: (_) => NewProjet()));
        _navigateToAjoutProjet();
      },
    );
  }

  void _onEdit(Quinzaine w) {
    if (w.qRun == 'oui') {
      _confirmAdmins(
        onConfirmed: () {
          _navigateToEditProjet(w);
        },
      );
    } else if (!isQuinzaineActive(w)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Erreur ..."),
          content: Text(
            "Impossible, la session est terminée !",
            style: TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Erreur ..."),
          content: Text(
            "Impossible de modifier cette Session, car une nouvelle Session a été créer au dessus de celle-ci !",
            style: TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  bool isQuinzaineActive(Quinzaine q) {
    final format = DateFormat('dd-MM-yyyy'); // adapte selon ton format
    final now = DateTime.now();

    try {
      final dateFin = format.parse(q.fin);
      return now.isBefore(
        dateFin.add(const Duration(days: 1)),
      ); // true si aujourd'hui est avant la date de fin
    } catch (e) {
      return false; // en cas d'erreur de format ou autre
    }
  }

  void _optionStraitPrestation() {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeuilleSousTraitant(
                      projet: widget.projet,
                      typeOffre: 'straitant',
                      pwd: widget.pwd,
                      typeUser: widget.typeUser,
                      pwdUser: widget.pwdUser,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.engineering),
              label: const Text("Sous-traitant"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeuilleSousTraitant(
                      projet: widget.projet,
                      typeOffre: 'prestation',
                      pwd: widget.pwd,
                      typeUser: widget.typeUser,
                      pwdUser: widget.pwdUser,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.engineering_outlined),
              label: const Text("Prestation"),
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

  void _optionSuiviMat() {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoLivraisonMatScreen(
                      projet: widget.projet,
                      pwd: widget.pwd,
                      typeUser: widget.typeUser,
                      pwdUser: widget.pwdUser,
                    ),
                  ),
                );
              },
              // icon: const Icon(Icons.engineering),
              label: const Text("Livraison matérels/riaux"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoSortieMatScreen(
                      projet: widget.projet,
                      pwd: widget.pwd,
                      typeUser: widget.typeUser,
                      pwdUser: widget.pwdUser,
                    ),
                  ),
                );
              },
              // icon: const Icon(Icons.engineering_outlined),
              label: const Text("Sortie de matériels"),
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

  void _finProjet() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        alignment:
            Alignment.center, // Centrage du dialog lui-même (Flutter 3.7+)
        title: const Center(
          child: Text("Gérer statut projet", textAlign: TextAlign.center),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmSpAdmin(onConfirmed: () => _logiqFinProjet());
              },
              // icon: const Icon(Icons.engineering),
              label: const Text("Basculer"),
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

  Future<void> _logiqFinProjet() async {
    setState(() => _isLoading = true);
    try {
      final reponse = await http.post(
        connUrl_,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "fin_projet",
          'id': widget.projet.id.toString(),
          'statut': widget.projet.statut,
        }),
      );

      setState(() => _isLoading = false);
      final data = jsonDecode(reponse.body);
      if (!mounted) return;

      if (data['success'] == true) {
        setState(() {
          _statut = _statut == 'En cours' ? 'Terminé' : 'En cours';
        });
      } else {
        _showErrorDialog(context, msg: data['message']);
      }
    } on SocketException {
      setState(() => _isLoading = false);
      _showErrorDialog(context);
    } on TimeoutException {
      setState(() => _isLoading = false);
      _showErrorDialog(context, msg: "Une erreur est survenue !");
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(context, msg: "Une erreur est survenue !");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(BuildContext context, {String? msg}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Erreur ..."),
        content: Text(
          msg ?? "Impossible de mener l'action. Vérifiez votre connexion.",
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
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
          title: const Text('Détails du projet'),
          // actions: [
          //   IconButton(
          //     icon: Icon(Icons.groups_2_rounded),
          //     onPressed: () {
          //       // Action quand on clique sur le tout
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => PageOuvrierProjet(
          //             idProjet: widget.projet.id.toString(),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ],
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),

        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadQuinzaines,
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
                              if (_statut == 'Terminé') {
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
                                _addNewProjet();
                              }
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.post_add_rounded,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                Text(
                                  "+_Session",
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
                              // _addNewProjet();
                              _optionSuiviMat();
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.webhook_sharp,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                Text(
                                  "Suivi Mat.",
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
                                  builder: (context) => HistoRapportJrScreen(
                                    projet: widget.projet,
                                    pwd: widget.pwd,
                                    typeUser: widget.typeUser,
                                    pwdUser: widget.pwdUser,
                                  ),
                                  // NewRapport(projet: widget.projet),
                                ),
                              );
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_note_sharp,
                                  // Icons.now_widgets_outlined,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                // SizedBox(height: 0),
                                Text(
                                  "Rapport-jrlier",
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
                              _optionStraitPrestation();
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
                                  "Contrats",
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PageOuvrierProjet(
                                    idProjet: widget.projet.id.toString(),
                                    pwd: widget.pwd,
                                    typeUser: widget.typeUser,
                                    pwdUser: widget.pwdUser,
                                    statut: widget.projet.statut,
                                  ),
                                ),
                              );
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  // Icons.engineering_outlined,
                                  Icons.groups_2_rounded,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                Text(
                                  "Liste ouvriers",
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
                          Text(
                            "Projet: ${widget.projet.nom}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              // fontStyle: FontStyle.italic, // Texte en italique
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _finProjet();
                            },
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                              minimumSize: WidgetStateProperty.all(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _statut,
                              style: TextStyle(
                                fontSize: 11,
                                color: _statut == 'En cours'
                                    ? Color(0xFF0D47A1)
                                    : Colors.orange,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                          Text(
                            "Bdg MO: ${widget.projet.bdgmo} f, Dép.: ${widget.projet.depense} f, Reste: ${widget.projet.reste} f",
                            style: TextStyle(
                              fontSize: 11,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontStyle: FontStyle.italic, // Texte en italique
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      // color: Colors.white,
                      child: Text(
                        "Liste des Sessions ($ttalQuinzaine)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // color: Colors.blue[900],
                        ),
                      ),
                    ),

                    // Liste scrollable
                    _filteredQuinzaines.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(20),
                            color: Colors.white,
                            child: Text(
                              "Aucune Session enregistrée pour l'instant.",
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _filteredQuinzaines.length,
                              itemBuilder: (_, i) {
                                final w = _filteredQuinzaines[i];
                                // String nom = w.periode;
                                return Container(
                                  height: 73,
                                  // margin: EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black,
                                        width: 0.8,
                                      ),
                                    ),
                                    // color: Colors.grey[50],
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,

                                          children: [
                                            Row(
                                              // mainAxisAlignment:
                                              // MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 170,
                                                  padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      right: BorderSide(
                                                        color: Colors.black,
                                                        width: 0.8,
                                                      ),
                                                    ),
                                                    // color: Colors.green[50],
                                                    // color: Colors.green[100],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "${w.periode} #${w.nber}, ",
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                              // letterSpacing: 1.2,
                                                              // fontStyle: FontStyle.italic,
                                                            ),
                                                          ),
                                                          isQuinzaineActive(w)
                                                              ? Text(
                                                                  "En cours",
                                                                  style: TextStyle(
                                                                    // color: Colors.blue,
                                                                    color: Color(
                                                                      0xFF0D47A1,
                                                                    ),
                                                                    fontSize:
                                                                        12,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                  ),
                                                                )
                                                              : Text(
                                                                  "Terminé",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .orange,
                                                                    fontSize:
                                                                        12,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                  ),
                                                                ),
                                                        ],
                                                      ),

                                                      Text(
                                                        "${w.debut} au ${w.fin}",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Créer le ${w.dateCreate}",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Dépenses: ${w.ttal} f",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    TextButton.icon(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                QuinzaineScreen(
                                                                  quinzaine: w,
                                                                  pwds: pwd_,
                                                                  typeUser: widget
                                                                      .typeUser,
                                                                  pwdUser: widget
                                                                      .pwdUser,
                                                                  statutProjet:
                                                                      widget
                                                                          .projet
                                                                          .statut,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                      label: Icon(
                                                        Icons
                                                            .remove_red_eye_outlined,
                                                        size: 25,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    TextButton.icon(
                                                      onPressed: () {
                                                        _onEdit(w);
                                                      },

                                                      label: Icon(
                                                        Icons.edit_square,
                                                        size: 25,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    TextButton.icon(
                                                      onPressed: () {
                                                        _onDelete(w);
                                                      },
                                                      label: Icon(
                                                        Icons.delete_forever,
                                                        size: 25,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
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
              ),
      ),
    );
  }
}
