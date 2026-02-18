import 'package:journal/models/trip_item.dart';

class Trip {
  int id;
  String name;
  bool isCurrent;

  List<TripItem>? itemList;

  Trip({
    required this.id,
    required this.name,
    required this.isCurrent,
    this.itemList,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      name: json['name'],
      isCurrent: json['current'] ?? false,
      itemList: json['itemList'] != null
          ? (json['itemList'] as List).map((i) => TripItem.fromJson(i)).toList()
          : null,
    );
  }
}
