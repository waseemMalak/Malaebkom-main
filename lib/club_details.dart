import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubDetailsPage extends StatelessWidget {
  final String clubName;
  final String clubLogo;
  final String clubCreator;
  final List<String> clubMembers;
  final List<String> clubSportsType;
  final String currentUserID;
  final String clubCreatorID;
  final String clubID; // Add clubID as a parameter

  ClubDetailsPage({
    required this.clubName,
    required this.clubLogo,
    required this.clubCreator,
    required this.clubMembers,
    required this.clubSportsType,
    required this.currentUserID,
    required this.clubCreatorID,
    required this.clubID, // Add clubID to the constructor
  });

  void sendJoinRequest(BuildContext context) async {
    String? userName;

    // Retrieve the current user's name from the 'users' collection
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      userName = userData['userName'];
    }

    if (userName != null) {
      // Create a join request document in the club's collection
      print('club id = ' + clubID);
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(clubID)
          .collection('joinRequests')
          .doc(currentUserID)
          .set({
        'userName': userName,
        'userID': currentUserID,
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membership request sent. Please wait for approval.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send membership request'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentUserClubCreator = (currentUserID == clubCreatorID);

    return Scaffold(
      appBar: AppBar(
        title: Text(clubName + ' club details'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2.0),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.9,
                      child: Image.network(
                        clubLogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Club Creator: $clubCreator',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Club Captains:', // Fill this with content later
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Club Members: ${clubMembers.join(", ")}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Club Sports Type: ${clubSportsType.join(", ")}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  if (isCurrentUserClubCreator)
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Player Requests',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!isCurrentUserClubCreator)
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Join Club'),
                      content: Text('Send a join request to the club creator?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            sendJoinRequest(context);
                            Navigator.pop(context);
                          },
                          child: Text('Send Request'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Join Club'),
            ),
        ],
      ),
    );
  }
}
