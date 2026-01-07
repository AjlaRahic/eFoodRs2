 
import 'package:efood_admin/models/jelo.dart';
import 'package:efood_admin/models/restoran.dart';
import 'package:efood_admin/providers/base_provider.dart';
 
class RestoranProvider extends BaseProvider<Restoran> {
  RestoranProvider(): super("Restoran");
 
   @override
  Restoran fromJson(data) {
    return Restoran.fromJson(data);
  }
}