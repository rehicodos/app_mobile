import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
import 'dart:convert';
import '../config/separe_millier.dart';
import '../models/straitant_model.dart';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class EditStraitant extends StatefulWidget {
  final Straitant contrat;
  const EditStraitant({super.key, required this.contrat});

  @override
  EditStraitantState createState() => EditStraitantState();
}

class EditStraitantState extends State<EditStraitant> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _offreController;
  late TextEditingController _ouvrierController;
  late TextEditingController _fonctionController;
  late TextEditingController _telController;
  late TextEditingController _prixOffreController;
  late TextEditingController _avancesController;
  // late DateTime _date = DateTime.now();
  bool isLoading = false;
  bool _hasSaved = false; // Pour savoir si un projet a été ajouté

  @override
  void initState() {
    super.initState();
    _offreController = TextEditingController(text: widget.contrat.offre);
    _ouvrierController = TextEditingController(text: widget.contrat.ouvrier);
    _fonctionController = TextEditingController(text: widget.contrat.fonction);
    _telController = TextEditingController(text: widget.contrat.tel);
    _prixOffreController = TextEditingController(
      text: widget.contrat.prixOffre,
    );
    _avancesController = TextEditingController(text: widget.contrat.avances);
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
              Navigator.pop(context, true);
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
                "action": "edit_straitant",
                "id": widget.contrat.id.toString(),
                "offre": _offreController.text.trim(),
                "ouvrier": _ouvrierController.text.trim(),
                "fonction": _fonctionController.text.trim(),
                "tel_ov": _telController.text.trim(),
                "prix_offre": enleverEspaces(
                  _prixOffreController.text.trim(),
                ).toString(),
                "avances": enleverEspaces(
                  _avancesController.text.trim(),
                ).toString(),
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
            title: const Text("Modification contrat"),
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
                            icon: const Icon(Icons.edit_square),
                            label: const Text("Modifier"),
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
