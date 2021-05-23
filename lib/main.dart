import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_google_map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> mapControllerCompleter = Completer();
  Position _currentPosition;
  String _currentAddress;

  final firstLocationController = TextEditingController();
  final secondLocationController = TextEditingController();

  String _firstAddress = '';
  String _secondAddress = "";

  // 現在位置取得
  void _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        mapControllerCompleter.future.then(
          (mapController) => mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  position.latitude,
                  position.longitude,
                ),
                zoom: 18.0,
              ),
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((error) {
      print(error);
    });
  }

  // 現在地の住所取得
  void _getAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      Placemark placemark = placemarks.first;

      setState(() {
        _currentAddress =
            "${placemark.country}, ${placemark.postalCode}, ${placemark.locality}, ${placemark.name}";
        firstLocationController.text = _currentAddress;
        _firstAddress = _currentAddress;
      });
    } catch (error) {
      print(error);
    }
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    var maxHeight = MediaQuery.of(context).size.height;
    var maxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              mapControllerCompleter.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                width: maxWidth - 32,
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: firstLocationController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'First Location',
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      TextField(
                        controller: secondLocationController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Second Location',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
