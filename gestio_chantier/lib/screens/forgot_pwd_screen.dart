import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  DemandeMotDePassePageState createState() => DemandeMotDePassePageState();
}

class DemandeMotDePassePageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  bool isLoading = false;

  void _showNoInternetDialog(BuildContext context, {String? msg}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Infos ..."),
        content: Text(
          msg ?? "Impossible d'envoyer la demande. Vérifiez votre connexion.",
          // style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigator.of(context).popUntil(
              //   (route) => route.isFirst,
              // ); // Ferme tout sauf la première page
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _envoyerDemande() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        ConnBackend.connUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "demande_mdp",
          "nom": _nomController.text.trim(),
          "tel": _telephoneController.text.trim(),
        }),
      );

      setState(() => isLoading = true);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        if (data['success'] == true) {
          _showNoInternetDialog(context, msg: data['message']);
          _nomController.clear();
          _telephoneController.clear();
        } else {
          _showNoInternetDialog(context, msg: data['message']);
        }
      } else {
        if (!mounted) return;
        _showNoInternetDialog(context, msg: data['message']);
      }
    } on SocketException {
      setState(() => isLoading = false);
      _showNoInternetDialog(context);
    } on TimeoutException {
      setState(() => isLoading = false);
      _showNoInternetDialog(context, msg: "Une erreur est survenue !");
    } catch (e) {
      setState(() => isLoading = false);
      _showNoInternetDialog(context, msg: "Une erreur est survenue !");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demande de mot de passe"),
        // backgroundColor: Colors.blueAccent,
        // backgroundColor: Colors.blue[200],
      ),
      body: ConnectionOverlayWatcher(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Faites une demande de mot de passe auprès de l'administrateur",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF0D47A1),
                      // fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: "Votre nom, prénom",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _telephoneController,
                    decoration: const InputDecoration(
                      labelText: 'Votre numéro de téléphone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.phone,
                    // textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Champ requis';
                      }
                      if (value.length < 10 || value.length > 10) {
                        return 'Veuillez entrer un numéro de téléphone valide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text("Envoyer la demande"),
                          onPressed: _envoyerDemande,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
