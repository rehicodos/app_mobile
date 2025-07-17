import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../config/separe_millier.dart';
import '../models/ov_quinzaine_model.dart';
import '../config/conn_backend.dart';
import '../config/internet_verify.dart';
// import '../models/quinzaine_model.dart';

class UpdateOuvrierPageQ extends StatefulWidget {
  final WorkersQuinzaine ouvrier;

  const UpdateOuvrierPageQ({super.key, required this.ouvrier});

  @override
  State<UpdateOuvrierPageQ> createState() => _UpdateOuvrierPageQState();
}

class _UpdateOuvrierPageQState extends State<UpdateOuvrierPageQ> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _functionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPaiement = 'Aucun';
  Uint8List? _photo;

  // final DateTime _date = DateTime.now();

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isTakingPicture = false;
  bool _hasSaved = false;

  List<CameraDescription> _cameras = [];
  CameraLensDirection _currentDirection = CameraLensDirection.back;
  late FaceDetector _faceDetector;

  Uri connUrl_ = ConnBackend.connUrl;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );

    _nameController.text = widget.ouvrier.nom;
    _functionController.text = widget.ouvrier.fonction;
    _priceController.text = (widget.ouvrier.prixJr.toString()).replaceAll(
      ' ',
      '',
    );
    // _priceController.text = enleverEspaces(widget.ouvrier.prixJr);
    _phoneController.text = widget.ouvrier.tel;
    _selectedPaiement = widget.ouvrier.mobileMoney;
    _photo = widget.ouvrier.photo;
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );
    _currentDirection = camera.lensDirection;
    _cameraController = CameraController(camera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() => _isCameraReady = true);
  }

  Future<void> _toggleCamera() async {
    if (_cameras.isEmpty) return;
    final newDirection = _currentDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    final newCamera = _cameras.firstWhere(
      (c) => c.lensDirection == newDirection,
      orElse: () => _cameras.first,
    );

    await _cameraController?.dispose();
    _cameraController = CameraController(newCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();

    setState(() {
      _isCameraReady = true;
      _currentDirection = newCamera.lensDirection;
    });
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraReady || _isTakingPicture) return;

    setState(() => _isTakingPicture = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final compressed = await FlutterImageCompress.compressWithList(bytes);

      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Aucun visage détecté.")));
        return;
      }

      _photo = Uint8List.fromList(compressed);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la capture.")),
      );
    } finally {
      setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate() || _photo == null) {
      _showErrorDialog(
        "Veuillez remplir tous les champs et prendre une photo.",
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        connUrl_,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "update_ovQuinzaine",
          "id": widget.ouvrier.id.toString(),
          // "idProjet": widget.ouvrier.idProjet.toString(),
          // "idQuinzaine": widget.ouvrier.idQuinzaine.toString(),
          "nom": _nameController.text,
          "fonction": _functionController.text,
          "phone": _phoneController.text,
          "price": _priceController.text,
          "mobileMoney": _selectedPaiement,
          "photo": base64Encode(_photo!),
        }),
      );

      if (!mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _hasSaved = true;
        _showSuccessDialog(data['message']);
      } else {
        _showErrorDialog(data['message'] ?? "Échec de la mise à jour.");
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog("Erreur : $e");
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(msg, style: TextStyle(color: Colors.red, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Succès"),
        content: Text(msg, style: TextStyle(color: Colors.green, fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              if (_hasSaved) {
                Navigator.pop(context, true);
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
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
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
        validator: val,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _hasSaved);
      },
      child: ConnectionOverlayWatcher(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Modifier Ouvrier"),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Date d'ajout : ${widget.ouvrier.dateAdd}"),
                          ],
                        ),
                        _buildInput(
                          "Nom, Prenom",
                          _nameController,
                          TextInputType.text,
                          (v) => v!.isEmpty ? "Champ requis" : null,
                        ),
                        _buildInput(
                          "Fonction",
                          _functionController,
                          TextInputType.text,
                          (v) => v!.isEmpty ? "Champ requis" : null,
                        ),
                        _buildInput(
                          "Prix journalier",
                          _priceController,
                          TextInputType.number,
                          (v) => v!.isEmpty ? "Champ requis" : null,
                        ),
                        _buildInput(
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
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedPaiement,
                          decoration: const InputDecoration(
                            labelText: 'Mode de paiement',
                            border: OutlineInputBorder(),
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
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => setState(
                            () => _selectedPaiement = val ?? 'Aucun',
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _capturePhoto,
                          icon: const Icon(Icons.camera),
                          label: const Text("Capturer nouvelle photo"),
                        ),
                        const SizedBox(height: 8),
                        _photo != null
                            ? Image.memory(_photo!, width: 200, height: 150)
                            : const Text("Photo actuelle"),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitUpdate,
                          child: const Text("Mettre à jour"),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
