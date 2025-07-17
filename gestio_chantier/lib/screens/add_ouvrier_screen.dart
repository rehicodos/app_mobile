import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/internet_verify.dart';
import '../models/quinzaine_model.dart';
import '../config/conn_backend.dart';

class WorkerRegistrationCameraPage extends StatefulWidget {
  final Quinzaine infoQuinzaine;
  const WorkerRegistrationCameraPage({super.key, required this.infoQuinzaine});
  @override
  State<WorkerRegistrationCameraPage> createState() =>
      _WorkerRegistrationCameraPageState();
}

class _WorkerRegistrationCameraPageState
    extends State<WorkerRegistrationCameraPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _functionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPaiement = 'Aucun';

  DateTime _date = DateTime.now();
  Uint8List? _photo;

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isTakingPicture = false;
  bool _hasSaved = false;

  List<CameraDescription> _cameras = [];
  CameraLensDirection _currentDirection = CameraLensDirection.back;

  late FaceDetector _faceDetector;

  Uri connUrl_ = ConnBackend.connUrl;

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
              Navigator.of(context).pop();
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
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableContours: false,
        enableClassification: false,
        minFaceSize: 0.1,
      ),
    );
  }

  // Future<void> _initCamera() async {
  //   final cameras = await availableCameras();
  //   final rearCamera = cameras.firstWhere(
  //     (cam) => cam.lensDirection == CameraLensDirection.front,
  //     // (cam) => cam.lensDirection == CameraLensDirection.back,
  //   );
  //   _cameraController = CameraController(rearCamera, ResolutionPreset.medium);
  //   await _cameraController!.initialize();
  //   setState(() => _isCameraReady = true);
  // }

  // Initialisation
  Future<void> _initCamera() async {
    _cameras = await availableCameras();

    // Par défaut, utiliser la caméra arrière/frontale
    final frontCamera = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _currentDirection = frontCamera.lensDirection;

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();

    setState(() {
      _isCameraReady = true;
    });
  }

  // Fonction pour basculer entre les caméras
  Future<void> _toggleCamera() async {
    if (_cameras.isEmpty) return;

    final newDirection = _currentDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    final newCamera = _cameras.firstWhere(
      (c) => c.lensDirection == newDirection,
      orElse: () => _cameras.first,
    );

    _currentDirection = newCamera.lensDirection;

    // Fermer l'ancien contrôleur
    await _cameraController?.dispose();

    _cameraController = CameraController(newCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();

    setState(() {
      _isCameraReady = true;
    });
  }

  Future<bool> _detectFace(Uint8List bytes) async {
    final temp = File(
      '${(await Directory.systemTemp.createTemp()).path}/tmp.jpg',
    );
    await temp.writeAsBytes(bytes);
    final inputImage = InputImage.fromFile(temp);
    final faces = await _faceDetector.processImage(inputImage);
    return faces.isNotEmpty;
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraReady || _isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
    });

    // Affiche un loader pendant la capture
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imgFile = await _cameraController!.takePicture();
      final originalBytes = await File(imgFile.path).readAsBytes();

      final compressedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: 200,
        minHeight: 200,
        quality: 90,
      );

      final validFace = await _detectFace(Uint8List.fromList(compressedBytes));
      if (!mounted) return;
      Navigator.pop(context); // Ferme le loader

      if (!validFace) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun visage détecté, essaie encore.")),
        );
        return;
      }

      setState(() => _photo = Uint8List.fromList(compressedBytes));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Ferme le loader même en cas d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la capture")),
      );
    } finally {
      setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _submitForm() async {
    // Fermer le clavier si ouvert
    FocusScope.of(context).unfocus();

    // Vérifier que le formulaire est rempli et la photo présente
    if (!_formKey.currentState!.validate() || _photo == null) {
      // if (!mounted) return;
      _showErrorDialog(
        context,
        msg: "Veuillez remplir tous les champs et prendre une photo",
      );

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text(
      //       "Veuillez remplir tous les champs et prendre une photo",
      //     ),
      //   ),
      // );
      return;
    }

    _formKey.currentState!.save();

    // Affiche le loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http
          .post(
            connUrl_,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "create_new_ov_pageQ",
              "idProjet": widget.infoQuinzaine.idProjet.toString(),
              "idQuinzaine": widget.infoQuinzaine.id.toString(),
              "periode": widget.infoQuinzaine.periode,
              "name": _nameController.text,
              "function": _functionController.text,
              "phone": _phoneController.text,
              "price": _priceController.text,
              "date": DateFormat('yyyy-MM-dd').format(_date),
              "mobileMoney": _selectedPaiement,
              "photo": base64Encode(_photo!),
            }),
          )
          .timeout(const Duration(seconds: 10)); // ⏱ Timeout

      if (!mounted) return;
      Navigator.pop(context); // Ferme le loader

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _hasSaved = true;
        _showNoInternetDialog(context, msg: data['message']);

        _formKey.currentState!.reset();
        _nameController.clear();
        _functionController.clear();
        _priceController.clear();
        _phoneController.clear();
        setState(() {
          _photo = null;
          _selectedPaiement = 'Aucun';
          _date = DateTime.now();
        });
      } else {
        // Gestion spécifique des erreurs
        final msg = data['message'] ?? "Erreur inconnue";
        _showErrorDialog(context, msg: msg);
      }
    } on TimeoutException {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, msg: "La connexion a expiré. Réessayez.");
      }
    } on SocketException {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, msg: "Pas de connexion Internet.");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, msg: "Une erreur est survenue !, $e");
      }
    }
  }

  Future<bool> sendWorkerToServer({
    required String idProjet,
    required String idQuinzaine,
    required String name,
    required String function,
    required String phone,
    required String price,
    required String date,
    required String mobileMoney,
    required Uint8List photoBytes,
  }) async {
    final url = connUrl_;

    final corps = jsonEncode({
      "action": "create_new_ov_pageQ",
      "idProjet": idProjet,
      "idQuinzaine": idQuinzaine,
      "name": name,
      "function": function,
      "phone": phone,
      "price": price,
      "date": date,
      "mobileMoney": mobileMoney,
      "photo": base64Encode(photoBytes),
    });
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: corps,
    );

    if (response.body.isEmpty) throw Exception("Réponse vide du serveur");

    try {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      throw Exception(
        "Une erreur est survenue !",
        // "Erreur de décodage JSON : $e\nRéponse brute : ${response.body}",
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _nameController.dispose();
    _functionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildTextInput(
    String label,
    TextEditingController ctrl,
    TextInputType type,
    String? Function(String?) val,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
        validator: val,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy').format(_date);
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
            title: const Text("Enregistrement Ouvrier"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.cameraswitch),
                onPressed: _toggleCamera,
              ),
            ],
          ),
          body: _isCameraReady
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text("Date d'ajout : $dateFmt")],
                            ),
                            _buildTextInput(
                              "Nom, Prenom",
                              _nameController,
                              TextInputType.text,
                              (v) => v!.isEmpty ? "Champ requis" : null,
                            ),
                            _buildTextInput(
                              "Fonction",
                              _functionController,
                              TextInputType.text,
                              (v) => v!.isEmpty ? "Champ requis" : null,
                            ),
                            _buildTextInput(
                              "Prix journalier",
                              _priceController,
                              TextInputType.number,
                              (v) => v!.isEmpty ? "Champ requis" : null,
                            ),
                            _buildTextInput(
                              "Téléphone",
                              _phoneController,
                              TextInputType.phone,
                              (v) {
                                return RegExp(
                                      r'^(?:\+33|0)[1-9](?:[\s.-]?\d{2}){4}$',
                                    ).hasMatch(v!)
                                    ? null
                                    : "Numéro invalide";
                              },
                            ),
                            SizedBox(height: 3),
                            // Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedPaiement,
                              decoration: InputDecoration(
                                labelText: 'Mode de paiement',
                                filled: true,
                                fillColor: Colors.white,
                                // prefixIcon: Icon(Icons.payment, color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              items:
                                  [
                                        'Aucun',
                                        'Moov Money',
                                        'Mtn Money',
                                        'Orange Money',
                                        'Wave',
                                      ]
                                      .map(
                                        (mode) => DropdownMenuItem(
                                          value: mode,
                                          child: Text(mode),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _selectedPaiement = value;
                                  // Si dans un StatefulWidget, n'oublie pas setState
                                  setState(() => _selectedPaiement = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _capturePhoto,
                        icon: const Icon(Icons.camera),
                        label: const Text("Capturer photo"),
                      ),
                      const SizedBox(height: 10),
                      _photo != null
                          ? Image.memory(_photo!, width: 200, height: 150)
                          : const Text("Aucune photo"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text("Enregistrer l'ouvrier"),
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
