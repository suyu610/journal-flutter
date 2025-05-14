class Paging{
  List list;
  int total;
  bool hasNextPage;
  Paging(
      {required this.total,
      required this.list,
      required this.hasNextPage}
  );

  factory Paging.fromJson(Map<String, dynamic> json) {
    return Paging(
      total: json['total'],
      list: json['list'],
      hasNextPage: json['hasNextPage'],
    );
  }
}


