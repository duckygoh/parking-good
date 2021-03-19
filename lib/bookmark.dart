import 'package:flutter/material.dart';
import 'dart:math';

//final List<String> entries = <String>['Carpark A', 'Carpark B', 'Carpark C']; // to use it dynamically eventually
//final List<int> colorCodes = <int>[300, 200, 100];

// explore ListTile

class Bookmark extends StatefulWidget {
  @override
  _BookmarkState createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {

  // List of Carparks
  List<String> carparks;
  GlobalKey<RefreshIndicatorState> refreshKey;
  Random r;

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    carparks = List();
    addCarparks();

  }

  addCarparks(){
    carparks.add("Carpark A");
    carparks.add("Carpark B");
    carparks.add("Carpark C");
    carparks.add("Carpark D");
    carparks.add("Carpark E");
  }

  addRandomCarpark(){
    int nextCount = r.nextInt(100);
    setState(() {
      carparks.add("Company $nextCount");
    });
  }

  removeCarpark(index) {
    setState(() {
      carparks.removeAt(index);
    });
  }

  undoDelete(index, carpark) {
    setState(() {
      carparks.insert(index, carpark);
    });
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    addRandomCarpark();
    return null;
  }

  showSnackBar(context, carpark, index) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('$carpark deleted'),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          undoDelete(index, carpark);
        },
      ),
    ));
  }

  Widget refreshBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),

    );
  }

  Widget list() {
    return ListView.builder(
      padding: EdgeInsets.all(20.0),
      itemCount: carparks.length,
      itemBuilder: (BuildContext context, int index) {
        return row(context, index);
      },
    );
  }

  Widget row(context, index) {
    return Dismissible(
      key: Key(carparks[index]),
      onDismissed: (direction) {
        var carpark = carparks[index];
        showSnackBar(context, carpark, index);
        removeCarpark(index);
      },
      background: refreshBg(),
      child: Card(
        child: ListTile(
          title: Text(carparks[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmark"),
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async{
          await refreshList();
        },
        child: list(),
      ),
    );
  }
}