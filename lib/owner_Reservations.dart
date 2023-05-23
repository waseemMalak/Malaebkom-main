import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:malaebkom/owner_profile.dart';
import 'package:malaebkom/field_owner.dart';
import 'login.dart';
import 'my_drawer_header_owner.dart';

class ownerReservations extends StatefulWidget {
  const ownerReservations({super.key});

  @override
  State<ownerReservations> createState() => _ownerReservationsState();
}

class _ownerReservationsState extends State<ownerReservations> {
  var currentPage = DrawerSections.reservations;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text("My Reservations"),
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
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('fields').get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error occurred.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final fields = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];
              final fieldId = field.id;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('fields')
                    .doc(fieldId)
                    .collection('matches')
                    .where('fieldOwnerId',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error occurred.'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final matches = snapshot.data?.docs ?? [];

                  return Column(
                    children: [
                      Divider(
                        color: Colors.grey,
                        height: 1,
                        thickness: 1,
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 1,
                        thickness: 1,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final match = matches[index];
                          final matchHeldAt = match['matchHeldAt'];
                          final price = match['price'];
                          final duration = match['duration'];
                          final startingHour = match['startingHour'];
                          final matchDate = match['matchDate'];
                          final players = match['playersJoined'];

                          return ListTile(
                            title: Text(
                                'Reservation at: $matchDate at $startingHour'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  color: Colors.black,
                                  height: 1,
                                  thickness: 1,
                                ),
                                Text('Match Held At: $matchHeldAt'),
                                Text('Price: $price JOD'),
                                Text('Duration: $duration'),
                                Text('Players Joined: $players'),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
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
                  profilePage(context);
                } else if (id == 3) {
                  currentPage = DrawerSections.reservations;
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

Future<void> profilePage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ownerProfile(),
    ),
  );
}
