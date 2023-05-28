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

  Future<void> sendJoinRequest(BuildContext context) async {
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

  Future<void> approveJoinRequest(String joinRequestID) async {
    await FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubID)
        .collection('joinRequests')
        .doc(joinRequestID)
        .update({'status': 'approved'});

    // Add the user to the clubMembers list
    await FirebaseFirestore.instance.collection('clubs').doc(clubID).update({
      'clubMembers': FieldValue.arrayUnion([joinRequestID])
    });
  }

  Future<void> rejectJoinRequest(String joinRequestID) async {
    await FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubID)
        .collection('joinRequests')
        .doc(joinRequestID)
        .delete();
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
                        'Join Requests',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isCurrentUserClubCreator)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('clubs')
                          .doc(clubID)
                          .collection('joinRequests')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        List<Widget> joinRequestsWidgets = [];
                        List<DocumentSnapshot> joinRequests =
                            snapshot.data!.docs;

                        for (var joinRequest in joinRequests) {
                          String joinRequestID = joinRequest.id;
                          String userName =
                              joinRequest['userName'] ?? 'Unknown User';
                          String userID = joinRequest['userID'] ?? '';

                          String status = joinRequest['status'] ?? 'unknown';

                          Widget joinRequestWidget = ListTile(
                            title: Text(userName),
                            subtitle: Text('ID: $userID'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    approveJoinRequest(joinRequestID);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors
                                        .green, // Set button color to green
                                  ),
                                  child: Text('Approve'),
                                ),
                                SizedBox(width: 8.0),
                                ElevatedButton(
                                  onPressed: () {
                                    rejectJoinRequest(joinRequestID);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        Colors.red, // Set button color to red
                                  ),
                                  child: Text('Reject'),
                                ),
                              ],
                            ),
                          );

                          joinRequestsWidgets.add(joinRequestWidget);
                        }

                        return Column(
                          children: joinRequestsWidgets,
                        );
                      },
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
                          style: ElevatedButton.styleFrom(
                            primary: Colors
                                .green, // Set the background color to green
                          ),
                          child: Text(
                            'Send Request',
                            style: TextStyle(
                              color:
                                  Colors.white, // Set the text color to white
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Set the background color to green
              ),
              child: Text(
                'Join Club',
                style: TextStyle(
                  color: Colors.white, // Set the text color to white
                ),
              ),
            ),
        ],
      ),
    );
  }
}
