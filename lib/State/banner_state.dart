import 'package:flutter/cupertino.dart';

class BannerState extends ChangeNotifier {
  int _eventStatus;
  int _galaxyStatus;
  int _mapStatus;

  void setEventStatus(int status) {
    this._eventStatus = status;
  }

  int getEventStatus() {
    return this._eventStatus;
  }

  void setGalaxyStatus(int status) {
    this._galaxyStatus = status;
  }

  int getGalaxyStatus() {
    return this._galaxyStatus;
  }

  void setMapStatus(int status) {
    this._mapStatus = status;
  }

  int getMapStatus() {
    return this._mapStatus;
  }
}