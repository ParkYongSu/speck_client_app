import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

Future<RemoteConfig> getRemoteConfig() async {
  RemoteConfig remoteConfig;
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
  await remoteConfig.fetchAndActivate();
  print("존시나 ${remoteConfig.getString("update_version_ios")}");
  return remoteConfig;
}
