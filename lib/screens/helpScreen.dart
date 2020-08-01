import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:jandhanv2/screens/styles/style.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Opening an Account')),
        body: Center(
            child: Container(
                width: MediaQuery.of(context).size.width - 40,
                alignment: Alignment.center,
                child: ExpandableTheme(
                    data: const ExpandableThemeData(
                      iconColor: Colors.blue,
                      useInkWell: true,
                    ),
                    child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: <Widget>[
                          Style.space(),
                          Container(
                              decoration: Style.boxDecor(),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ExpandablePanel(
                                  header: Text(
                                    'Documents Required (any one)',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.blue),
                                  ),
                                  collapsed: Text(
                                    'Driving License, Aadhaar Card, Voter ID, Passport,PAN Card, NREGA Card.',
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  expanded: Text(
                                    'description',
                                    softWrap: true,
                                  ),
                                  tapHeaderToExpand: true,
                                  hasIcon: true,
                                ),
                              )),
                          Style.space(),
                          Container(
                              decoration: Style.boxDecor(),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ExpandablePanel(
                                  header: Text('Form',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue)),
                                  collapsed: Text(
                                    'Online form for opening an PMJDY Account.',
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  expanded: Text(
                                    'https://pmjdy.gov.in/files/forms/account-opening/English.pdf',
                                    softWrap: true,
                                  ),
                                  tapHeaderToExpand: true,
                                  hasIcon: true,
                                ),
                              )),
                          Style.space(),
                          Container(
                              decoration: Style.boxDecor(),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ExpandablePanel(
                                  header: Text('KYC Details',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue)),
                                  collapsed: Text(
                                    'Fill up the form and attach',
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  expanded: Text(
                                    "Fill up the form and attach the necessary government ID's.",
                                    softWrap: true,
                                  ),
                                  tapHeaderToExpand: true,
                                  hasIcon: true,
                                ),
                              )),
                          Style.space(),
                          Container(
                              decoration: Style.boxDecor(),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ExpandablePanel(
                                  header: Text(
                                      'Take it to a Nearby Bank Branch',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue)),
                                  collapsed: Text(
                                    'The form alongwith the proofs',
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  expanded: Text(
                                    'The form alongwith the proofs (original copy) must be taken to the bank branch where you want to create an account.',
                                    softWrap: true,
                                  ),
                                  tapHeaderToExpand: true,
                                  hasIcon: true,
                                ),
                              )),
                          Style.space(),
                          Container(
                              decoration: Style.boxDecor(),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ExpandablePanel(
                                  header: Text('Verification',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue)),
                                  collapsed: Text(
                                    'After a proper scrutiny',
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  expanded: Text(
                                    'After a proper scrutiny, your account will be opened.',
                                    softWrap: true,
                                  ),
                                  tapHeaderToExpand: true,
                                  hasIcon: true,
                                ),
                              )),
                        ])))));
  }
}
