import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CreateClubPage extends StatefulWidget {
  @override
  _CreateClubPageState createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  String? _clubLogo;
  String _clubName = '';
  List<String> _clubSportsType = [];
  List<String> _clubMembers = [];

  Future<void> _uploadClubLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg'; // Generate a unique filename
      final storageReference =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);
      await storageReference.putFile(file);
      final downloadURL = await storageReference.getDownloadURL();
      setState(() {
        _clubLogo = downloadURL;
      });
    }
  }

  void _createClub() async {
    if (_clubLogo != null &&
        _clubName.isNotEmpty &&
        _clubSportsType.isNotEmpty) {
      // Create a new document in the "clubs" collection
      final clubData = {
        'clubLogo': _clubLogo,
        'clubName': _clubName,
        'clubSportsType': _clubSportsType,
        'clubMembers': _clubMembers,
      };
      await FirebaseFirestore.instance.collection('clubs').add(clubData);

      // Show a success message or navigate back to the previous page
    } else {
      // Show an error message or handle the case where required fields are not filled
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Club'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Club Logo
              GestureDetector(
                onTap: _uploadClubLogo,
                child: _clubLogo != null
                    ? Image.network(
                        _clubLogo!,
                        width: 100,
                        height: 100,
                      )
                    : Icon(
                        Icons.add_a_photo,
                        size: 100,
                      ),
              ),
              SizedBox(height: 16.0),
              // Club Name
              TextField(
                decoration: InputDecoration(
                  labelText: 'Club Name',
                ),
                onChanged: (value) {
                  setState(() {
                    _clubName = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              // Club Sports Type
              Text('Club Sports Type:'),
              Wrap(
                children: [
                  _buildSportsTypeCheckbox('Football'),
                  _buildSportsTypeCheckbox('Basketball'),
                  _buildSportsTypeCheckbox('Tennis'),
                  _buildSportsTypeCheckbox('Bowling'),
                  _buildSportsTypeCheckbox('Golf'),
                  _buildSportsTypeCheckbox('Archery'),
                  _buildSportsTypeCheckbox('Baseball'),
                  _buildSportsTypeCheckbox('Rugby'),
                  _buildSportsTypeCheckbox('Volleyball'),
                ],
              ),
              SizedBox(height: 16.0),
              // Club Members
              Text('Club Members:'),
              // Implement logic to handle club members (add/remove)

              ListView.builder(
                shrinkWrap: true,
                itemCount: _clubMembers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_clubMembers[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          _clubMembers.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16.0),
              // Submit Button
              ElevatedButton(
                onPressed: _createClub,
                child: Text('Create a Club+'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  primary: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportsTypeCheckbox(String sportsType) {
    final isSelected = _clubSportsType.contains(sportsType);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value != null && value) {
                _clubSportsType.add(sportsType);
              } else {
                _clubSportsType.remove(sportsType);
              }
            });
          },
        ),
        Text(sportsType),
      ],
    );
  }
}
