import 'package:flutter/material.dart';
import 'dart:async';
import 'carpark.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'bookmarkdetail.dart';

//ToDo: To solve latitute and longitute issue for displaying, might be relating to database issue

class BookmarkList extends StatefulWidget{

  final int count = 0;

  @override
  _BookmarkListState createState() => _BookmarkListState();
}

class _BookmarkListState extends State<BookmarkList> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Carpark> carparkList;
  int count = 0; // initially

  @override
  Widget build(BuildContext context) {

    if(carparkList == null) {
      carparkList = List<Carpark>();
      updateListView();
    }

    return Scaffold(

      appBar: AppBar(
        title: Text('Bookmarks'),
      ),

      body: getCarparkListView(),

      floatingActionButton: FloatingActionButton(
        heroTag: null, // why u want t be a hero? => Investigate why suddenly requires a heroTag.
        onPressed: () {
          debugPrint("FAB Clicked");
          navigatorToDetail(Carpark('', '', '', '', '', '', ''), "Add Note");
        },

        tooltip: "Add Bookmark",

        child: Icon(Icons.add),
      ),
    );
  }

  ListView getCarparkListView() {

    TextStyle titleStyle =  Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position){
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              // to comment out this portion
              leading: CircleAvatar(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                child: Icon(Icons.local_parking),
              ),

              title: Text("Carpark: " + this.carparkList[position].ppName, style: titleStyle,),

              //subtitle: Text(this.carparkList[position].ppCode),
              //option to add more subtitle:
              //https://stackoverflow.com/questions/53539523/flutter-how-to-use-listtile-threeline/53539803
              //subtitle: Text("Rate: " + this.carparkList[position].weekdayRate), // Code added previously
              subtitle: Container(margin: const EdgeInsets.only(top: 5.0), // code to add padding between title and subtitle
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,  // code to align left
                  children: <Widget>[
                    Text("Weekday Rate: " + this.carparkList[position].weekdayRate),
                    Text("Saturday Rate: " + this.carparkList[position].satdayRate),
                    Text("Sunday PH Rate: " + this.carparkList[position].sunPHRate)
                  ],
                ),
              ),

              trailing: Container(height: double.infinity, // to center the icon
                child: GestureDetector(
                  onTap: () {
                    _delete(context, carparkList[position]);
                  },
                  child: Icon(Icons.delete, color: Colors.grey,),

                ),
              ),
              onTap: () {
                debugPrint("ListTile Tapped");
                navigatorToDetail(this.carparkList[position],'Edit Note');
                //ToDo: To redirect to the markers instead when click
              },
            ),
          );
        }
    );
  }

  // delete function
  void _delete(BuildContext context, Carpark carpark) async {

    int result = await databaseHelper.deleteCarpark(carpark.id);
    if (result != 0){
      _showSnackBar(context, 'Carpark Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {

    final snackBar = SnackBar(duration: const Duration(seconds: 3), content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }


  // navigator push functions
  //ToDo: To remove the position argument error if not required
  void navigatorToDetail(Carpark carpark, String title) async {

    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return BookmarkDetail(carpark, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initialiseDatabase();
    dbFuture.then((database) {

      Future<List<Carpark>> carparkListFuture = databaseHelper.getCarparkList();
      carparkListFuture.then((carparkList) {
        setState(() {
          this.carparkList = carparkList;
          this.count = carparkList.length;
        });
      });
    });
  }
}