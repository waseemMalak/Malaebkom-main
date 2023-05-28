import 'package:flutter/material.dart';

class ClubDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Details'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Club Details',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
