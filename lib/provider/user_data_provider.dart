import 'dart:typed_data';

import 'package:flutter/material.dart';

class UserDataProvider extends ChangeNotifier {

  String _sharingStatus = '';
  String _sharingPasswordDisabled = '';

  String _accountType = '';
  String _username = '';
  String _email = '';

  Uint8List _profilePicture = Uint8List(0);
  bool _profilePictureEnabled = false;

  String get sharingStatus => _sharingStatus;
  String get sharingPasswordDisabled => _sharingPasswordDisabled;

  String get email => _email;
  String get username => _username;
  String get accountType => _accountType;

  Uint8List get profilePicture => _profilePicture;
  bool get profilePictureEnabled => _profilePictureEnabled;

  void setSharingStatus(String status) {
    _sharingStatus = status;
    notifyListeners();
  }

  void setSharingPasswordStatus(String status) {
    _sharingPasswordDisabled = status;
    notifyListeners();
  }
  
  void setAccountType(String accountType) {
    _accountType = accountType;
    notifyListeners();
  }
  
  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setProfilePicture(Uint8List data) {
    _profilePicture = data;
    notifyListeners();
  }

  void setProfilePictureEnabled(bool data) {
    _profilePictureEnabled = data;
    notifyListeners();
  }

}