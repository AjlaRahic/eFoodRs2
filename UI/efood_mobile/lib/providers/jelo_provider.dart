import 'package:efood_mobile/models/jelo.dart';
import 'package:efood_mobile/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Jelo> {
  ProductProvider() : super("Jelo");

  @override
  Jelo fromJson(data) {
    return Jelo.fromJson(data);
  }

  List<Jelo> items = [];

  Future<void> fetchAll() async {
    var result = await super.get();
    items = result.result;
  }
}
