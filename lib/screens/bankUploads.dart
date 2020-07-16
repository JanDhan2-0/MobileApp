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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyApp1(),
    );
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
    // Create a corresponding State class, which holds data related to the form.  
    class MyCustomFormState extends State<MyCustomForm> {  
      // Create a global key that uniquely identifies the Form widget  
      // and allows validation of the form.  
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

        final StorageUploadTask uploadTask1 = aadharStorageReference.putFile(_aadharImage);
        final StorageUploadTask uploadTask2 = panStorageReference.putFile(_panImage);

        final StreamSubscription<StorageTaskEvent> streamSubscription1 = uploadTask1.events.listen((event) {
          print('EVENT ${event.type}');
        });
        final StreamSubscription<StorageTaskEvent> streamSubscription2 = uploadTask2.events.listen((event) {
          print('EVENT ${event.type}');
        });

        // Cancel your subscription when done.
        await uploadTask1.onComplete;
        streamSubscription1.cancel();

        await uploadTask2.onComplete;
        streamSubscription2.cancel();

        String aadharUrl = await aadharStorageReference.getDownloadURL();
        String panUrl = await panStorageReference.getDownloadURL();
        await _firestore.collection("AccoutDocuments").document(code.toString()).setData({
          "name":nameController.text,
          "phone":phoneController.text,
          "email":emailController.text,
          "branchId":branchIdController.text,
          "dob":dobController.text,
          "address":addressController.text,
          "aadharUrl": aadharUrl,
          "panUrl":panUrl,
          "bank": _bankName,
          "uniqueId":code
        }
        );
        await http.post(
          'http://205afcdfb1fb.ngrok.io/account/sendOtp/',
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

      Future getImage(var documentNo) async{
        File image = await ImagePicker.pickImage(source: ImageSource.camera);
        if(documentNo == 1){
          setState(() {
            _aadharImage = image;
          });
        }
        else{
          setState(() {
            _panImage = image;
          });
        }
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
                  hintText: 'Enter your full name',  
                  labelText: 'Name',  
                ),  
                validator: (value) {  
                  if (value.isEmpty) {  
                    return 'Please enter some text';  
                  }  
                  return null;  
                },  
              ),  
              TextFormField(  
                controller: phoneController,
                decoration: const InputDecoration(  
                  icon: const Icon(Icons.phone),  
                  hintText: 'Enter a phone number',  
                  labelText: 'Phone',  
                ),  
                validator: (value) {  
                  if (value.isEmpty) {  
                    return 'Please enter valid phone number';  
                  }  
                  return null;  
                },  
              ),  
              TextFormField(  
                controller: dobController,
                decoration: const InputDecoration(  
                icon: const Icon(Icons.calendar_today),  
                hintText: 'Enter your date of birth',  
                labelText: 'Dob',  
                ),  
                validator: (value) {  
                  if (value.isEmpty) {  
                    return 'Please enter valid date';  
                  }  
                  return null;  
                },  
               ),
              TextFormField( 
                controller: addressController, 
                decoration: const InputDecoration(  
                  icon: const Icon(Icons.home),  
                  hintText: 'Enter your Address',  
                  labelText: 'Permanent Address',  
                ),  
                validator: (value) {  
                  if (value.isEmpty) {  
                    return 'Please enter the Address';  
                  }  
                  return null;  
                },  
              ),
              TextFormField(  
                controller: branchIdController,
                decoration: const InputDecoration(  
                  icon: const Icon(Icons.account_balance),  
                  hintText: 'Enter the Branch Id',  
                  labelText: 'Branch Id',  
                ),  
                validator: (value) {  
                  if (value.isEmpty) {  
                    return 'Please enter the branch Id';  
                  }  
                  return null;  
                },  
              ),
              TextFormField(  
                controller: emailController,
                decoration: const InputDecoration(  
                  icon: const Icon(Icons.email),  
                  hintText: 'Enter the Email',  
                  labelText: 'Email',  
                ),  
                validator: (value) {  
                  if (value.isEmpty) {  
                    return 'Please enter the email';  
                  }  
                  return null;  
                },  
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
                ),
                SizedBox(height: 10.0,),
                Column(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        getImage(1);
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
            child: (_aadharImage != null ) ? Image.file(_aadharImage,fit: BoxFit.fill,) : Image.asset("assets/images/aadhaar.jpg"),
            ),
                SizedBox(height: 10.0,),
                    RaisedButton(
                  onPressed: () {
                    getImage(2);
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
            child: (_panImage != null ) ? Image.file(_panImage,fit: BoxFit.fill,) : Image.asset("assets/images/pan.jpg"),
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
    