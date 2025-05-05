import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class camerascreen extends StatefulWidget {
  const camerascreen({super.key});

  @override
  State<camerascreen> createState() => _camerascreenState();
}

class _camerascreenState extends State<camerascreen> {
  late CameraController camController;
  bool isCameraInitialized = false;
  bool isFlashOn = false;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    camController = CameraController(cameras[0], ResolutionPreset.high);
    await camController.initialize();

    if (!mounted) return;
    setState(() {
      isCameraInitialized = true;
    });
  }

  Future<void> _captureImage() async {
    if (!camController.value.isInitialized) return;

    final picture = await camController.takePicture();
    setState(() {
      imagePath = picture.path;
    });

    // You can return the image path to homepage if needed
    // Navigator.pop(context, imagePath);
  }

  @override
  void dispose() {
    camController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              if (!camController.value.isInitialized) return;

              setState(() {
                isFlashOn = !isFlashOn;
              });

              await camController.setFlashMode(
                isFlashOn ? FlashMode.torch : FlashMode.off,
              );
            },
          ),
        ],
      ),
      body:
          isCameraInitialized
              ? Stack(
                children: [
                  Positioned.fill(child: CameraPreview(camController)),
                  // Capture button at bottom center
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: FloatingActionButton(
                        onPressed: _captureImage,
                        backgroundColor: Colors.white,
                        shape: CircleBorder(),
                        child: Icon(Icons.camera_alt, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
