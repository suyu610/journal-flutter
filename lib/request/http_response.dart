// ignore_for_file: constant_identifier_names

import 'dart:convert';

class Result<T> {
  int? code;
  String? errorMsg;
  T? data;

  Result();

// from json
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result<T>()
      ..code = json['code']
      ..errorMsg = json['errorMsg']
      ..data = json['data'] as T;
  }

// to json
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'errorMsg': errorMsg,
      'data': data,
    };
  }

  @override
  String toString() {
    return jsonEncode(this);
  }

  static const int SUCCESS_CODE = 0;
}
