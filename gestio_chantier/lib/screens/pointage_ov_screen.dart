import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import '../config/internet_verify.dart';
import '../models/ouvrier_model.dart';
import '../models/quinzaine_model.dart';
import '../config/conn_backend.dart';

class PageOuvrierPointage extends StatefulWidget {
  final Quinzaine q;
  const PageOuvrierPointage({super.key, required this.q});

  @override
  State<PageOuvrierPointage> createState() => _PageOuvrierPointageState();
}

class _PageOuvrierPointageState extends State<PageOuvrierPointage> {
  List<Worker> _workers = [];
  bool _isLoading = true;
  int _ttalOvProjet = 0;
  final DateTime _date = DateTime.now();
  bool _hasSaved = false;

  List<CameraDescription> _cameras = [];
  CameraLensDirection _currentDirection = CameraLensDirection.back;

  CameraController? _cameraController;
  bool _isCameraReady = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: false,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadWorkers();
  }

  // Future<void> _initCamera() async {
  //   final cameras = await availableCameras();
  //   final rear = cameras.firstWhere(
  //     // (c) => c.lensDirection == CameraLensDirection.back,
  //     (c) => c.lensDirection == CameraLensDirection.front,
  //   );
  //   _cameraController = CameraController(rear, ResolutionPreset.medium);
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

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final url = ConnBackend.withParams({
      "action": "list_ovPointage",
      "id": widget.q.id.toString(),
      "idp": widget.q.idProjet.toString(),
      "dateNow": DateFormat('dd-MM-yyyy').format(_date),
    });
    final resp = await http.get(url);
    final data = jsonDecode(resp.body) as List;
    setState(() {
      _workers = data.map((e) => Worker.fromJson(e)).toList();
      _ttalOvProjet = _workers.length;
      _isLoading = false;
    });
  }

  Future<void> _captureAndCompare(Worker w) async {
    if (!_isCameraReady) return;

    // Affiche le loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final photo = await _cameraController!.takePicture();
      final imageFile = File(photo.path);
      final inputImage = InputImage.fromFile(imageFile);
      // final faces = await _faceDetector.processImage(inputImage);

      // if (faces.isEmpty) {
      //   _showMessage("Aucun visage détecté !");
      //   return;
      // }

      // ✅ Pause de 2 secondes
      await Future.delayed(const Duration(milliseconds: 700));

      // Prendre la 2ᵉ photo automatiquement
      final secondShot = await _cameraController!.takePicture();

      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableTracking: true,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      final inputImage2 = InputImage.fromFilePath(secondShot.path);

      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Analyse d'image capturée en cours ...",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);
      final faces2 = await faceDetector.processImage(inputImage2);

      if (faces.isEmpty || faces2.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context); // Ferme le loader
        _showMessage(
          "Aucun visage détecté. Veuillez bien cadrer votre visage.",
        );
        return;
      }

      final f1 = faces.first;
      final f2 = faces2.first;

      // Comparaison vivante : mouvement ou clignement d'yeux
      final leftEyeDiff =
          ((f1.leftEyeOpenProbability ?? 0.0) -
                  (f2.leftEyeOpenProbability ?? 0.0))
              .abs();
      final rightEyeDiff =
          ((f1.rightEyeOpenProbability ?? 0.0) -
                  (f2.rightEyeOpenProbability ?? 0.0))
              .abs();

      final angleYDiff =
          ((f1.headEulerAngleY ?? 0.0) - (f2.headEulerAngleY ?? 0.0)).abs();
      final angleZDiff =
          ((f1.headEulerAngleZ ?? 0.0) - (f2.headEulerAngleZ ?? 0.0)).abs();

      if ((leftEyeDiff + rightEyeDiff) < 0.2 && (angleYDiff + angleZDiff) < 5) {
        if (!mounted) return;
        Navigator.pop(context); // Ferme le loader
        _showMessage(
          "Aucun signe de vie ou mouvement détecté. Veuillez cligner les yeux ou bouger légèrement la tête.",
        );
        return;
      }

      // Liveness detection très basique : il faut 1 visage avec yeux visibles
      // final face = faces.first;
      // if (face.leftEyeOpenProbability == null ||
      //     face.rightEyeOpenProbability == null ||
      //     face.leftEyeOpenProbability! < 0.5 ||
      //     face.rightEyeOpenProbability! < 0.5) {
      //   _showMessage(
      //     "Veuillez ouvrir les yeux pour prouver que vous êtes vivant.",
      //   );
      //   return;
      // }

      // Lecture image capturée
      final capturedBytes = await imageFile.readAsBytes();

      // Décodage image base64 depuis la base
      // final base64Ref = w.photo; // base64 String
      final refBytes = w.photo;

      final similarity = await _compareFaces(capturedBytes, refBytes);

      if (!mounted) return;
      Navigator.pop(context); // Ferme le loader

      if (similarity > 0.75) {
        final response = await http
            .post(
              ConnBackend.connUrl,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "action": "pointage_worker",
                "id_worker": w.id.toString(),
                "getDiffDay": getDifference(widget.q.debut),
              }),
            )
            .timeout(const Duration(seconds: 10));

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          _hasSaved = true;
          _showMessage("${w.name} pointé avec succès !", success: true);

          setState(() {
            _workers.removeWhere((worker) => worker.id == w.id);
            _ttalOvProjet = _workers.length;
          });
        } else {
          _showMessage(data['message']);
        }
      } else {
        _showMessage("Visage non reconnu ou différent !");
      }
    } on TimeoutException {
      if (mounted) {
        // Navigator.pop(context);
        _showMessage("Le serveur ne répond pas. Réessaye encore.");
      }
    } on SocketException {
      if (mounted) {
        // Navigator.pop(context);
        _showMessage(
          "Pas de connexion Internet ou votre connexion est instable.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Navigator.pop(context); // Ferme le loader
      _showMessage("Erreur lors du traitement !");
    }
  }

  Future<double> _compareFaces(Uint8List img1Bytes, Uint8List img2Bytes) async {
    final img1 = img.decodeImage(img1Bytes);
    final img2 = img.decodeImage(img2Bytes);
    if (img1 == null || img2 == null) return 0.0;

    // Redimensionner les images à une même taille
    final resized1 = img.copyResize(img1, width: 128, height: 128);
    final resized2 = img.copyResize(img2, width: 128, height: 128);

    // Extraire les données d'image sous forme de bytes RGBA
    final bytes1 = resized1.getBytes(); // → Uint8List
    final bytes2 = resized2.getBytes();

    if (bytes1.length != bytes2.length) return 0.0;

    double diff = 0;
    for (int i = 0; i < bytes1.length; i++) {
      diff += (bytes1[i] - bytes2[i]).abs();
    }

    final maxDiff = bytes1.length * 255.0;
    return 1 - (diff / maxDiff); // Plus proche de 1 → plus similaire
  }

  // void _showMessage(String msg) {
  //   if (!mounted) return;
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  // }
  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  String getDifference(String targetDateStr) {
    try {
      final now = DateTime.now();
      final targetDate = DateFormat('dd-MM-yyyy').parse(targetDateStr);

      final diff = now.difference(targetDate).inDays;

      if (diff == 0) {
        return "${diff + 1}";
      } else if (diff > 0) {
        return "${diff + 1}";
      } else {
        return "Dans ${-diff} jour${diff < -1 ? 's' : ''}";
      }
    } catch (e) {
      return "Date invalide";
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
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
            title: const Text("Pointage des ouvriers"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.cameraswitch),
                onPressed: _toggleCamera,
              ),
            ],

            // backgroundColor: Colors.blue[900],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Caméra en direct",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isCameraReady
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.55,
                                    height: 130,
                                    child: CameraPreview(_cameraController!),
                                  ),
                                )
                              : const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          Text(
                            "Nombre d'ouvrier à pointer : $_ttalOvProjet",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // if (_isCameraReady)
                    //   Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: ClipRRect(
                    //       borderRadius: BorderRadius.circular(10),
                    //       child: SizedBox(
                    //         width: MediaQuery.of(context).size.width * 0.6,
                    //         height: 150,
                    //         child: CameraPreview(_cameraController!),
                    //       ),
                    //     ),
                    //   ),
                    const Divider(thickness: 2),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _workers.length,
                        itemBuilder: (_, i) {
                          final w = _workers[i];
                          return Column(
                            children: [
                              ListTile(
                                // leading: CircleAvatar(
                                //   radius: 25,
                                //   backgroundImage: MemoryImage(
                                //     w.photo ,
                                //   ),
                                // ),
                                leading: ClipOval(
                                  child: Image.memory(
                                    w.photo,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  w.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  w.function,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () => _captureAndCompare(w),
                                  icon: const Icon(Icons.fingerprint),
                                  label: const Text("Pointer"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0D47A1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 8,
                                    ),
                                    minimumSize: const Size(80, 36),
                                  ),
                                ),
                              ),
                              const Divider(thickness: 1),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
