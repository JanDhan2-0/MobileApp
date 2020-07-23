import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jandhanv2/models/place.dart';
import 'package:jandhanv2/screens/bankUploads.dart';
import 'package:jandhanv2/services/marker_service.dart';
import 'package:jandhanv2/services/places_service.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:jandhanv2/screens/feedbackScreen.dart';
import 'package:jandhanv2/screens/missingScreen.dart';
import 'package:jandhanv2/screens/requestScreen.dart';
import 'package:jandhanv2/screens/updatesScreen.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jan Dhan 2.0',
      home: GeolocationExample(),
      routes: {
        '/missing': (context) => MissingScreen(),
        '/request': (context) => RequestScreen(),
        '/feedback': (context) => FeedbackScreen(),
        '/updates': (context) => UpdateScreen(),
        '/upload': (context) => HomeScreen1()
      },
    );
  }
}

class GeolocationExampleState extends State {
  Geolocator _geolocator;
  Position _position;
  var pressAtm = true;
  var pressBank = false;
  var pressPo = false;
  var pressAmbassador = false;
  var pressCSC = false;
  var type = "atm";
  var markers;
  BitmapDescriptor atmIcon, bankIcon, emitraIcon, cscIcon, poIcon;
  double _positionLatitude;
  GoogleMapController mapController;
  double _positionLongitude;
  PlacesService placesService;
  MarkerService markerService;
  List<Place> placesMarkers;
  final apiKey = "AIzaSyCILGP87TZPkXUobQfqDp9mkPA7IXnEGXU";
  void checkPermission() {
    _geolocator.checkGeolocationPermissionStatus().then((status) {
      print('status: $status');
    });
    _geolocator
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationAlways)
        .then((status) {
      print('always status: $status');
    });
    _geolocator.checkGeolocationPermissionStatus(
        locationPermission: GeolocationPermission.locationWhenInUse)
      ..then((status) {
        print('whenInUse status: $status');
      });
  }

  @override
  void initState() {
    super.initState();
    placesService = PlacesService();
    markerService = MarkerService();
    _geolocator = Geolocator();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(100, 100)), 'assets/images/atm.png')
        .then((onValue) {
      atmIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(100, 100)), 'assets/images/bank.png')
        .then((onValue) {
      bankIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(100, 100)), 'assets/images/po.png')
        .then((onValue) {
      poIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(100, 100)), 'assets/images/csc.png')
        .then((onValue) {
      cscIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(100, 100)),
            'assets/images/e-mitra.png')
        .then((onValue) {
      emitraIcon = onValue;
    });

    checkPermission();
    updateLocation();
  }

  void updatePlace(double lat, double long, String type) async {
    List<Place> places = await placesService.getPlaces(lat, long, type);
    setState(() {
      placesMarkers = places;
      updateMarkers(placesMarkers, type);
    });
  }

  void updateMarkers(List<Place> placeMarkers, String type) {
    debugPrint('Type: ' + type);
    markers = (placeMarkers != null)
        ? markerService.getMarkers(
            placeMarkers,
            type,
            (type == 'atm')
                ? atmIcon
                : (type == 'bank')
                    ? bankIcon
                    : (type == 'post_office')
                        ? poIcon
                        : (type == 'csc') ? cscIcon : emitraIcon)
        : List<Marker>();
  }

  void updateLocation() async {
    try {
      Position newPosition = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(new Duration(seconds: 5));
      setState(() {
        _position = newPosition;
        _positionLatitude = _position.latitude;
        _positionLongitude = _position.longitude;
        updatePlace(_positionLatitude, _positionLongitude, "atm");
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Widget _buildContainer(List<Place> placeMarkers, String type) {
    debugPrint(placeMarkers.length.toString() +
        " Debug Print Response " +
        "hilllaaaa");
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for (var place in placeMarkers)
              Padding(
                padding: const EdgeInsets.only(
                    right: 2.5, left: 2.5, top: 4.0, bottom: 4.0),
                child: _boxes(place, type),
              ),
          ],
        ),
      ),
    );
  }

  Widget _boxes(Place place, type) {
    return Container(
      child: new FittedBox(
        child: Material(
            color: Colors.white,
            elevation: 5.0,
            borderRadius: BorderRadius.circular(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: myDetailsContainer1(place),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  _launchURL(data) async {
    if (await canLaunch(data)) {
      await launch(data);
    } else {
      throw 'Could not launch $data';
    }
  }

  Widget myDetailsContainer1(Place place) {
    return Material(
        child: InkWell(
      child: Container(
          height: MediaQuery.of(context).size.height / 3 + 30,
          width: 500.0,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    child: Text(
                  place.name,
                  style: TextStyle(
                      color: Colors.lightBlue[600],
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold),
                )),
                SizedBox(height: 5.0),
                Container(
                    child: Text(
                  place.vicinity,
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 24.0,
                  ),
                )),
                SizedBox(height: 5.0),
                Row(
                  children: [
                    Text(
                      "Status: ${place.openNow}" +
                          "\nOpening Hours: ${place.openingHours}",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.feedback),
                                iconSize: 40.0,
                                color: Colors.blue[600],
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FeedbackScreen(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.call),
                                color: Colors.blue[600],
                                iconSize: 40.0,
                                onPressed: () {
                                  _launchURL("tel:${place.phoneNumber}");
                                },
                              )
                            ]))
                  ],
                )
              ])),
      onTap: () => _gotoLocation(
          place.geometry.location.lat, place.geometry.location.lng),
    ));
  }

  Future<void> _gotoLocation(double lat, double long) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 20,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }

  void returnToCenter() {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(_positionLatitude, _positionLongitude),
      zoom: 14,
      tilt: 0.0,
      bearing: 0.0,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: SvgPicture.asset('assets/images/logo.svg',
              semanticsLabel: 'logo of jdd', height: 30.0, width: 30.0),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.search,
                  size: 22.5,
                ),
                onPressed: () async {
                  LocationResult result = await showLocationPicker(
                    context,
                    apiKey,
                    initialCenter:
                        LatLng(_positionLongitude, _positionLongitude),
                    automaticallyAnimateToCurrentLocation: true,
                    myLocationButtonEnabled: true,
                    layersButtonEnabled: true,
                    resultCardAlignment: Alignment.bottomCenter,
                  );
                  print("result = $result");
                  setState(() {
                    _positionLatitude = result.latLng.latitude;
                    _positionLongitude = result.latLng.longitude;
                    updatePlace(_positionLatitude, _positionLongitude, "atm");
                    mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(_positionLatitude, _positionLongitude),
                        14.0, // Zoom factor
                      ),
                    );
                  });
                }),
            IconButton(
              icon: Icon(
                Icons.assistant,
                size: 22.5,
              ),
              onPressed: () {
                // _handlePressButton();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.live_help,
                size: 22.5,
              ),
              onPressed: () {
                _launchURL("tel:+12054489824");
              },
            ),
            IconButton(
              icon: Icon(
                Icons.language,
                size: 22.5,
              ),
              onPressed: () {
                // _handlePressButton();
              },
            )
          ]),
      drawer: navigationDrawer(),
      body: (_position != null && placesMarkers != null)
          ? Container(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        height:
                            2 * MediaQuery.of(context).size.height / 3 - 17.5,
                        width: MediaQuery.of(context).size.width,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target:
                                  LatLng(_positionLatitude, _positionLongitude),
                              zoom: 14.0),
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                          },
                          zoomGesturesEnabled: true,
                          gestureRecognizers: Set()
                            ..add(Factory<PanGestureRecognizer>(
                                () => PanGestureRecognizer())),
                          markers: Set<Marker>.of(markers),
                          myLocationButtonEnabled: false,
                          myLocationEnabled: true,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: new ButtonBar(
                          mainAxisSize: MainAxisSize.min,
                          buttonPadding: EdgeInsets.all(0.0),
                          children: <Widget>[
                            new FlatButton(
                              child: new Text('ATM'),
                              textColor: pressAtm ? Colors.white : Colors.black,
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20)),
                              ),
                              color: pressAtm ? Colors.blue : Colors.white,
                              onPressed: () => setState(() {
                                type = "atm";
                                pressAtm = true;
                                pressAmbassador = false;
                                pressPo = false;
                                pressBank = false;
                                pressCSC = false;
                                updatePlace(_positionLatitude,
                                    _positionLongitude, "atm");
                              }),
                            ),
                            new FlatButton(
                              child: new Text('Branch'),
                              textColor:
                                  pressBank ? Colors.white : Colors.black,
                              color: pressBank ? Colors.blue : Colors.white,
                              onPressed: () => setState(() {
                                type = "bank";
                                pressAtm = false;
                                pressAmbassador = false;
                                pressPo = false;
                                pressBank = true;
                                pressCSC = false;
                                updatePlace(_positionLatitude,
                                    _positionLongitude, "bank");
                              }),
                            ),
                            new FlatButton(
                              child: new Text('PO'),
                              textColor: pressPo ? Colors.white : Colors.black,
                              color: pressPo ? Colors.blue : Colors.white,
                              onPressed: () => setState(() {
                                type = "po";
                                pressAtm = false;
                                pressAmbassador = false;
                                pressPo = true;
                                pressBank = false;
                                pressCSC = false;
                                updatePlace(_positionLatitude,
                                    _positionLongitude, "post_office");
                              }),
                            ),
                            new FlatButton(
                              child: new Text('CSC'),
                              textColor: pressCSC ? Colors.white : Colors.black,
                              color: pressCSC ? Colors.blue : Colors.white,
                              onPressed: () => setState(() {
                                type = "csc";
                                pressAtm = false;
                                pressAmbassador = false;
                                pressPo = false;
                                pressBank = false;
                                pressCSC = true;
                                updatePlace(_positionLatitude,
                                    _positionLongitude, "csc");
                              }),
                            ),
                            new FlatButton(
                              child: new Text('E-Mitra'),
                              textColor:
                                  pressAmbassador ? Colors.white : Colors.black,
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                    topRight: Radius.circular(20)),
                              ),
                              color:
                                  pressAmbassador ? Colors.blue : Colors.white,
                              onPressed: () => setState(() {
                                type = "bm";
                                pressAtm = false;
                                pressAmbassador = true;
                                pressPo = false;
                                pressBank = false;
                                pressCSC = false;
                                updatePlace(_positionLatitude,
                                    _positionLongitude, "bank_mitra");
                              }),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 50.0,
                              left: MediaQuery.of(context).size.width - 50.0),
                          child: Material(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                            child: IconButton(
                                enableFeedback: true,
                                icon: Icon(Icons.center_focus_strong,
                                    color: Colors.blue[600]),
                                onPressed: returnToCenter),
                          )),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 2 * MediaQuery.of(context).size.height / 3 -
                                17.5),
                        child: _buildContainer(placesMarkers, type),
                      )
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class GeolocationExample extends StatefulWidget {
  @override
  GeolocationExampleState createState() => new GeolocationExampleState();
}

class navigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      color: Colors.blue[600],
      child: ListView(
        children: <Widget>[
          createDrawerHeader(),
          Divider(color: Colors.white),
          createDrawerBodyItem(
            icon: Icons.contact_phone,
            text: 'Upload Account Info',
            onTap: () => Navigator.pushNamed(context, '/upload'),
          ),
          createDrawerBodyItem(
            icon: Icons.feedback,
            text: 'Feedback',
            onTap: () => Navigator.pushNamed(context, '/feedback'),
          ),
          createDrawerBodyItem(
            icon: Icons.pin_drop,
            text: 'Missing Banks/ATM',
            onTap: () => Navigator.pushNamed(context, '/missing'),
          ),
          createDrawerBodyItem(
            icon: Icons.report,
            text: 'Request Bank/ATM',
            onTap: () => Navigator.pushNamed(context, '/request'),
          ),
          createDrawerBodyItem(
            icon: Icons.notifications_active,
            text: 'Latest Updates',
            onTap: () => Navigator.pushNamed(context, '/updates'),
          ),
          createDrawerBodyItem(
            icon: Icons.help,
            text: 'Help',
            // onTap: () => Navigator.pushNamed(context, '/'),
          ),
          Divider(color: Colors.white),
          ListTile(
            title: Text('App version 1.0.3',
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    ));
  }
}

Widget createDrawerBodyItem(
    {IconData icon, String text, GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(
          icon,
          color: Colors.white,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)),
        ),
      ],
    ),
    onTap: onTap,
  );
}

Widget createDrawerHeader() {
  return DrawerHeader(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SvgPicture.asset('assets/images/logo.svg',
            semanticsLabel: 'Jan Dhan 2.0 logo'),
        Text(
          "Jan Dhan 2.0",
          style: TextStyle(
              color: Colors.white, fontSize: 21.0, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
