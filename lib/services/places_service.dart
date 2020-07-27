import 'package:flutter/widgets.dart';
import 'package:jandhanv2/models/place.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlacesService {
  final key = 'AIzaSyCILGP87TZPkXUobQfqDp9mkPA7IXnEGXU';
  Future<List<Place>> getPlaces(
      double lat, double lng, String type, String lang) async {
    debugPrint("hiii");
    String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&type=' +
            type +
            '&language=' +
            lang +
            '&rankby=distance&key=$key';
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    debugPrint(jsonResults.toList().toString());
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }
}
