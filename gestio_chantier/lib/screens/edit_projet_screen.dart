import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';
import '../models/projet_model.dart';

class EditProjet extends StatefulWidget {
  final Projets projets;
  const EditProjet({super.key, required this.projets});

  @override
  EditProjetState createState() => EditProjetState();
}

class EditProjetState extends State<EditProjet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _bdgMoController;
  late TextEditingController _clientController;
  late int _id;
  bool _hasSaved = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _id = widget.projets.id;
    _nomController = TextEditingController(text: widget.projets.nom);
    _bdgMoController = TextEditingController(text: widget.projets.bdgmo);
    _clientController = TextEditingController(text: widget.projets.client);
  }

  void _showNoInternetDialog(BuildContext context, {String? msg}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Infos ..."),
        content: Text(
          msg ?? "Impossible de mener l'action. Vérifiez votre connexion.",
          // style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // _hasSaved = true;
              // Navigator.of(context).popUntil(
              //   (route) => route.isFirst,
              // ); // Ferme tout sauf la première page

              Navigator.of(context).pop();
              Navigator.pop(context, true);
              // Navigator.of(context).pop();
              // Navigator.pop(context, true);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
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
              // Navigator.of(context).popUntil(
              //   (route) => route.isFirst,
              // ); // Ferme tout sauf la première page
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        ConnBackend.connUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "edit_projet",
          "id": _id,
          "nom": _nomController.text.trim(),
          "bdgmo": _bdgMoController.text.trim(),
          "client": _clientController.text.trim(),
        }),
      );

      setState(() => isLoading = true);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _hasSaved = true;
        if (!mounted) return;
        if (data['success'] == true) {
          _showNoInternetDialog(context, msg: data['message']);
          _nomController.clear();
          _bdgMoController.clear();
          _clientController.clear();
        } else {
          _showErrorDialog(context, msg: data['message']);
        }
      } else {
        if (!mounted) return;
        _showErrorDialog(context, msg: data['message']);
      }
    } on SocketException {
      setState(() => isLoading = false);
      _showErrorDialog(context);
    } on TimeoutException {
      setState(() => isLoading = false);
      _showErrorDialog(context, msg: "Une erreur est survenue !");
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog(context, msg: "Une erreur est survenue !");
    } finally {
      setState(() => isLoading = false);
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
            title: const Text("Modification projet"),
            // backgroundColor: Colors.blueAccent,
            backgroundColor: Colors.blue[200],
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      "Renseignez les champs",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        // fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: "Nom projet",
                        prefixIcon: Icon(Icons.business_center),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _bdgMoController,
                      decoration: const InputDecoration(
                        labelText: "Budget main d'ouvre",
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _clientController,
                      decoration: const InputDecoration(
                        labelText: "Nom du client",
                        prefixIcon: Icon(Icons.sensor_occupied_rounded),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.text,
                      // textInputAction: TextInputAction.next,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Champ requis" : null,
                    ),

                    const SizedBox(height: 20),

                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.send_and_archive),
                            label: const Text("Enregistrer"),
                            onPressed: _enregistrer,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
