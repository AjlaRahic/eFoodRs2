

import 'package:efood_mobile/models/dojmovi.dart';
import 'package:efood_mobile/providers/base_provider.dart';

class DojmoviProvider extends BaseProvider<Dojmovi> {
  DojmoviProvider(): super("Dojmovi");

   @override
  Dojmovi fromJson(data) {
    return Dojmovi.fromJson(data);
  }
}