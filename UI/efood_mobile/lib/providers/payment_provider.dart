// lib/providers/payment_provider.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_provider.dart';

class PaymentProvider extends BaseProvider<void> {
  PaymentProvider() : super("payments/paypal");
  @override
  fromJson(data) => null;

  Future<Map<String, String>> createPayPalOrder(double amount) async {
    final uri = Uri.parse('$totalUrl/create'); // POST /payments/paypal/create
    final res = await http.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode({"Amount": amount}),
    );
    if (isValidResponse(res)) {
      final data = jsonDecode(res.body);
      return {
        'orderId': data['orderId'] as String,
        'approveUrl': data['approveUrl'] as String,
      };
    }
    throw Exception('Create PayPal order failed: ${res.body}');
  }

  Future<int> capturePayPalOrder(String orderId, int korisnikId) async {
    final uri = Uri.parse('$totalUrl/capture/$orderId?korisnikId=$korisnikId');
    final res = await http.post(uri, headers: createHeaders());
    if (isValidResponse(res)) {
      final data = jsonDecode(res.body);
      return data['narudzbaId'] as int;
    }
    throw Exception('Capture PayPal order failed: ${res.body}');
  }
}
