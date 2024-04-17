import 'dart:io';
import 'dart:js_util';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ReceiptPage extends StatefulWidget {
  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> cameras;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    setupCameras();
  }

  Future<void> setupCameras() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> takePicture() async {
    final path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

    await _controller.takePicture();

    return path;
  }

  Future<String> uploadPicture(String path) async {
    final ref = FirebaseStorage.instance.ref().child('receipts').child('${DateTime.now()}.png');
    await ref.putFile(File(path));

    return await ref.getDownloadURL();
  }

  Future<void> savePicture(String url) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('receipts').add({
      'url': url,
      'date': DateTime.now(),
    });
  }

  Future<void> deletePicture(DocumentSnapshot doc) async {
    await FirebaseStorage.instance.refFromURL(doc['url']).delete();
    await doc.reference.delete();
    setState (() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).collection('receipts').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }         
          return ListView(
            children: snapshot.data!.docs.isEmpty 
              ? <Widget>[Text(
                'No photos found.',
                style: TextStyle(fontSize: 30.0),
                )]
              : snapshot.data!.docs.map((doc) {
                  return ListTile(
                    leading: Container(
	                    width: 50.0,
                      height: 50.0,
                    	child: Image.network(doc['url'], fit: BoxFit.cover),
                    ),
                    title: Text(doc['date'].toDate().toString()),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Image.network(doc['url']),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Close'),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                }
                              ),
                            ],
                          );
                        },
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deletePicture(doc),
                  ),
                );
              }).toList(),
          );
        },
      ),
      floatingActionButton: Container(
        height: 80.0,
        width: 80.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.red[400],
            onPressed: () async {

              final picker = ImagePicker();
              final pickedFile = await picker.getImage(source: ImageSource.gallery);
      
              if (pickedFile != null) {
                final File file = File(pickedFile.path);
                try {
                  // Assuming uploadPicture is a function that uploads a file to Firebase Storage
                  // and returns the download URL
                  final url = await uploadPicture(file.path);
                  // Assuming savePicture is a function that saves the URL to Firestore
                  await savePicture(url);
                  setState(() {});
                } catch (e) {
                  print('Error: $e');
                }
              }
            },
            child: Icon(Icons.add_a_photo_rounded, size: 35.0),
          ),
        ),
      ),
    );
  }
}