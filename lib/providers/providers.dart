import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cameraProvider = FutureProvider<CameraController>((ref) async {
  final cameras = await availableCameras();
  if (cameras.isEmpty) {
    throw Exception("No Cameras available");
  }

  final cameraController =
      CameraController(cameras[0], ResolutionPreset.medium);

  // Initialize the camera controller
  await cameraController.initialize();

  return cameraController;
});
