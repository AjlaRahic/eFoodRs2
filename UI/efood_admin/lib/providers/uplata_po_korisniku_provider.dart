import 'package:efood_admin/models/uplata_po_korisniku.dart';
import 'package:efood_admin/providers/base_provider.dart';

class UplatePoKorisnikuProvider extends BaseProvider<UplataPoKorisniku> {
  UplatePoKorisnikuProvider() : super("Report/reportUplatePoKorisniku");

  @override
  UplataPoKorisniku fromJson(data) {
    return UplataPoKorisniku(
      iznos: data['iznos'],
      datumTransakcije: data['datumTransakcije'],
      imeKorisnika: data['imeKorisnika'],
      prezimeKorisnika: data['prezimeKorisnika'],
      brojTransakcije: data['brojTransakcije'],
      nacinPlacanja: data['nacinPlacanja']

    );
  }
}
 