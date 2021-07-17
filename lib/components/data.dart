import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Data extends ChangeNotifier {
  bool loading = false;
  User user;
  bool dark = true;
  String selectedPoliceTag = "Robbery";
  String selectedMedicalTag = "Cardiac Arrest";
  String notificationText;

  void setNotificationtext(String _text) {
    notificationText = _text;
    notifyListeners();
  }

  void setPoliceTag(String _tag) {
    selectedPoliceTag = _tag;
    notifyListeners();
  }

  void setMedicaltag(String _tag) {
    selectedMedicalTag = _tag;
    notifyListeners();
  }

  double getZoom(double meters) {
    if (meters < 20)
      return 20;
    else if (meters < 100)
      return 18.8;
    else if (meters < 300)
      return 17.8;
    else if (meters < 600)
      return 16.8;
    else if (meters < 1000)
      return 16;
    else if (meters < 2500)
      return 14.8;
    else if (meters < 4000)
      return 14;
    else if (meters < 6000)
      return 13.2;
    else if (meters < 8000)
      return 12;
    else
      return 12;
  }

  void changeLoading(bool _loadingStatus) {
    loading = _loadingStatus;
    notifyListeners();
  }

  void setMapTheme(bool _theme) {
    dark = _theme;
    notifyListeners();
  }

  void setUser(User _user) {
    user = _user;
    notifyListeners();
  }
}
