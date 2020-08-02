import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jandhanv2/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jandhanv2/screens/ReviewsScreen.dart';

class MarkerService {
  List<Marker> getMarkers(List<Place> places, String type,
      BitmapDescriptor myIcon, BitmapDescriptor otherIcon,context) {
    List<Marker> markers = <Marker>[];
    places.forEach((place) {
      Marker marker = Marker(
          markerId: MarkerId(place.place_id),
          draggable: false,
          infoWindow: InfoWindow(title: place.name, snippet: place.vicinity,onTap:()=>{
              Navigator.push(context,
                                        MaterialPageRoute(
                                          builder: (context) => ReviewsScreen(),
                                        ),
                                      )
          } ),
          position:
              LatLng(place.geometry.location.lat, place.geometry.location.lng),
          icon: type == 'atm'
              ? place.userComplaints < 10 ? myIcon : otherIcon
              : myIcon);
      markers.add(marker);
    });
    return markers;
  }
}
