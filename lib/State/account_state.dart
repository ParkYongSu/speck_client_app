import 'package:flutter/cupertino.dart';

class AccountState extends ChangeNotifier {
  String _mainAccount;
  String _subAccount;
  String _enterMain;
  String _enterSub;

  String getEnterSub() => _enterSub;

  setEnterSub(String value) {
    _enterSub = value;
    notifyListeners();
  }

  setEnterSub2(String value) {
    _enterSub = value;
  }

  String getEnterMain() => _enterMain;

  setEnterMain(String value) {
    _enterMain = value;
    notifyListeners();
  }

  setEnterMain2(String value) {
    _enterMain = value;
  }

  String getSubAccount() => _subAccount;

  setSubAccount(String value) {
    _subAccount = value;
    notifyListeners();
  }

  setSubAccount2(String value) {
    _subAccount = value;
  }

  String getMainAccount() => _mainAccount;

  setMainAccount(String value) {
    _mainAccount = value;
    notifyListeners();
  }

  setMainAccount2(String value) {
    _mainAccount = value;
  }
}