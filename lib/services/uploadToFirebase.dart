import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
Firestore _firestore = Firestore.instance;

Future uploadMissingInformation(String name,String phone,String bank,String location,String touchPoint) async {

  var rng = new Random();
  var code = rng.nextInt(900000) + 100000;
  var dataToUpload = {
      'name':name,
      'phone':phone,
      'bank':bank,
      'location':location,
      'touchPoint':touchPoint,
      'missingRequestId': code.toString()
  };
  if(touchPoint == 'ATM'){
    await _firestore.collection("MissingATMs").document(dataToUpload['missingRequestId'].toString()).setData(dataToUpload);
  }
  else{
    await _firestore.collection("MissingBanks").document(dataToUpload['missingRequestId'].toString()).setData(dataToUpload);
  }
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
  if(touchPoint == 'ATM'){
    await _firestore.collection("RequestedATMs").document(dataToUpload['RequestedRequestId'].toString()).setData(dataToUpload);
  }
  else{
    await _firestore.collection("RequestedBanks").document(dataToUpload['RequestedRequestId'].toString()).setData(dataToUpload);
  }
}


Future uploadFeedbackInformation(String name,String phone,String bank,String touchPoint,String address,LatLng latLng,String feedback) async {

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
      'FeedbackRequestId': code.toString(),
      'feedback': feedback
  };
  if(touchPoint == 'ATM'){
    await _firestore.collection("FeedbackATMs").document(dataToUpload['FeedbackRequestId'].toString()).setData(dataToUpload);
  }
  else{
    await _firestore.collection("FeedbackBanks").document(dataToUpload['FeedbackRequestId'].toString()).setData(dataToUpload);
  }
}