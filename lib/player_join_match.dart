import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malaebkom/my_drawer_header_owner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'player.dart';

import 'package:firebase_auth/firebase_auth.dart';

class PlayerJoinMatchPage extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> match;

  PlayerJoinMatchPage({required this.match});

  void joinMatch(QueryDocumentSnapshot<Map<String, dynamic>> match) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    String? userName;
    String? userPhone;

    // Retrieve the userName from the "users" collection
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      userName = userSnapshot.get('userName');
      userPhone = userSnapshot.get('phone');
    }

    print('userId: $userId');
    print('userName: $userName');
    print('userPhone: $userPhone');
    print(match['playersJoined']);

    // Get the current list of joined players (if any)
    dynamic playersJoined = match['playersJoined'];
    List<dynamic> joinedPlayers =
        playersJoined is List ? List.from(playersJoined) : [];

    print('joinedPlayers: $joinedPlayers');

    // Check if the userName is already in the joined players list
    if (!joinedPlayers.contains(userName)) {
      // Add the new player's userName to the list
      joinedPlayers.add(userName);

      // Update the 'playersJoined' field in the match document
      await match.reference.update({'playersJoined': joinedPlayers});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Match At: ${match['matchHeldAt']}'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            match['fieldImage'][0],
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
          ),
          SizedBox(height: 16),
          Text(
            'Match Held At: ${match['matchHeldAt']}',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 8),
          Tooltip(
            message:
                'Note that price will be distributed based on how many players join the match. Contact the match creator\'s phone number for more inquiries.',
            showDuration: Duration(seconds: 8),
            child: Text(
              'Price: \$${match['price'].toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Time:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Match Date: ${match['matchDate']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Starting Hour: ${match['startingHour']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Divider(
                    thickness: 2,
                    color: Colors.black,
                  ),
                  Text(
                    'Match Creator Info:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Match created by: ${match['matchCreator']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Phone Number: ',
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        width: 30,
                        child: IconButton(
                          icon: Icon(Icons.phone),
                          color: Colors.green,
                          onPressed: () {
                            String phoneNumber = match['matchCreatorNumber'];
                            launch('tel:$phoneNumber');
                          },
                        ),
                      ),
                      Container(
                        width: 30,
                        child: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            size: 24,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            String phoneNumber =
                                '+962' + match['matchCreatorNumber'];
                            launch('https://wa.me/$phoneNumber');
                          },
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${match['matchCreatorNumber']}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 2,
                    color: Colors.black,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Match Services:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${match['matchServices']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Divider(
                    thickness: 2,
                    color: Colors.black,
                  ),
                  Text(
                    'Match Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${match['matchDescription']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Divider(
                    thickness: 2,
                    color: Colors.black,
                  ),
                  Text(
                    'Joined Players: (${match['playersJoined']?.length ?? 0})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${match['playersJoined']?.join(", ") ?? ""}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: () {
              String matchLocation = match['matchLocation'];
              String mapUrl =
                  'https://www.google.com/maps/search/?api=1&query=$matchLocation';
              launch(mapUrl);
            },
          ),
          GestureDetector(
            onTap: () {
              String matchLocation = match['matchLocation'];
              String mapUrl =
                  'https://www.google.com/maps/search/?api=1&query=$matchLocation';
              launch(mapUrl);
            },
            child: Text('Match Location on Google Maps'),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Join Match'),
                    content: Text('Join match at: ${match['matchHeldAt']}'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Join'),
                        onPressed: () {
                          joinMatch(match);

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Join Successful'),
                              content: Text(
                                  'You have successfully joined the match.'),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Player()),
                                    );
                                  },
                                ),
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
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            child: Text('Join Match!'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class PlayerViewMatches extends StatefulWidget {
  @override
  _PlayerViewMatchesState createState() => _PlayerViewMatchesState();
}

class _PlayerViewMatchesState extends State<PlayerViewMatches> {
  late Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> matchesStream;

  @override
  void initState() {
    super.initState();
    matchesStream = FirebaseFirestore.instance
        .collection('fields')
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> matches = [];
      for (var fieldDoc in snapshot.docs) {
        var matchDocs = await fieldDoc.reference.collection('matches').get();
        for (var matchDoc in matchDocs.docs) {
          if (matchDoc.data()['matchType'] == 'public') {
            matches.add(matchDoc);
          }
        }
      }
      return matches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player View Matches'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: matchesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final matches = snapshot.data!;
            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final fieldImages = match['fieldImage'] as List<dynamic>;
                final matchCreator = match['matchCreator'] as String;
                final matchHeldAt = match['matchHeldAt'] as String;
                final price = match['price'] as double;
                final startingHour = match['startingHour'] as String;
                final matchDate = match['matchDate'] as String;
                final matchCreatorPhone = match['MatchCreatorNumber'] as String;

                return Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            fieldImages[0],
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                          ),
                          Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  matchHeldAt,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Price: \$${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Starting Hour: $startingHour',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlayerJoinMatchPage(match: match),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                              ),
                              child: Text('Join Match'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'Price: \$${price.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Match Held At: $matchHeldAt',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
