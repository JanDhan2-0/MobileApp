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
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import './styles/style.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyApp1();
  }
}

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(tr('accinfo'))), body: MyCustomForm());
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

enum AppState {
  free,
  picked,
  cropped,
}

class MyCustomFormState extends State<MyCustomForm> {
  Firestore _firestore = Firestore.instance;
  AppState state1;
  File _aadharImage;
  AppState state2;
  File _panImage;
  File _sigImage;
  AppState state3;
  File _photoImage;
  AppState state4;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final panNoController = TextEditingController();
  final aadharNoController = TextEditingController();

  String _bankName;

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
                  
                  MaterialPageRoute(builder: (context) => MyApp1()),
                );
              },
            ),
          ],
        );
      },
    );
  }


  String encrypt(String data){
      var str = data;
      var bytes = utf8.encode(str);
      var base64Str = base64.encode(bytes);
      return base64Str;
  }

  Future uploadImages() async {
    await pr.show();
    var rng = new Random();
    var code = rng.nextInt(900000) + 100000;
    final StorageReference aadharStorageReference =
        FirebaseStorage().ref().child("Aadhar/aadhaar_card" + code.toString());
    final StorageReference panStorageReference =
        FirebaseStorage().ref().child("PAN/pan_card" + code.toString());
    final StorageReference sigStorageReference =
        FirebaseStorage().ref().child("Signature/sig" + code.toString());
    final StorageReference photoStorageReference =
        FirebaseStorage().ref().child("Photo/photo" + code.toString());

    final StorageUploadTask uploadTask1 =
        aadharStorageReference.putFile(_aadharImage);
    final StorageUploadTask uploadTask2 =
        panStorageReference.putFile(_panImage);
    final StorageUploadTask uploadTask3 =
        sigStorageReference.putFile(_sigImage);
    final StorageUploadTask uploadTask4 =
        photoStorageReference.putFile(_photoImage);

    final StreamSubscription<StorageTaskEvent> streamSubscription1 =
        uploadTask1.events.listen((event) {
      print('EVENT ${event.type}');
    });
    final StreamSubscription<StorageTaskEvent> streamSubscription2 =
        uploadTask2.events.listen((event) {
      print('EVENT ${event.type}');
    });
    final StreamSubscription<StorageTaskEvent> streamSubscription3 =
        uploadTask3.events.listen((event) {
      print('EVENT ${event.type}');
    });
    final StreamSubscription<StorageTaskEvent> streamSubscription4 =
        uploadTask4.events.listen((event) {
      print('EVENT ${event.type}');
    });

    await uploadTask1.onComplete;
    streamSubscription1.cancel();

    await uploadTask2.onComplete;
    streamSubscription2.cancel();

    await uploadTask3.onComplete;
    streamSubscription3.cancel();

    await uploadTask4.onComplete;
    streamSubscription4.cancel();

    String aadharUrl = await aadharStorageReference.getDownloadURL();
    String panUrl = await panStorageReference.getDownloadURL();
    String signatureUrl = await sigStorageReference.getDownloadURL();
    String photoUrl = await photoStorageReference.getDownloadURL();

    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate);

    await _firestore
        .collection("Banks")
        .document(_bankName)
        .collection("Account")
        .document(code.toString())
        .setData({
      "name": encrypt(nameController.text),
      "phone": encrypt(phoneController.text),
      "email": encrypt(emailController.text),
      "dob": encrypt(dobController.text),
      "address": encrypt(addressController.text),
      "aadharUrl": encrypt(aadharUrl),
      "panUrl": encrypt(panUrl),
      "signatureUrl": encrypt(signatureUrl),
      "photoUrl": encrypt(photoUrl),
      "bank": encrypt(_bankName),
      "uniqueId": code,
      "status": "Pending",
      "account_creation_date": encrypt(formattedDate),
      "purpose": "A/C Creation",
      "formId": _bankName + code.toString(),
      "panNo": encrypt(panNoController.text),
      "aadharNo": encrypt(aadharNoController.text),
      "bankInitiated":false
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

  Future<Null> _pickImage1() async {
    _aadharImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (_aadharImage != null) {
      setState(() {
        state1 = AppState.picked;
      });
    }
  }

  Future<Null> _cropImage1() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _aadharImage.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue[600],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _aadharImage = croppedFile;
      setState(() {
        state1 = AppState.cropped;
      });
    }
  }

  void _clearImage1() {
    _aadharImage = null;
    setState(() {
      state1 = AppState.free;
    });
  }

  Future<Null> _pickImage3() async {
    _sigImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (_sigImage != null) {
      setState(() {
        state3 = AppState.picked;
      });
    }
  }

  Future<Null> _cropImage3() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _sigImage.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue[600],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _sigImage = croppedFile;
      setState(() {
        state3 = AppState.cropped;
      });
    }
  }

  void _clearImage3() {
    _sigImage = null;
    setState(() {
      state3 = AppState.free;
    });
  }

  Future<Null> _pickImage4() async {
    _photoImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (_photoImage != null) {
      setState(() {
        state4 = AppState.picked;
      });
    }
  }

  Future<Null> _cropImage4() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _photoImage.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue[600],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _photoImage = croppedFile;
      setState(() {
        state4 = AppState.cropped;
      });
    }
  }

  void _clearImage4() {
    _photoImage = null;
    setState(() {
      state4 = AppState.free;
    });
  }

  Future<Null> _pickImage2() async {
    _panImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (_panImage != null) {
      setState(() {
        state2 = AppState.picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    state1 = AppState.free;
    state2 = AppState.free;
    state3 = AppState.free;
    state4 = AppState.free;
  }

  Future<Null> _cropImage2() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _panImage.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue[600],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _panImage = croppedFile;
      setState(() {
        state2 = AppState.cropped;
      });
    }
  }

  void _clearImage2() {
    _panImage = null;
    setState(() {
      state2 = AppState.free;
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        message: '\tUploading Data...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget:
            SizedBox(height: 50, width: 50, child: CircularProgressIndicator()),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold));
    return SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Container(
              width: MediaQuery.of(context).size.width - 9.0,
              padding: EdgeInsets.all(25.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                      controller: nameController,
                      decoration: Style.inputDecor(
                          Icon(Icons.person), tr('name'), 'Enter your Name')),
                  Style.space(),
                  TextFormField(
                    controller: phoneController,
                    decoration: Style.inputDecor(Icon(Icons.call), tr('phno'),
                        'Enter your Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  Style.space(),
                  TextFormField(
                    controller: dobController,
                    decoration: Style.inputDecor(Icon(Icons.calendar_today),
                        tr('dob'), 'Enter your Date of Birth'),
                    keyboardType: TextInputType.datetime,
                  ),
                  Style.space(),
                  TextFormField(
                      controller: addressController,
                      decoration: Style.inputDecor(Icon(Icons.location_city),
                          tr('permaddr'), 'Enter your Address'),
                      keyboardType: TextInputType.multiline),
                  Style.space(),
                  TextFormField(
                      controller: emailController,
                      decoration: Style.inputDecor(Icon(Icons.mail),
                          tr('email'), 'Enter your E-Mail ID'),
                      keyboardType: TextInputType.emailAddress),
                  Style.space(),
                  TextFormField(
                      controller: aadharNoController,
                      decoration: Style.inputDecor(
                          Icon(Icons.chrome_reader_mode),
                          tr('aadhaar'),
                          'Enter your Aadhaar Number'),
                      keyboardType: TextInputType.number),
                  Style.space(),
                  TextFormField(
                    controller: panNoController,
                    decoration: Style.inputDecor(
                        Icon(Icons.credit_card), 'PAN', 'Enter your PAN'),
                    keyboardType: TextInputType.number,
                  ),
                  Style.space(),
                  Container(
                      decoration: Style.boxDecor(),
                      child: DropDownFormField(
                        titleText: tr('selbank'),
                        hintText: 'Please choose one',
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
                            "value": "SBI",
                          },
                          {
                            "display": "Bank Of Baroda",
                            "value": "BOB",
                          },
                          {
                            "display": "HDFC Bank",
                            "value": "HDFC",
                          },
                          {
                            "display": "Punjab National Bank",
                            "value": "PNB",
                          },
                        ],
                        textField: 'display',
                        valueField: 'value',
                      )),
                  Style.space(),
                  Column(
                    children: <Widget>[
                      Container(
                        height: 200,
                        child: (_aadharImage != null)
                            ? Image.file(
                                _aadharImage,
                                fit: BoxFit.fill,
                              )
                            : GestureDetector(
                                onTap: () => (state1 == AppState.free)
                                    ? _pickImage1()
                                    : (state1 == AppState.picked)
                                        ? _cropImage1()
                                        : _clearImage1(),
                                child:
                                    Style.greyBox(context, tr('aadhaarimg'))),
                      ),
                      Style.space(),
                      Container(
                        height: 200,
                        child: (_panImage != null)
                            ? Image.file(
                                _panImage,
                                fit: BoxFit.fill,
                              )
                            : GestureDetector(
                                onTap: () => (state2 == AppState.free)
                                    ? _pickImage2()
                                    : (state2 == AppState.picked)
                                        ? _cropImage2()
                                        : _clearImage2(),
                                child: Style.greyBox(context, tr('panimg'))),
                      ),
                      Style.space(),
                      Container(
                        height: 200,
                        child: (_sigImage != null)
                            ? Image.file(
                                _sigImage,
                                fit: BoxFit.fill,
                              )
                            : GestureDetector(
                                onTap: () => (state3 == AppState.free)
                                    ? _pickImage3()
                                    : (state3 == AppState.picked)
                                        ? _cropImage3()
                                        : _clearImage3(),
                                child: Style.greyBox(context, tr('signimg'))),
                      ),
                      Style.space(),
                      Container(
                        height: 200,
                        child: (_photoImage != null)
                            ? Image.file(
                                _photoImage,
                                fit: BoxFit.fill,
                              )
                            : GestureDetector(
                                onTap: () => (state4 == AppState.free)
                                    ? _pickImage4()
                                    : (state4 == AppState.picked)
                                        ? _cropImage4()
                                        : _clearImage4(),
                                child: Style.greyBox(context, tr('passimg'))),
                      ),
                    ],
                  ),
                  Style.space(),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: MaterialButton(
                      height: 49.0,
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.all(10),
                      textColor: Colors.white,
                      child: new Text(
                        tr('submit'),
                        style: TextStyle(fontSize: 18.0),
                      ),
                      onPressed: () => {uploadImages()},
                      splashColor: Colors.redAccent,
                    ),
                  )
                ],
              ),
            )));
  }
}
