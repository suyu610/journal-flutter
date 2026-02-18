// --- 数据模型 ---
class TripItem {
  final int id;
  final int tripId;
  final String itemName;
  bool isPacked;
  final int quantity;

  TripItem({
    required this.id,
    required this.tripId,
    required this.itemName,
    required this.isPacked,
    required this.quantity,
  });

  factory TripItem.fromJson(Map<String, dynamic> json) {
    return TripItem(
      id: json['id'],
      tripId: json['tripId'],
      itemName: json['itemName'],
      isPacked: json['isPacked'],
      quantity: json['quantity'],
    );
  }
}
