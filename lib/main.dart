import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:jandhanv2/models/place.dart';
import 'package:jandhanv2/screens/bankUploads.dart';
import 'package:jandhanv2/services/marker_service.dart';
import 'package:jandhanv2/services/places_service.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';

import 'package:jandhanv2/screens/missingScreen.dart';
import 'package:jandhanv2/screens/requestScreen.dart';
import 'package:jandhanv2/screens/updatesScreen.dart';
import 'package:jandhanv2/screens/feedbackScreen.dart';
import 'package:jandhanv2/screens/schemesScreen.dart';
import 'dart:ui';

import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:intro_slider/intro_slider.dart';
import 'classes/Language.dart';

void main() async {
  runApp(BasicApp());
}

class BasicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jan Dhan Drashak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: IntroScreen(),
    );
  }
}

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "JAN DHAN 2.0",
        styleTitle: TextStyle(
            color: Colors.black, fontSize: 25, fontFamily: 'Quicksand'),
        description:
            "One stop solution for all your financial needs in minimum taps.",
        styleDescription: TextStyle(
            color: Colors.black, fontSize: 14, fontFamily: 'Quicksand'),
        pathImage: "assets/images/walk_logo.png",
        heightImage: 125.0,
        widthImage: 100.0,
        backgroundColor: const Color(0xf2f8f9ff),
      ),
    );

    slides.add(
      new Slide(
        title: "FINANCIAL INCLUSION",
        styleTitle: TextStyle(
            color: Colors.black, fontSize: 25, fontFamily: 'Quicksand'),
        description:
            "Bring everyone of all ages, sects, cultures and professions together by providing financial literacy and faster grievance redressal.",
        styleDescription: TextStyle(
            color: Colors.black, fontSize: 14, fontFamily: 'Quicksand'),
        pathImage: "assets/images/inclu.png",
        heightImage: 125.0,
        widthImage: 100.0,
        backgroundColor: const Color(0xf2f8f9ff),
      ),
    );
    slides.add(
      new Slide(
        title: "MULTILINGUAL & MULTIMODAL",
        styleTitle: TextStyle(
            color: Colors.black, fontSize: 22, fontFamily: 'Quicksand'),
        description:
            "Talk to our AI powered chatbot or a Live 24/7 Helpline for financial information.",
        styleDescription: TextStyle(
            color: Colors.black, fontSize: 14, fontFamily: 'Quicksand'),
        pathImage: "assets/images/chat.png",
        heightImage: 125.0,
        widthImage: 100.0,
        backgroundColor: const Color(0xf2f8f9ff),
      ),
    );
    slides.add(
      new Slide(
        title: "CONTACTLESS VERIFICATION",
        styleTitle: TextStyle(
            color: Colors.black, fontSize: 22, fontFamily: 'Quicksand'),
        description:
            "Upload documents securely for any bank related verifications.",
        styleDescription: TextStyle(
            color: Colors.black, fontSize: 14, fontFamily: 'Quicksand'),
        pathImage: "assets/images/credit.png",
        heightImage: 125.0,
        widthImage: 100.0,
        backgroundColor: const Color(0xf2f8f9ff),
      ),
    );
  }

  void onDonePress() {
    // TODO: go to next screen
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MyApp1()));
  }

  void onSkipPress() {
    // TODO: go to next screen
    onDonePress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IntroSlider(
            slides: this.slides,
            onDonePress: this.onDonePress,
            onSkipPress: this.onSkipPress,
            nameDoneBtn: 'Done',
            nameNextBtn: 'Next',
            nameSkipBtn: 'Skip',
            styleNameDoneBtn:
                TextStyle(color: Colors.blue[600], fontSize: 16.0),
            styleNamePrevBtn:
                TextStyle(color: Colors.blue[600], fontSize: 16.0),
            styleNameSkipBtn:
                TextStyle(color: Colors.blue[600], fontSize: 16.0),
            colorActiveDot: Colors.blue[600],
            colorDot: Colors.grey));
  }
}

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyLocalization(supportedLocales: [
              Locale('en'),
              Locale('hi'),
              Locale('mr'),
              Locale('kn'),
              Locale('te'),
              Locale('ta'),
              Locale('gu'),
              Locale('pa')
            ], path: 'assets/translations', child: MyApp());
  }
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Jan Dhan 2.0',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      home: GeolocationExample(),
      routes: {
        '/missing': (context) => MissingScreen(),
        '/request': (context) => RequestScreen(),
        '/feedback': (context) => FeedbackScreen(),
        '/updates': (context) => UpdateScreen(),
        '/upload': (context) => HomeScreen1(),
        '/schemes': (context) => SchemesScreen()
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
  var hello = ' ';
  BitmapDescriptor atmIcon,
      bankIcon,
      emitraIcon,
      cscIcon,
      poIcon,
      bankCloseIcon;
  double _positionLatitude;
  GoogleMapController mapController;
  double _positionLongitude;
  PlacesService placesService;
  MarkerService markerService;

  ScrollController _scrollController;
  GlobalKey _search = GlobalObjectKey("search");
  GlobalKey _assistant = GlobalObjectKey("assistant");
  GlobalKey _helpine = GlobalObjectKey("helpline");
  GlobalKey _language = GlobalObjectKey("language");
  GlobalKey _drawer = GlobalObjectKey("drawer");

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
    _scrollController = ScrollController();
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

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(100, 100)),
            'assets/images/bank_close.png')
        .then((onValue) {
      bankCloseIcon = onValue;
    });

    checkPermission();
    updateLocation();
    checkFirstSeen();
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('tutorSeen') ?? false);
    if (_seen) {
      return;
    } else {
      await prefs.setBool('tutorSeen', true);
       Timer(Duration(seconds: 2), () => showCoachMarkFAB());
    }
  }

  void showCoachMarkFAB() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = _search.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
        targetContext: _search.currentContext,
        markRect: markRect,
        children: [
          Center(
              child: Text("Tap here to set Location",
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  )))
        ],
        duration: null,
        onClose: () {
          Timer(Duration(seconds: 0), () => showCoachMarkAssistant());
        });
  }

  void showCoachMarkAssistant() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = _assistant.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
        targetContext: _assistant.currentContext,
        markRect: markRect,
        children: [
          Center(
              child: Text("Tap here to talk to our Digital Assistant",
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  )))
        ],
        duration: null,
        onClose: () {
          Timer(Duration(seconds: 0), () => showCoachMarkHelpline());
        });
  }

  void showCoachMarkHelpline() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = _helpine.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
        targetContext: _helpine.currentContext,
        markRect: markRect,
        children: [
          Center(
              child: Text("Tap here for our 24X7 Live Helpline",
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  )))
        ],
        duration: null,
        onClose: () {
          Timer(Duration(seconds: 0), () => showCoachMarkLanguage());
        });
  }

  void showCoachMarkLanguage() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = _language.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
        targetContext: _language.currentContext,
        markRect: markRect,
        children: [
          Center(
              child: Text("Tap here to change Language",
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  )))
        ],
        duration: null,
        onClose: () {
          duration:
          Duration(seconds: 1);
        });
  }

  void updatePlace(double lat, double long, String type) async {
    List<Place> places = await placesService.getPlaces(
        lat, long, type, context.locale.toString());
    setState(() {
      placesMarkers = places;
      updateMarkers(placesMarkers, type);
    });
  }

  void updateMarkers(List<Place> placeMarkers, String type) {
    // debugPrint('Type: ' + type);
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
                        : (type == 'csc') ? cscIcon : emitraIcon,
            bankCloseIcon)
        : List<Marker>();
    markers.add(Marker(
        markerId: MarkerId('30'),
        draggable: false,
        consumeTapEvents: false,
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(_positionLatitude, _positionLongitude)));
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
          width: 600.0,
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
                Container(
                    child: Text(
                  place.vicinity,
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 24.0,
                  ),
                )),
                Row(
                  children: [
                    Text(
                      "${place.openNow}" +
                          " | ${place.userRatingCount} reports"
                              "\nOpening Hours: ${place.openingHours}",
                      style: TextStyle(
                        color: place.openNow == 'Open'
                            ? Colors.green[300]
                            : Colors.red[300],
                        fontSize: 26.0,
                      ),
                    ),
                    Spacer(),
                    ButtonBar(alignment: MainAxisAlignment.end, children: [
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
                    ])
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
          title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  key: _search,
                  icon: Icon(
                    Icons.search,
                    size: 22.5,
                    semanticLabel: 'Search for your location',
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
                  },
                  tooltip: 'Search Icon',
                ),
                IconButton(
                  key: _assistant,
                  icon: Icon(
                    Icons.assistant,
                    size: 22.5,
                    semanticLabel: 'Jan Dhan 2.0 Chatbot',
                  ),
                  onPressed: () {
                    _launchURL(
                        "https://assistant.google.com/services/invoke/uid/0000007b2fc19bd8?hl=en");
                  },
                  tooltip: 'Assistant Icon',
                ),
                IconButton(
                  key: _helpine,
                  icon: Icon(
                    Icons.live_help,
                    size: 22.5,
                    semanticLabel: 'Jan Dhan Live Help',
                  ),
                  onPressed: () {
                    _launchURL("tel:+12054489824");
                  },
                  tooltip: 'Jan Dhan Live Helpline',
                )
              ]),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.all(10.0),
                child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                      onChanged: (Language language) {
                        context.locale = Locale(language.languageCode);
                        updatePlace(_positionLatitude , _positionLongitude, type);
                      },
                      underline: Container(height: 0),
                      icon: Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 22.5,
                        semanticLabel: 'Select your languages',
                        key: _language,
                      ),
                      items: Language.languageList()
                          .map<DropdownMenuItem<Language>>(
                              (lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Container(
                                    child: Row(
                                      children: <Widget>[
                                        Text(lang.name,
                                            style: TextStyle(fontSize: 12.0))
                                      ],
                                    ),
                                  )))
                          .toList(),
                    )))
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
                                target: LatLng(
                                    _positionLatitude, _positionLongitude),
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
                            compassEnabled: false,
                            mapToolbarEnabled: true,
                            circles: Set.from([
                              Circle(
                                  circleId: CircleId('0'),
                                  center: LatLng(
                                      _positionLatitude, _positionLongitude),
                                  radius: 1250,
                                  strokeColor: Color(0x5DA9CAff),
                                  strokeWidth: 1,
                                  fillColor: Color(0x5DA9CAff)),
                              Circle(
                                  circleId: CircleId('1'),
                                  center: LatLng(
                                      _positionLatitude, _positionLongitude),
                                  radius: 2500,
                                  strokeColor: Color(0x3DA9CAff),
                                  strokeWidth: 1,
                                  fillColor: Color(0x3DA9CAff)),
                              Circle(
                                  circleId: CircleId('2'),
                                  center: LatLng(
                                      _positionLatitude, _positionLongitude),
                                  radius: 5000,
                                  strokeColor: Color(0x2DA9CAff),
                                  strokeWidth: 1,
                                  fillColor: Color(0x2DA9CAff))
                            ])),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: new ButtonBar(
                          mainAxisSize: MainAxisSize.min,
                          buttonPadding: EdgeInsets.all(0.0),
                          children: <Widget>[
                            new FlatButton(
                              child: new Text(tr('atm')),
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
                              child: new Text(tr('branch')),
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
                              child: new Text(tr('po')),
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
                              child: new Text(tr('csc')),
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
                              child: new Text(tr('emitra')),
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
            text: tr('accinfo'),
            onTap: () => Navigator.pushNamed(context, '/upload'),
          ),
          createDrawerBodyItem(
            icon: Icons.feedback,
            text: tr('feedback'),
            onTap: () => Navigator.pushNamed(context, '/feedback'),
          ),
          createDrawerBodyItem(
            icon: Icons.pin_drop,
            text: tr('missing'),
            onTap: () => Navigator.pushNamed(context, '/missing'),
          ),
          createDrawerBodyItem(
            icon: Icons.report,
            text: tr('request'),
            onTap: () => Navigator.pushNamed(context, '/request'),
          ),
          createDrawerBodyItem(
            icon: Icons.notifications_active,
            text: tr('updates'),
            onTap: () => Navigator.pushNamed(context, '/updates'),
          ),
          createDrawerBodyItem(
            icon: Icons.score,
            text: tr('schemes'),
            onTap: () => Navigator.pushNamed(context, '/schemes'),
          ),
          createDrawerBodyItem(
            icon: Icons.help,
            text: tr('help'),
            // onTap: () => Navigator.pushNamed(context, '/'),
          ),
          Divider(color: Colors.white),
          ListTile(
            title: Text(tr('version'), style: TextStyle(color: Colors.white)),
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
          tr('title'),
          style: TextStyle(
              color: Colors.white, fontSize: 21.0, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
