// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:malaebkom/owner_profile.dart';
// import 'package:malaebkom/owner_Reservations.dart';

// import 'login.dart';
// import 'my_drawer_header_owner.dart';

// class Field {
//   final String name;
//   final String imagePath;

//   Field({required this.name, required this.imagePath});
// }

// class FieldOwnerApp extends StatelessWidget {
//   final List<Field> fields = [
//     Field(name: 'Field 1', imagePath: 'assets/images/stadium1.jpg'),
//     Field(name: 'Field 2', imagePath: 'assets/images/stadium1.jpg'),
//     Field(name: 'Field 3', imagePath: 'assets/images/stadium1.jpg'),
//     Field(name: 'Field 4', imagePath: 'assets/images/stadium1.jpg'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Field Owner App',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: FieldOwner(fields: fields),
//     );
//   }
// }

// class FieldOwner extends StatefulWidget {
//   final List<Field> fields;

//   FieldOwner({required this.fields, Key? key}) : super(key: key);

//   @override
//   State<FieldOwner> createState() => _FieldOwnerState();
// }

// enum DrawerSections { home, profile, reservations }

// class _FieldOwnerState extends State<FieldOwner> {
//   var currentPage = DrawerSections.home;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green[600],
//         title: Text("Home"),
//         actions: [
//           IconButton(
//             onPressed: () {
//               logout(context);
//             },
//             icon: Icon(
//               Icons.logout,
//             ),
//           )
//         ],
//       ),
//       drawer: Drawer(
//         child: SingleChildScrollView(
//           child: Container(
//             child: Column(
//               children: [
//                 MyHeaderDrawer(),
//                 MyDrawerList(),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'My Fields',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16.0),
//             Expanded(
//               // Use Expanded widget to allow field list to take up all available vertical space
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.black, width: 1.0),
//                 ),
//                 child: ListView.builder(
//                   itemCount: widget.fields.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     final field = widget.fields[index];
//                     return FieldCard(field: field);
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           // TODO: Implement logic for adding new field
//         },
//         icon: Icon(Icons.add),
//         label: Text('Add new Field'),
//       ),
//     );
//   }

//   Future<void> logout(BuildContext context) async {
//     CircularProgressIndicator();
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LoginPage(),
//       ),
//     );
//   }

//   Widget MyDrawerList() {
//     return Container(
//         padding: EdgeInsets.only(
//           top: 15,
//         ),
//         child: Column(
//           children: [
//             menuItem(1, "Home", Icons.home,
//                 currentPage == DrawerSections.home ? true : false),
//             menuItem(2, "Profile", Icons.person,
//                 currentPage == DrawerSections.profile ? true : false),
//             menuItem(3, "Reservations", Icons.calendar_today,
//                 currentPage == DrawerSections.reservations ? true : false),
//           ],
//         ));
//   }

//   Widget menuItem(int id, String title, IconData icon, bool selected) {
//     return Material(
//         color: selected ? Colors.grey[300] : Colors.transparent,
//         child: InkWell(
//             onTap: () {
//               setState(() {
//                 if (id == 1) {
//                   currentPage = DrawerSections.home;
//                 } else if (id == 2) {
//                   currentPage = DrawerSections.profile;
//                   profilePage(context);
//                 } else if (id == 3) {
//                   currentPage = DrawerSections.reservations;
//                   reservationPage(context);
//                 }
//               });
//             },
//             child: Padding(
//                 padding: EdgeInsets.all(15.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                         child: Icon(
//                       icon,
//                       size: 20,
//                       color: Colors.black,
//                     )),
//                     Expanded(
//                         flex: 3,
//                         child: Text(
//                           title,
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                           ),
//                         ))
//                   ],
//                 ))));
//   }
// }

// class FieldCard extends StatelessWidget {
//   final Field field;

//   FieldCard({required this.field});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: GestureDetector(
//         onTap: () {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text('Field Details'),
//                 content: Text(field.name),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: Text('Close'),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               field.name, // Display field name above the image
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Container(
//               padding: EdgeInsets.all(8.0),
//               child: Stack(
//                 children: [
//                   Image.asset(
//                     field.imagePath,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: 200,
//                   ),
//                   Positioned(
//                     top: 0,
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: Opacity(
//                         opacity: 0.9,
//                         child: Container(
//                           color: Colors.black,
//                           child: Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text(
//                               'View details',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Future<void> reservationPage(BuildContext context) async {
//   CircularProgressIndicator();
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => const ownerReservations(),
//     ),
//   );
// }

// Future<void> profilePage(BuildContext context) async {
//   CircularProgressIndicator();
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (context) => ownerProfile(),
//     ),
//   );
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malaebkom/owner_profile.dart';
import 'package:malaebkom/owner_Reservations.dart';

import '../login.dart';
import '../my_drawer_header_owner.dart';
import 'addNewField.dart';

class Field {
  final String name;
  final String imagePath;

  Field({required this.name, required this.imagePath});
}

class FieldOwnerApp extends StatelessWidget {
  final List<Field> fields = [
    Field(name: 'Field 1', imagePath: 'assets/images/stadium1.jpg'),
    Field(name: 'Field 2', imagePath: 'assets/images/stadium1.jpg'),
    Field(name: 'Field 3', imagePath: 'assets/images/stadium1.jpg'),
    Field(name: 'Field 4', imagePath: 'assets/images/stadium1.jpg'),
  ];

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
              // Use Expanded widget to allow field list to take up all available vertical space
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0),
                ),
                child: ListView.builder(
                  itemCount: widget.fields.length,
                  itemBuilder: (BuildContext context, int index) {
                    final field = widget.fields[index];
                    return FieldCard(field: field);
                  },
                ),
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
                ))));
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
                content: Text(field.name),
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
              field.name, // Display field name above the image
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
