import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malaebkom/player_profile.dart';
import 'package:malaebkom/player_reservations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player.dart';

import 'login.dart';
import 'my_drawer_header_owner.dart';
import 'owner_Reservations.dart';

class PlayerViewField extends StatefulWidget {
  const PlayerViewField({super.key});

  @override
  State<PlayerViewField> createState() => _PlayerViewFieldState();
}

class _PlayerViewFieldState extends State<PlayerViewField> {
  List<DocumentSnapshot> fields = []; // list of all fields in firestore
  List<DocumentSnapshot> filteredFields = []; // list of fields after filtering
  GlobalKey<AutoCompleteTextFieldState<String>> searchKey =
      GlobalKey(); // key for search bar
  TextEditingController searchController =
      TextEditingController(); // controller for search bar

  @override
  void initState() {
    super.initState();
    getFields();
  }

  void getFields() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('fields').get();
    print(snapshot); // print the snapshot
    setState(() {
      fields = snapshot.docs;
      filteredFields = fields;
    });
  }

  // function to filter fields by name
  void filterFields(String query) {
    List<DocumentSnapshot> filteredList = [];
    fields.forEach((field) {
      String fieldName = field['fieldName'].toString().toLowerCase();
      if (fieldName.contains(query.toLowerCase())) {
        filteredList.add(field);
      }
    });
    setState(() {
      filteredFields = filteredList;
    });
  }

  var currentPage = DrawerSections.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text("Fields"),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SimpleAutoCompleteTextField(
              key: searchKey,
              controller: searchController,
              suggestions:
                  fields.map((e) => e['fieldName'].toString()).toList(),
              textChanged: (value) {
                filterFields(value);
              },
              decoration: InputDecoration(
                labelText: 'Search by field name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredFields.isEmpty
                ? Center(child: Text('No fields found'))
                : ListView.builder(
                    itemCount: filteredFields.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot field = filteredFields[index];
                      return ListTile(
                        title: Text(field['fieldName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: ${field['price']}'),
                          ],
                        ),
                      );
                    },
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
                  profilePage(context);
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

Future<void> HomePage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const Player(),
    ),
  );
}

Future<void> reservationPage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const PlayerReservations(),
    ),
  );
}

Future<void> profilePage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => PlayerProfile(),
    ),
  );
}
