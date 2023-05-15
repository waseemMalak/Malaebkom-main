import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malaebkom/player_profile.dart';
import 'package:malaebkom/player_reservations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player.dart';
import 'player_view_field_details.dart';
import 'login.dart';
import 'my_drawer_header_owner.dart';
import 'owner_Reservations.dart';

class PlayerViewField extends StatefulWidget {
  const PlayerViewField({super.key});

  @override
  State<PlayerViewField> createState() => _PlayerViewFieldState();
}

class _PlayerViewFieldState extends State<PlayerViewField> {
  List<DocumentSnapshot> fields = [];
  List<DocumentSnapshot> filteredFields = [];
  GlobalKey<AutoCompleteTextFieldState<String>> searchKey = GlobalKey();
  TextEditingController searchController = TextEditingController();

  bool _sortAscending = true;

  void _sortFields() {
    setState(() {
      _sortAscending = !_sortAscending;
    });
  }

  @override
  void initState() {
    super.initState();
    getFields();
  }

  void getFields() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('fields').get();
    setState(() {
      fields = snapshot.docs;
      filteredFields = fields;
    });
  }

  void filterFields(String query) {
    List<DocumentSnapshot> filteredList = [];
    List<String> fieldNames =
        fields.map((e) => e['fieldName'].toString()).toList();
    fieldNames.forEach((fieldName) {
      if (fieldName.toLowerCase().contains(query.toLowerCase())) {
        fields.forEach((field) {
          if (field['fieldName'].toString().toLowerCase() ==
              fieldName.toLowerCase()) {
            filteredList.add(field);
          }
        });
      }
    });
    setState(() {
      filteredFields = filteredList;
    });
  }

  var currentPage = DrawerSections.viewFields;

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
                labelStyle: TextStyle(
                  color: Colors.green,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.green),
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
                        contentPadding: EdgeInsets.all(10),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              field['fieldName'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Image.network(
                                    field['fieldImages'][0],
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.8),
                                            Colors.transparent
                                          ],
                                        ),
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      height: 50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Starting From: ${field['price'].toString()} JD',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PlayerViewFieldDetials(
                                                          field: field),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                            child: Text('Book now'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
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
            menuItem(4, "Fields", Icons.stadium,
                currentPage == DrawerSections.viewFields ? true : false),
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
                } else if (id == 4) {
                  currentPage = DrawerSections.viewFields;
                  viewFieldsPage(context);
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
  viewFields,
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

Future<void> viewFieldsPage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => PlayerViewField(),
    ),
  );
}
