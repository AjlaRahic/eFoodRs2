
import 'package:efood_admin/models/drzava.dart';
import 'package:efood_admin/providers/base_provider.dart';

class DrzavaProvider extends BaseProvider<Drzava> {
  DrzavaProvider(): super("Drzava");

   @override
  Drzava fromJson(data) {
    return Drzava.fromJson(data);
  }
}