class PageInfo {
  int currentPage;
  int perPage;
  int pageCount;
  int itemCount;
  bool hasNextPage;
  bool hasPreviousPage;

  PageInfo.fromJson(Map<String, dynamic> json)
      : currentPage = json['currentPage'],
        perPage = json['perPage'],
        pageCount = json['pageCount'],
        itemCount = json['itemCount'],
        hasNextPage = json['hasNextPage'],
        hasPreviousPage = json['hasPreviousPage'];
}

class Pagination {
  List<Map<String, Object>> items;
  PageInfo pageInfo;

  Pagination.fromJson(Map<String, dynamic> json)
      : items = json['items'],
        pageInfo = PageInfo.fromJson(json['pageInfo']);
}
