import 'package:connectivity/connectivity.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

class Connect {
  static const NOT_CONNECTED = 0;
  static const MOBILE = 1;
  static const WIFI = 2;

  Future<int> getConnectionState() async {
    var result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.mobile) {

      return Connect.MOBILE;
    }
    else if (result == ConnectivityResult.wifi) {
      return Connect.WIFI;
    }
    else if (result == ConnectivityResult.none) {
      return Connect.NOT_CONNECTED;
    }
    else {
      return Connect.NOT_CONNECTED;
    }
  }
}