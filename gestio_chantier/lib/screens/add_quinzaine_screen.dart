import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class NewQuinzaine extends StatefulWidget {
  final int idProjet;
  const NewQuinzaine({super.key, required this.idProjet});

  @override
  NewQuinzaineState createState() => NewQuinzaineState();
}

class NewQuinzaineState extends State<NewQuinzaine> {
  final _formKey = GlobalKey<FormState>();

  final DateTime _date = DateTime.now();
  bool isLoading = false;
  bool _hasSaved = false; // Pour savoir si un projet a été ajouté

  String _selectedType = 'Semaine';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 7));

  final _startController = TextEditingController();
  final _endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateControllers();
  }

  void _updateEndDate() {
    _endDate = _selectedType == 'Semaine'
        ? _startDate.add(Duration(days: 7))
        : _startDate.add(Duration(days: 15));
    _updateControllers();
  }

  void _updateControllers() {
    _startController.text = _formatDate(_startDate);
    _endController.text = _formatDate(_endDate);
  }

  String _formatDate(DateTime date) {
    // return "${date.year}-${_pad(date.month)}-${_pad(date.day)}";
    return "${_pad(date.day)}-${_pad(date.month)}-${date.year}";
  }

  // String _formatDateSend(DateTime date) {
  //   return "${date.year}-${_pad(date.month)}-${_pad(date.day)}";
  // }

  String _pad(int n) => n.toString().padLeft(2, '0');

  // Future<void> _pickDate({required bool isStart}) async {
  //   DateTime initial = isStart ? _startDate : _endDate;

  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: initial,
  //     firstDate: DateTime.now().subtract(Duration(days: 30)),
  //     lastDate: DateTime.now().add(Duration(days: 365)),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       if (isStart) {
  //         _startDate = picked;
  //         _updateEndDate(); // recalculer la date de fin
  //       } else {
  //         _endDate = picked;
  //         _endController.text = _formatDate(picked);
  //       }
  //     });
  //   }
  // }

  Future<void> _pickDate({required bool isStart}) async {
    DateTime initial = isStart ? _startDate : _endDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(), // ✅ aujourd’hui minimum
      lastDate: DateTime.now().add(Duration(days: 60)), // ✅ 2 mois max
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _updateEndDate();
        } else {
          _endDate = picked;
          _endController.text = _formatDate(picked);
        }
      });
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
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
              // Navigator.of(context).pop();
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

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        ConnBackend.connUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "new_quinzaine",
          "idprojet": widget.idProjet.toString(),
          "session": _selectedType,
          "debut": DateFormat('dd-MM-yyyy').format(_startDate),
          "fin": DateFormat('dd-MM-yyyy').format(_endDate),
          "date": DateFormat('dd-MM-yyyy').format(_date),
          "statut": "En cours",
        }),
      );

      setState(() => isLoading = true);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _hasSaved = true; // Le projet a été ajouté
        if (!mounted) return;
        if (data['success'] == true) {
          _showNoInternetDialog(context, msg: data['message']);
          // setState(() {
          //   _selectedType = 'Semaine'; // valeur par défaut
          //   _startDate = DateTime.now();
          //   _endDate = _startDate.add(
          //     Duration(days: 7),
          //   ); // recalcul automatique
          //   _updateControllers(); // met à jour les champs visibles
          // });
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
      _showErrorDialog(context, msg: "Une erreur est survenue1 !");
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog(context, msg: "Une erreur est survenue2 $e !");
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
          // backgroundColor: Color(0xFFE3F2FD), // Bleu très pâle ➤ App éducative, médicale ou de gestion
          // backgroundColor: Color(0xFFE8F5E9), // Vert pastel clair Calmant, utilisé dans apps de bien-être ou environnement
          // backgroundColor: Color(0xFFE0F7FA),
          // backgroundColor: Color(0xFFFAFAFA),

          // backgroundColor: Color(0xFFEDE7F6),
          // backgroundColor: Color.fromARGB(255, 249, 247, 251), // beau
          // backgroundColor: Color(0xFFD0E2F2), // elang
          // backgroundColor: Color.fromARGB(255, 250, 248, 235),
          appBar: AppBar(
            title: const Text("Nouvelle session"),
            // backgroundColor: Colors.blueAccent,
            backgroundColor: Color(0xFF0D47A1),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Choisir période et date début",
                      style: TextStyle(
                        fontSize: 21,
                        // color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        // fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 11),
                    // Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type de période',
                        filled: true,
                        fillColor: Colors.white, // ✅ couleur de fond
                        prefixIcon: Icon(
                          Icons.settings_ethernet_outlined,
                          color: Colors.blue,
                        ), // ✅ icône préfixe
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(12),
                        //   borderSide: BorderSide(color: Colors.blue),
                        // ),
                      ),
                      items: ['Semaine', 'Quinzaine']
                          .map(
                            (val) =>
                                DropdownMenuItem(value: val, child: Text(val)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedType = val;
                            _updateEndDate();
                          });
                        }
                      },
                      // decoration: InputDecoration(labelText: 'Type de période'),
                    ),
                    SizedBox(height: 13),

                    // Input Date Début
                    TextFormField(
                      controller: _startController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Début',
                        // suffixIcon: Icon(Icons.calendar_today),
                        prefixIcon: Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onTap: () => _pickDate(isStart: true),
                    ),
                    SizedBox(height: 13),

                    // Input Date Fin
                    TextFormField(
                      controller: _endController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fin',
                        // suffixIcon: Icon(Icons.calendar_today),
                        prefixIcon: Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      // onTap: () => _pickDate(isStart: false),
                      onTap: () {},
                    ),

                    SizedBox(height: 20),

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
