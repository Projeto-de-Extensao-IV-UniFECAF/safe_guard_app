import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class MonitoringScreen extends StatefulWidget {
  @override
  _MonitoringScreenState createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  PoseDetector? _poseDetector;
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  final _storage = const FlutterSecureStorage();

  bool _fallDetected = false;
  Timer? _fallTimer;
  Timer? _autoDetectionTimer; // <-- Adicione este timer

  final String accountSid = 'SUA-SID-ACCOUNT';
  final String authToken = 'AUTHTOKEN';
  final String fromNumber = 'NUMERO DO TWILLIO';

  @override
  void initState() {
    super.initState();
    _poseDetector = PoseDetector(options: PoseDetectorOptions());
    _initializeCamera();
    // Inicia o timer para detecção automática a cada 15 segundos
    _autoDetectionTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _captureAndDetectPose(),
    );
  }

  @override
  void dispose() {
    _fallTimer?.cancel();
    _autoDetectionTimer?.cancel(); // <-- Cancele o timer ao sair
    _cameraController?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    _cameraController = CameraController(
      _cameras[0], // Câmera traseira
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _captureAndDetectPose() async {
    if (!_cameraController!.value.isInitialized) return;

    try {
      final picture = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(picture.path);

      final poses = await _poseDetector!.processImage(inputImage);

      for (final pose in poses) {
        final head = pose.landmarks[PoseLandmarkType.nose];
        final knee = pose.landmarks[PoseLandmarkType.leftKnee];
        if (head != null && knee != null && knee.y < head.y) {
          _sendAlertSMS();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagem processada com sucesso')),
      );
    } catch (e) {
      print('Erro ao capturar ou processar imagem: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: \$e')),
      );
    }
  }

  void _simulateFallDetection() async {
  setState(() => _fallDetected = true);
  await _sendAlertSMS();
}

  Future<void> _sendAlertSMS() async {
    final userName = await _storage.read(key: 'user_name') ?? 'Usuário';
    final responsiblePhone = await _storage.read(key: 'responsible_phone');
    if (responsiblePhone == null) return;

    final uri = Uri.https('api.twilio.com', '/2010-04-01/Accounts/$accountSid/Messages.json');

final response = await http.post(
  uri,
  headers: {
    'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
    'Content-Type': 'application/x-www-form-urlencoded',
  },
  body: {
    'From': fromNumber,
    'To': '+55$responsiblePhone',
    'Body': 'Alerta: uma possível queda agora há pouco.',
  },
);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        response.statusCode == 201 || response.statusCode == 200
            ? 'Alerta enviado com sucesso'
            : 'Erro ao enviar alerta: \${response.body}',
      )),
    );

    setState(() => _fallDetected = false);
  }

  void _cancelAlert() {
    _fallTimer?.cancel();
    setState(() => _fallDetected = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerta cancelado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Monitoramento')),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          if (_fallDetected)
            _buildFallDetectedOverlay()
          else
            _buildControlButtons()
        ],
      ),
    );
  }

  Widget _buildFallDetectedOverlay() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Detectamos uma queda. Você está bem?',
            style: TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _cancelAlert,
            child: const Text('Cancelar Alerta'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: _captureAndDetectPose,
            child: const Text('Detectar Pose Agora'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _simulateFallDetection,
            child: const Text('Simular Queda'),
          ),
        ],
      ),
    );
  }
}
