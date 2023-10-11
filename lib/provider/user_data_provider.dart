import 'package:flutter/material.dart';

class UserDataProvider extends ChangeNotifier {

  String _sharingStatus = '';
  String _sharingPasswordDisabled = '';

  String _accountType = '';
  String _username = '';
  String _email = '';

  String get sharingStatus => _sharingStatus;
  String get sharingPasswordDisabled => _sharingPasswordDisabled;

  String get email => _email;
  String get username => _username;
  String get accountType => _accountType;

  void setSharingStatus(String status) {
    _sharingStatus = status;
  }

  void setSharingPasswordStatus(String status) {
    _sharingPasswordDisabled = status;
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

}