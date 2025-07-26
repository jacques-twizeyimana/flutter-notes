import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLogin = true;
  bool get isLogin => _isLogin;

  bool _isAuthenticating = false;
  bool get isAuthenticating => _isAuthenticating;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  void toggleAuthMode() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isAuthenticating = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    try {
      _isAuthenticating = true;
      notifyListeners();
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name
      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.reload();
      _user = _auth.currentUser;
    } catch (e) {
      if (e is FirebaseAuthException) {
        debugPrint(
          'Sign up error: code=${e.code}, message=${e.message}, details=$e',
        );
      } else {
        debugPrint('Sign up error: $e');
      }
      rethrow;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
