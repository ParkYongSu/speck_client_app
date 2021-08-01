import 'package:flutter/material.dart';

class RecommendBannerState extends ChangeNotifier {
  /// 상태변경되어도 한번만 열리게 하는 장치
  /// 1 -> 한번도 안연상태
  /// 0 -> 연상태
  int _mapBannerState = 1;
  int _galaxyBannerState = 1;

  void setMapBannerState(int state) {
    this._mapBannerState = state;
    notifyListeners();
  }

  void setGalaxyBannerState(int state) {
    this._galaxyBannerState = state;
    notifyListeners();
  }

  int getMapBannerState() {
    return this._mapBannerState;
  }

  int getGalaxyBannerState() {
    return this._galaxyBannerState;
  }

}