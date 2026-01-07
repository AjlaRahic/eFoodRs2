import 'dart:async';
import 'dart:convert';

import 'package:efood_mobile/models/korisnik.dart';
import 'package:efood_mobile/models/uloga.dart';
import 'package:flutter/cupertino.dart';

class Authorization {
  static String? username;
  static String? password;
  static int? userId;
  static Korisnik? korisnik;
  static Uloga? uloga;
  static String? email;
}

class Info {
  static String? name;
  static String? surname;
  static String? image;
  static int? id;
}

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}

Image imageFromBase64String(String base64Image) {
  return Image.memory(base64Decode(base64Image));
}
