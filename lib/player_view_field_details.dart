import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'player_book_match.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  double _rating = 0.0;
  int _ratingCount = 0;

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

  bool _isRated = false;

  void _onRatingChanged(double rating) {
    if (!_isRated) {
      setState(() {
        _rating = rating;
        _ratingCount++;
        _isRated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text(widget.field['fieldName']),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.width * 8 / 16,
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
                      aspectRatio: 16 / 8,
                      viewportFraction: 1.0,
                      initialPage: 0,
                      enableInfiniteScroll: false,
                      autoPlay: false,
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
                  Divider(
                    color: Colors.black,
                    thickness: 1.0,
                  ),
                  Text(
                    'Field Owner Contact Number:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        child: IconButton(
                          icon: Icon(Icons.phone),
                          color: Colors.green,
                          onPressed: () {
                            String phoneNumber =
                                widget.field['fieldOwnerNumber'];
                            launch('tel:$phoneNumber');
                          },
                        ),
                      ),
                      Container(
                        width: 36,
                        child: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            size: 24,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            String phoneNumber =
                                '+962' + widget.field['fieldOwnerNumber'];
                            launch('https://wa.me/$phoneNumber');
                          },
                        ),
                      ),
                      Text(
                        '${widget.field['fieldOwnerNumber']}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1.0,
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
                  Text(
                    'Field Services: ${widget.field['fieldServices'].toString().split(",").join(",")}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Field Sport Type: ${widget.field['fieldSports'].toString().split(",").join(",")}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Field Opening hours: ${widget.field['openingHours'].toString()}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 20.0,
                    unratedColor: Colors.grey[300],
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: _onRatingChanged,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Average Field Rating: ${_ratingCount > 0 ? (_rating / _ratingCount).toStringAsFixed(2) : 'N/A'}',
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
      ),
    );
  }
}
