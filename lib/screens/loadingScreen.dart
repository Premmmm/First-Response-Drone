import 'dart:async';
import 'package:frd/components/MySlide.dart';
import 'package:frd/components/data.dart';
import 'package:frd/screens/EmergencyScreen.dart';
import 'package:frd/screens/LoginScreen.dart';
import 'package:frd/screens/Map%20Screens/MapScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 14.0);
  }

  Future<void> checkLogin() async {
    StreamSubscription<User> userSub;
    try {
      userSub = FirebaseAuth.instance.authStateChanges().listen(
        (User user) {
          if (user == null) {
            print("Signed out daw");
            Navigator.push(
              context,
              MySlide(
                page: LoginScreen(),
              ),
            );
            userSub.cancel();
          } else {
            print('${user.email} ${user.displayName}');
            print("signed in daw");
            Provider.of<Data>(context, listen: false).setUser(user);
            showToast('Signed in as ${user.email}');
            FirebaseDatabase.instance
                .reference()
                .child('people')
                .child(user.uid.toString())
                .child('status')
                .once()
                .then((DataSnapshot snapshot) {
              if (snapshot.value != null) {
                if (snapshot.value.toString() != "completed") {
                  Navigator.push(context, MySlide(page: MapScreen()));
                } else {
                  Navigator.push(
                    context,
                    MySlide(
                      page: EmergencyScreen(),
                    ),
                  );
                }
              } else {
                Navigator.push(
                  context,
                  MySlide(
                    page: EmergencyScreen(),
                  ),
                );
              }
            });

            userSub.cancel();
          }
        },
      );
    } on FirebaseException {
      print('Splash screen Firebase Exception daawww ');
    } catch (e) {
      print('Splash screen try catch daww $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.blue,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}
