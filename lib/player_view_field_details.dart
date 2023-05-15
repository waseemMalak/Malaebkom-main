import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'player_book_match.dart';

class PlayerViewFieldDetials extends StatefulWidget {
  final DocumentSnapshot field;

  const PlayerViewFieldDetials({Key? key, required this.field})
      : super(key: key);

  @override
  _PlayerViewFieldDetialsState createState() => _PlayerViewFieldDetialsState();
}

class _PlayerViewFieldDetialsState extends State<PlayerViewFieldDetials> {
  String _locationName = '';
  CarouselController _carouselController = CarouselController();
  @override
  void initState() {
    super.initState();
    _getLocationName();
  }

  Future<void> _getLocationName() async {
    final coordinates =
        widget.field['location'].split(',').map(double.parse).toList();
    try {
      final placemarks =
          await placemarkFromCoordinates(coordinates[0], coordinates[1]);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final thoroughfare = placemark.thoroughfare ?? '';
        final subLocality = placemark.subLocality ?? '';
        final locality = placemark.locality ?? '';
        final administrativeArea = placemark.administrativeArea ?? '';
        setState(() {
          _locationName =
              '$thoroughfare $subLocality $locality $administrativeArea'
                  .replaceAll('+', ' ');
        });
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
  }

  Future<void> _launchMaps() async {
    final coordinates =
        widget.field['location'].split(',').map(double.parse).toList();
    final url =
        'https://www.google.com/maps/search/?api=1&query=${coordinates[0]},${coordinates[1]}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text(widget.field['fieldName']),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 9 / 16,
            child: Stack(
              children: [
                CarouselSlider(
                  carouselController: _carouselController,
                  items: widget.field['fieldImages'].map<Widget>((image) {
                    return Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    );
                  }).toList(),
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    autoPlay: false, // Disable automatic slide transition
                    enlargeCenterPage: false,
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: ColorFiltered(
                          colorFilter:
                              ColorFilter.mode(Colors.green, BlendMode.srcIn),
                          child: Icon(Icons.arrow_back),
                        ),
                        onPressed: () {
                          // Move to the previous image
                          _carouselController.previousPage();
                        },
                      ),
                      IconButton(
                        icon: ColorFiltered(
                          colorFilter:
                              ColorFilter.mode(Colors.green, BlendMode.srcIn),
                          child: Icon(Icons.arrow_forward),
                        ),
                        onPressed: () {
                          // Move to the next image
                          _carouselController.nextPage();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Field Name: ${widget.field['fieldName']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Price Per Hour: ${widget.field['price'].toString()} JD',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Location: $_locationName',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: _launchMaps,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              height: 60,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Icon(Icons.location_pin),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Field Location On Map',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlayerBookMatch(field: widget.field),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
                child: Text('Book Now!'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
