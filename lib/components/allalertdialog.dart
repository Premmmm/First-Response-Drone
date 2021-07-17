import 'package:frd/components/Constants.dart';
import 'package:frd/components/MySlide.dart';
import 'package:frd/components/data.dart';
import 'package:frd/screens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frd/components/getlocation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_tts/flutter_tts.dart';

GetLocation getLocation = GetLocation();

class AllAlertDialogues {
  Constants constants = Constants();
  Future<bool> confirmationAlertDialog(
      BuildContext context, String message, String msg) {
    return showDialog(
      context: context,
      builder: (BuildContext context1) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context2, StateSetter setState) {
              return Container(
                height: msg == "Fire" ? 200 : 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        msg == "Fire"
                            ? "FIRE EMERGENCY"
                            : msg == "Police"
                                ? "POLICE EMERGENCY"
                                : "MEDICAL EMERGENCY",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (msg != "Fire")
                      Container(
                        alignment: Alignment.center,
                        child: DropdownButtonHideUnderline(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 1.0, style: BorderStyle.solid),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                            ),
                            child: DropdownButton<String>(
                              items: msg == "Police"
                                  ? Constants().police.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList()
                                  : Constants().medical.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                              style:
                                  GoogleFonts.montserrat(color: Colors.white),
                              dropdownColor: Colors.grey[850],
                              icon: Icon(
                                Icons.arrow_drop_down_sharp,
                                color: Colors.black,
                                size: 35,
                              ),
                              hint: Text(
                                msg == 'Police'
                                    ? Provider.of<Data>(context)
                                        .selectedPoliceTag
                                    : Provider.of<Data>(context)
                                        .selectedMedicalTag,
                                style:
                                    GoogleFonts.montserrat(color: Colors.black),
                              ),
                              isExpanded: false,
                              onChanged: (_) async {
                                print(_);
                                await FlutterTts().setSpeechRate(0.9);
                                await FlutterTts().speak(_);
                                msg == "Police"
                                    ? Provider.of<Data>(context, listen: false)
                                        .setPoliceTag(_)
                                    : Provider.of<Data>(context, listen: false)
                                        .setMedicaltag(_);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              Vibration.vibrate(duration: 10);
                              Navigator.of(context1).pop(false);
                            },
                            child: const Icon(
                              Icons.clear,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Vibration.vibrate(duration: 10);
                              Provider.of<Data>(context, listen: false)
                                  .changeLoading(true);
                              GetLocation().getEmergencyLocation(context, msg);
                              Navigator.of(context1).pop(false);
                            },
                            child: Icon(
                              Icons.check,
                              color: Colors.red[800],
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> logOutConformation(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context1) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Container(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'ARE YOU SURE?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'This will log you out.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Vibration.vibrate(duration: 10);
                          Navigator.of(context1).pop(false);
                        },
                        child: const Icon(
                          Icons.clear,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Vibration.vibrate(duration: 10);
                          GoogleSignIn().signOut();
                          FirebaseAuth.instance.signOut();
                          Navigator.of(context1).pop(false);
                          // Navigator.of(context).pop();
                          Navigator.push(context, MySlide(page: LoginScreen()));
                        },
                        child: Icon(
                          Icons.check,
                          color: Colors.red[800],
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
