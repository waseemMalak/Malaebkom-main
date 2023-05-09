import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malaebkom/player.dart';
import 'package:malaebkom/owner_Reservations.dart';
import 'package:malaebkom/player_reservations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'my_drawer_header_owner.dart';
import 'owner_Reservations.dart';

class PlayerProfile extends StatefulWidget {
  const PlayerProfile({super.key});

  @override
  State<PlayerProfile> createState() => _PlayerProfileState();
}

class _PlayerProfileState extends State<PlayerProfile> {
  var currentPage = DrawerSections.profile;
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
              Colors.green,
              Colors.indigo,
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
                        new SizedBox(
                          height: _height / 30,
                        ),
                        new Padding(
                          padding: new EdgeInsets.only(top: _height / 20),
                          child: new Column(
                            children: <Widget>[
                              infoChild(_width, Icons.email,
                                  getCurrentUseremail().toString()),
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
                              infoChild(_width, Icons.password, '********'),
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                elevation: 5.0,
                                height: 40,
                                onPressed: () {
                                  CircularProgressIndicator();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Player(),
                                    ),
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
                                color: Colors.green,
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
                  HomePage(context);
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
    Navigator.of(context).pop();
  }
}

enum DrawerSections {
  home,
  profile,
  reservations,
}

Future<void> reservationPage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PlayerReservations(),
    ),
  );
}

Future<void> HomePage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => Player(),
    ),
  );
}

Widget headerChild(String header, int value) => new Expanded(
        child: new Column(
      children: <Widget>[
        new Text(header),
        new SizedBox(
          height: 8.0,
        ),
        new Text(
          '$value',
          style: new TextStyle(
              fontSize: 14.0,
              color: const Color(0xFF26CBE6),
              fontWeight: FontWeight.bold),
        )
      ],
    ));

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
              color: Colors.green,
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