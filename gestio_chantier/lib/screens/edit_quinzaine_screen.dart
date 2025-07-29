import 'dart:async';
import 'dart:io';
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/quinzaine_model.dart';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class EditQuinzaine extends StatefulWidget {
  final Quinzaine quinzaine;

  const EditQuinzaine({super.key, required this.quinzaine});

  @override
  EditQuinzaineState createState() => EditQuinzaineState();
}

class EditQuinzaineState extends State<EditQuinzaine> {
  final _formKey = GlobalKey<FormState>();
  // final DateTime _date = DateTime.now();
  bool isLoading = false;
  bool _hasSaved = false;

  String _selectedType = 'Semaine';
  late DateTime _startDate;
  late DateTime _endDate;

  final _startController = TextEditingController();
  final _endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.quinzaine.periode;
    _startDate = DateFormat('dd-MM-yyyy').parse(widget.quinzaine.debut);
    _endDate = DateFormat('dd-MM-yyyy').parse(widget.quinzaine.fin);
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
    return "${_pad(date.day)}-${_pad(date.month)}-${date.year}";
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  // Future<void> _pickDateo({required bool isStart}) async {
  //   DateTime initial = isStart ? _startDate : _endDate;

  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: initial,
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime.now().add(Duration(days: 60)),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       if (isStart) {
  //         _startDate = picked;
  //         _updateEndDate();
  //       } else {
  //         _endDate = picked;
  //         _endController.text = _formatDate(picked);
  //       }
  //     });
  //   }
  // }

  Future<void> _pickDate({required bool isStart}) async {
    DateTime today = DateTime.now();
    DateTime last = today.add(Duration(days: 60));
    DateTime initial = isStart ? _startDate : _endDate;

    // ✅ Corriger si initialDate est hors plage
    if (initial.isBefore(today)) {
      initial = today;
    } else if (initial.isAfter(last)) {
      initial = last;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: last,
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
        ),
        actions: [
          TextButton(
            onPressed: () {
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
          msg ?? "Impossible de mener l'action.",
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

  void _modifier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        ConnBackend.connUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "update_quinzaine",
          "id": widget.quinzaine.id.toString(),
          "idprojet": widget.quinzaine.idProjet.toString(),
          "periode": _selectedType,
          "debut": DateFormat('dd-MM-yyyy').format(_startDate),
          "fin": DateFormat('dd-MM-yyyy').format(_endDate),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;
      if (response.statusCode == 200 && data['success'] == true) {
        _hasSaved = true;
        _showNoInternetDialog(context, msg: data['message']);
      } else {
        _showErrorDialog(context, msg: data['message']);
      }
    } on SocketException {
      setState(() => isLoading = false);
      _showErrorDialog(context);
    } on TimeoutException {
      setState(() => isLoading = false);
      _showErrorDialog(context, msg: "Une erreur est survenue !");
    } catch (e) {
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
            title: const Text("Modifier la session"),
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
                      "Modifier période et date début",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 11),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type de période',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.settings_ethernet_outlined,
                          color: Colors.blue,
                        ),
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
                    ),
                    SizedBox(height: 13),
                    TextFormField(
                      controller: _startController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Début',
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
                    TextFormField(
                      controller: _endController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fin',
                        prefixIcon: Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onTap: () {},
                    ),
                    SizedBox(height: 20),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.edit_calendar),
                            label: const Text("Modifier"),
                            onPressed: _modifier,
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
