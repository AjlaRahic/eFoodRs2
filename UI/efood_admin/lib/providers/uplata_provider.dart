
import 'package:efood_admin/models/uplata.dart';
import 'package:efood_admin/providers/base_provider.dart';

class uplataProvider extends BaseProvider<Uplata> {
  uplataProvider(): super("uplata");

   @override
  Uplata fromJson(data) {
    return Uplata.fromJson(data);
  }
}