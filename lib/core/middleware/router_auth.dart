import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';
import 'package:journal/core/log.dart';

class RouteAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(
    String? route,
  ) {
    Log().d("======>$route");
    return RouteSettings(name: route);
  }
}
