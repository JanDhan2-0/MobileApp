import 'dart:convert';

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
    List<Place> places =  jsonResults.map((place) => Place.fromJson(place,lang)).toList();
    return translate(places,lang);
  }

  Future<List<Place>> translate(List<Place> places,String language) async {

    /**
     * Algorithm:
     *  1. I will first convert all the names
     *  2. I will then convert all the vicinity wala part
     *  3. I will replace it in corresponding json
     *  4. We will reload the screen. 
     */
  // List<Place> translatedPlaces;
  debugPrint("Hello");
  List<String> atmNamesVicinity = new List<String>();

  for(int i=0;i<places.length;i++){
    atmNamesVicinity.add(places[i].name);
    atmNamesVicinity.add(places[i].vicinity);
  }


    Map data = {
      'q': atmNamesVicinity,
      'target': language
    };

    String body = json.encode(data);
    http.Response response = await http.post(
      'https://translation.googleapis.com/language/translate/v2?key=AIzaSyCILGP87TZPkXUobQfqDp9mkPA7IXnEGXU',
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    var jsonResult = convert.jsonDecode(response.body);
    var jsonTrans = jsonResult['data']['translations'] as List;
    var k = 0;
    for(int i=0;i<jsonTrans.length;i+=2){
        places[k].name = jsonTrans[i]['translatedText'];
        places[k].vicinity = jsonTrans[i+1]['translatedText'];
        k = k + 1;
    }
  return places;
}

}
