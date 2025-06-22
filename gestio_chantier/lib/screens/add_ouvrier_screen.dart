import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/conn_backend.dart';

class WorkerRegistrationCameraPage extends StatefulWidget {
  const WorkerRegistrationCameraPage({super.key});
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

  DateTime _date = DateTime.now();
  Uint8List? _photo;

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isTakingPicture = false;

  late FaceDetector _faceDetector;

  Uri connUrl_ = ConnBackend.connUrl;

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

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final rearCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
    );
    _cameraController = CameraController(rearCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() => _isCameraReady = true);
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
    if (!_formKey.currentState!.validate() || _photo == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs et prendre une photo",
          ),
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    // Affiche un loader pendant l'envoi
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await sendWorkerToServer(
        name: _nameController.text,
        function: _functionController.text,
        phone: _phoneController.text,
        price: _priceController.text,
        date: DateFormat('yyyy-MM-dd').format(_date),
        photoBytes: _photo!,
      );

      if (!mounted) return;
      Navigator.pop(context); // Ferme le loader

      if (success) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Succès'),
            content: const Text('Ouvrier enregistré !'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _formKey.currentState!.reset();
                  _nameController.clear();
                  _functionController.clear();
                  _priceController.clear();
                  _phoneController.clear();
                  setState(() {
                    _photo = null;
                    _date = DateTime.now();
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Erreur'),
            content: const Text("Erreur d'enregistrement"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Ferme le loader même si erreur
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erreur'),
          content: Text('Erreur lors de l\'envoi !'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> sendWorkerToServer({
    required String name,
    required String function,
    required String phone,
    required String price,
    required String date,
    required Uint8List photoBytes,
  }) async {
    final url = connUrl_;
    // final url = Uri.parse(
    //   "http://192.168.1.8:8080/chantier_gestion_api/add_ouvrier.php",
    // );

    final corps = jsonEncode({
      "action": "create_new_ov",
      "name": name,
      "function": function,
      "phone": phone,
      "price": price,
      "date": date,
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
        "Erreur de décodage !",
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: val,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy').format(_date);
    return Scaffold(
      appBar: AppBar(title: const Text("Enregistrement Ouvrier")),
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
                          children: [
                            Text("Date d'ajout : $dateFmt"),
                            // ElevatedButton(
                            //   onPressed: () async {
                            //     final picked = await showDatePicker(
                            //       context: context,
                            //       initialDate: _date,
                            //       firstDate: DateTime(2020),
                            //       lastDate: DateTime.now(),
                            //     );
                            //     if (picked != null) {
                            //       setState(() => _date = picked);
                            //     }
                            //   },
                            //   child: const Text("Changer"),
                            // ),
                          ],
                        ),
                        _buildTextInput(
                          "Nom",
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
    );
  }
}
