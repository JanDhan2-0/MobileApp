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
      appBar: AppBar(title: Text('Upload Details')),
      body: MyCustomForm());
  }
} 
    // Create a Form widget.  
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
    // Create a corresponding State class, which holds data related to the form.  
    class MyCustomFormState extends State<MyCustomForm> {  
      // Create a global key that uniquely identifies the Form widget  
      // and allows validation of the form.  
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
          // flutter defined function
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Upload Success"),
                content: new Text("An OTP has been sent to your mobile. Please share the same with the bank executive when you visit the bank."),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
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

      Future uploadImages() async{
        await pr.show();
        var rng = new Random();
        var code = rng.nextInt(900000) + 100000;
        final StorageReference aadharStorageReference = FirebaseStorage().ref().child("Aadhar/aadhaar_card"+code.toString());
        final StorageReference panStorageReference = FirebaseStorage().ref().child("PAN/pan_card"+code.toString());
        final StorageReference sigStorageReference = FirebaseStorage().ref().child("Signature/sig"+code.toString());
        final StorageReference photoStorageReference = FirebaseStorage().ref().child("Photo/photo"+code.toString());
        
        final StorageUploadTask uploadTask1 = aadharStorageReference.putFile(_aadharImage);
        final StorageUploadTask uploadTask2 = panStorageReference.putFile(_panImage);
        final StorageUploadTask uploadTask3 = sigStorageReference.putFile(_sigImage);
        final StorageUploadTask uploadTask4 = photoStorageReference.putFile(_photoImage);

        final StreamSubscription<StorageTaskEvent> streamSubscription1 = uploadTask1.events.listen((event) {
          print('EVENT ${event.type}');
        });
        final StreamSubscription<StorageTaskEvent> streamSubscription2 = uploadTask2.events.listen((event) {
          print('EVENT ${event.type}');
        });
        final StreamSubscription<StorageTaskEvent> streamSubscription3 = uploadTask3.events.listen((event) {
          print('EVENT ${event.type}');
        });
        final StreamSubscription<StorageTaskEvent> streamSubscription4 = uploadTask4.events.listen((event) {
          print('EVENT ${event.type}');
        });

        // Cancel your subscription when done.
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

        await _firestore.collection("Banks").document(_bankName).collection("Account").document(code.toString()).setData({
          "name":nameController.text,
          "phone":phoneController.text,
          "email":emailController.text,
          "dob":dobController.text,
          "address":addressController.text,
          "aadharUrl": aadharUrl,
          "panUrl":panUrl,
          "signatureUrl":signatureUrl,
          "photoUrl":photoUrl,
          "bank": _bankName,
          "uniqueId":code,
          "status":"Pending",
          "account_creation_date": formattedDate,
          "purpose":"A/C Creation",
          "formId":_bankName+code.toString(),
          "panNo":panNoController.text,
          "aadharNo":aadharNoController.text
        }
        );
        await http.post(
          'http://jandhan2.herokuapp.com/account/sendOtp/',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            "number":phoneController.text,
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
            toolbarColor: Colors.deepOrange,
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
            toolbarColor: Colors.deepOrange,
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
            toolbarColor: Colors.deepOrange,
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
            toolbarColor: Colors.deepOrange,
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
        // Build a Form widget using the _formKey created above.  
        // user defined function
  
        pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
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
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
          );
                return SingleChildScrollView(
           child: Form(  
          key: _formKey,  
          child: Column(  
            children: <Widget>[  
              TextFormField(  
                      controller: nameController,
                      decoration: const InputDecoration(  
                        icon: const Icon(Icons.person),  
                        hintText: 'Enter your name',  
                        labelText: 'Name',  
                      ), 
                    ),
                    SizedBox(height: 10.0,),  
                    TextFormField( 
                      controller: phoneController, 
                      decoration: const InputDecoration(  
                        icon: const Icon(Icons.phone),  
                        hintText: 'Enter a phone number',  
                        labelText: 'Phone',  
                      ),  
                      keyboardType: TextInputType.number,
                    ), 
                    SizedBox(height: 10.0,),  
              TextFormField(  
                controller: dobController,
                decoration: const InputDecoration(  
                icon: const Icon(Icons.calendar_today),  
                hintText: 'Enter your date of birth',  
                labelText: 'Dob',  
                ),  
               ),
               SizedBox(height: 10.0,), 
              TextFormField( 
                controller: addressController, 
                decoration: const InputDecoration(  
                  icon: const Icon(Icons.home),  
                  hintText: 'Enter your Address',  
                  labelText: 'Permanent Address',  
                ),  
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 10.0,), 
              TextFormField(  
                controller: emailController,
                decoration: const InputDecoration(  
                  icon: const Icon(Icons.email),  
                  hintText: 'Enter the Email',  
                  labelText: 'Email',  
                ),  
                keyboardType: TextInputType.emailAddress,
              ),
                 SizedBox(height: 10.0,),  
                    TextFormField( 
                      controller: aadharNoController, 
                      decoration: const InputDecoration(  
                        icon: const Icon(Icons.confirmation_number),  
                        hintText: 'Enter the Aadhar Number',  
                        labelText: 'Phone',  
                      ),  
                      keyboardType: TextInputType.number,
                    ), 
                       SizedBox(height: 10.0,),  
                    TextFormField( 
                      controller: panNoController, 
                      decoration: const InputDecoration(  
                        icon: const Icon(Icons.confirmation_number),  
                        hintText: 'Enter the PAN Number',  
                        labelText: 'Phone',  
                      ),  
                      keyboardType: TextInputType.number,
                    ), 
              SizedBox(height: 20.0,),
              DropDownFormField(
                  titleText: 'Select the Bank',
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
                ),
                SizedBox(height: 10.0,),
                Column(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        debugPrint(state1.toString());
                        if (state1 == AppState.free)
                            _pickImage1();
                        else if (state1 == AppState.picked)
                          _cropImage1();
                        else if (state1 == AppState.cropped) _clearImage1();
                      },
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF1976D2),
                              Color(0xFF42A5F5),
                            ],
                          ),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child:
                            const Text('Choose Aadhar Card', style: TextStyle(fontSize: 20)),
                      ),
          ),
          SizedBox(height: 10.0,),
          Container(
            margin: EdgeInsets.all(10.0),
            height: 300,
            width: double.infinity,
            child: (_aadharImage != null ) ? Image.file(_aadharImage,fit: BoxFit.fill,) : Image.asset("assets/images/a.png"),
            ),
                SizedBox(height: 10.0,),
                    RaisedButton(
                  onPressed: () {
                    if (state2 == AppState.free)
                    _pickImage2();
                  else if (state2 == AppState.picked)
                    _cropImage2();
                  else if (state2 == AppState.cropped) _clearImage2();
                  },
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child:
                        const Text('Choose Pan Card', style: TextStyle(fontSize: 20)),
                  ),
          ),
          SizedBox(height: 10.0,),
          Container(
            margin: EdgeInsets.all(10.0),
            height: 300,
            width: double.infinity,
            child: (_panImage != null ) ? Image.file(_panImage,fit: BoxFit.fill,) : Image.asset("assets/images/a.png"),
            ),
               SizedBox(height: 10.0,),
                    RaisedButton(
                  onPressed: () {
                    if (state3 == AppState.free)
                    _pickImage3();
                  else if (state3 == AppState.picked)
                    _cropImage3();
                  else if (state3 == AppState.cropped) _clearImage3();
                  },
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child:
                        const Text('Choose Signature', style: TextStyle(fontSize: 20)),
                  ),
          ),
          SizedBox(height: 10.0,),
          Container(
            margin: EdgeInsets.all(10.0),
            height: 300,
            width: double.infinity,
            child: (_sigImage != null ) ? Image.file(_sigImage,fit: BoxFit.fill,) : Image.asset("assets/images/a.png"),
            ),
           SizedBox(height: 10.0,),
                    RaisedButton(
                  onPressed: () {
                    if (state4 == AppState.free)
                    _pickImage4();
                  else if (state3 == AppState.picked)
                    _cropImage4();
                  else if (state4 == AppState.cropped) _clearImage4();
                  },
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child:
                        const Text('Choose Photo', style: TextStyle(fontSize: 20)),
                  ),
          ),
          SizedBox(height: 10.0,),
          Container(
            margin: EdgeInsets.all(10.0),
            height: 300,
            width: double.infinity,
            child: (_photoImage != null ) ? Image.file(_photoImage,fit: BoxFit.fill,) : Image.asset("assets/images/a.png"),
            ),
                  ],
                ),
                 RaisedButton(
                      onPressed: () {
                          uploadImages();
                      },
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF1976D2),
                              Color(0xFF42A5F5),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child:
                            const Text('Upload', style: TextStyle(fontSize: 20)),
                      ),
          ),
              ],  
          ),  
        )
        );  
      }  
    }  
    