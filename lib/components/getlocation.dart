import 'package:flutter/cupertino.dart';
import 'package:frd/components/data.dart';
import 'package:frd/components/firebaseOperations.dart';
import 'package:frd/components/getCoordinates.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:collection';
import 'package:provider/provider.dart';

final firebasertdb = FirebaseDatabase.instance.reference();

class GetLocation {
  void getEmergencyLocation(BuildContext context, String msg) async {
    Position position = await GetCoordinates().getCoordinates();
    HashMap<String, double> locationDistance = HashMap<String, double>();
    await FirebaseDatabase.instance
        .reference()
        .child(msg == 'Medical' ? "Hospitals" : msg)
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> parentValues = snapshot.value;
        parentValues.forEach((key, value) {
          double _lat = 0.0;
          double _lon = 0.0;
          Map<dynamic, dynamic> coordinates = value;
          coordinates.forEach((key, value1) {
            if (key.toString() == 'lat')
              _lat = double.parse(value1.toString());
            else if (key.toString() == 'lon')
              _lon = double.parse(value1.toString());
          });

          double _dist = Geolocator.distanceBetween(
              position.latitude, position.longitude, _lat, _lon);
          locationDistance.putIfAbsent(key.toString(), () => _dist);
        });
      }
    });

    double _nearestdistance = 10000000000000000;
    String _nearestDepartmentName;
    locationDistance.forEach((key, value) {
      if (_nearestdistance > value) {
        _nearestdistance = value;
        _nearestDepartmentName = key.toString();
      }
      print('$key  $value');
    });
    print(_nearestDepartmentName);
    print(_nearestdistance);
    String _notificationtext;

    Data provider = Provider.of<Data>(context, listen: false);

    if (msg == "Medical") {
      _notificationtext =
          "Reported ${provider.selectedMedicalTag} to $_nearestDepartmentName";
    } else if (msg == "Police") {
      _notificationtext =
          "Reported ${provider.selectedPoliceTag} to $_nearestDepartmentName";
    } else {
      _notificationtext = "Reported fire emergency to $_nearestDepartmentName";
    }
    provider.setNotificationtext(_notificationtext);
    FirebaseOperations().setData(context, msg, position);
  }
}
