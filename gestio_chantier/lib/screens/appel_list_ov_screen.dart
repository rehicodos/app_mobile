import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/ouvrier_model.dart';
import '../screens/edit_ouvrier_screen.dart';
import '../config/conn_backend.dart';

class PageOuvrier extends StatefulWidget {
  const PageOuvrier({super.key});
  @override
  State<PageOuvrier> createState() => _PageOuvrierState();
}

class _PageOuvrierState extends State<PageOuvrier> {
  List<Worker> _workers = [];
  bool _isLoading = true;

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({"action": "list_ov"});
    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      _workers = data.map((e) => Worker.fromJson(e)).toList();
      _isLoading = false;
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
  Widget build(BuildContext cintx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des ouvriers')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWorkers,
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
    );
  }
}
