import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../models/ouvrier_model.dart';
import '../config/conn_backend.dart';

class WorkerEditPage extends StatefulWidget {
  // final Map<String, dynamic> worker;
  // const WorkerEditPage({super.key, required this.worker});

  final Worker worker;

  const WorkerEditPage({super.key, required this.worker});

  @override
  State<WorkerEditPage> createState() => _WorkerEditPageState();
}

class _WorkerEditPageState extends State<WorkerEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _functionController;
  late TextEditingController _priceController;
  late TextEditingController _phoneController;
  DateTime _date = DateTime.now();
  Uint8List? _photo;
  Uint8List? _originalPhoto;

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isTakingPicture = false;

  late FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.worker.name);
    _functionController = TextEditingController(text: widget.worker.function);
    _priceController = TextEditingController(
      text: widget.worker.price.toString(),
    );
    _phoneController = TextEditingController(text: widget.worker.phone);
    _date = DateFormat('yyyy-MM-dd').parse(widget.worker.date);
    // _originalPhoto = base64Decode(widget.worker.photo);
    _originalPhoto = widget.worker.photo;
    _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
    );
    _cameraController = CameraController(backCamera, ResolutionPreset.medium);
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
    // if (!mounted) return;

    setState(() => _isTakingPicture = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imgFile = await _cameraController!.takePicture();
      final bytes = await File(imgFile.path).readAsBytes();
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 90,
        minHeight: 200,
        minWidth: 200,
      );

      final valid = await _detectFace(Uint8List.fromList(compressed));
      if (!mounted) return;
      Navigator.pop(context); // Ferme le loader

      if (!valid) {
        if (!mounted) return;
        // Navigator.pop(context); // Fermer le dialog
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(const SnackBar(content: Text("Aucun visage détecté.")));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun visage détecté, essaie encore.")),
        );
        return;
      }

      setState(() => _photo = Uint8List.fromList(compressed));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erreur de capture.")));
    } finally {
      // Navigator.pop(context); // Fermer le dialog
      setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // setState(() => _isUpdating = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final body = {
      "action": "update_ov",
      "id": widget.worker.id,
      "name": _nameController.text,
      "function": _functionController.text,
      "phone": _phoneController.text,
      "price": _priceController.text,
      // "date": DateFormat('yyyy-MM-dd').format(_date),
      "photo": _photo != null ? base64Encode(_photo!) : null,
    };

    final res = await http.post(
      ConnBackend.connUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (!mounted) return;
    Navigator.pop(context); // Fermer le dialog
    // setState(() => _isUpdating = false);

    if (res.statusCode == 200 && jsonDecode(res.body)['success'] == true) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Erreur"),
          content: const Text("La modification a échoué."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
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

  Widget _buildField(
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
      appBar: AppBar(title: const Text("Modifier l'ouvrier")),
      body: _isCameraReady
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text("Date d'ajout : $dateFmt"),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField(
                          "Nom",
                          _nameController,
                          TextInputType.text,
                          (v) => v!.isEmpty ? "Requis" : null,
                        ),
                        _buildField(
                          "Fonction",
                          _functionController,
                          TextInputType.text,
                          (v) => v!.isEmpty ? "Requis" : null,
                        ),
                        _buildField(
                          "Prix journalier",
                          _priceController,
                          TextInputType.number,
                          (v) => v!.isEmpty ? "Requis" : null,
                        ),
                        _buildField(
                          "Téléphone",
                          _phoneController,
                          TextInputType.phone,
                          (v) => v!.isEmpty ? "Requis" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _cameraController != null
                      ? Container(
                          width: 200,
                          height: 150,
                          decoration: BoxDecoration(border: Border.all()),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CameraPreview(_cameraController!),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Prendre nouvelle photo"),
                  ),
                  const SizedBox(height: 10),
                  _photo != null
                      ? Image.memory(_photo!, width: 200, height: 150)
                      : _originalPhoto != null
                      ? Image.memory(_originalPhoto!, width: 200, height: 150)
                      : const Text("Aucune photo"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitUpdate,
                    child: const Text("Mettre à jour"),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
