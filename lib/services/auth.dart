import 'package:dollar_dollar/pages/MyHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get stream => _auth.authStateChanges().asBroadcastStream();

  Future<String?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _parseSignInAuthException(e);
    }
  }

  Future<String?> signIn({required String email, required String password, required BuildContext context}) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    // Navigate to MyHomePage after sign in
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyHomePage(title: 'Dollar Dollar',),
      ),
    );
    return userCredential.user?.uid;  // Return the user's ID
  } catch (e) {
    print('Sign-in error: $e');
    return null;
  }
}
  Future<String?> createAccountWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _parseCreateAccountAuthException(e);
    }
  }

  String? get userId {
    final user = _auth.currentUser;
    return user?.uid;
  }

  void signOut() {
    _auth.signOut();
  }

  String _parseSignInAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'Email address is not formatted correctly';
      case 'user-not-found':
      case 'wrong-password':
      case 'user-disabled':
        return 'Invalid username or password';
      case 'network-request-failed':
        return 'Please ensure you are online and try again';
      case 'too-many-requests':
      case 'operation-not-allowed':
      default:
        return 'An unknown error occurred';
    }
  }

  String _parseCreateAccountAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Email address is not formatted correctly';
      case 'email-already-in-use':
        return 'This email address already exists';
      case 'network-request-failed':
        return 'Please ensure you are online and try again';
      default:
        return 'An unknown error occurred';
    }
  }
}
