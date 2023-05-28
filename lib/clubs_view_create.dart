import 'package:flutter/material.dart';
import 'clubs_create.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'club_details.dart';

class ClubsViewCreate extends StatefulWidget {
  const ClubsViewCreate({Key? key}) : super(key: key);

  @override
  _ClubsViewCreateState createState() => _ClubsViewCreateState();
}

class _ClubsViewCreateState extends State<ClubsViewCreate> {
  Future<QuerySnapshot> _fetchClubs() async {
    // Retrieve the club collection data from Firestore
    QuerySnapshot clubSnapshot =
        await FirebaseFirestore.instance.collection('clubs').get();
    return clubSnapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clubs'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: _fetchClubs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                List<QueryDocumentSnapshot> clubDocuments = snapshot.data!.docs;

                if (clubDocuments.isEmpty) {
                  return Center(
                    child: Text('No clubs found.'),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: clubDocuments.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          // Extract the club data from the document snapshot
                          Map<String, dynamic> clubData = clubDocuments[index]
                              .data() as Map<String, dynamic>;

                          // Extract club logo, name, and sports types
                          String clubLogo = clubData['clubLogo'];
                          String clubName = clubData['clubName'];
                          List<String> clubSportsType =
                              List<String>.from(clubData['clubSportsType']);

                          return ListTile(
                            tileColor: Colors.green,
                            leading: Container(
                              width: 80,
                              height: 80,
                              color: Colors.white, // White background color
                              child: Image.network(
                                clubLogo,
                                fit: BoxFit.contain,
                              ),
                            ),
                            title: Text(
                              'Club Name: $clubName',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${clubSportsType.join(', ')}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClubDetailsPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.green,
                              ),
                              child: Text('Join'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.green,
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateClubPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                primary: Colors.transparent,
                elevation: 0,
              ),
              child: Text(
                'Create a Club+',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
