import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gmail_clone/widget/user_image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:notify_inapp/notify_inapp.dart';

class VideoRecord extends StatefulWidget {
  const VideoRecord({Key? key}) : super(key: key);

  @override
  _VideoRecordState createState() => _VideoRecordState();
}

class _VideoRecordState extends State<VideoRecord> {
  late CameraController controller;
  XFile? videoFile;
  VideoPlayerController? videoController;
  bool isRecording = false;
  bool isRecordingFinished = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    setState(() {});
  }

  Future<void> startRecording() async {
    setState(() {
      isRecording = true;
      isRecordingFinished = false;
    });
    await controller.startVideoRecording();
    setState(() {});
  }

  Future<void> stopRecording() async {
    videoFile = await controller.stopVideoRecording();

    // Save video to gallery
    final result = await ImageGallerySaver.saveFile(videoFile!.path);

    // Check if the video was saved successfully
    if (result['isSuccess']) {
      // Save video to firestore
      saveVideoToFirestore();
      // Delete the video file from cache
      // File(videoFile!.path).deleteSync();
    }

    videoController = VideoPlayerController.file(File(videoFile!.path))
      ..initialize().then((_) {
        setState(() {});
        videoController!.play();
      });

    ///

    ///
    setState(() {
      isRecording = false;
      isRecordingFinished = true;
    });
    Notify notify = Notify();
    // ignore: use_build_context_synchronously
    notify.show(
      context,
      Container(
        color: Theme.of(context).secondaryHeaderColor,
        width: double.infinity,
        height: 70,
        child: const Center(child: Text('Video Saved to Gallery and Server')),
      ),
    );
  }

  void saveVideoToFirestore() async {
    PickImageWidget pickImageWidget = PickImageWidget();
    print(222222);
    await pickImageWidget.uploadVideoToFireSrore(File(videoFile!.path));
    print(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: <Widget>[
              CameraPreview(controller),
              if (videoFile != null)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: videoController!.value.size.width,
                      height: videoController!.value.size.height,
                      child: VideoPlayer(videoController!),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          isRecording
              ? const Text('Again click on the camera icon to Stop Recording')
              : const Text('Click on the camera icon to start Recording'),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!controller.value.isRecordingVideo) {
            startRecording();
          } else {
            stopRecording();
          }
        },
        child: Icon(
            controller.value.isRecordingVideo ? Icons.stop : Icons.videocam),
      ),
    );
  }
}
