import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/projet_model.dart';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class NewLivraisonMat extends StatefulWidget {
  final Projets projet;
  const NewLivraisonMat({super.key, required this.projet});

  @override
  NewLivraisonMatState createState() => NewLivraisonMatState();
}

class NewLivraisonMatState extends State<NewLivraisonMat> {
  final _formKey = GlobalKey<FormState>();

  final _designController = TextEditingController();
  final _uniteController = TextEditingController();
  final _qteController = TextEditingController();
  final _nberBlController = TextEditingController();
  final _qualiteController = TextEditingController();
  final _retourMatController = TextEditingController();
  final _qteRetounerController = TextEditingController();

  // final DateTime _date = DateTime.now();
  bool isLoading = false;
  bool _hasSaved = false; // Pour savoir si un projet a été ajouté

  final String rien = 'RAS';
  final String bon = 'Bon';

  @override
  void initState() {
    super.initState();

    _qualiteController.text = bon;
    _retourMatController.text = rien;
    _qteRetounerController.text = rien;
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
              "action": "add_livraison_mat",
              "id_projet": widget.projet.id.toString(),
              "design": _designController.text.trim(),
              "unite": _uniteController.text.trim(),
              "qte": _qteController.text.trim(),
              "nber_bl": _nberBlController.text.trim(),
              "qualites": _qualiteController.text.trim(),
              "retour_mat": _retourMatController.text.trim(),
              "qte_retour_mat": _qteRetounerController.text.trim(),
              // "date_": DateFormat('dd-MM-yyyy').format(_date),
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

          _designController.clear();
          _uniteController.clear();
          _qteController.clear();
          _uniteController.clear();
          _nberBlController.clear();
          _qualiteController.text = bon;
          _retourMatController.text = rien;
          _qteRetounerController.text = rien;
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
            title: const Text("Nouvelle livraison"),
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
                      controller: _designController,
                      decoration: const InputDecoration(
                        labelText: 'Désignation mat.',
                        border: OutlineInputBorder(),
                        alignLabelWithHint:
                            true, // ← utile pour les champs multilignes
                      ),
                      keyboardType: TextInputType.multiline,
                      // textInputAction: TextInputAction.next,
                      maxLines: null, // ← permet plusieurs lignes (automatique)
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ce champ est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _uniteController,
                      decoration: const InputDecoration(
                        labelText: 'Unité',
                        border: OutlineInputBorder(),
                        // ← utile pour les champs multilignes
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
                      controller: _qteController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
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
                      controller: _nberBlController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro BL',
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
                      controller: _qualiteController,
                      decoration: const InputDecoration(
                        labelText: 'Qualité du mat.',
                        border: OutlineInputBorder(),
                        alignLabelWithHint:
                            true, // ← utile pour les champs multilignes
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null, // ← permet plusieurs lignes (automatique)
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ce champ est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _retourMatController,
                      decoration: const InputDecoration(
                        labelText: "Retour mat.",
                        border: OutlineInputBorder(),
                        alignLabelWithHint:
                            true, // ← utile pour les champs multilignes
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null, // ← permet plusieurs lignes (automatique)
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ce champ est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _qteRetounerController,
                      decoration: const InputDecoration(
                        labelText: "Quantité retournée",
                        border: OutlineInputBorder(),
                        alignLabelWithHint:
                            true, // ← utile pour les champs multilignes
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null, // ← permet plusieurs lignes (automatique)
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
