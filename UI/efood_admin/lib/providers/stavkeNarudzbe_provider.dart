
import 'package:efood_admin/models/stavkeNarudzbe.dart';
import 'package:efood_admin/providers/base_provider.dart';

class stavkeNarudzbeProvider extends BaseProvider<StavkeNarudzbe> {
  stavkeNarudzbeProvider(): super("stavkeNarudzbe");

   @override
  StavkeNarudzbe fromJson(data) {
    return StavkeNarudzbe.fromJson(data);
  }
}