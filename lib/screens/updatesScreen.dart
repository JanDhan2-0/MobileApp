import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserList(),
    );
  }
}

class UserList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserListState();
  }
}

class _UserListState extends State<UserList> {
  final String apiUrl = "https://jandhan2.herokuapp.com/message/getUpdates";

  List<dynamic> _users = [];

  void fetchUsers() async {
    var result = await http.get(apiUrl);
    setState(() {
      _users = json.decode(result.body)['response'];
      debugPrint(_users.toList().toString());
    });
  }

  void _openDescActivity(var user) {
    DetailsScreen(
      desc: user,
    );
  }

  Widget _buildList() {
    return _users.length != 0
        ? RefreshIndicator(
            child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: _users.length,
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
                                          DetailsScreen(desc: _users[index])));
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(_users[index]['imageUrl'])),
                              title: Text(_users[index]['title']),
                              subtitle: Text(_users[index]['location'] +
                                  "  " +
                                  _users[index]['date']),
                              trailing: Text(_users[index]['time']),
                            ))
                      ],
                    ),
                  );
                }),
            onRefresh: _getData,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Latest Updates"),
      ),
      body: Container(
        child: _buildList(),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final desc;
  // In the constructor, require a Todo.
  DetailsScreen({Key key, @required this.desc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text('Detail Information'),
            ),
            body: Builder(builder: (context) {
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(20.0),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        desc['title'],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Image(
                        image: NetworkImage(desc['imageUrl']),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: Text(
                          desc['description'],
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Additional File Url " + desc['additionalFileUrl'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "Location " + desc['location'],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Date and Time " + desc['date'] + " " + desc['time'],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Post By: " + desc['postBy'],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })));
  }
}
