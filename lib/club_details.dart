import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClubDetailsPage extends StatelessWidget {
  final String clubName;
  final String clubLogo;
  final String clubCreator;
  final List<String> clubMembers;
  final List<String> clubSportsType;
  final String currentUserID;
  final String clubCreatorID;
  final String clubID;
  final String clubCreatorPhone;

  ClubDetailsPage({
    required this.clubName,
    required this.clubLogo,
    required this.clubCreator,
    required this.clubMembers,
    required this.clubSportsType,
    required this.currentUserID,
    required this.clubCreatorID,
    required this.clubID,
    required this.clubCreatorPhone,
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

  void launchPhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch phone call';
    }
  }

  void launchWhatsAppChat(String phoneNumber) async {
    String formattedPhoneNumber = '+962$phoneNumber';
    String url = 'https://wa.me/$formattedPhoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch WhatsApp chat';
    }
  }

  void approveJoinRequest(String joinRequestID) async {
    DocumentSnapshot joinRequestSnapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubID)
        .collection('joinRequests')
        .doc(joinRequestID)
        .get();

    if (joinRequestSnapshot.exists) {
      Map<String, dynamic> joinRequestData =
          joinRequestSnapshot.data() as Map<String, dynamic>;
      String userName = joinRequestData['userName'];
      String userID = joinRequestData['userID'];

      // Update the club document to add the user to clubMembers and clubMembersID lists
      await FirebaseFirestore.instance.collection('clubs').doc(clubID).update({
        'clubMembers': FieldValue.arrayUnion([userName]),
        'clubMembersID': FieldValue.arrayUnion([userID]),
      });

      // Delete the join request document
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(clubID)
          .collection('joinRequests')
          .doc(joinRequestID)
          .delete();
    }
  }

  void rejectJoinRequest(String joinRequestID) async {
    // Delete the join request document
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

                        if (joinRequests.isEmpty) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'Currently No Join Requests Available',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

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
                        return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            child: Column(
                              children: joinRequestsWidgets,
                            ));
                      },
                    ),
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                              'Contact Club Owner at: ' + clubCreatorPhone),
                        ),
                        IconButton(
                          onPressed: () {
                            launchPhoneCall(clubCreatorPhone);
                          },
                          icon: Icon(
                            Icons.phone,
                            color: Colors.green,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            String phoneNumber = '+962' + clubCreatorPhone;
                            launch('https://wa.me/$phoneNumber');
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.green,
                          ),
                        ),
                      ],
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
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          child: Text(
                            'Send Request',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: Text(
                'Join Club',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
