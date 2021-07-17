import 'package:flutter/scheduler.dart';
import 'package:frd/screens/Map%20Screens/DeployedDroneStream.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibration/vibration.dart';

class MapStream extends StatelessWidget {
  final Position currentPosition;
  final BitmapDescriptor customIcon;
  final String uid;
  final BuildContext mapScreenContext;
  MapStream({
    @required this.currentPosition,
    @required this.customIcon,
    @required this.uid,
    @required this.mapScreenContext,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child('people')
          .child(uid)
          .child('status')
          .onValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          print("Map stream does not have data");
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        if (snapshot.data.snapshot.value == null) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        } else if (snapshot.data.snapshot.value.toString().toLowerCase() ==
            'completed') {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Vibration.vibrate(pattern: [60, 50, 60, 50]);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height - 150,
                    left: 20,
                    right: 20),
                backgroundColor: Colors.white,
                duration: Duration(seconds: 5),
                content: SizedBox(
                  height: 40,
                  child: Text(
                    'Emergency situation adressed\nThank you for saving a life',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF484848)),
                  ),
                ),
              ),
            );
            Navigator.popAndPushNamed(mapScreenContext, '/emergencyScreen');
          });
        }
        return DeployedDroneStream(
          customIcon: customIcon,
          currentPosition: currentPosition,
          snapshot: snapshot,
          mapScreenContext: mapScreenContext,
        );
      },
    );
  }
}
