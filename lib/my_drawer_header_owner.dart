import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({Key? key}) : super(key: key);

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserImage();
  }

  Future<void> fetchUserImage() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> ds = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      setState(() {
        imageUrl = ds.get('image_url');
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[600],
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageUrl != null && imageUrl != 'assets/images/def.jpg'
                    ? NetworkImage(imageUrl!) as ImageProvider<Object>
                    : AssetImage('assets/images/def.jpg'),
              ),
            ),
          ),
          Container(
            child: FutureBuilder<String?>(
              future: getCurrentUserName(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final username = snapshot.data!;
                  return Text(
                    '$username',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          Text(
            getCurrentUseremail().toString(),
            style: TextStyle(color: Colors.white, fontSize: 14),
          )
        ],
      ),
    );
  }
}

String? getCurrentUseremail() {
  final User? user = _auth.currentUser;
  if (user != null) {
    return user.email;
  } else {
    return 'User not logged in';
  }
}

Future<String?> getCurrentUserName() async {
  String? uName;
  try {
    DocumentSnapshot<Map<String, dynamic>> ds = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    uName = ds.get('userName');
  } catch (e) {
    print(e.toString());
  }
  return uName;
}
