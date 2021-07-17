import 'dart:async';
import 'package:frd/components/MySlide.dart';
import 'package:frd/components/data.dart';
import 'package:frd/screens/EmergencyScreen.dart';
import 'package:frd/screens/Map%20Screens/MapScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth auth = FirebaseAuth.instance;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController _photoController, _buttonController;
  Animation _photoAnimation, _buttonAnimation;

  bool isSpinning = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  initState() {
    super.initState();

    _photoController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _buttonController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _photoAnimation = RelativeRectTween(
            begin: RelativeRect.fromLTRB(0, 0, 0, 0),
            end: RelativeRect.fromLTRB(0, 0, 0, 250))
        .animate(CurvedAnimation(
            parent: _photoController, curve: Curves.decelerate));
    _buttonAnimation = RelativeRectTween(
            begin: RelativeRect.fromLTRB(0, 0, 0, 0),
            end: RelativeRect.fromLTRB(0, 400, 0, 0))
        .animate(CurvedAnimation(
            parent: _photoController, curve: Curves.decelerate));
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isSpinning = true;
    });
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential authUser =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User _user = authUser.user;
      if (_user != null) {
        assert(!_user.isAnonymous);
        assert(await _user.getIdToken() != null);
        final User currentUser = auth.currentUser;
        assert(_user.uid == currentUser.uid);
        print(_user.uid);
        Provider.of<Data>(context, listen: false).setUser(_user);
        print('Sign in with GOOGLE SUCCEDEED');
        print('DISPLAY NAME:   ${_user.displayName}');
        print('EMAIL:  ${_user.email}');

        FirebaseDatabase.instance
            .reference()
            .child('people')
            .child(_user.uid)
            .child('status')
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            if (snapshot.value.toString() != "completed") {
              setState(() {
                isSpinning = false;
              });
              Navigator.push(context, MySlide(page: MapScreen()));
            } else {
              setState(() {
                isSpinning = false;
              });
              Navigator.push(
                context,
                MySlide(
                  page: EmergencyScreen(),
                ),
              );
            }
          } else {
            setState(() {
              isSpinning = false;
            });
            Navigator.push(
              context,
              MySlide(
                page: EmergencyScreen(),
              ),
            );
          }
        });
        // Navigator.push(
        //   context,
        //   MySlide(page: EmergencyScreen()),
        // );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isSpinning = false;
      });
      print('Failed with error code: ${e.code}');
      print(e.message);
    } catch (e) {
      setState(() {
        isSpinning = false;
      });
      print('Failed with error code: ${e.code}');
      print(e.message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[200],
          duration: Duration(seconds: 2),
          content: Container(
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                'An error occurred while signing in',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  void onSignInButtonPressed() {
    Vibration.vibrate(duration: 10);
    signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    _photoController.forward();
    _buttonController.forward();

    return WillPopScope(
      onWillPop: () {
        return SystemNavigator.pop();
      },
      child: SafeArea(
          child: ModalProgressHUD(
        inAsyncCall: isSpinning,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xFF0E193F),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
              leading: SizedBox(),
              title: Text(
                "FRD",
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1.2),
              ),
              centerTitle: true,
              backgroundColor: Color(0xFF171717),
            ),
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                PositionedTransition(
                  rect: _buttonAnimation,
                  child: Center(
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.only(
                          left: 30, right: 30, bottom: 10, top: 10),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.indigo, Colors.blue]),
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(5)),
                      child: TextButton(
                        onPressed: () => onSignInButtonPressed(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/GoogleLogo.png',
                              height: 25,
                              width: 25,
                            ),
                            Text(
                              'SIGN IN WITH GOOGLE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'MontserratBold'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                PositionedTransition(
                  rect: _photoAnimation,
                  child: Center(
                    child: Hero(
                        tag: 'logo',
                        child: Image.asset('assets/images/frd.png')),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
