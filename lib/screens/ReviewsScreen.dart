import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Reviews'),
          automaticallyImplyLeading: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false))),
      body: ReviewList(),
    );
  }
}

class ReviewList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReviewListState();
  }
}

class _ReviewListState extends State<ReviewList> {
  final String apiUrl = "http://jandhan2.herokuapp.com/appReview/bank/SBI/touchPoint/ATM/reviews";
  List<dynamic> _reviews = [];
  // ignore: non_constant_identifier_names
  double averageRating;
  int total;
  void fetchUsers() async {
    var result = await http.get(apiUrl);
    setState(() {
      _reviews = json.decode(result.body)['response'];
      total = json.decode(result.body)['totalReviews'];
      averageRating  =json.decode(result.body)['averageRating'];
      debugPrint(_reviews.toList().toString());
    });
  }

  Widget _buildList() {
    return _reviews.length != 0
        ? Container(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: EdgeInsets.all(8.0),
                itemCount: _reviews.length,
                itemBuilder: (BuildContext context, int index) {
                  return new Card(
                child: new Container(
                  padding: new EdgeInsets.all(32.0),
                  child: new Column(
                    children: <Widget>[
                      new Text(_reviews[index]['feebdack']),
                      new Text(_reviews[index]['rating'].toString() + " Stars"),
                      new Text(_reviews[index]['date']),
                      new Text(_reviews[index]['sentiment'])
                    ],
                  ),
                ),
              );
                }),
          )
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
  'atm','service','security','branch'
];
void changeData(){
    List<dynamic> ans = new List<dynamic>();
    debugPrint(tag.toString());
    for(int i=0;i<_reviews.length;i++){
        int len = _reviews[i]['tags'].length;
        String ans1 = " ";
        String ans2 = " ";
        String ans3 = " ";
        String ans4 = " ";

        if(len == 1){
            ans1 = _reviews[i]['tags'][0];
        }
        else if(len == 2){
            ans1 = _reviews[i]['tags'][0];
            ans1 = _reviews[i]['tags'][1];
        }
        else if(len  == 3){
            ans1 = _reviews[i]['tags'][0];
            ans2 = _reviews[i]['tags'][1];
            ans3 = _reviews[i]['tags'][2];
        }
        else{
            ans1 = _reviews[i]['tags'][0];
            ans2 = _reviews[i]['tags'][1];
            ans3 = _reviews[i]['tags'][2];
            ans4 = _reviews[i]['tags'][3];
        }
        if(ans1 == options[tag] || ans2 == options[tag] || ans3 == options[tag] || ans4 == options[tag] ){
            ans.add(_reviews[i]);
        }
    }
      ans.add(_reviews[0]);
    _reviews = ans;
}

  @override
  Widget build(BuildContext context) {
    return Container(
        
        child: Column(children: <Widget>[
            Text("Suggestion Tags",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
            ChipsChoice<int>.single(
          value: tag,
          options: ChipsChoiceOption.listFrom<int, String>(
            source: options,
            value: (i, v) => i,
            label: (i, v) => v,
          ),
          onChanged: (val) => setState(() => {
            tag = val,
            changeData()
            }),
        ),
        Text("Total Reviews: "+total.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
        Text("Average Rating: "+averageRating.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
        SingleChildScrollView(
                  child: Column(
            children: <Widget>[
              _buildList(),
            ],
          ),
        )
        ],
         )
      );
  }
}
