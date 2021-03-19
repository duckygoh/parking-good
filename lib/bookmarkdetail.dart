import 'package:flutter/material.dart';
import 'dart:async';
import 'carpark.dart';
import 'database_helper.dart';

class BookmarkDetail extends StatefulWidget {

  final String appBarTitle;
  final Carpark carpark;

  BookmarkDetail(this.carpark, this.appBarTitle);

  @override
  _BookmarkDetailState createState() => _BookmarkDetailState(this.carpark, this.appBarTitle);
}

class _BookmarkDetailState extends State<BookmarkDetail> {

  // Controller for TextField

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Carpark carpark;

  TextEditingController carparkNoController = TextEditingController();
  TextEditingController carparkNameController = TextEditingController();
  TextEditingController carparkLatController = TextEditingController();
  TextEditingController carparkLogController = TextEditingController();

  // add additional 3 controller
  TextEditingController carparkWeekdayRateController = TextEditingController();
  TextEditingController carparkSatdayRateController = TextEditingController();
  TextEditingController carparkSunPHRateController = TextEditingController();

  _BookmarkDetailState(this.carpark, this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.headline6;

    carparkNoController.text = carpark.ppCode;
    carparkNameController.text = carpark.ppName;
    carparkLatController.text = carpark.latitude;
    carparkLogController.text = carpark.longitude;

    // add additional 3 controller
    carparkWeekdayRateController.text = carpark.weekdayRate;
    carparkSatdayRateController.text = carpark.satdayRate;
    carparkSunPHRateController.text = carpark.sunPHRate;

    return WillPopScope(
        onWillPop: (){
          // Write some code to control things, when user press back navigation button in device
          moveToLastScreen();
        },
        child: Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(icon: Icon(
            Icons.arrow_back),
            onPressed: () {
              // Write some code to control things, when user press back button
              // in AppBar
              moveToLastScreen();
          }
        ),
      ),

      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[

            // First Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: carparkNoController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint("Something changed in Car Park No Text Field");
                  updateppCode();
                },
                decoration: InputDecoration(
                    labelText: "Carpark No",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),

            // Second Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: carparkNameController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint("Something changed in Car Park Name Text Field");
                  updateppName();
                },
                decoration: InputDecoration(
                  labelText: "Carpark Name",
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),

            // Third Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: carparkLatController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint("Something changed in Car Park Lat Text Field");
                  updatelat();
                },
                decoration: InputDecoration(
                    labelText: "Carpark Latitude",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),

            // Fourth Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: carparkLogController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint("Something changed in Car Park Log Text Field");
                  updatelog();
                },
                decoration: InputDecoration(
                    labelText: "Carpark Longitude",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),

            // Fifth Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: carparkWeekdayRateController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint("Something changed in Car Park Weekday Rate Text Field");
                  updateweekdayrate();
                },
                decoration: InputDecoration(
                    labelText: "Carpark WeekdayRate",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),

            // Sixth Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: carparkSatdayRateController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint("Something changed in Car Park Sat Day Rate Text Field");
                  updatesatdayrate();
                },
                decoration: InputDecoration(
                    labelText: "Carpark SatDayRate",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),

            // Seventh Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: carparkSunPHRateController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint("Something changed in Car Park SunPH Rate Text Field");
                  updatesunphrate();
                },
                decoration: InputDecoration(
                    labelText: "Carpark SundayPHRate",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),

            //8 Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        "Save",
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () {
                        setState(() {
                          debugPrint("Save Button Clicked");
                          _save();
                        });
                      },
                    ),
                  ),

                  Container(width: 5.0,),

                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        "Delete",
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () {
                        setState(() {
                          debugPrint("Delete Button Clicked");
                          _delete();
                        });
                      },
                    ),
                  ),


                ],
              ),
            ),

          ],
        ),
      )
    ));
  }

  // method definition
  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // update the code
  void updateppCode() {
    carpark.ppCode = carparkNoController.text;
  }

  // update the name
  void updateppName(){
    carpark.ppName = carparkNameController.text;
  }

  // update the lat
  void updatelat() {
    carpark.latitude = carparkLatController.text;
  }

  // update the log
  void updatelog() {
    carpark.longitude = carparkLatController.text;
  }

  // update the weekdayrate
  void updateweekdayrate() {
    carpark.weekdayRate = carparkWeekdayRateController.text;
  }

  // update the satdayrate
  void updatesatdayrate() {
    carpark.satdayRate = carparkSatdayRateController.text;
  }

  // update the sunphrate
  void updatesunphrate() {
    carpark.sunPHRate = carparkSunPHRateController.text;
  }

  void _save() async {
    moveToLastScreen();

    int result;

    if (carpark.id != null) { // update operation
      result = await helper.updateCarpark(carpark);
    } else { // insert
      result = await helper.insertCarpark(carpark);
    }

    if (result != 0) { // success
      _showAlertDialog("Status", "Carpark Saved Successfully");
    } else { // failure
      _showAlertDialog("Status", "Problem Saving Carpark");
    }

  }
  void _delete() async{

    moveToLastScreen();

    // case 1: if user is trying to delete the new carpark
    if(carpark.id == null) {
      _showAlertDialog('Status', 'No carpark was detected');
      return;
    }

    // case 2: user is trying to delete the old carpark that already has a valid id
    int result = await helper.deleteCarpark(carpark.id);

    if (result != 0 ){
      _showAlertDialog('Status', 'Carpark deleted successfully');
    }

    else {
      _showAlertDialog('Status', 'Error Occurred while deleteing carpark');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }
}