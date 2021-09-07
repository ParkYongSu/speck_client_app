import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
RemoteConfig remoteConfig;

Future<RemoteConfig> getRemoteConfig() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;
  Map<String, dynamic> defaults =
  (Platform.isAndroid)
      ? {
    "update_version_android" : "$currentVersion",
    "min_version" : "1.0.0"
  }
      : {
    "update_version_ios" : "$currentVersion",
    "min_version" : "1.0.0"
  };

  remoteConfig = RemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero)).then((value) => print("value"));
  await remoteConfig.setDefaults(defaults);
  try {
    await remoteConfig.fetchAndActivate();
  }
  catch (e) {
    print(e);
  }
  print(5);

  return remoteConfig;
}
