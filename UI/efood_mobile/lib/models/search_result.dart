class SearchResult<T>{
  int count=0;
  List<T> result=[];
  SearchResult({List<T>? result, int? count})
      : result = result ?? [],
        count = count ?? 0;
}