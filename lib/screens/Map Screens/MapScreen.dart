import 'package:frd/components/data.dart';
import 'package:frd/screens/Map%20Screens/MapStream.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

GoogleMapController googleMapController;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position _currentPosition;
  BitmapDescriptor customIcon1;
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    getCurrentCoordinates();
  }


  @override
  void dispose() {
    googleMapController.dispose();
    Wakelock.disable();
    super.dispose();
  }

  Future<void> getCurrentCoordinates() async {
    print('GetCoordinates fuction called');
    double lat, lon;
    await FirebaseDatabase.instance
        .reference()
        .child('people')
        .child(Provider.of<Data>(context, listen: false).user.uid.toString())
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, value) {
          if (key.toString() == "lat") {
            lat = double.parse(value.toString());
          } else if (key.toString() == 'lon') {
            lon = double.parse(value.toString());
          }
        });
      }
    });

    // ignore: missing_required_param
    _currentPosition = Position(latitude: lat, longitude: lon);

    await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                size: Size(100, 100), platform: TargetPlatform.android),
            "assets/images/dronee.png")
        .then((icon) {
      customIcon1 = icon;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return SystemNavigator.pop();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            backgroundColor: Color(0xFF171717),
            centerTitle: true,
            leading: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Hero(
                tag: 'logo',
                child: Image.asset('assets/images/frd.png'),
              ),
            ),
            title: Text(
              'Drone Status',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.2),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => getCurrentCoordinates(),
              ),
            ],
          ),
          body: _currentPosition != null
              ? MapStream(
                  currentPosition: _currentPosition,
                  customIcon: customIcon1,
                  uid: Provider.of<Data>(context, listen: false).user.uid,
                  mapScreenContext: context,
                )
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
        ),
      ),
    );
  }
}
