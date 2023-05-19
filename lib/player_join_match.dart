import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerJoinMatchPage extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> match;

  PlayerJoinMatchPage({required this.match});

  @override
  Widget build(BuildContext context) {
    // Use the match data here to display the join match page
    // You can access the match properties using match['propertyName']
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Match'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Match Details'),
            Text('Match Held At: ${match['matchHeldAt']}'),
            Text('Price: \$${match['price'].toStringAsFixed(2)}'),
            Text('Starting Hour: ${match['startingHour']}'),
            Text('match created by: ${match['matchCreator']}'),

            // Add more widgets to display other match details as needed
          ],
        ),
      ),
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
        backgroundColor:
            Colors.green, // Set the AppBar background color to green
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

                return Card(
                  elevation: 2,
                  child: Stack(
                    children: [
                      Image.network(
                        fieldImages.first,
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
                            primary:
                                Colors.green, // Set the button color to green
                          ),
                          child: Text('Join Match'),
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
