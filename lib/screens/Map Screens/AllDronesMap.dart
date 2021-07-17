import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:frd/components/data.dart';

class AllDronesMap extends StatefulWidget {
  final Set<Marker> markers;
  final Position currentPosition;
  final BuildContext mapScreenContext;
  const AllDronesMap({
    @required this.markers,
    @required this.currentPosition,
    @required this.mapScreenContext,
  });

  @override
  _AllDronesMapState createState() => _AllDronesMapState();
}

class _AllDronesMapState extends State<AllDronesMap> {
  GoogleMapController googleMapController;
  void showSnackBar() {
    try {
      Future.delayed(Duration(seconds: 3), () async {
        await FlutterTts().setSpeechRate(0.8);
        await FlutterTts().speak(
            Provider.of<Data>(widget.mapScreenContext, listen: false)
                .notificationText);
        ScaffoldMessenger.of(widget.mapScreenContext).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(widget.mapScreenContext).size.height * 0.5,
              left: 20,
              right: 20,
            ),
            backgroundColor: Colors.white,
            duration: Duration(seconds: 5),
            content: SizedBox(
              height: 40,
              child: Text(
                Provider.of<Data>(context, listen: false).notificationText,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF484848),
                ),
              ),
            ),
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Stack(
            children: [
              GoogleMap(
                scrollGesturesEnabled: true,
                compassEnabled: true,
                myLocationButtonEnabled: true,
                tiltGesturesEnabled: false,
                mapType: MapType.normal,
                markers: widget.markers,
                onMapCreated: (GoogleMapController controller) async {
                  googleMapController = controller;
                  String getJsonFile = await rootBundle
                      .loadString("assets/mapstyles/mapAubergineTheme.json");
                  googleMapController.setMapStyle(getJsonFile);
                  showSnackBar();
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.currentPosition.latitude,
                      widget.currentPosition.longitude),
                  zoom: 13,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.01,
                right: 11,
                child: Container(
                  height: 40,
                  width: 40,
                  color: Provider.of<Data>(context).dark
                      ? Colors.white
                      : Colors.grey[850],
                  child: Provider.of<Data>(context).dark
                      ? IconButton(
                          icon: Icon(Icons.wb_sunny, color: Colors.red),
                          onPressed: () {
                            Vibration.vibrate(duration: 10);
                            Provider.of<Data>(context, listen: false)
                                .setMapTheme(false);
                            googleMapController.setMapStyle(null);
                          },
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.nightlight_round,
                            size: 18,
                          ),
                          onPressed: () async {
                            Vibration.vibrate(duration: 10);
                            Provider.of<Data>(context, listen: false)
                                .setMapTheme(true);
                            String getJsonFile = await rootBundle.loadString(
                                "assets/mapstyles/mapAubergineTheme.json");
                            googleMapController.setMapStyle(getJsonFile);
                          },
                        ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: MediaQuery.of(context).size.height * 0.12,
                child: Container(
                  height: 38,
                  width: 38,
                  color: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.location_searching_outlined,
                        color: Colors.grey[850]),
                    onPressed: () {
                      googleMapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(
                            widget.currentPosition.latitude,
                            widget.currentPosition.longitude,
                          ),
                          13.4,
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.2 - 90,
          decoration: BoxDecoration(
            color: Colors.grey[900],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              Text(
                "Finding Nearby drones",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
