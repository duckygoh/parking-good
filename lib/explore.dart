//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:rflutter_alert/rflutter_alert.dart';


import 'dart:math' show cos, sqrt, asin;

class Explore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapView(),
    );
  }
}
class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool searching = false;
  var lat ="";
  var longi = "";
  //map config
  CameraPosition _initialLocation = CameraPosition(target: LatLng(1.360365, 103.808375), zoom: 10);
  GoogleMapController mapController;
  List<String> carparkName = [];
  final Geolocator _geolocator = Geolocator();
  Position latLong;
  Position _currentPosition;
  String _currentAddress;
  var _prefixTapped = false;
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;
  final _focusNode = FocusNode();
  Set<Marker> markers = {};
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor helpIcon;

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<Map<String,dynamic>> markerDist =[];


  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // controller for alert text field
  final alertText = TextEditingController();

  _openPopup(context) {
    Alert(
        context: context,
        title: "Fill up the details",
        content: Column(
          children: <Widget>[
            TextField(
              controller: alertText,
              autofocus: true,
              decoration: InputDecoration(
                icon: Icon(Icons.notes),
                labelText: 'Describe your problem',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () => [Navigator.of(context, rootNavigator: true).pop(),sendAlert(alertText.text)],
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }


  getCoordinates(carparkNames) async {
    var url = 'https://valerianlow123.000webhostapp.com/getDet.php?carparkName=' + carparkNames;
    http.Response response = await http.get(url);
    var data = jsonDecode(response.body);
    var result = data["Result"];
    print(result);
    for(var item in result){
      setState(() {
        lat = item['lat'];
        longi = item['longi'];
      });
    }
    startAddressController.text = "";
    //_prefixTapped = true;
    searching = false;
    carparkName = new List<String>();
    _focusNode.unfocus();
  }

  getData() async{
    var url = 'https://valerianlow123.000webhostapp.com/getDet.php';
    http.Response response = await http.get(url);
    var data = jsonDecode(response.body);
    var result = data["Result"];
    print(result);
    for(var item in result){
      setState(() {
        markers.add(
          Marker(
            icon: pinLocationIcon,
            markerId: MarkerId(item['carparkNo']),
            position: LatLng(double.parse(item['lat']),
              double.parse(item['longi']),
            ),
            infoWindow: InfoWindow(
                title: item['carparkName']),
            onTap: () {},
          ),
        );
      });
    }
    await getAlert();
    markerDist = await calcDistance(markers);
  }


  Future <List< Map<String,dynamic> >> calcDistance(markers) async
  {
    latLong = await _geolocator.
    getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List <Map> distanceBtw;
    for (var item in markers) {
      num distance;
      distance = mp.SphericalUtil.computeDistanceBetween(
          mp.LatLng(latLong.latitude, latLong.longitude),
          mp.LatLng(item.position.latitude, item.position.longitude));
      num kmDistance = distance * 0.001;
      String kmDistanceS = kmDistance.toStringAsFixed(2);
      Map markerDist = new Map();
      markerDist = {'markerID': item.markerId.toString(), 'distance': kmDistanceS};
      showSnackBar(context, markerDist['markerID']);
      distanceBtw.add(markerDist);
    }
    //showSnackBar(context, distanceBtw);
   // print(distanceBtw[1]["markerID"] + " "+distanceBtw[1]['distance']);
    return distanceBtw;
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
            icon: helpIcon,
            markerId: MarkerId(item['id']),
            position: LatLng(double.parse(item['lat']),
              double.parse(item['longi']),
            ),
            infoWindow: InfoWindow(
                title: item['alertText']),
            onTap: () {},
          ),
        );
      });
    }
  }

  sendAlert(String alertText) async {
    latLong = await _geolocator.
    getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(latLong);
    String lat = latLong.latitude.toString();
    String longi = latLong.longitude.toString();
    var url = 'https://valerianlow123.000webhostapp.com/sendAlert.php?lat=' + lat +'&longi=' + longi +'&alertText=' +" \" "+ alertText.toString() + "\"";
    http.Response response = await http.get(url);
    var data = jsonDecode(response.body);

    print(data);
    String queryStatus ="";
    if (data == true)
      {
        queryStatus = "Alert Sent!";
      }
    if(data == false)
      {
        queryStatus = "Please try again!";
      }
    showSnackBar(context, queryStatus);
    await getAlert();
    }

  showSnackBar(context, text) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }



  // Method for retrieving the current location
  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
      await getData(); //new
      //await getAlert();
    }).catchError((e) {
      print(e);
    });
  }
  searchCarpark(String carpark) async {
    var url = 'https://valerianlow123.000webhostapp.com/searchCarpark.php?carparkName='+carpark;
    http.Response response = await http.get(url);
    var data = jsonDecode(response.body);
    var result = data["Result"];
    print(result);
    carparkName = new List<String>();
    for(var item in result){
      setState((){
      carparkName.add(item['carparkName']);
      });
    }
  }
  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        //startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Placemark> startPlacemark =
      await _geolocator.placemarkFromAddress(_startAddress);
      List<Placemark> destinationPlacemark =
      await _geolocator.placemarkFromAddress(_destinationAddress);

      if (startPlacemark != null && destinationPlacemark != null) {
        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude)
            : startPlacemark[0].position;
        Position destinationCoordinates = destinationPlacemark[0].position;

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that
        // southwest coordinate <= northeast coordinate
        if (startCoordinates.latitude <= destinationCoordinates.latitude) {
          _southwestCoordinates = startCoordinates;
          _northeastCoordinates = destinationCoordinates;
        } else {
          _southwestCoordinates = destinationCoordinates;
          _northeastCoordinates = startCoordinates;
        }

        // Accomodate the two locations within the
        // camera view of the map
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        // double distanceInMeters = await Geolocator().bearingBetween(
        //   startCoordinates.latitude,
        //   startCoordinates.longitude,
        //   destinationCoordinates.latitude,
        //   destinationCoordinates.longitude,
        // );

        await _createPolylines(startCoordinates, destinationCoordinates);

        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          print('DISTANCE: $_placeDistance km');
        });

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyBukm1GVM5hUTbBtEuzU-F4a6YoBzFRplk", // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.lightGreen[700],
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }


    Widget _textField({
      TextEditingController controller,
      String label,
      String hint,
      String initialValue,
      double width,
      Icon prefixIcon,
      Widget suffixIcon,
      Function(String) locationCallback,
    }) {
      return Container(
        width: width * 0.8,
        child: TextFormField(
          onChanged: (value) {
            setState(() {
              searchCarpark(value);
            });
          },
          onTap:() {
            if(_prefixTapped==false) {
              setState(() {
                searching = true;
              });
            }
            else{
              _focusNode.unfocus();
              _prefixTapped = false;
            }
          },
          controller: controller,
          focusNode: _focusNode,
          // initialValue: initialValue,
          decoration: new InputDecoration(
            prefixIcon: GestureDetector(
              child : prefixIcon,
              onTap:() {
                setState(() {
                  startAddressController.text = "";
                  _prefixTapped = true;
                  searching = false;
                  carparkName = new List<String>();
                  _focusNode.unfocus();
                });
              },
            ),
            suffixIcon: suffixIcon,
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              borderSide: BorderSide(
                color: Colors.grey[400],
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              borderSide: BorderSide(
                color: Colors.blue[300],
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(15),
            hintText: hint,
          ),
        ),
      );
    }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    //searchCarpark("");
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _prefixTapped) _focusNode.unfocus();
      _prefixTapped = false;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/marker.png').then((onValue) {
      pinLocationIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/caution.png').then((onValue) {
      helpIcon = onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Listener(
        onPointerDown: (_)  {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus.unfocus();
            }
        },
    child: Container(
      height: height,
      width: width,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: markers != null ? Set<Marker>.from(markers) : null,
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.grey[300], // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.grey[300], // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Places',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          searching ?
                          _textField(
                              label: 'Search',
                              hint: 'Search places',
                              //initialValue: _currentAddress,
                              prefixIcon:  Icon(Icons.close),
                              /*suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  prefixIcon: Icon(Icons.close);
                                  //startAddressController.text = _currentAddress;
                                  //_startAddress = _currentAddress;
                                },
                              ),*/
                              controller: startAddressController,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              })
                          :
                          _textField(
                              label: 'Search',
                              hint: 'Search places',
                              //initialValue: _currentAddress,
                              prefixIcon: Icon(Icons.search),
                              /*suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  prefixIcon: Icon(Icons.close);
                                  //startAddressController.text = _currentAddress;
                                  //_startAddress = _currentAddress;
                                },
                              ),*/
                              controller: startAddressController,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              }),
                          carparkName.length != 0 || startAddressController.text.isNotEmpty ?
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: carparkName.length,
                              itemBuilder: (context, index) {
                                  return ListTile(
                                    title:
                                    Text('${carparkName[index]}'),
                                    onTap: () async{
                                      await getCoordinates(carparkName[index]);
                                      mapController.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                                target: LatLng(
                                                double.parse(lat),
                                                double.parse(longi),
                                                ),
                                              zoom: 18.0,
                                            ),
                                          ),
                                      );
                                    }
                                  );
                              },
                            ),
                          ):
                              new Text(""),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'DISTANCE: $_placeDistance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 80.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.white, // button color
                      child: InkWell(
                        splashColor: Colors.blue, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 150.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.red, // button color
                      child: InkWell(
                        splashColor: Colors.blue, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.add_alert),
                        ),
                        onTap: () => _openPopup(context),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ),
    );
  }
}




