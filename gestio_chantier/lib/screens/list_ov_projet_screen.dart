import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/internet_verify.dart';
import '../models/ouvrier_model.dart';
import '../screens/edit_ouvrier_screen.dart';
import '../config/conn_backend.dart';

class PageOuvrierProjet extends StatefulWidget {
  final String idProjet;
  final List pwd;
  final String typeUser;
  final String pwdUser;
  final String statut;

  const PageOuvrierProjet({
    super.key,
    required this.idProjet,
    required this.pwd,
    required this.typeUser,
    required this.pwdUser,
    required this.statut,
  });
  @override
  State<PageOuvrierProjet> createState() => _PageOuvrierProjetState();
}

class _PageOuvrierProjetState extends State<PageOuvrierProjet> {
  List<Worker> _workers = [];
  bool _isLoading = true;
  int _ttalOvProjet = 0;
  late List pwd_;

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
    pwd_ = widget.pwd;
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({
      "action": "list_ov",
      "id": widget.idProjet.toString(),
    });
    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      _workers = data.map((e) => Worker.fromJson(e)).toList();
      _isLoading = false;
      _ttalOvProjet = _workers.length;
    });
  }

  Future<void> _deleteWorker(int id) async {
    final reponse = await http.post(
      connUrl_,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"action": "delete_ov", 'id': id.toString()}),
    );
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
        _workers.removeWhere((w) => w.id == id);
        _ttalOvProjet = _workers.length;
      });
    }
  }

  void _onDelete(Worker w) {
    _confirmSpAdmin(onConfirmed: () => _deleteWorker(w.id));
  }

  void _onEdit(Worker w) {
    _confirmAdmins(
      onConfirmed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkerEditPage(worker: w)),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return ConnectionOverlayWatcher(
      child: Scaffold(
        appBar: AppBar(title: const Text('Liste des ouvriers')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadWorkers,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 0.5),
                        ),
                        color: Colors.grey[200],
                      ),
                      child: Text(
                        "Nombre total d'ouvrier du projet : $_ttalOvProjet",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    Expanded(
                      child: ListView.separated(
                        itemCount: _workers.length,
                        itemBuilder: (_, i) {
                          final w = _workers[i];
                          return ListTile(
                            leading: ClipOval(
                              child: Image.memory(
                                w.photo,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              w.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${w.function}\n${w.phone}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  // color: Colors.green,
                                  icon: const Icon(Icons.edit_square),
                                  onPressed: () {
                                    if (widget.statut == 'Terminé') {
                                      // if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Impossible, le projet est terminé',
                                            // style: TextStyle(color: Colors.red),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else {
                                      _onEdit(w);
                                    }
                                  },
                                ),
                                IconButton(
                                  // color: Colors.red,
                                  icon: const Icon(
                                    Icons.delete_forever_rounded,
                                  ),
                                  onPressed: () => _onDelete(w),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, i) =>
                            Divider(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
