import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class camerascreen extends StatefulWidget {
  const camerascreen({super.key});

  @override
  State<camerascreen> createState() => _camerascreenState();
}

class _camerascreenState extends State<camerascreen> {
  Rect? detectedRect;
  Rect? previousRect;
  late CameraController camController;
  bool isCameraInitialized = false;
  bool isFlashOn = false;
  bool isProcessing = false;
  String? imagePath;
  int stableCounter = 0;
  bool isBusy =false; // throttle
  late final TextRecognizer textRecognizer;


  bool _areRectsSimilar(Rect? r1, Rect r2, {double threshold = 20.0}) {
    if (r1 == null) return false;
    return (r1.left - r2.left).abs() < threshold &&
        (r1.top - r2.top).abs() < threshold &&
        (r1.width - r2.width).abs() < threshold &&
        (r1.height - r2.height).abs() < threshold;
  }


  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _initializeCamera();
  }


  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    camController = CameraController(cameras[0], ResolutionPreset.high);
    await camController.initialize();
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    await camController.startImageStream((CameraImage image) async {
      if (isBusy || isProcessing) return;
      isBusy = true;

      // throttle: wait 500ms before next detection
      Future.delayed(const Duration(milliseconds: 500), () {
        isBusy = false;
      });

      isProcessing = true;

      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
        final camera = camController.description;
        final imageRotation =
            InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
        final inputImageFormat =
            InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

        final metadata = InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        );

        final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);

        final recognizedText = await textRecognizer.processImage(inputImage);

        if (recognizedText.blocks.isNotEmpty) {
          final newBox = recognizedText.blocks.first.boundingBox;

          if (_areRectsSimilar(previousRect, newBox)) {
            stableCounter++;
          } else {
            stableCounter = 0;
          }

          previousRect = newBox;

          if (stableCounter >= 3) {
            setState(() {
              detectedRect = newBox;
            });
          }
        } else {
          stableCounter = 0;
          setState(() => detectedRect = null);
        }

      } catch (e) {
        print("Detection error: $e");
      } finally {
        isProcessing = false;
      }
    });


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
        title: const Text('Document Scanner'),
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

                  // Yellow rectangle (document detection)
                  if (detectedRect != null)
                    CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: DocumentBoxPainter(
                        rect: detectedRect!,
                        imageSize: Size(
                          camController.value.previewSize!.height,
                          camController.value.previewSize!.width,
                        ),
                        widgetSize: MediaQuery.of(context).size,
                      ),
                    ),

                  // Capture button
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: FloatingActionButton(
                        onPressed: _captureImage,
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

class DocumentBoxPainter extends CustomPainter {
  final Rect rect;
  final Size imageSize;
  final Size widgetSize;

  DocumentBoxPainter({
    required this.rect,
    required this.imageSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;

    final scaledRect = Rect.fromLTRB(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.right * scaleX,
      rect.bottom * scaleY,
    );

    final paint =
        Paint()
          ..color = Colors.yellow
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    canvas.drawRect(scaledRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
