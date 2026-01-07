import 'package:efood_mobile/models/prilozi.dart';
import 'package:efood_mobile/models/search_result.dart';
import 'package:efood_mobile/providers/base_provider.dart';

class PriloziProvider extends BaseProvider<Prilozi> {
  PriloziProvider() : super("Prilozi");

  @override
  Prilozi fromJson(data) {
    return Prilozi.fromJson(data);
  }
  List<Prilozi> items = [];

  Future<SearchResult<Prilozi>> getPrilozi({int? prilogId}) {
    final filter = prilogId != null ? {"prilogId": prilogId} : null;
    return get(filter: filter);
  }
   Future<void> fetchAll() async {
    var result = await super.get();
    items = result.result;
  }

}
