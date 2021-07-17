import 'package:frd/screens/Map%20Screens/AllDronesMap.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AllDronesStream extends StatefulWidget {
  final Position currentPosition;
  final BitmapDescriptor customIcon;
  final BuildContext mapScreenContext;

  AllDronesStream({
    @required this.currentPosition,
    @required this.customIcon,
    @required this.mapScreenContext,
  });

  @override
  _AllDronesStreamState createState() => _AllDronesStreamState();
}

class _AllDronesStreamState extends State<AllDronesStream> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.reference().child("Drone").onValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Set<Marker> markers = <Marker>{};
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        if (snapshot.data.snapshot.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 20),
                Text("No value")
              ],
            ),
          );
        } else {
          Map<dynamic, dynamic> droneNames = snapshot.data.snapshot.value;
          droneNames.forEach((droneName, droneDetails) {
            double lat = 0, lon = 0;
            String _status;
            if (droneName.toString().contains("FRD")) {
              Map<dynamic, dynamic> droneDet = droneDetails;
              droneDet.forEach((key, value) {
                if (key.toString() == 'lat') {
                  lat = double.parse(value.toString());
                } else if (key.toString() == 'lon') {
                  lon = double.parse(value.toString());
                } else if (key.toString() == 'status') {
                  _status = value.toString();
                }
              });

              if (_status.toLowerCase() == 'offline')
                markers.add(
                  Marker(
                    icon: widget.customIcon,
                    infoWindow: InfoWindow(
                        title: droneName.toString(), snippet: "$lat, $lon"),
                    markerId: MarkerId(droneName.toString()),
                    position: LatLng(lat, lon),
                  ),
                );
            }
          });
          markers.add(
            Marker(
              markerId: MarkerId("Home"),
              infoWindow: InfoWindow(
                  title: "Home",
                  snippet:
                      '${widget.currentPosition.latitude}, ${widget.currentPosition.longitude}'),
              position: LatLng(widget.currentPosition.latitude,
                  widget.currentPosition.longitude),
            ),
          );
        }
        return AllDronesMap(
          currentPosition: widget.currentPosition,
          markers: markers,
          mapScreenContext:widget.mapScreenContext,
        );
      },
    );
  }
}
