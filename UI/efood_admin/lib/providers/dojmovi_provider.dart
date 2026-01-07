
import 'package:efood_admin/models/dojmovi.dart';
import 'package:efood_admin/providers/base_provider.dart';

class DojmoviProvider extends BaseProvider<Dojmovi> {
  DojmoviProvider(): super("Dojmovi");

   @override
  Dojmovi fromJson(data) {
    return Dojmovi.fromJson(data);
  }
}