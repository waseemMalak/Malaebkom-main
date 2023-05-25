import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'my_drawer_header_owner.dart';
import 'player_view_fields.dart';
import 'player_view_matches.dart';
import 'package:intl/intl.dart';

class PlayerReservations extends StatefulWidget {
  const PlayerReservations({Key? key}) : super(key: key);

  @override
  State<PlayerReservations> createState() => _PlayerReservationsState();
}

class _PlayerReservationsState extends State<PlayerReservations> {
  var currentPage = DrawerSections.reservations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text("My Reservations"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(
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
                const MyHeaderDrawer(),
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
                    .where('matchCreatorId',
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
                        color: Colors.black,
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

                          // Convert matchDate and startingHour to DateTime objects
                          final matchDateTime =
                              DateFormat('dd MMM yyyy').parse(matchDate);
                          final startingDateTime =
                              DateFormat('HH:mm').parse(startingHour);

                          // Calculate the current time
                          final now = DateTime.now();

                          // Calculate the difference between the current time and matchDateTime
                          final difference = matchDateTime.difference(now);

                          // Check if the difference is 24 hours or more
                          final isCancellable = difference.inHours >= 24;

                          return Stack(
                            children: [
                              ListTile(
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
                                    Text('Players: $players'),
                                  ],
                                ),
                              ),
                              if (isCancellable) // Only show the button if it's cancellable
                                Positioned(
                                  bottom: 1.0,
                                  right: 8.0,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Cancel Reservation'),
                                            content: Text(
                                                'Are you sure you want to cancel this reservation?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (match.reference != null) {
                                                    match.reference.delete();
                                                  }
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Yes'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text('Cancel Reservation'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                    ),
                                  ),
                                ),
                            ],
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
      padding: const EdgeInsets.only(
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
          menuItem(4, "Fields", Icons.stadium,
              currentPage == DrawerSections.viewFields ? true : false),
          menuItem(5, "Matches", Icons.sports_score_sharp,
              currentPage == DrawerSections.viewMatches ? true : false),
        ],
      ),
    );
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
              profilePage(context);
            } else if (id == 3) {
              currentPage = DrawerSections.reservations;
            } else if (id == 4) {
              currentPage = DrawerSections.viewFields;
              viewFieldsPage(context);
            } else if (id == 5) {
              currentPage = DrawerSections.viewMatches;
              viewMatchesPage(context);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DrawerSections {
  home,
  profile,
  reservations,
  viewFields,
  viewMatches,
}
