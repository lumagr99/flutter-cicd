import 'package:flutter/cupertino.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

final List<Device> defaultDevices = [
  Device.phone, // 390x844 (iPhone 13)
  Device.iphone11, // 414x896
  const Device(
    name: 'SmallAndroid',
    size: Size(320, 640),
    devicePixelRatio: 2.0,
    textScale: 1.0,
    safeArea: EdgeInsets.all(0),
  ),
  const Device(
    name: 'TabletLandscape',
    size: Size(1024, 768),
    devicePixelRatio: 2.0,
    textScale: 1.0,
    safeArea: EdgeInsets.all(0),
  ),
];
