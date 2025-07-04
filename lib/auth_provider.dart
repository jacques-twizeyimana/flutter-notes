import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isValidPassword(String password) {
    final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return password.length >= 6 && specialCharRegex.hasMatch(password);
  }

  Future<void> signUp(String email, String password) async {
    if (!_isValidPassword(password)) {
      throw Exception(
        'Password must be at least 6 characters long and contain at least one special character.',
      );
    }
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        print(
          'Sign up error: code=${e.code}, message=${e.message}, details=$e',
        );
      } else {
        print('Sign up error: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
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
