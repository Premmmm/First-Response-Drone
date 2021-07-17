import 'package:frd/components/MySlide.dart';
import 'package:frd/components/data.dart';
import 'package:frd/screens/Map%20Screens/MapScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

final firebaseRTDB = FirebaseDatabase.instance.reference();

class FirebaseOperations {
  Future<void> setData(BuildContext context, String msg,Position position) async {
    User user = Provider.of<Data>(context, listen: false).user;
    await firebaseRTDB.child('people').child(user.uid.toString()).set({
      'type': msg,
      'lat': position.latitude,
      'lon': position.longitude,
      'userName': user.displayName,
      'uid': user.uid,
      'dateTime': DateTime.now().toString(),
      'email': user.email,
      'status': 'reported',
      'emergencyDetail': msg != "Fire"
          ? msg == "Police"
              ? Provider.of<Data>(context, listen: false).selectedPoliceTag
              : Provider.of<Data>(context, listen: false).selectedMedicalTag
          : "Fire Help"
    });
    print('data set successfully');
    Provider.of<Data>(context, listen: false).changeLoading(false);
    Navigator.push(context, MySlide(page: MapScreen()));
  }
}
