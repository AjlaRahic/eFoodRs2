 
import 'package:efood_admin/models/jelo.dart';
import 'package:efood_admin/providers/base_provider.dart';
 
class ProductProvider extends BaseProvider<Jelo> {
  ProductProvider(): super("Jelo");
 
   @override
  Jelo fromJson(data) {
    return Jelo.fromJson(data);
  }
}