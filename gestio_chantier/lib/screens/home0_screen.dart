import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/admin_screen.dart';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';
import '../models/pwds.dart';
import '../models/projet_model.dart';
import '../screens/new_projet_screen.dart';
import '../screens/chantier_screen.dart';
import '../screens/edit_projet_screen.dart';

class Home0Screen extends StatefulWidget {
  const Home0Screen({super.key});
  @override
  State<Home0Screen> createState() => _Home0State();
}

class _Home0State extends State<Home0Screen> {
  List<Projets> _projets = [];
  late String pwd;
  late String pwdSuper;
  late int ttalProjet = 0;
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  List<Projets> _filteredProjets = []; // Liste filtrée à afficher
  List _pwdData = [];

  Uri connUrl_ = ConnBackend.connUrl;

  void _navigateToAjoutProjet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewProjet()),
    );

    if (result == true) {
      _loadWorkers(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  void _navigateToEditProjet(Projets w) async {
    final result = await Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => NewProjet()),
      MaterialPageRoute(builder: (_) => EditProjet(projets: w)),
    );

    if (result == true) {
      _loadWorkers(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWorkers();
    _searchController.addListener(_filterProjets);
    // _searchController.addListener(() {
    //   _filterProjets(); // filtre les projets selon la recherche
    //   setState(
    //     () {},
    //   ); // force l'affichage/mise à jour de l'UI (ex : bouton "✖")
    // });
  }

  void _filterProjets() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProjets = _projets.where((p) {
        return p.nom.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({"action": "list_projets"});
    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      _projets = data.map((e) => Projets.fromJson(e)).toList();
      _filteredProjets = List.from(_projets); // ✅ important
      ttalProjet = _projets.length;
      _isLoading = false;
    });
    getPasswords();
  }

  Future<Pwds?> _pwds() async {
    final url_ = ConnBackend.withParams({"action": "pwds"});
    final resp_ = await http.get(url_);
    final jsonData = jsonDecode(resp_.body);
    return Pwds.fromJson(jsonData);
  }

  void getPasswords() async {
    final pwds = await _pwds();
    pwd = pwds!.pwdAd;
    pwdSuper = pwds.pwdSAd;
    _pwdData = [pwds.pwdPortail, pwds.pwdAd, pwds.pwdSAd, pwds.entreprise];
  }

  Future<void> _confirmSpAdmin({required VoidCallback onConfirmed}) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mdp super admin'),
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
              if (ctrl.text == pwdSuper) {
                Navigator.pop(context, true);
              } else if (ctrl.text == "") {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Le champ ne doit pas etre vide !',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Mot de passe incorrect',
                      style: TextStyle(color: Colors.red),
                    ),
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
              if (ctrl.text == pwd || ctrl.text == pwdSuper) {
                Navigator.pop(context, true);
              } else if (ctrl.text == "") {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Le champ ne doit pas etre vide !',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Mot de passe incorrect',
                      style: TextStyle(color: Colors.red),
                    ),
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

  Future<void> _deleteProjet(int id) async {
    final reponse = await http.post(
      connUrl_,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"action": "delete_projet", 'id': id.toString()}),
    );
    final reponseData = jsonDecode(reponse.body);
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
    _loadWorkers();
  }

  void _onDelete(Projets w) {
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

  void _onEdit(Projets w) {
    _confirmAdmins(
      onConfirmed: () {
        // Redirection vers un formulaire pré-rempli d'édition
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => EditProjet(projets: w)),
        // );
        _navigateToEditProjet(w);
      },
    );
  }

  void _navigateToHistoChefChantier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminScreen(password: _pwdData)),
    );

    if (result == true) {
      getPasswords(); // 🔁 Recharge la liste si un projet a été ajouté
    }
  }

  @override
  Widget build(BuildContext cintx) {
    return ConnectionOverlayWatcher(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          title: const Text('ProChantierSuivi App'),

          // centerTitle: true,
          // elevation: 10,
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const SizedBox(height: 50),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Accueil"),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Quitter"),
                onTap: () {},
              ),
            ],
          ),
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
                      // color: Colors.grey[200],
                      color: Colors.grey[300],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Action quand on clique sur le tout
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => LoginPage()),
                              // );
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                Text(
                                  "Manuel",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _addNewProjet();
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => const NewProjet(),
                              //   ),
                              // );
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.playlist_add,
                                  // Icons.now_widgets_outlined,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                // SizedBox(height: 0),
                                Text(
                                  "+_projet",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _navigateToHistoChefChantier();
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.admin_panel_settings_outlined,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                // SizedBox(height: 0),
                                Text(
                                  "Admin",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Action quand on clique sur le tout
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  // title: Text(success ? "Succès" : "Erreur"),
                                  title: Text("Besoin d'aide ?"),
                                  content: Text(
                                    "Contactez M. Zorobi au 05 04 45 74 83, pour repondre a tout votre besoin ou difficulté concernant l'application.",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  // backgroundColor: success ? Colors.green[100] : Colors.red[100],
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  size: 27,
                                  color: Colors.blue,
                                ),
                                // SizedBox(height: 0),
                                Text(
                                  "Aide",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     // Action quand on clique sur le tout
                          //   },
                          //   child: const Column(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       Icon(
                          //         Icons.logout_outlined,
                          //         size: 27,
                          //         color: Colors.blue,
                          //       ),
                          //       // Icon(Icons.login_sharp, size: 27, color: Colors.blue),
                          //       Text(
                          //         "Déconnexion",
                          //         style: TextStyle(
                          //           fontSize: 10,
                          //           color: Colors.black,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
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
                            "Liste des projets ($ttalProjet)",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              // fontStyle: FontStyle.italic, // Texte en italique
                            ),
                          ),
                          SizedBox(height: 2),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              // height: 30,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                // color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.blue),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Rechercher projet ici ...',
                                        border: InputBorder.none,
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white70,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 3.0,
                                              horizontal: 10.0,
                                            ),
                                        // suffixIcon:
                                        //     _searchController.text.isNotEmpty
                                        //     ? IconButton(
                                        //         icon: Icon(Icons.close),
                                        //         onPressed: () {
                                        //           _searchController
                                        //               .clear(); // Efface le champ
                                        //           // _resetSearch();                   // Réinitialise la liste
                                        //         },
                                        //       )
                                        //     : null,
                                      ),
                                      // onChanged: _performSearch,
                                      // onSubmitted: _performSearch,
                                    ),
                                  ),
                                  ?_searchController.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            // _performSearch(_controller.text);
                                            _searchController.clear();
                                          },
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.blue,
                                            // color: Colors.grey[700],
                                          ),
                                        )
                                      : null,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Liste scrollable
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 10,
                        ),
                        // itemCount: _projets.length,
                        itemCount: _filteredProjets.length,
                        itemBuilder: (_, i) {
                          // final w = _projets[i];
                          final w = _filteredProjets[i];
                          String nom = w.nom;
                          return Container(
                            height: 48,

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
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                left: 15,
                                                top: 6,
                                              ),
                                              // color: Colors.blue,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "$nom,",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      // letterSpacing: 1.2,
                                                      // fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                  Text(
                                                    w.statut,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          const Color.fromARGB(
                                                            255,
                                                            1,
                                                            45,
                                                            81,
                                                          ),
                                                      // letterSpacing: 1.2,
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
                                                    // String nomch = w.nom;
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChantierScreen(
                                                              projet: w,
                                                              adm: pwd,
                                                              admSuper:
                                                                  pwdSuper,
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
                                                  onPressed: () => _onEdit(w),
                                                  label: Icon(
                                                    Icons.edit_square,
                                                    size: 25,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                TextButton.icon(
                                                  onPressed: () => _onDelete(w),
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
