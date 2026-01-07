import 'package:efood_admin/providers/base_provider.dart';
import 'package:efood_admin/models/promet_po_korisniku.dart';

class PrometPoKorisnikuProvider extends BaseProvider<PrometPoKorisniku> {
  PrometPoKorisnikuProvider() : super("Report/reportPrometPoKorisniku");

  @override
  PrometPoKorisniku fromJson(data) {
    return PrometPoKorisniku(
      imeKorisnika: data['ImeKorisnika'],
      datumNarudzbe: data['DatumNarudzbe'],
      nazivKategorije: data['NazivKategorije']?? 'N/A',
    );
  }
}

