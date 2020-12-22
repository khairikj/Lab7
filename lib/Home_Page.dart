import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;
  final picker = ImagePicker();
  String _uploadFileURL;
  CollectionReference imgColRef;

  void initState() {
    imgColRef = FirebaseFirestore.instance.collection('imageURLs');
    super.initState();
  }

  Future _openGallery(BuildContext context) async{
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      _image = File(picture.path);
    });

    if (picture.path == null) retrieveLostData();
    Navigator.of(context).pop();
  }

  Future _openCamera(BuildContext context) async{
    var picture = await picker.getImage(source: ImageSource.camera);
    this.setState(() {
      _image = File(picture.path);
    });
    Navigator.of(context).pop();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if(response.isEmpty) {
      return;
    }
    if(response.file != null) {
      setState(() {
        _image = File(response.file.path);
      });
    } else {
      print(response.file);
    }
  }

  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage().ref().child('images/${Path.basename(_image.path)}');

    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print ('File uploaded');

    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadFileURL = fileURL;
      });
    }).whenComplete(() async {
      await imgColRef.add({'url':_uploadFileURL});
      print('link added to database');
    });
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Make a choice'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text('Gallery'),
                onTap: () {
                  _openGallery(context);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                child: Text('Camera'),
                onTap: () {
                  _openCamera(context);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 40,),
                Text("Gallery", style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40,),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    child: Column(
                      children: <Widget>[
                         _image == null ? Text('No Image Selected') : Image.file(_image, width: 300, height: 300,)
                      ],
                    ),
                  ),
                ),
              ],
            )
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_a_photo),
          onPressed: (){
            _showChoiceDialog(context);
          },
        ),
    );
  }
}

