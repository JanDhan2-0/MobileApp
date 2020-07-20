import 'package:jandhanv2/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerService {
  List<Marker> getMarkers(
      List<Place> places, String type, BitmapDescriptor myIcon) {
    List<Marker> markers = <Marker>[];
    places.forEach((place) {
      Marker marker = Marker(
          markerId: MarkerId(place.name),
          draggable: false,
          infoWindow: InfoWindow(title: place.name, snippet: place.vicinity),
          position:
              LatLng(place.geometry.location.lat, place.geometry.location.lng),
          icon: myIcon);
      markers.add(marker);
    });
    return markers;
  }
}
