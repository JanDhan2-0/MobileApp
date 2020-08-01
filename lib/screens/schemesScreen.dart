import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:jandhanv2/screens/styles/style.dart';

class SchemesScreen extends StatefulWidget {
  @override
  _SchemesScreenState createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  var healthScheme = false;
  var financialScheme = true;
  int schemeType = 1;

  int areaType = 1;
  var urbanScheme = true;
  var ruralScheme = false;

  int genderType = 1;
  var genderMale = true;
  var genderFemale = false;

  int ageType = 59;
  var ageLess60 = true;
  var ageGreater60 = false;
  List<dynamic> _schemes = [];
  // static final String params = "age="+ ageType.toString() +"&area=" + areaType.toString()+"&schemeType="+schemeType.toString()+"&gender="+genderType.toString();

  void fetchSchemes() async {
    final String params = "age=" +
        ageType.toString() +
        "&area=" +
        areaType.toString() +
        "&schemeType=" +
        schemeType.toString() +
        "&gender=" +
        genderType.toString();
    final String apiUrl =
        "https://jandhan2.herokuapp.com/schemes/getSchemes?" + params;
    // debugPrint(schemeType.toString());
    // debugPrint(ageType.toString());
    // debugPrint(genderType.toString());
    // debugPrint(areaType.toString());
    var result = await http.get(apiUrl);
    setState(() {
      _schemes = json.decode(result.body)['response'];
      // debugPrint(_schemes.toList().toString());
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSchemes();
  }

  Widget _buildList() {
    return _schemes.length != 0
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(8.0),
            itemCount: _schemes.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SchemeDetail(desc: _schemes[index])));
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                                _schemes[index]['image'])),
                        title: Text(_schemes[index]['title']),
                        subtitle: Text(_schemes[index]['tooltip']),
                      ),
                    )
                  ],
                ),
              );
            })
        : Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: tr('schemes'),
        home: Scaffold(
          appBar: AppBar(
            title: Text(tr('schemes')),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
          body: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: new ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  buttonPadding: EdgeInsets.all(0.0),
                  children: <Widget>[
                    new FlatButton(
                      child: new Text("  " + tr('fin_schemes') + " "),
                      textColor: financialScheme ? Colors.white : Colors.black,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20)),
                      ),
                      color: financialScheme ? Colors.blue : Colors.white,
                      onPressed: () => setState(() {
                        schemeType = 1;
                        financialScheme = true;
                        healthScheme = false;
                      }),
                    ),
                    new FlatButton(
                      child: new Text("  " + tr('hel_schemes') + " "),
                      textColor: healthScheme ? Colors.white : Colors.black,
                      color: healthScheme ? Colors.blue : Colors.white,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      onPressed: () => setState(() {
                        schemeType = 2;
                        financialScheme = false;
                        healthScheme = true;
                      }),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: new ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  buttonPadding: EdgeInsets.all(0.0),
                  children: <Widget>[
                    new FlatButton(
                      child: new Text("  " + tr('urban_area') + " "),
                      textColor: urbanScheme ? Colors.white : Colors.black,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20)),
                      ),
                      color: urbanScheme ? Colors.blue : Colors.white,
                      onPressed: () => setState(() {
                        areaType = 1;
                        urbanScheme = true;
                        ruralScheme = false;
                      }),
                    ),
                    new FlatButton(
                      child: new Text("  " + tr('rural_area') + " "),
                      textColor: ruralScheme ? Colors.white : Colors.black,
                      color: ruralScheme ? Colors.blue : Colors.white,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      onPressed: () => setState(() {
                        areaType = 2;
                        urbanScheme = false;
                        ruralScheme = true;
                      }),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: new ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  buttonPadding: EdgeInsets.all(0.0),
                  children: <Widget>[
                    new FlatButton(
                      child: new Text("  " + tr('male') + " "),
                      textColor: genderMale ? Colors.white : Colors.black,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20)),
                      ),
                      color: genderMale ? Colors.blue : Colors.white,
                      onPressed: () => setState(() {
                        genderType = 1;
                        genderMale = true;
                        genderFemale = false;
                      }),
                    ),
                    new FlatButton(
                      child: new Text("  " + tr('female') + " "),
                      textColor: genderFemale ? Colors.white : Colors.black,
                      color: genderFemale ? Colors.blue : Colors.white,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      onPressed: () => setState(() {
                        genderType = 2;
                        genderMale = false;
                        genderFemale = true;
                      }),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: new ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  buttonPadding: EdgeInsets.all(0.0),
                  children: <Widget>[
                    new FlatButton(
                      child: new Text("   " + tr('age') + " < 60  "),
                      textColor: ageLess60 ? Colors.white : Colors.black,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20)),
                      ),
                      color: ageLess60 ? Colors.blue : Colors.white,
                      onPressed: () => setState(() {
                        ageType = 59;
                        ageLess60 = true;
                        ageGreater60 = false;
                      }),
                    ),
                    new FlatButton(
                      child: new Text("   " + tr('age') + " > 60  "),
                      textColor: ageGreater60 ? Colors.white : Colors.black,
                      color: ageGreater60 ? Colors.blue : Colors.white,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      onPressed: () => setState(() {
                        ageType = 60;
                        ageLess60 = false;
                        ageGreater60 = true;
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: 300,
                child: MaterialButton(
                  height: 40.0,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: new Text(
                    tr('get_schemes'),
                    style: TextStyle(fontSize: 18.0),
                  ),
                  onPressed: () => {fetchSchemes()},
                  splashColor: Colors.redAccent,
                ),
              ),
              SizedBox(height: 15),
              Text(
                tr('list'),
                style: TextStyle(fontSize: 16.0, color: Colors.blue[600]),
              ),
              _buildList()
            ],
          ),
        ));
  }
}

class SchemeDetail extends StatelessWidget {
  final desc;

  SchemeDetail({Key key, @required this.desc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(desc['title'])),
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
                                    tr("desc"),
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.blue),
                                  ),
                                  collapsed: Text(
                                    desc['description'],
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  expanded: Text(
                                    desc['description'],
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
                                  header: Text(tr('benefits'),
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue)),
                                  collapsed: Text(
                                    desc['Benefits'],
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  expanded: Text(
                                    desc['Benefits'],
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
                                  header: Text(tr('elig'),
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue)),
                                  collapsed: Text(
                                    desc['eligibility'],
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  expanded: Text(
                                    desc['eligibility'],
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
                                  header: Text(tr('doc'),
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue)),
                                  collapsed: Text(
                                    desc['documentsRequired'],
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  expanded: Text(
                                    desc['documentsRequired'],
                                    softWrap: true,
                                  ),
                                  tapHeaderToExpand: true,
                                  hasIcon: true,
                                ),
                              )),
                        ])))));
  }
}
