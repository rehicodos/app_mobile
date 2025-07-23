import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class NewChefChantier extends StatefulWidget {
  const NewChefChantier({super.key});

  @override
  NewChefChantierState createState() => NewChefChantierState();
}

class NewChefChantierState extends State<NewChefChantier> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _telController = TextEditingController();
  final _pwdController = TextEditingController();

  // final DateTime _date = DateTime.now();
  bool isLoading = false;
  bool _hasSaved = false; // Pour savoir si un projet a été ajouté

  @override
  void initState() {
    super.initState();
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
      final response = await http
          .post(
            ConnBackend.connUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "add_chef_chantier",
              "nom": _nomController.text.trim(),
              "tel": _telController.text.trim(),
              "pwd": _pwdController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      setState(() => isLoading = true);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _hasSaved = true; // Le projet a été ajouté
        if (!mounted) return;
        if (data['success'] == true) {
          _showNoInternetDialog(context, msg: data['message']);

          _formKey.currentState!.reset();

          _nomController.clear();
          _telController.clear();
          _pwdController.clear();
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
      _showErrorDialog(context, msg: "Une erreur est survenue ! $e");
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
            title: const Text("Nouveau chef chantier"),
            // backgroundColor: Colors.blueAccent,
            // backgroundColor: Colors.blue[200],
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Text(
                      "Renseignez les champs",
                      style: TextStyle(
                        fontSize: 20,
                        // color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        // fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom chef chantier',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ce champ est requis';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _telController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro téléphone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        return RegExp(
                              r'^(?:\+33|0)[1-9](?:[\s.-]?\d{2}){4}$',
                            ).hasMatch(val!)
                            ? null
                            : "Numéro invalide";
                      },
                    ),

                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _pwdController,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ce champ est requis';
                        }
                        return null;
                      },
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
