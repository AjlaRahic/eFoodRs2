import 'package:efood_mobile/models/korpa.dart';
import 'package:efood_mobile/models/status.dart';
import 'package:efood_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';
import '../models/jelo.dart';
import 'package:http/http.dart' as http;

class StatusProvider extends BaseProvider<Status> {
  StatusProvider() : super("StatusNarudzbe");

  @override
  Status fromJson(data) {
    return Status.fromJson(data);
  }
  
}

