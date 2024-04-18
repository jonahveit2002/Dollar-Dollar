import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:dollar_dollar/pages/ReciptPage.dart';


class TakePictureScreen extends StatefulWidget {
  final CameraController controller;

  const TakePictureScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder<void>(
            future: widget.controller.initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Align(
                  alignment: Alignment(0, -0.4), // Adjust this value to move the preview up or down
                  child: CameraPreview(widget.controller),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80.0,
                width: 80.0,
                child: FittedBox(
                  child: FloatingActionButton(
                    heroTag: 'camera2',
                    backgroundColor: Colors.red[400],
                    onPressed: () async {
                      try {
                        final image = await widget.controller.takePicture();
                        Navigator.pop(context, image.path);
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Icon(Icons.camera_alt_rounded, size: 35.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}