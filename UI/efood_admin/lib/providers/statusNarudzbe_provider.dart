
import 'package:efood_admin/models/statusNarudzbe.dart';
import 'package:efood_admin/providers/base_provider.dart';

class StatusNarudzbeProvider extends BaseProvider<StatusNarudzbe> {
  StatusNarudzbeProvider(): super("StatusNarudzbe");

   @override
  StatusNarudzbe fromJson(data) {
    return StatusNarudzbe.fromJson(data);
  }
}