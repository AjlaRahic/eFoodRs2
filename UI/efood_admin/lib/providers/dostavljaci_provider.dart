import 'package:efood_admin/models/korisnik.dart';
import 'package:efood_admin/providers/base_provider.dart';

class DostavljaciProvider extends BaseProvider<Korisnik> {
  DostavljaciProvider() : super("Korisnik/Dostavljaci");

  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }
}
