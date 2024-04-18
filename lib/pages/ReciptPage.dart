import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dollar_dollar/pages/FullScreenImagePage.dart';
import 'package:dollar_dollar/pages/TakePictureScreen.dart';
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

  Future<String> uploadPicture(String path) async {
    final ref = FirebaseStorage.instance.ref().child('receipts').child('${DateTime.now()}.png');
    await ref.putFile(File(path));

    return await ref.getDownloadURL();
  }

  Future<void> savePicture(String url, String name) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('receipts').add({
      'url': url,
      'date': DateTime.now(),
      'name': name,
    });
  }

  Future<void> deletePicture(DocumentSnapshot doc) async {
    await FirebaseStorage.instance.refFromURL(doc['url']).delete();
    await doc.reference.delete();
    setState (() {});
  }

  Future<String?> getPhotoName(BuildContext context) async {
    String? photoName;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter receipt name'),
          content: TextField(
            onChanged: (value) {
              photoName = value;
            },
            decoration: InputDecoration(hintText: "Receipt name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    return photoName;
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
          return snapshot.data!.docs.isEmpty 
            ? Center(
              child: Text(
                'No receipts found.',
                style: TextStyle(fontSize: 30.0),
              ),
            )
            : ListView(
                children: snapshot.data!.docs.map((doc) {
                  return Card(
                    color: Colors.red[400],
                    elevation: 5,
                    child: ListTile(
                      leading: Container(
                        width: 50.0,
                        height: 50.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(doc['url'], fit: BoxFit.cover),
                        ),
                      ),
                      title: Text(doc['name']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImagePage(imageUrl: doc['url']),
                          ),
                        );                              
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deletePicture(doc),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 80.0,
            width: 80.0,
            child: FittedBox(
              child: FloatingActionButton(
                heroTag: 'camera1',
                backgroundColor: Colors.red[400],
                onPressed: () async {
                  final path = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakePictureScreen(controller: _controller),
                    ),
                  );
                  if (path != null) {
                    final photoName = await getPhotoName(context);
                    if (photoName != null && photoName.isNotEmpty) {
                      final url = await uploadPicture(path);
                      await savePicture(url, photoName);
                      setState(() {});
                    }
                  }
                },
                child: Icon(Icons.add_a_photo_rounded, size: 35.0),
              ),
            ),
          ),
          SizedBox(width: 10), // Add some spacing between the buttons
          Container(
            height: 80.0,
            width: 80.0,
            child: FittedBox(
              child: FloatingActionButton(
                heroTag: 'camera2',
                backgroundColor: Colors.red[400],
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.getImage(source: ImageSource.gallery);
      
                  if (pickedFile != null) {
                    final File file = File(pickedFile.path);
                    try {
                      final photoName = await getPhotoName(context);
                      if (photoName != null && photoName.isNotEmpty) {
                        final url = await uploadPicture(file.path);
                        await savePicture(url, photoName);
                        setState(() {});
                      }
                    } catch (e) {
                      print('Error: $e');
                    }
                  }
                },
                child: Icon(Icons.add_photo_alternate_rounded, size: 40.0),
              ),
            )
          ),
        ],
      ),
    );
  }
}