import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/internet_verify.dart';
import '../models/ouvrier_model.dart';
import '../screens/edit_ouvrier_screen.dart';
import '../config/conn_backend.dart';

class PageOuvrierProjet extends StatefulWidget {
  final String idProjet;
  const PageOuvrierProjet({super.key, required this.idProjet});
  @override
  State<PageOuvrierProjet> createState() => _PageOuvrierProjetState();
}

class _PageOuvrierProjetState extends State<PageOuvrierProjet> {
  List<Worker> _workers = [];
  bool _isLoading = true;
  int _ttalOvProjet = 0;

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
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

  Future<void> _confirmAdminAction({required VoidCallback onConfirmed}) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation admin'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe admin'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text == 'admin123'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onConfirmed();
    } else if (confirmed == false) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mot de passe incorrect')));
    }
  }

  Future<void> _deleteWorker(int id) async {
    final reponse = await http.post(
      connUrl_,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"action": "delete_ov", 'id': id.toString()}),
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

  void _onDelete(Worker w) {
    _confirmAdminAction(onConfirmed: () => _deleteWorker(w.id));
  }

  void _onEdit(Worker w) {
    _confirmAdminAction(
      onConfirmed: () {
        // Redirection vers un formulaire pré-rempli d'édition
        // Ici tu pourras injecter 'w' dans le formulaire de modification.

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkerEditPage(worker: w)),
        );

        // if (!mounted) return;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Modifier l'ouvrier Zorobi (implémenter formulaire)"),
        //   ),
        // );
      },
    );
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
                      child: ListView.builder(
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
                            title: Text(w.name),
                            subtitle: Text('${w.function} • ${w.phone}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _onEdit(w),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _onDelete(w),
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
