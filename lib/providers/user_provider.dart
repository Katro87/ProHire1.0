import 'package:flutter/material.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _userModel;
  bool _isLoading = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  Future<void> fetchUser(String uid) async {
    _setLoading(true);
    try {
      _userModel = await _firestoreService.getUser(uid);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateUser(uid, data);
      await fetchUser(uid);
    } catch (e) {
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
