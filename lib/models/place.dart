import 'package:jandhanv2/models/geometry.dart';
import 'package:easy_localization/easy_localization.dart';

class Place {
  String name;
  double rating;
  int userRatingCount;
  String vicinity;
  Geometry geometry;
  String openNow;
  String openingHours;
  String phoneNumber;
  int userComplaints = 0;
  String place_id;
  Place(
      {this.geometry,
      this.name,
      this.rating,
      this.userRatingCount,
      this.vicinity,
      this.openNow,
      this.openingHours,
      this.phoneNumber,
      this.place_id});

  Place.fromJson(Map<dynamic, dynamic> parsedJson, String lang)
      : name = parsedJson['name'],
        rating = (parsedJson['rating'] != null)
            ? parsedJson['rating'].toDouble()
            : null,
        userRatingCount = (parsedJson['user_ratings_total'] != null)
            ? parsedJson['user_ratings_total']
            : null,
        vicinity = parsedJson['vicinity'],
        openNow = (parsedJson['opening_hours'] != null)
            ? (parsedJson['opening_hours']['open_now'])
                ? tr('open')
                : tr('closed')
            : tr('out'),
        geometry = Geometry.fromJson(parsedJson['geometry']),
        openingHours = (parsedJson['opening_hours'] != null)
            ? "10:00 - 18:00"
            : "09:00 - 19:00",
        phoneNumber = (parsedJson['formatted_phone_number'] == null)
            ? "9611890453"
            : "9780456211",
        place_id = parsedJson['place_id'],
        userComplaints = 0;
}
