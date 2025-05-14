import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'core/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  kTextForceVerticalCenterEnable = false;

  initApp(Env.beta);
}
