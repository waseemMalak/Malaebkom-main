import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player_join_match.dart';
import 'package:intl/intl.dart';

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
      final now = DateTime.now();
      List<QueryDocumentSnapshot<Map<String, dynamic>>> matches = [];
      for (var fieldDoc in snapshot.docs) {
        var matchDocs = await fieldDoc.reference.collection('matches').get();
        for (var matchDoc in matchDocs.docs) {
          if (matchDoc.data()['matchType'] == 'public') {
            final matchStartingHour = matchDoc.data()['startingHour'] as String;
            final matchDate = DateFormat('dd MMM yyyy')
                .parse(matchDoc.data()['matchDate'] as String);
            final matchDateTime = DateTime(
              matchDate.year,
              matchDate.month,
              matchDate.day,
              _getHour(matchStartingHour),
              _getMinute(matchStartingHour),
            );

            if (matchDateTime.isAfter(now)) {
              matches.add(matchDoc);
            }
          }
        }
      }
      return matches;
    });
  }

  int _getHour(String startingHour) {
    final hourString = startingHour.split(':')[0];
    final isPM = startingHour.toLowerCase().contains('pm');

    if (isPM) {
      return int.parse(hourString) + 12; // Convert to 24-hour format
    } else {
      return int.parse(hourString);
    }
  }

  int _getMinute(String startingHour) {
    final minuteString = startingHour.split(':')[1].split(' ')[0];
    return int.parse(minuteString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Matches'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: matchesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final matches = snapshot.data!;
            if (matches.isEmpty) {
              return Center(
                child: Text('Currently No Matches Available Check Again Later'),
              );
            }
            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final fieldImages = match['fieldImage'] as List<dynamic>;
                final matchHeldAt = match['matchHeldAt'] as String;
                final price = match['price'] as double;
                final startingHour = match['startingHour'] as String;
                final matchDate = match['matchDate'];
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
                            SizedBox(height: 4),
                            Text(
                              'match Date: $matchDate',
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
                          child: Text('View Match Details'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: Text('No matches found.'),
            );
          }
        },
      ),
    );
  }
}
