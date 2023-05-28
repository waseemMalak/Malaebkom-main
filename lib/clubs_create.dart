import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'clubs_view_create.dart';

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
    if (_clubLogo == null) {
      // Show validation error message using a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red, // Set the background color to red
          content: Text('Club logo is required.'),
        ),
      );
      return;
    }
    if (_clubName.isEmpty) {
      // Show validation error message using a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red, // Set the background color to red
          content: Text('club name is are required.'),
        ),
      );
      return;
    }
    if (_clubSportsType.isEmpty) {
      // Show validation error message using a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red, // Set the background color to red
          content: Text('Club sports type is required.'),
        ),
      );
      return;
    }

    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Retrieve the user's name from the "users" collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Check if the user exists in the "users" collection
      if (userSnapshot.exists) {
        // Retrieve the user's name
        String clubCreator = userSnapshot['userName'];

        // Retrieve the user's ID
        String clubCreatorId = currentUser.uid;

        // Create a new document in the "clubs" collection
        final clubData = {
          'clubLogo': _clubLogo,
          'clubName': _clubName,
          'clubSportsType': _clubSportsType,
          'clubMembers': _clubMembers,
          'clubCreator': clubCreator,
          'clubCreatorId': clubCreatorId,
        };
        DocumentReference newClubRef =
            await FirebaseFirestore.instance.collection('clubs').add(clubData);

        // Show a success message or navigate to the ClubsViewCreate page
        if (newClubRef.id != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ClubsViewCreate(),
            ),
          );
        } else {
          // Handle error creating the club document
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red, // Set the background color to red
              content: Text('Failed to create the club. Please try again.'),
            ),
          );
        }
      }
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
