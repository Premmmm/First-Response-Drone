import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart' as geod;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:frd/components/data.dart';
import 'package:frd/screens/Map%20Screens/AllDronesStream.dart';
import 'package:frd/screens/Map%20Screens/DeployedDroneMap.dart';

class DeployedDroneStream extends StatefulWidget {
  final Position currentPosition;
  final AsyncSnapshot<dynamic> snapshot;
  final BitmapDescriptor customIcon;
  final BuildContext mapScreenContext;
  DeployedDroneStream({
    @required this.currentPosition,
    @required this.snapshot,
    @required this.customIcon,
    @required this.mapScreenContext,
  });
  @override
  _DeployedDroneStreamState createState() => _DeployedDroneStreamState();
}

class _DeployedDroneStreamState extends State<DeployedDroneStream> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child("Drone")
          .child(widget.snapshot.data.snapshot.value.toString())
          .onValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        double lat;
        double lon;
        double _dist;
        String _status;
        String _eta = "";
        double _speed;
        Set<Marker> markers = <Marker>{};
        Set<Polyline> polylines = {};
        List<LatLng> latlng = [];

        geod.LatLng midpoint;

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        if (snapshot.data.snapshot.value == null) {
          return AllDronesStream(
            currentPosition: widget.currentPosition,
            customIcon: widget.customIcon,
            mapScreenContext: widget.mapScreenContext,
          );
        } else {
          Map<dynamic, dynamic> cc = snapshot.data.snapshot.value;
          cc.forEach((key, value) {
            if (key.toString() == 'lat') {
              lat = double.parse(value.toString());
            } else if (key.toString() == 'lon') {
              lon = double.parse(value.toString());
            } else if (key.toString() == 'status') {
              _status = value.toString();
            } else if (key.toString() == 'speed') {
              _speed = double.parse(value.toString());
            }
          });

          _dist = Geolocator.distanceBetween(widget.currentPosition.latitude,
              widget.currentPosition.longitude, lat, lon);
          if (_dist > 20) {
            if (_speed != 0.0) {
              int _min = Duration(seconds: (_dist ~/ _speed)).inMinutes.round();
              if (_min < 1) {
                _eta = '1 min.';
              } else {
                _eta = _min.toString() + " min.";
              }
            } else {
              if (_status == "offline")
                _eta = "null";
              else
                _eta = '1 min.';
            }
          } else {
            _eta = '1 min.';
          }

          markers.clear();

          markers.add(Marker(
            icon: widget.customIcon,
            markerId: MarkerId(widget.snapshot.data.snapshot.value.toString()),
            infoWindow: InfoWindow(
              title: widget.snapshot.data.snapshot.value.toString(),
              snippet: '$lat, $lon',
            ),
            position: LatLng(lat, lon),
          ));
          markers.add(Marker(
            markerId: MarkerId("Home"),
            infoWindow: InfoWindow(title: "Home", snippet: '$lat, $lon'),
            position: LatLng(widget.currentPosition.latitude,
                widget.currentPosition.longitude),
          ));

          latlng.add(LatLng(lat, lon));

          LatLng _new = LatLng(lat, lon);
          LatLng _news = LatLng(widget.currentPosition.latitude,
              widget.currentPosition.longitude);

          latlng.add(_new);
          latlng.add(_news);

          polylines.add(
            Polyline(
              polylineId: PolylineId("haha"),
              visible: true,
              points: latlng,
              width: 4,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              color:
                  Provider.of<Data>(context).dark ? Colors.white : Colors.blue,
            ),
          );

          midpoint = geod.Geodesy().midPointBetweenTwoGeoPoints(
              geod.LatLng(widget.currentPosition.latitude,
                  widget.currentPosition.longitude),
              geod.LatLng(lat, lon));
        }
        return DeployedDroneMap(
          markers: markers,
          polylines: polylines,
          midpoint: midpoint,
          status: _status,
          eta: _eta,
          dist: _dist,
          droneName: widget.snapshot.data.snapshot.value.toString(),
        );
      },
    );
  }
}
