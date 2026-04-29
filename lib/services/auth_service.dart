import 'package:firebase_auth/firebase_auth.dart';
import 'package:mini_fiverr/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential?> signUp(String email, String password, String name, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final securityQuestions = _firestoreService.generateSecurityQuestions();
      
      // Create user document in Firestore
      await _firestoreService.createUser(result.user!.uid, {
        'uid': result.user!.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': role,
        'profileCompleted': false,
        'profilePicUrl': '',
        'createdAt': DateTime.now(),
        'walletBalance': 0.0,
        'securityQuestions': securityQuestions,
      });
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }
}
