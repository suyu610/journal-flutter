class TripModel {
  int? id;
  String type;
  String status;
  String number;
  String duration;
  String depCity;
  String? depStation;
  String depTime;
  String depDate;
  String? depGate;
  String arrCity;
  String? arrStation;
  String arrTime;
  int dayDiff;
  String? seatClass;
  String? seatDetail;
  String? remark;
  int? indexOrder;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'index_order': indexOrder,
      'status': status,
      'transport': {
        'number': number,
        'duration': duration,
      },
      'departure': {
        'city': depCity,
        'station_airport': depStation,
        'time': depTime,
        'date': depDate,
        'gate_platform': depGate,
      },
      'arrival': {
        'city': arrCity,
        'station_airport': arrStation,
        'time': arrTime,
        'day_diff': dayDiff,
      },
      'finance': {
        'seat_class': seatClass,
        'seat_detail': seatDetail,
      },
      'meta': {
        'remark': remark,
      },
    };
  }

  TripModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        indexOrder = json['index_order'],
        type = json['type'],
        status = json['status'],
        number = json['transport']['number'] ?? '',
        duration = json['transport']['duration'] ?? '',
        depCity = json['departure']['city'],
        depStation = json['departure']['station_airport'],
        depTime = json['departure']['time'],
        depDate = json['departure']['date'],
        depGate = json['departure']['gate_platform'],
        arrCity = json['arrival']['city'],
        arrStation = json['arrival']['station_airport'],
        arrTime = json['arrival']['time'],
        dayDiff = json['arrival']['day_diff'] ?? 0,
        seatClass = json['finance']['seat_class'],
        seatDetail = json['finance']['seat_detail'],
        remark = json['meta']['remark'];
}
