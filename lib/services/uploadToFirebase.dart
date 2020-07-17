import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
Firestore _firestore = Firestore.instance;

Future uploadMissingInformation(String name,String phone,String bank,String location,String touchPoint,LatLng latLng) async {

  var rng = new Random();
  var code = rng.nextInt(900000) + 100000;
  var dataToUpload = {
      'name':name,
      'phone':phone,
      'bank':bank,
      'latitude':latLng.latitude,
      'longitude':latLng.longitude,
      'location':location,  
      'touchPoint':touchPoint,
      'missingRequestId': code.toString()
  };
  await _firestore.collection("Banks").document(bank).collection("Missing").document(dataToUpload['missingRequestId'].toString()).setData(dataToUpload);
}

Future uploadRequestInformation(String name,String phone,String bank,String touchPoint,String address,LatLng latLng,String comments) async {

  var rng = new Random();
  var code = rng.nextInt(900000) + 100000;
  var dataToUpload = {
      'name':name,
      'phone':phone,
      'bank':bank,
      'locationAddress': address,
      'latitude': latLng.latitude.toString(),
      'longitude':latLng.longitude.toString(),
      'touchPoint':touchPoint,
      'RequestedRequestId': code.toString(),
      'comments':comments
  };
  await _firestore.collection("Banks").document(bank).collection("Request").document(dataToUpload['RequestedRequestId'].toString()).setData(dataToUpload);
}


Future uploadFeedbackInformation(String name,String phone,String bank,String touchPoint,String address,LatLng latLng,String feedback,var rating,var issue) async {

  var rng = new Random();
  var code = rng.nextInt(900000) + 100000;
  var now = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  String formattedDate = formatter.format(now);
  var dataToUpload = {
      'name':name,
      'phone':phone,
      'bank':bank,
      'locationAddress': address,
      'latitude': latLng.latitude.toString(),
      'longitude':latLng.longitude.toString(),
      'touchPoint':touchPoint,
      'FeedbackRequestId': code.toString(),
      'feedback': feedback,
      'rating':rating,
      'date': formattedDate,
      'issue':issue
  };
    await _firestore.collection("Banks").document(bank).collection("Feedback").document(dataToUpload['FeedbackRequestId'].toString()).setData(dataToUpload);
}