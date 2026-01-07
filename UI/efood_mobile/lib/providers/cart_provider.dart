import 'package:efood_mobile/models/korpa.dart';
import 'package:efood_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';
import '../models/jelo.dart';
import 'package:http/http.dart' as http;

class CartProvider extends BaseProvider<Korpa> {
  CartProvider() : super("Korpa");

  @override
  Korpa fromJson(data) {
    return Korpa.fromJson(data);
  }

  List<Korpa> _cartItems = [];

  double get totalPrice {
    return _cartItems.fold(
        0, (sum, item) => sum + (item.cijena ?? 0) * (item.kolicina ?? 0));
  }

  List<Korpa> get cartItems => _cartItems;

}
