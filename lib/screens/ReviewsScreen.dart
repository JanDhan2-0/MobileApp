import 'package:chips_choice/chips_choice.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'styles/style.dart';

class ReviewsScreen extends StatelessWidget {
  final String atmbank;
  ReviewsScreen({Key key, @required this.atmbank}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Reviews'),
          automaticallyImplyLeading: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false))),
      body: ReviewList(atmbank: atmbank),
    );
  }
}

class ReviewList extends StatefulWidget {
  final String atmbank;
  ReviewList({Key key, @required this.atmbank}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ReviewListState(atmbank: atmbank);
  }
}

class _ReviewListState extends State<ReviewList> {
  final String atmbank;
  _ReviewListState({Key key, @required this.atmbank});
  List<dynamic> _reviews = [];
  // ignore: non_constant_identifier_names
  double averageRating;
  int total;
  void fetchUsers() async {
    debugPrint(atmbank);
    var result = await http.get(
        "https://jandhan2.herokuapp.com/appReview/bank/SBI/touchPoint/" +
            atmbank.toUpperCase() +
            "/reviews");
    setState(() {
      _reviews = json.decode(result.body)['response'];
      total = json.decode(result.body)['totalReviews'];
      averageRating = double.parse(
          (json.decode(result.body)['averageRating']).toStringAsFixed(2));
      debugPrint(_reviews.toList().toString());
    });
  }

  Widget _ratingBar(double rating) {
    return RatingBar(
      initialRating: rating,
      itemSize: 20.0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (double r) {},
    );
  }

  Widget _buildList() {
    return _reviews.length != 0
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _reviews.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                  child: new Container(
                padding: EdgeInsets.all(10.0),
                decoration: Style.boxDecor(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Text(_reviews[index]['feebdack']),
                    Style.space(),
                    _ratingBar(_reviews[index]['rating'].toDouble()),
                    Style.space(),
                    new Text("Date: " + _reviews[index]['date']),
                    _reviews[index]['sentiment'] == 'positive'
                        ? Text('Positive',
                            style: TextStyle(color: Colors.green[300]))
                        : Text('Negative',
                            style: TextStyle(color: Colors.red[300]))
                  ],
                ),
              ));
            })
        : Center(child: CircularProgressIndicator());
  }

  Future<void> _getData() async {
    setState(() {
      fetchUsers();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  int tag = 2;

  List<String> options = [
    tr('atm'),
    tr('service'),
    tr('security'),
    tr('branch')
  ];
  void changeData() {
    List<dynamic> ans = new List<dynamic>();
    debugPrint(tag.toString());
    for (int i = 0; i < _reviews.length; i++) {
      int len = _reviews[i]['tags'].length;
      String ans1 = " ";
      String ans2 = " ";
      String ans3 = " ";
      String ans4 = " ";

      if (len == 1) {
        ans1 = _reviews[i]['tags'][0];
      } else if (len == 2) {
        ans1 = _reviews[i]['tags'][0];
        ans1 = _reviews[i]['tags'][1];
      } else if (len == 3) {
        ans1 = _reviews[i]['tags'][0];
        ans2 = _reviews[i]['tags'][1];
        ans3 = _reviews[i]['tags'][2];
      } else {
        ans1 = _reviews[i]['tags'][0];
        ans2 = _reviews[i]['tags'][1];
        ans3 = _reviews[i]['tags'][2];
        ans4 = _reviews[i]['tags'][3];
      }
      if (ans1 == options[tag] ||
          ans2 == options[tag] ||
          ans3 == options[tag] ||
          ans4 == options[tag]) {
        ans.add(_reviews[i]);
      }
    }
    ans.add(_reviews[0]);
    _reviews = ans;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            ChipsChoice<int>.single(
              value: tag,
              options: ChipsChoiceOption.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
              onChanged: (val) => setState(() => {tag = val, changeData()}),
            ),
            Text("\nTotal Reviews: " + total.toString(),
                textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            Text("Average Rating: " + averageRating.toString() + "\n",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            _buildList(),
          ],
        ));
  }
}
