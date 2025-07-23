import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/rapport_jr_model.dart';
import '../config/internet_verify.dart';
import '../config/conn_backend.dart';

class EditRapport extends StatefulWidget {
  final RapportJrModel rapport;
  const EditRapport({super.key, required this.rapport});

  @override
  EditRapportState createState() => EditRapportState();
}

class EditRapportState extends State<EditRapport> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _rapportJrController;
  late TextEditingController _incidentController;
  late TextEditingController _visitePersoController;
  late TextEditingController _essaiOperationController;
  late TextEditingController _documentRecusController;
  late TextEditingController _receptionOvController;
  late TextEditingController _infoHseController;
  late TextEditingController _approsMatController;
  late TextEditingController _matUseController;
  late TextEditingController _persoEmployerController;
  late TextEditingController _travoEvolutionController;
  late TextEditingController _matEnStocksController;
  late TextEditingController _observationFinJrController;
  late TextEditingController _travoEvolutionPourcentController;

  // final DateTime _date = DateTime.now();
  bool isLoading = false;
  bool _hasSaved = false; // Pour savoir si un projet a été ajouté

  final String rien = 'néant';
  String _selectedclimats = 'Soleil';

  @override
  void initState() {
    super.initState();

    _rapportJrController = TextEditingController(
      text: widget.rapport.rapportJr,
    );
    _incidentController = TextEditingController(text: widget.rapport.incident);
    _visitePersoController = TextEditingController(
      text: widget.rapport.visitePerso,
    );
    _essaiOperationController = TextEditingController(
      text: widget.rapport.essaiOperation,
    );
    _documentRecusController = TextEditingController(
      text: widget.rapport.docRecus,
    );
    _receptionOvController = TextEditingController(
      text: widget.rapport.receptionOv,
    );
    _infoHseController = TextEditingController(text: widget.rapport.infoHse);
    _approsMatController = TextEditingController(
      text: widget.rapport.approsMat,
    );
    _matUseController = TextEditingController(text: widget.rapport.matUse);
    _persoEmployerController = TextEditingController(
      text: widget.rapport.persoEmployer,
    );
    _travoEvolutionController = TextEditingController(
      text: widget.rapport.travoEvolution,
    );
    _matEnStocksController = TextEditingController(
      text: widget.rapport.matEnStocks,
    );
    _observationFinJrController = TextEditingController(
      text: widget.rapport.observation,
    );
    _travoEvolutionPourcentController = TextEditingController(
      text: widget.rapport.travoPourcntage,
    );

    setState(() => _selectedclimats = widget.rapport.climat);
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

    setState(() => isLoading = true);
    try {
      final response = await http
          .post(
            ConnBackend.connUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "edite_rapport_jr",
              "id": widget.rapport.id.toString(),
              "rapportJr": _rapportJrController.text.trim(),
              "incident": _incidentController.text.trim(),
              "visite_perso": _visitePersoController.text.trim(),
              "essai_operation": _essaiOperationController.text.trim(),
              "doc_recus": _documentRecusController.text.trim(),
              "reception_ov": _receptionOvController.text.trim(),
              "info_hse": _infoHseController.text.trim(),
              "appros_mat": _approsMatController.text.trim(),
              "mat_use": _matUseController.text.trim(),
              "perso_employer": _persoEmployerController.text.trim(),
              "travo_evolution": _travoEvolutionController.text.trim(),
              "travo_pourcntage": _travoEvolutionPourcentController.text.trim(),
              "mat_en_stocks": _matEnStocksController.text.trim(),
              "observation_fin_jr": _observationFinJrController.text.trim(),
              "climat": _selectedclimats,
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
            title: const Text("Modification rapport"),
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
                      controller: _rapportJrController,
                      decoration: const InputDecoration(
                        labelText: 'Taches prévues',
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
                      controller: _incidentController,
                      decoration: const InputDecoration(
                        labelText: 'Incident de chantier',
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
                      controller: _visitePersoController,
                      decoration: const InputDecoration(
                        labelText: 'Visite de personnalité',
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
                      controller: _essaiOperationController,
                      decoration: const InputDecoration(
                        labelText: 'Essaie et opération',
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
                      controller: _documentRecusController,
                      decoration: const InputDecoration(
                        labelText: 'Documents ou courriers reçus',
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
                      controller: _receptionOvController,
                      decoration: const InputDecoration(
                        labelText: "Reception d'ouvrage",
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
                      controller: _infoHseController,
                      decoration: const InputDecoration(
                        labelText: "Info/hse du chantier",
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
                      controller: _approsMatController,
                      decoration: const InputDecoration(
                        labelText: "Appros matériaux",
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
                      controller: _matUseController,
                      decoration: const InputDecoration(
                        labelText: "Matériaux utilisés",
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
                      controller: _persoEmployerController,
                      decoration: const InputDecoration(
                        labelText: "Personnel employés",
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
                      controller: _travoEvolutionController,
                      decoration: const InputDecoration(
                        labelText: "Etape d'evolution des travaux",
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
                      controller: _travoEvolutionPourcentController,
                      decoration: const InputDecoration(
                        labelText: "Etape d'avancement des travaux en %",
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
                      controller: _matEnStocksController,
                      decoration: const InputDecoration(
                        labelText: "Matériaux en stocks",
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
                      controller: _observationFinJrController,
                      decoration: const InputDecoration(
                        labelText: "Observation et recommendation",
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
                    // Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedclimats,
                      decoration: InputDecoration(
                        labelText: 'Climat',
                        filled: true,
                        fillColor: Colors.white, // ✅ couleur de fond
                      ),
                      items: ['Pluie', 'Soleil', 'Autres']
                          .map(
                            (val) =>
                                DropdownMenuItem(value: val, child: Text(val)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedclimats = val;
                          });
                        }
                      },
                      // decoration: InputDecoration(labelText: 'Type de période'),
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
