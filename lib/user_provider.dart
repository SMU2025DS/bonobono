import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _docId;
  String? _email;
  String? _docmapId;

  String? get docId => _docId;
  String? get email => _email;
  String? get docmapId => _docmapId;


  void setUser(String docId, String email) {
    _docId = docId;
    _email = email;
    notifyListeners();
  }

  void clearUser() {
    _docId = null;
    _email = null;
    notifyListeners();
  }

  void setMap(String docmapId) {
    _docmapId = docmapId;
    notifyListeners();
  }

  void clearMap() {
    _docmapId = null;
    notifyListeners();
  }

}
