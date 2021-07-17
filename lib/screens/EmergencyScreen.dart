import 'package:flutter_tts/flutter_tts.dart';
import 'package:frd/components/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frd/components/allalertdialog.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

// ignore: must_be_immutable
class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  AllAlertDialogues allAlertDialogues = AllAlertDialogues();

  AnimationController _policeAnimationController,
      _medicalAnimationController,
      _fireAnimationController;
  Animation _fireAnimation, _policeAnimation, _medicalAnimation;

  @override
  void dispose() {
    _policeAnimationController.dispose();
    _fireAnimationController.dispose();
    _medicalAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _policeAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 750),
    );
    _fireAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100),
    );
    _medicalAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1350),
    );

    _policeAnimation = Tween(begin: Offset(2, 0.0), end: Offset(0.0, 0.0))
        .animate(CurvedAnimation(
            parent: _policeAnimationController, curve: Curves.decelerate));
    _fireAnimation = Tween(begin: Offset(2, 0.0), end: Offset(0.0, 0.0))
        .animate(CurvedAnimation(
            parent: _fireAnimationController, curve: Curves.decelerate));
    _medicalAnimation = Tween(begin: Offset(2, 0.0), end: Offset(0.0, 0.0))
        .animate(CurvedAnimation(
            parent: _medicalAnimationController, curve: Curves.decelerate));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _policeAnimationController.forward();
    _fireAnimationController.forward();
    _medicalAnimationController.forward();
    return WillPopScope(
      onWillPop: () {
        return SystemNavigator.pop();
      },
      child: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: Provider.of<Data>(context).loading,
          child: Scaffold(
            backgroundColor: Color(0xFF13161D),
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
                'FRD',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1.2),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.power_settings_new),
                  onPressed: () =>
                      AllAlertDialogues().logOutConformation(context),
                )
              ],
            ),
            body: SizedBox(
              height: size.height,
              width: size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SlideTransition(
                      position: _policeAnimation,
                      child: TextButton(
                        onPressed: () async {
                          Vibration.vibrate(duration: 10);
                          await FlutterTts().setSpeechRate(0.8);
                          await FlutterTts().speak("Police Emergency");
                          allAlertDialogues.confirmationAlertDialog(context,
                              'This will call for police help.', 'Police');
                        },
                        child: Image.asset(
                          'assets/images/police.png',
                          width: 225,
                          height: 225,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SlideTransition(
                      position: _medicalAnimation,
                      child: TextButton(
                        onPressed: () async {
                          Vibration.vibrate(duration: 10);
                          await FlutterTts().setSpeechRate(0.8);
                          await FlutterTts().speak("Medical Emergency");
                          allAlertDialogues.confirmationAlertDialog(context,
                              'This will call for medical help.', 'Medical');
                        },
                        child: Image.asset(
                          'assets/images/medical.png',
                          width: 195,
                          height: 195,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    SlideTransition(
                      position: _fireAnimation,
                      child: TextButton(
                        onPressed: () async {
                          Vibration.vibrate(duration: 10);
                          await FlutterTts().setSpeechRate(0.8);
                          await FlutterTts().speak("Fire Emergency");
                          allAlertDialogues.confirmationAlertDialog(
                              context, 'This will call for fire help.', 'Fire');
                        },
                        child: Image.asset(
                          'assets/images/fire.png',
                          width: 215,
                          height: 215,
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
    );
  }
}
