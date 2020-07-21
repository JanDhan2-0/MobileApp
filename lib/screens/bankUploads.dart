import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jandhanv2/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

class HomeScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Create JDD Account'),
          automaticallyImplyLeading: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false))),
      body: MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  Firestore _firestore = Firestore.instance;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final branchIdController = TextEditingController();
  String _bankName;
  File _aadharImage;
  File _panImage;
  ProgressDialog pr;
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Upload Success"),
          content: new Text(
              "An OTP has been sent to your mobile. Please share the same with the bank executive when you visit the bank."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future uploadImages() async {
    await pr.show();
    var rng = new Random();
    var code = rng.nextInt(900000) + 100000;
    final StorageReference aadharStorageReference =
        FirebaseStorage().ref().child("Aadhar/aadhaar_card" + code.toString());
    final StorageReference panStorageReference =
        FirebaseStorage().ref().child("PAN/pan_card" + code.toString());

    final StorageUploadTask uploadTask1 =
        aadharStorageReference.putFile(_aadharImage);
    final StorageUploadTask uploadTask2 =
        panStorageReference.putFile(_panImage);

    final StreamSubscription<StorageTaskEvent> streamSubscription1 =
        uploadTask1.events.listen((event) {
      print('EVENT ${event.type}');
    });
    final StreamSubscription<StorageTaskEvent> streamSubscription2 =
        uploadTask2.events.listen((event) {
      print('EVENT ${event.type}');
    });

    await uploadTask1.onComplete;
    streamSubscription1.cancel();

    await uploadTask2.onComplete;
    streamSubscription2.cancel();

    String aadharUrl = await aadharStorageReference.getDownloadURL();
    String panUrl = await panStorageReference.getDownloadURL();
    await _firestore
        .collection("AccoutDocuments")
        .document(code.toString())
        .setData({
      "name": nameController.text,
      "phone": phoneController.text,
      "email": emailController.text,
      "branchId": branchIdController.text,
      "dob": dobController.text,
      "address": addressController.text,
      "aadharUrl": aadharUrl,
      "panUrl": panUrl,
      "bank": _bankName,
      "uniqueId": code
    });
    await http.post(
      'http://jandhan2.herokuapp.com/account/sendOtp/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "number": phoneController.text,
        "otp": code.toString()
      }),
    );

    pr.hide().whenComplete(() {
      _showDialog();
    });
  }

  Future getImage(var documentNo) async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (documentNo == 1) {
      setState(() {
        _aadharImage = image;
      });
    } else {
      setState(() {
        _panImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        message: 'Uploading Data',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    return SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Name",
                        hintText: "Enter your full name",
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 2.75, color: Colors.blue[600])),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue[600],
                            width: 2.0,
                          ),
                        )),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter Name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                        hintText: 'Enter a phone number',
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.call),
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 2.75, color: Colors.blue[600])),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue[600],
                            width: 2.0,
                          ),
                        )),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter valid Phone Number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    controller: dobController,
                    decoration: InputDecoration(
                        hintText: 'DD/MM/YYYY',
                        labelText: 'DOB',
                        prefixIcon: Icon(Icons.calendar_today),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 2.75, color: Colors.blue[600])),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue[600],
                            width: 2.0,
                          ),
                        )),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a valid Date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                        hintText: 'Enter your Address',
                        labelText: 'Permanent Address',
                        prefixIcon: Icon(Icons.home),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 2.75, color: Colors.blue[600])),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue[600],
                            width: 2.0,
                          ),
                        )),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a valid Address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    controller: branchIdController,
                    decoration: InputDecoration(
                        hintText: 'Enter the Branch Id',
                        labelText: 'Branch Id',
                        prefixIcon: Icon(Icons.account_balance),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 2.75, color: Colors.blue[600])),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue[600],
                            width: 2.0,
                          ),
                        )),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the Branch ID';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        hintText: 'Enter the Email',
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 2.75, color: Colors.blue[600])),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue[600],
                            width: 2.0,
                          ),
                        )),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the Email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(width: 2.0, color: Colors.blue[600]),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: DropDownFormField(
                        titleText: 'Select Bank',
                        hintText: 'Choose one',
                        value: _bankName,
                        onSaved: (value) {
                          setState(() {
                            _bankName = value;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _bankName = value;
                          });
                        },
                        dataSource: [
                          {
                            "display": "State Bank Of India",
                            "value": "State Bank Of India",
                          },
                          {
                            "display": "Punjab National Bank",
                            "value": "Punjab National Bank",
                          },
                          {
                            "display": "Indian Bank",
                            "value": "Indian Bank",
                          },
                          {
                            "display": "Bank of Baroda",
                            "value": "Bank Of Baroda",
                          },
                          {
                            "display": "Karnataka Bank",
                            "value": "Karnataka Bank"
                          },
                        ],
                        textField: 'display',
                        valueField: 'value',
                      )),
                  SizedBox(
                    height: 15.0,
                  ),
                  Column(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () => null, //getImage(1),
                          child: Container(
                            height: 180,
                            child: (_aadharImage != null)
                                ? Image.file(
                                    _aadharImage,
                                    fit: BoxFit.fill,
                                  )
                                : Container(
                                    height: 180,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blueGrey[50],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                        padding: EdgeInsets.only(top: 75.0),
                                        child: Column(children: <Widget>[
                                          Icon(Icons.linked_camera),
                                          Text('Add Passport Size Photo')
                                        ]))),
                          )),
                      SizedBox(
                        height: 15.0,
                      ),
                      GestureDetector(
                          onTap: () => getImage(1),
                          child: Container(
                            height: 180,
                            child: (_aadharImage != null)
                                ? Image.file(
                                    _aadharImage,
                                    fit: BoxFit.fill,
                                  )
                                : Container(
                                    height: 180,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blueGrey[50],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                        padding: EdgeInsets.only(top: 75.0),
                                        child: Column(children: <Widget>[
                                          Icon(Icons.linked_camera),
                                          Text('Add Aadhar Card')
                                        ]))),
                          )),
                      SizedBox(
                        height: 15.0,
                      ),
                      GestureDetector(
                          onTap: () => getImage(2),
                          child: Container(
                            height: 200,
                            child: (_panImage != null)
                                ? Image.file(
                                    _panImage,
                                    fit: BoxFit.fill,
                                  )
                                : Container(
                                    height: 180,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.blueGrey[50],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                        padding: EdgeInsets.only(top: 75.0),
                                        child: Column(children: <Widget>[
                                          Icon(Icons.linked_camera),
                                          Text('Add Pan Card')
                                        ]))),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  GestureDetector(
                      onTap: () => null, //getImage(1),
                      child: Container(
                        height: 180,
                        child: (_aadharImage != null)
                            ? Image.file(
                                _aadharImage,
                                fit: BoxFit.fill,
                              )
                            : Container(
                                height: 180,
                                width: 375,
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey[50],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
                                child: Padding(
                                    padding: EdgeInsets.only(top: 75.0),
                                    child: Column(children: <Widget>[
                                      Icon(Icons.linked_camera),
                                      Text('Add Signature')
                                    ]))),
                      )),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    width: 375,
                    height: 49.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: RaisedButton(
                      onPressed: () {
                        uploadImages();
                      },
                      color: Colors.blue[600],
                      child: Text('UPLOAD',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )));
  }
}
