import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../modals/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token, _userId;
  DateTime? _expriedTime;
  Timer? _authTimer;

  bool get isAuth {
    return token != '';
  }

  String get token {
    if (_token != null &&
        _expriedTime != null &&
        _expriedTime!.isAfter(DateTime.now())) {
      return _token!;
    } else {
      return '';
    }
  }

  String get userId {
    return _userId!;
  }

  void logOut() {
    _token = '';
    _userId = '';
    _expriedTime = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void autoLogOut() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpire = _expriedTime!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logOut);
  }

  Future<void> _athenticate(
      String email, String password, String urlSagment) async {
    var url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSagment?key=AIzaSyAhHAMR7wWUZCMAAw8-Ou6jVuBApkh5W6k');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true},
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expriedTime = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expireDate': _expriedTime!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> autoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')!);
    prefs.setString('userData', extractedData);

    final expryDate = DateTime.parse(extractedData['expireDate'].toString());

    if (expryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'].toString();
    _expriedTime = expryDate;
    _userId = extractedData['userId'].toString();
    notifyListeners();
    autoLogOut();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    return _athenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return _athenticate(email, password, 'signInWithPassword');
  }
}
