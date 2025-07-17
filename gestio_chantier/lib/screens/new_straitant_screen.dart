import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestio_chantier/config/separe_millier.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/projet_model.dart';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class NewStraitant extends StatefulWidget {
  final Projets projet;
  final String typeOffre;
  const NewStraitant({
    super.key,
    required this.projet,
    required this.typeOffre,
  });

  @override
  NewStraitantState createState() => NewStraitantState();
}

class NewStraitantState extends State<NewStraitant> {
  final _formKey = GlobalKey<FormState>();

  final _offreController = TextEditingController();
  final _ouvrierController = TextEditingController();
  final _fonctionController = TextEditingController();
  final _telController = TextEditingController();
  final _prixOffreController = TextEditingController();
  // final _versementController = TextEditingController();
  final _avancesController = TextEditingController();
  final DateTime _date = DateTime.now();
  bool isLoading = false;
  bool _hasSaved = false; // Pour savoir si un projet a été ajouté

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

    int? prixOffre = int.tryParse(
      enleverEspaces(_prixOffreController.text.trim()),
    );
    int? prixAvance = int.tryParse(
      enleverEspaces(_avancesController.text.trim()),
    );
    if (prixAvance! > prixOffre!) {
      _showErrorDialog(
        context,
        msg: "L'avance ne doit pas etre supperieur au prix de l'offre !",
      );
    } else {
      setState(() => isLoading = true);
      try {
        final response = await http
            .post(
              ConnBackend.connUrl,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "action": "new_straitant",
                "type_offre": widget.typeOffre.toString(),
                "id_projet": widget.projet.id.toString(),
                "offre": _offreController.text.trim(),
                "ouvrier": _ouvrierController.text.trim(),
                "fonction": _fonctionController.text.trim(),
                "tel_ov": _telController.text.trim(),
                "prix_offre": enleverEspaces(
                  _prixOffreController.text.trim(),
                ).toString(),
                "versement": '0',
                // "reste": '0',
                "avances": enleverEspaces(
                  _avancesController.text.trim(),
                ).toString(),
                "date_": DateFormat('dd-MM-yyyy').format(_date),
                "statut": "non",
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
            _offreController.clear();
            _ouvrierController.clear();
            _fonctionController.clear();
            _prixOffreController.clear();
            _telController.clear();
            // _resteController.clear();
            _avancesController.clear();
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
            title: const Text("Nouveau contrat"),
            // backgroundColor: Colors.blueAccent,
            // backgroundColor: Colors.blue[200],
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
                        // color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        // fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _offreController,
                      decoration: const InputDecoration(
                        labelText: "Description contrat",
                        prefixIcon: Icon(Icons.new_label),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _ouvrierController,
                      decoration: const InputDecoration(
                        labelText: "Nom ouvrier",
                        prefixIcon: Icon(Icons.engineering),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _fonctionController,
                      decoration: const InputDecoration(
                        labelText: "Fonction ouvrier",
                        prefixIcon: Icon(Icons.sensor_occupied_rounded),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _telController,
                      decoration: const InputDecoration(
                        labelText: "Numéro ouvrier",
                        prefixIcon: Icon(Icons.phone_callback_rounded),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
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
                      // val == null || val.isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _prixOffreController,
                      decoration: const InputDecoration(
                        labelText: "Prix offre",
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
                    // const SizedBox(height: 10),
                    // TextFormField(
                    //   controller: _versementController,
                    //   decoration: const InputDecoration(
                    //     labelText: "Versement",
                    //     prefixIcon: Icon(Icons.monetization_on),
                    //     border: OutlineInputBorder(),
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //   ),
                    //   keyboardType: TextInputType.number,
                    //   textInputAction: TextInputAction.next,
                    //   validator: (val) =>
                    //       val == null || val.isEmpty ? "Champ requis" : null,
                    // ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _avancesController,
                      decoration: const InputDecoration(
                        labelText: "Avance",
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
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
