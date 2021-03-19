import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'alert.dart';
//import 'bookmark.dart';
import 'calculate.dart';
import 'explore.dart';
// to import the files
import 'bookmarklist.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';




//import 'package:floating_search_bar/floating_search_bar.dart';
String token = "";

// defines the entry point of every flutter application
void main()
{
  runApp
    (
      Navigator()
  );
}


class Navigator extends StatelessWidget {

  // to retrieve the URA access token required to call the URA APIs
  // that are required
  void getToken() async {
    http.Response response = await http.get(
        Uri.encodeFull(
            "https://www.ura.gov.sg/uraDataService/insertNewToken.action"),
        headers: {
          "AccessKey": "15602784-c17e-4688-9ce3-f5ce38e605da"
        }
    );
    print(response.body);

    Map<String, dynamic> map = json.decode(response.body);
    token = map["Result"];
    print(token);
    getCarparks();

    //final jsonResponse = json.decode(response.body);
    //print(jsonResponse);
    //TokenResponse tokenResponse= new TokenResponse.fromJson(jsonResponse);
    //print(tokenResponse.result);
    //print(token);

    //List data = json.decode(response.body);
    //print(data);
  }

  // to call the URA API to GET the list of car parks information
  void getCarparks() async {
    http.Response response = await http.get(
        Uri.encodeFull(
            "https://www.ura.gov.sg/uraDataService/invokeUraDS?service=Car_Park_Details"),
        headers: {
          "AccessKey": "15602784-c17e-4688-9ce3-f5ce38e605da",
          "Token": token
        }
    );
    //print(response.body);

    Map<String, dynamic> map = json.decode(response.body);
    print(map['Result']);
    List<dynamic> carparkList = map['Result'];
    print(carparkList[0]["geometries"][0]["coordinates"]);

    //List< Map<String, dynamic>> carParkList = map['Result'];
    //String jsonString  = map['Result'].toString();
    //Carpark carparkList = new Carpark.fromJson(map);


    //print(carParkList[123]['ppName']);
    //print (carparkList.ppName);

  }

  // to use the getToken and getCarparks methods and configure the
  // top-level Navigator of flutter
  @override
  Widget build(BuildContext context) {
    getToken();
    getCarparks();
    return new MaterialApp
      (
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),
      // home: MyBottomNavigationBar(),
      home: Scaffold(
        body: DoubleBackToCloseApp(
          child: MyBottomNavigationBar(),
          snackBar: const SnackBar(
            duration: const Duration(seconds: 1),
            content: Text('Tap back again to exit the app'),
          ),
        ),
      ),
    );
  }


}

class MyBottomNavigationBar extends StatefulWidget
{
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar>
{

  int _currentIndex = 0;
  
  final List<Widget> _children =
  [
    // ToDo: implement Navigator.push
    Explore(),
    BookmarkList(), // to change back to bookmark once done testing
    Calculate(),
    Alert(),
  ];

  // logic required when an icon is tapped on the bottom navigation bar
  // (change the index)
  void onTappedBar(int index)
  {
    setState(() {
      _currentIndex = index;
    });
  }

  // to configure the logic of the bottom navigation bar for the
  // flutter app as well as setting the UI of the bottom navigation bar
  // such as icons
  @override
  Widget build(BuildContext context) {
    return new Scaffold
      (
      body:
      IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar
        (
        onTap: onTappedBar,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_sharp),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.taxi_alert),
            label: 'Alert',
          ),
        ],
      ),
    );
  }
}