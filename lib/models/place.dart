import 'package:jandhanv2/models/geometry.dart';

class Place {
  final String name;
  final double rating;
  final int userRatingCount;
  final String vicinity;
  final Geometry geometry;
  final String openNow;
  final String openingHours;
  final String phoneNumber;

  Place(
      {this.geometry,
      this.name,
      this.rating,
      this.userRatingCount,
      this.vicinity,
      this.openNow,
      this.openingHours,
      this.phoneNumber});

  Place.fromJson(Map<dynamic, dynamic> parsedJson)
      : name = parsedJson['name'],
        rating = (parsedJson['rating'] != null)
            ? parsedJson['rating'].toDouble()
            : null,
        userRatingCount = (parsedJson['user_ratings_total'] != null)
            ? parsedJson['user_ratings_total']
            : null,
        vicinity = parsedJson['vicinity'],
        openNow = (parsedJson['opening_hours'] != null)
            ? (parsedJson['opening_hours']['open_now']) ? "Open" : "Closed"
            : "Not Available",
        geometry = Geometry.fromJson(parsedJson['geometry']),
        openingHours = (parsedJson['opening_hours'] != null)
            ? "10:00 - 18:00"
            : "09:00 - 19:00",
        phoneNumber = (parsedJson['formatted_phone_number'] == null)
            ? "9611890453"
            : "9780456211";
}
