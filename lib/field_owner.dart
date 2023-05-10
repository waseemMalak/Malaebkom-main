import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malaebkom/owner_profile.dart';
import 'package:malaebkom/owner_Reservations.dart';
import 'package:malaebkom/field_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login.dart';
import '../my_drawer_header_owner.dart';
import 'addNewField.dart';

class Field {
  late String fieldId;
  final String fieldName;
  final String imagePath;
  final double price;
  final List<String> fieldServices;
  final List<String> fieldSports;

  Field({
    required this.fieldName,
    required this.imagePath,
    required this.fieldId,
    required this.price,
    required this.fieldServices,
    required this.fieldSports,
  });
}

class FieldOwnerApp extends StatelessWidget {
  final List<Field> fields = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Owner App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FieldOwner(fields: fields),
    );
  }
}

class FieldOwner extends StatefulWidget {
  final List<Field> fields;

  FieldOwner({required this.fields, Key? key}) : super(key: key);

  @override
  State<FieldOwner> createState() => _FieldOwnerState();
}

enum DrawerSections { home, profile, reservations }

class _FieldOwnerState extends State<FieldOwner> {
  var currentPage = DrawerSections.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text("Home"),
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
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Fields',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('fields')
                    .where('userId',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final fieldName = documents[index]['fieldName'];
                      final fieldImages = documents[index]['fieldImages'];
                      final fieldId = documents[index].id;
                      final price = documents[index]['price'];
                      // final fieldServices = documents[index]['fieldServices'];
                      final fieldServices = documents[index]['fieldServices'];
                      final services = fieldServices is String
                          ? [fieldServices]
                          : fieldServices.cast<String>();
                      final fieldSports = documents[index]['fieldSports'];
                      final sports = fieldSports is String
                          ? [fieldSports]
                          : fieldSports.cast<String>();

                      return Container(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fieldName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                print(documents[index].id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FieldDetails(
                                      field: Field(
                                        fieldName: fieldName,
                                        imagePath: fieldImages[0],
                                        fieldId: fieldId,
                                        price: price,
                                        fieldServices: services,
                                        fieldSports: sports,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(fieldImages[0]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Opacity(
                                      opacity: 0.4,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Opacity(
                                        opacity: 0.9,
                                        child: Container(
                                          color: Colors.black,
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'View details',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          newfieldPage(context); // TODO: Implement logic for adding new field
        },
        icon: Icon(Icons.add),
        label: Text('Add new Field'),
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
          ),
        ),
      ),
    );
  }
}

class FieldCard extends StatelessWidget {
  final Field field;

  FieldCard({required this.field});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Field Details'),
                content: Text(field.fieldName),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.fieldName, // Display field name above the image
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Image.asset(
                    field.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Opacity(
                        opacity: 0.9,
                        child: Container(
                          color: Colors.black,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'View details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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

Future<void> profilePage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ownerProfile(),
    ),
  );
}

Future<void> newfieldPage(BuildContext context) async {
  CircularProgressIndicator();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FieldOwnerForm(),
    ),
  );
}
