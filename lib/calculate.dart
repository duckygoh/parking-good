import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class Calculate extends StatefulWidget {
  @override
  _CalculateState createState() => _CalculateState();
}

class _CalculateState extends State<Calculate> {

  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  String carPark;
  //Todo logic to find cost of carpark entered
  double cost=120;
  Duration durationParked;

  final carparkController = TextEditingController();

  Duration duration(DateTime start, DateTime end){
    Duration difference = start.difference(end);
    this.durationParked = difference;
    return difference;
  }

  double calcCost(Duration duration, double cost){
    return (duration.inMinutes.toInt() * (cost/60)) / 100; //return total cost in decimals, eg. $1.2
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    carparkController.dispose();
    super.dispose();
  }

  Widget _buildCarpark() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child:  TextField(
        //autofillHints: <List of Strings >,
        controller: carparkController,
        decoration: InputDecoration(
          labelText: "Carpark",
          hintText: 'Enter a Carpark',
        ),
      ),
    );
  }

  Widget _buildStart() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Text("Start:"),
          new TimePickerSpinner(
            is24HourMode: true,
            normalTextStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey
            ),
            highlightedTextStyle: TextStyle(
                fontSize: 16,
                color: Colors.black
            ),
            spacing: 10,
            itemHeight: 20,
            isForce2Digits: true,
            onTimeChange: (time) {
              setState(() {
                start = time;
              });
            },
          ),
        ],
      )
    );
  }

  Widget _buildEnd() {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          children: [
            Text("End:"),
            new TimePickerSpinner(
              is24HourMode: true,
              normalTextStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey
              ),
              highlightedTextStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black
              ),
              spacing: 10,
              itemHeight: 20,
              isForce2Digits: true,
              onTimeChange: (time) {
                setState(() {
                  end = time;
                });
              },
            ),
          ],
        )
    );
  }

  Widget _buildDuration(){
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Text('Duration',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          Text(
            duration(end, start).toString().substring(0,4) + ' Hours',
            style: TextStyle(fontSize: 16),
          ),
      ]),
    );
  }

  Widget _buildCost(){
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Column(
          children: [
            Text('Cost',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            Text(
              calcCost(durationParked, cost).toString(),
              style: TextStyle(fontSize: 16),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculate'),),
      body: Container(
        child: Column(
          children: [_buildCarpark(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStart(),
              _buildEnd(),],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDuration(),
              _buildCost(),
            ],
          ),
          ],
        )
      ));
    }
  }


