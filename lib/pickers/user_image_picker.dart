import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  //const UserImagePicker({Key? key}) : super(key: key);
  UserImagePicker(this.imgePickfn);
  final Function(File pickedImage) imgePickfn;
  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = File(pickedFile!.path);
    });
    widget.imgePickfn(File(pickedFile!.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      CircleAvatar(
        radius: 62,
        backgroundColor: Colors.green,
        child: CircleAvatar(
          radius: 60,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : const AssetImage('assets/images/def.jpg') as ImageProvider,
        ),
      ),
      TextButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.image, color: Colors.green),
        label: const Text('Add Image',
            style: TextStyle(
              color: Colors.green,
            )),
      ),
    ]);
  }
}
