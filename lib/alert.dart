import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:http/http.dart' as http;
import 'dart:convert';

//AIzaSyBukm1GVM5hUTbBtEuzU-F4a6YoBzFRplk - GMAPS API KEY


class Alert extends StatefulWidget {
  @override
  _AlertState createState() => _AlertState();
}


class _AlertState extends State<Alert> {
  Position _currentPosition;
  final Geolocator _geolocator = Geolocator();

  Position latLong;
  GoogleMapController mapController; //mapController variable
  location.Location _location = location.Location(); //location object
  Set<Marker> markers = {};

  final LatLng _center = const LatLng(45.521563, -122.677433); //random starting point value.

  //UI stuff
  Color _iconColor = Colors.red;
  List <bool> _likes = List.filled(2, true);

  void _onMapCreated  (GoogleMapController controller) {
    mapController = controller;
    _location.onLocationChanged.listen((location.LocationData event) {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(event.latitude, event.longitude), zoom: 15),
        //get current position and update camera
      ));
    });
    getAlert();
  }

  //TEST FLOATING ACTION BUTTON
  Widget _buildalertbutton() {
    return Container(
      padding: EdgeInsets.only(left: 295.0,top:450),
      //margin: EdgeInsets.all(10),

        child:FloatingActionButton(onPressed:() => sendAlert(),
            backgroundColor: Colors.red,
          child: Icon(Icons.add_alert),
        )

      //alignment: Alignment(0.95,0.1),
    );
  }


  sendAlert() async {

    latLong = await _geolocator.
    getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(latLong);
    String lat = latLong.latitude.toString();
    String longi = latLong.latitude.toString();
    var url = 'https://valerianlow123.000webhostapp.com/sendAlert.php?lat='+ lat +'&longi='+ longi;
    http.Response response = await http.get(url);
    var data = jsonDecode(response.body);

    await getAlert();

  }

  getAlert() async{
    var url = 'https://valerianlow123.000webhostapp.com/getAlert.php';
    http.Response response = await http.get(url);
    var data = jsonDecode(response.body);
    var result = data["Result"];
    print(result);
    for(var item in result){
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId(item['id']),
            position: LatLng(double.parse(item['lat']),
              double.parse(item['longi']),
            ),
            onTap: () {},
          ),
        );
      });
    }
  }


  Widget _buildsuggestions(){

    return ListView(

      //FIRST CARD
        children: [Card(
          child: ListTile(
              contentPadding: EdgeInsets.all(5),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Carpark Name:")]),
              subtitle: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Lots Available:"), Text("\$Cost"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Predicted Lots:"), Text("Distance"),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: _likes[0] ? Icon(Icons.favorite_border, color: _iconColor) : Icon(Icons.favorite, color: _iconColor),onPressed: (){
                setState(() {
                  if(_likes[0]){
                    _likes[0] = false;
                  }
                  else
                    _likes[0] = true;
                });
              },
              )
          ),
        ),

          //SECOND CARD
          Card(
            child: ListTile(
                contentPadding: EdgeInsets.all(5),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Carpark Name:")]),
                subtitle: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Lots Available:"), Text("\$Cost"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Predicted Lots:"), Text("Distance"),
                      ],
                    ),
                  ],
                ),
                trailing:
                IconButton(
                  icon: _likes[1] ? Icon(Icons.favorite_border, color: _iconColor) : Icon(Icons.favorite, color: _iconColor),onPressed: (){
                  setState(() {
                    print("${_likes[1]}");
                    if(_likes[1]){
                      _likes[1] = false;
                      print("${_likes[1]}");
                    } else {
                    _likes[1] = true;
                    print("${_likes[1]}");
                    }
                  });
                },
                )
            ),
          )]
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.terrain,
        ),
              _buildsuggestions(),

        ]
      )
    );


  }

  }


