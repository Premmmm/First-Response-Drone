import 'package:frd/components/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geodesy/geodesy.dart' as geod;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class DeployedDroneMap extends StatefulWidget {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final geod.LatLng midpoint;
  final String status;
  final String eta;
  final double dist;
  final String droneName;
  DeployedDroneMap(
      {@required this.markers,
      @required this.polylines,
      @required this.midpoint,
      @required this.status,
      @required this.eta,
      @required this.droneName,
      @required this.dist});
  @override
  _DeployedDroneMapState createState() => _DeployedDroneMapState();
}

class _DeployedDroneMapState extends State<DeployedDroneMap> {
  GoogleMapController googleMapController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Stack(
            children: [
              GoogleMap(
                compassEnabled: true,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                mapType: MapType.normal,
                markers: widget.markers,
                polylines: widget.polylines,
                onCameraIdle: () {
                  Future.delayed(Duration(seconds: 5), () {
                    print(widget.dist);
                    googleMapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(widget.midpoint.latitude,
                            widget.midpoint.longitude),
                        Provider.of<Data>(context, listen: false)
                            .getZoom(widget.dist),
                      ),
                    );
                  });
                },
                onMapCreated: (GoogleMapController controller) async {
                  googleMapController = controller;
                  String getJsonFile = await rootBundle
                      .loadString("assets/mapstyles/mapAubergineTheme.json");
                  googleMapController.setMapStyle(getJsonFile);
                  googleMapController
                      .showMarkerInfoWindow(MarkerId(widget.droneName));
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      widget.midpoint.latitude, widget.midpoint.longitude),
                  zoom: Provider.of<Data>(context, listen: false)
                      .getZoom(widget.dist),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.01,
                right: 11,
                child: Container(
                  height: 38,
                  width: 38,
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
                right: 11,
                bottom: MediaQuery.of(context).size.height * 0.12,
                child: Container(
                  height: 40,
                  width: 40,
                  color: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.location_searching_outlined),
                    color: Colors.grey,
                    onPressed: () {
                      googleMapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(widget.midpoint.latitude,
                                widget.midpoint.longitude),
                            zoom: Provider.of<Data>(context, listen: false)
                                .getZoom(widget.dist),
                            tilt: 50,
                          ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/dronee.png',
                      width: 50,
                      height: 50,
                    ),
                    Text(widget.droneName, style: GoogleFonts.montserrat()),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.status.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    if (widget.status.toLowerCase() == 'arriving')
                      const SizedBox(height: 10),
                    if (widget.status.toLowerCase() == 'arriving')
                      Text(
                        'ETA  ${widget.eta}',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
