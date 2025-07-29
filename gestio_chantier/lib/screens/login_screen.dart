import 'dart:io'; // pour SocketException
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/conn_backend.dart';
// import '../screens/forgot_pwd_screen.dart';
import '../config/internet_verify.dart';
import '../screens/home0_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showNoInternetDialog(BuildContext context, {String? msg}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Erreur de connexion"),
        content: Text(
          msg ?? "Impossible de vous connecter. Vérifiez votre connexion.",
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            ConnBackend.connUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "login",
              "company": _companyController.text.trim(),
              "pwdae": _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        if (data['success'] == true) {
          if (_companyController.text == '@17dos1712dos12@' &&
              _passwordController.text == 'dos1712dos') {
            setState(() => _isLoading = false);
            _showNoInternetDialog(context, msg: data['message']);
            _companyController.clear();
            _passwordController.clear();
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Home0Screen()),
            );
          }
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur de connexion"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on SocketException {
      setState(() => _isLoading = false);
      _showNoInternetDialog(context);
    } on TimeoutException {
      setState(() => _isLoading = false);
      _showNoInternetDialog(
        context,
        msg: "Erreur, la requete a mis du temps. Réessayer encore.",
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showNoInternetDialog(context, msg: "Une erreur est survenue");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blueGrey[50],
      // backgroundColor: Colors.tealAccent,
      body: ConnectionOverlayWatcher(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.signal_wifi_statusbar_connected_no_internet_4_sharp,
                  size: 80,
                  color: Color(0xFF1565C0),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Connectez-vous",
                  // "Authentifier-vous",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: "Nom de l'entreprise",
                          prefixIcon: Icon(Icons.home_work_sharp),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Mot de passe",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitLogin,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                // backgroundColor: const Color.fromARGB(255,178,203,247,),
                                // backgroundColor: Colors.blue[100],
                              ),
                              child: const Text(
                                "Se connecter",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      const SizedBox(height: 12),
                      // TextButton(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (_) => const ForgotPasswordPage(),
                      //       ),
                      //     );
                      //   },
                      //   child: const Text(
                      //     "Mot de passe oublié ?",
                      //     style: TextStyle(color: Color(0xFF0D47A1)),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
