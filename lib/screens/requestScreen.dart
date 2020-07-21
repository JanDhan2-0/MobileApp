import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/i18n.dart'
    as location_picker;
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:jandhanv2/main.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../generated/i18n.dart';
import '../services/uploadToFirebase.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  LocationResult _pickedLocation;
  String _touchPoint;
  String _touchPointBank;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bankController = TextEditingController();
  final requestMsgController = TextEditingController();

  final apiKey = "AIzaSyCILGP87TZPkXUobQfqDp9mkPA7IXnEGXU";
  final _formKey = GlobalKey<FormState>();
  ProgressDialog pr;
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Thank you"),
          content: new Text(
              "Thank you for your request. We will review your request and will let you know the updates soon."),
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

  Future uploadData() async {
    await pr.show();
    uploadRequestInformation(
        nameController.text,
        phoneController.text,
        _touchPointBank,
        _touchPoint,
        _pickedLocation.address,
        _pickedLocation.latLng,
        requestMsgController.text);
    pr.hide().whenComplete(() {
      _showDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    return MaterialApp(
      localizationsDelegates: const [
        location_picker.S.delegate,
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en', ''), Locale('hi', '')],
      home: Scaffold(
        appBar: AppBar(
          title: Text('Request Bank/ATM'),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: Builder(builder: (context) {
          return SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.all(25.0),
                    width: MediaQuery.of(context).size.width,
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
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    width: 2.0, color: Colors.blue[600]),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: DropDownFormField(
                              titleText: 'Select your preffered Bank',
                              hintText: 'Please choose one',
                              value: _touchPointBank,
                              onSaved: (value) {
                                setState(() {
                                  _touchPointBank = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  _touchPointBank = value;
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
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    width: 2.0, color: Colors.blue[600]),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: DropDownFormField(
                              titleText: 'Select what you want',
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
                                  "display": "BANK",
                                  "value": "BANK",
                                },
                              ],
                              textField: 'display',
                              valueField: 'value',
                            )),
                        SizedBox(
                          height: 20.0,
                        ),
                        RaisedButton(
                            color: Colors.blue[100],
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
                            child: Container(
                                height: 49.0,
                                width: 200.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_location,
                                        color: Colors.blue[600],
                                      ),
                                      Text(
                                        'Pick location of Bank/ATM',
                                        style:
                                            TextStyle(color: Colors.blue[600]),
                                      ),
                                    ]))),
                        SizedBox(
                          height: 20.0,
                        ),
                        (_pickedLocation == null)
                            ? Text("(Bank/ATM Location will appear here)",
                                style: TextStyle(fontSize: 14))
                            : Center(
                                child: Text(_pickedLocation.address,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ),
                        SizedBox(
                          height: 15.0,
                        ),
                        TextFormField(
                          controller: requestMsgController,
                          decoration: InputDecoration(
                              hintText: 'Please add in special comments',
                              labelText: 'Add Special Comments',
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
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter valid Phone Number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          margin: EdgeInsets.all(15),
                          child: MaterialButton(
                            height: 49.0,
                            minWidth: double.infinity,
                            color: Theme.of(context).primaryColor,
                            padding: EdgeInsets.all(10),
                            textColor: Colors.white,
                            child: new Text(
                              "SUBMIT",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            onPressed: () => {uploadData()},
                            splashColor: Colors.redAccent,
                          ),
                        )
                      ],
                    ),
                  )));
        }),
      ),
    );
  }
}
