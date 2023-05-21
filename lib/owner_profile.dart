import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malaebkom/owner_Reservations.dart';
import 'package:malaebkom/field_owner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'my_drawer_header_owner.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class EditProfileDialog extends StatefulWidget {
  final String email;
  final String phone;

  EditProfileDialog({required this.email, required this.phone});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            // Call a function to update the user's email and phone number
            saveProfileChanges(
              _emailController.text,
              _phoneController.text,
            );
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> saveProfileChanges(String email, String phone) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'email': email,
        'phone': phone,
      });
    } catch (e) {
      print('Error updating profile: $e');
    }
  }
}

class ownerProfile extends StatefulWidget {
  const ownerProfile({super.key});

  @override
  State<ownerProfile> createState() => _ownerProfileState();
}

class _ownerProfileState extends State<ownerProfile> {
  var currentPage = DrawerSections.profile;
  //final ref= FirbaseDatabase.instance.ref('user');

  Future<int> getFieldCount() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('fields')
        .where('userId', isEqualTo: currentUserId)
        .get();

    return querySnapshot.size;
  }

  Future<void> fetchFieldCount() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .where('userId', isEqualTo: currentUserId)
          .get();

      setState(() {
        fieldCount = Future.value(querySnapshot.size);
      });
    } catch (e) {
      print('Error fetching field count: $e');
      setState(() {
        fieldCount = Future.error(e.toString());
      });
    }
  }

  late Future<int> fieldCount;

  @override
  void initState() {
    super.initState();
    fieldCount = getFieldCount();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return new Container(
      child: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
                gradient: new LinearGradient(colors: [
              const Color(0x0F26CBE6),
              const Color(0xFF26CBC0),
            ], begin: Alignment.topCenter, end: Alignment.center)),
          ),
          new Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green[600],
              title: Text("Profile"),
              actions: [
                IconButton(
                  onPressed: () {
                    logout(context);
                  },
                  icon: Icon(
                    Icons.logout,
                  ),
                )
              ],
            ),
            drawer: Drawer(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      MyHeaderDrawer(),
                      MyDrawerList(),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            body: new Container(
              child: new Stack(
                children: <Widget>[
                  new Align(
                    alignment: Alignment.center,
                    child: new Padding(
                      padding: new EdgeInsets.only(top: _height / 15),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new CircleAvatar(
                            backgroundImage:
                                new AssetImage('assets/images/def.jpg'),
                            radius: _height / 10,
                          ),
                          new SizedBox(
                            height: _height / 30,
                          ),
                          new Container(
                            child: FutureBuilder<String?>(
                              future: getCurrentUserName(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final username = snapshot.data!;
                                  return Text(
                                    '$username',
                                    style: new TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(top: _height / 2.2),
                    child: new Container(
                      color: Colors.white,
                    ),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(
                        top: _height / 2.6,
                        left: _width / 20,
                        right: _width / 20),
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          decoration: new BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                new BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 2.0,
                                    offset: new Offset(0.0, 2.0))
                              ]),
                          child: new Padding(
                            padding: new EdgeInsets.all(_width / 20),
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  headerChild('Number of Fields', fieldCount)
                                ]),
                          ),
                        ),
                        new Padding(
                          padding: new EdgeInsets.only(top: _height / 20),
                          child: new Column(
                            children: <Widget>[
                              infoChild(
                                  _width, Icons.email, getCurrentUseremail()),
                              new Container(
                                child: FutureBuilder<String?>(
                                  future: getCurrentphone(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final phone = snapshot.data!;
                                      return infoChild(
                                          _width, Icons.call, '$phone');
                                    } else if (snapshot.hasError) {
                                      return infoChild(_width, Icons.call,
                                          'Error: ${snapshot.error}');
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                elevation: 5.0,
                                height: 40,
                                onPressed: () async {
                                  final email = await getCurrentUseremail();
                                  final phone = await getCurrentphone();

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return EditProfileDialog(
                                        email: email ?? '',
                                        phone: phone ?? '',
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      '  Edit Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                color: Color(0xFF26CBEF),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  Widget MyDrawerList() {
    return Container(
        padding: EdgeInsets.only(
          top: 15,
        ),
        child: Column(
          children: [
            menuItem(1, "Home", Icons.home,
                currentPage == DrawerSections.home ? true : false),
            menuItem(2, "Profile", Icons.person,
                currentPage == DrawerSections.profile ? true : false),
            menuItem(3, "Reservations", Icons.calendar_today,
                currentPage == DrawerSections.reservations ? true : false),
          ],
        ));
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    return Material(
        color: selected ? Colors.grey[300] : Colors.transparent,
        child: InkWell(
            onTap: () {
              setState(() {
                if (id == 1) {
                  currentPage = DrawerSections.home;
                  homePage(context);
                } else if (id == 2) {
                  currentPage = DrawerSections.profile;
                } else if (id == 3) {
                  currentPage = DrawerSections.reservations;
                  reservationPage(context);
                }
              });
            },
            child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Icon(
                      icon,
                      size: 20,
                      color: Colors.black,
                    )),
                    Expanded(
                        flex: 3,
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ))
                  ],
                ))));
  }
}

enum DrawerSections {
  home,
  profile,
  reservations,
}

Future<void> homePage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => FieldOwnerApp()));
}

Future<void> reservationPage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ownerReservations(),
    ),
  );
}

// Updated headerChild widget:
Widget headerChild(String header, Future<int>? value, {int fallback = 0}) =>
    Expanded(
      child: Column(
        children: <Widget>[
          Text(header),
          SizedBox(height: 8.0),
          FutureBuilder<int>(
            future: value,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final fieldValue = snapshot.data!;
                return Text(
                  '$fieldValue',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: const Color(0xFF26CBE6),
                    fontWeight: FontWeight.bold,
                  ),
                );
              } else if (snapshot.hasError) {
                print('Error retrieving field count: ${snapshot.error}');
              }
              return Text(
                '$fallback',
                style: TextStyle(
                  fontSize: 14.0,
                  color: const Color(0xFF26CBE6),
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );

Widget infoChild(double width, IconData icon, data) => new Padding(
      padding: new EdgeInsets.only(bottom: 8.0),
      child: new InkWell(
        child: new Row(
          children: <Widget>[
            new SizedBox(
              width: width / 10,
            ),
            new Icon(
              icon,
              color: const Color(0xFF26CBE6),
              size: 36.0,
            ),
            new SizedBox(
              width: width / 20,
            ),
            new Text(data)
          ],
        ),
        onTap: () {
          print('Info Object selected');
        },
      ),
    );

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

Future<String?> getCurrentphone() async {
  String? uName;
  try {
    DocumentSnapshot<Map<String, dynamic>> ds = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    uName = ds.get('phone');
  } catch (e) {
    print(e.toString());
  }

  return uName;
}
