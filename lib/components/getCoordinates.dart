import 'package:geolocator/geolocator.dart';

class GetCoordinates {
  Future<Position> getCoordinates() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.latitude);
    print(position.longitude);
    return position;
  }
}
