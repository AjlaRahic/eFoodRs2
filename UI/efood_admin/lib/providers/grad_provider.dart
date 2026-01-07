
import 'package:efood_admin/models/grad.dart';
import 'package:efood_admin/providers/base_provider.dart';

class GradProvider extends BaseProvider<Grad> {
  GradProvider(): super("Grad");

   @override
  Grad fromJson(data) {
    return Grad.fromJson(data);
  }
}