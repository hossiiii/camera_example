import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// 実行されるmain関数
main() {
  runApp(MyApp());
}

// Stateを持たないWidgetオブジェクト
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

// Stateを持つWidgetオブジェクト
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// StatefulWidgetで管理されるStateオブジェクト
class _MyHomePageState extends State<MyHomePage> {
  CameraController controller;
  String imagePath;

  Future<void> _cameraInitialize() async {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription camera = cameras[0];
    controller = CameraController(camera, ResolutionPreset.high);
    await controller.initialize();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _cameraInitialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera example'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
          ),
          _captureIconWidget(),
          _thumbnailWidget(),
        ],
      ),
    );
  }

  // カメラのプレビューWidget
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return null;
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  // サムネイルWidget
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: imagePath == null
            ? null
            : SizedBox(
                child: Image.file(File(imagePath)),
                width: 64.0,
                height: 64.0,
              ),
      ),
    );
  }

  // カメラのアイコンWidget
  Widget _captureIconWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null && controller.value.isInitialized
              ? () async {
                  imagePath = await takePicture();
                  setState(() {});
                }
              : null,
        ),
      ],
    );
  }

  // タイムスタンプを返す関数
  String timestamp() {
    return DateTime.now().year.toString() +
        DateTime.now().month.toString() +
        DateTime.now().day.toString() +
        DateTime.now().hour.toString() +
        DateTime.now().minute.toString() +
        DateTime.now().second.toString();
  }

  // カメラで撮影した画像を保存する関数(非同期)
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }

    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      return null;
    }
    print(filePath);
    return filePath;
  }
}
