import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/i18n.dart' as location_picker;
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:jandhanv2/main.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../generated/i18n.dart';
import '../services/uploadToFirebase.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  LocationResult _pickedLocation;
  String _touchPoint;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bankController = TextEditingController();
  final feedbackMsgController = TextEditingController();
  String _issue;

  final apiKey = "AIzaSyCILGP87TZPkXUobQfqDp9mkPA7IXnEGXU";
   final _formKey = GlobalKey<FormState>(); 
   ProgressDialog pr;
            void _showDialog() {
          // flutter defined function
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Thank you"),
                content: new Text("Thank you for your feedback. We will let the concerned authorities regarding your concern."),
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

  Future uploadData() async{
    await pr.show();
    uploadFeedbackInformation(nameController.text,phoneController.text,bankController.text,_touchPoint,_pickedLocation.address,_pickedLocation.latLng,feedbackMsgController.text);
    pr.hide().whenComplete(() {
          _showDialog();
        });
  }

  @override
  Widget build(BuildContext context) {

        pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    return MaterialApp(
//      theme: ThemeData.dark(),
      title: 'location picker',
      localizationsDelegates: const [
        location_picker.S.delegate,
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en', ''),
        Locale('hi','')
      ],
      home: Scaffold(
        appBar: AppBar(
          title: Text('Feedback Bank/ATM'),
          automaticallyImplyLeading: true,
          leading: IconButton(icon: Icon(Icons.arrow_back),onPressed:()=> Navigator.pop(context,false),),
          
        ),
        body: Builder(builder: (context) {
          return SingleChildScrollView(
           child: Form(  
                  key: _formKey,
                  child: Column(
                  children: <Widget>[
                    SizedBox(height: 15.0,),
                    TextFormField(  
                      controller: nameController,
                      decoration: const InputDecoration(  
                        icon: const Icon(Icons.person),  
                        hintText: 'Enter your name',  
                        labelText: 'Name',  
                      ), 
                    ),
                    SizedBox(height: 15.0,),  
                    TextFormField( 
                      controller: phoneController, 
                      decoration: const InputDecoration(  
                        icon: const Icon(Icons.phone),  
                        hintText: 'Enter a phone number',  
                        labelText: 'Phone',  
                      ),  
                      keyboardType: TextInputType.number,
                    ), 
                    SizedBox(height: 15.0,),
                    TextFormField(  
                      controller: bankController,
                      decoration: const InputDecoration(  
                        icon: const Icon(Icons.person),  
                        hintText: 'Enter Bank Name',  
                        labelText: 'Bank Name',  
                      ), 
                    ),
                    SizedBox(height: 15.0,),
                    DropDownFormField(
                  titleText: 'Select the Touchpoint',
                  hintText: 'Please choose one',
                  value: _touchPoint,
                  onSaved: (value) {
                    setState(() {
                      _touchPoint = value;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _touchPoint = value;
                    });
                  },
                  dataSource: [
                    {
                      "display": "ATM",
                      "value": "ATM",
                    },
                    {
                      "display": "Bank",
                      "value": "Bank",
                    },
                  ],
                  textField: 'display',
                  valueField: 'value',
                ),
                SizedBox(height: 20.0,),
                DropDownFormField(
                  titleText: 'Select your problem domain',
                  hintText: 'Please choose one',
                  value: _issue,
                  onSaved: (value) {
                    setState(() {
                      _issue = value;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _issue = value;
                    });
                  },
                  dataSource: [
                    {
                      "display": "ATM Empty",
                      "value": "ATM Empty",
                    },
                    {
                      "display": "ATM Not Working",
                      "value": "ATM Not Working",
                    },

                    {
                      "display": "BANK Employee misconduct",
                      "value": "BANK Employee misconduct",
                    },
                    {
                      "display": "Regarding bribery",
                      "value": "Regarding bribery",
                    },
                    {
                      "display": "Other Bank related Issues",
                      "value": "Other Bank related Issues",
                    },
                    {
                      "display": "Other ATM related issues.",
                      "value": "Other ATM related issues.",
                    },
                  ],
                  textField: 'display',
                  valueField: 'value',
                ),
                SizedBox(height: 20.0,),
                    RaisedButton(
                            onPressed: () async {
                              LocationResult result = await showLocationPicker(
                                context,
                                apiKey,
                                initialCenter: LatLng(31.1975844, 29.9598339),
                              automaticallyAnimateToCurrentLocation: true,
                                myLocationButtonEnabled: true,
                                layersButtonEnabled: true,
                              resultCardAlignment: Alignment.bottomCenter,
                              );
                              print("result = $result");
                              setState(() => _pickedLocation = result);
                            },
                            child: Text('Pick location of Feedback Bank/ATM'),
                          ),
                          SizedBox(height: 20.0,),
                          (_pickedLocation == null) ? Text("Bank/ATM Location",
                            style: TextStyle(
                              
                            fontWeight: FontWeight.bold,
                            fontSize: 14)) :
                            Center(
                              child: Text(_pickedLocation.address,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                              
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                            ),  
                            SizedBox(height: 20.0,),
                            TextFormField(
                              controller: feedbackMsgController,
                              decoration: const InputDecoration(  
                              icon: const Icon(Icons.person),  
                              hintText: 'Explain the issue in detail',  
                              labelText: 'Explain the issue.',  
                            ),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                            ),
                                Container(
                                  margin: EdgeInsets.all(15),
                                  child: MaterialButton( 
                                    
                                    height: 40.0, 
                                    minWidth: double.infinity, 
                                    color: Theme.of(context).primaryColor, 
                                    padding: EdgeInsets.all(10),
                                    textColor: Colors.white, 
                                    child: new Text("Submit Information"), 
                                    onPressed: () => {
                                      uploadData()
                                    }, 
                                    splashColor: Colors.redAccent,
                                  ),
                                )          ],
            ),
          ));
        }),
      ),
    );
  }
}

   