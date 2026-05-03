import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? role;

  AuthResult({required this.success, this.errorMessage, this.role});
}

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AuthResult> login({
    required String mode,
    required String email,
    required String password,
    required String username,
    required String pinCode,
  }) async {
    try {
      if (mode == 'staff') {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        var userDoc = await _firestore
            .collection('USERS')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();

        if (userDoc.docs.isEmpty) {
          return AuthResult(
              success: false, 
              errorMessage: 'Staff account authenticated, but no profile found in database.');
        }

        String role = userDoc.docs.first.data()['role'] ?? 'staff';
        return AuthResult(success: true, role: role);

      } else {
        var querySnapshot = await _firestore
            .collection('USERS')
            .where('username', isEqualTo: username.trim())
            .where('pinCode', isEqualTo: pinCode.trim())
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return AuthResult(success: false, errorMessage: 'Invalid Username or PIN.');
        }

        String role = querySnapshot.docs.first.data()['role'] ?? 'student';
        return AuthResult(success: true, role: role);
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.message ?? 'Authentication error.');
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'An unexpected error occurred: $e');
    }
  }
}