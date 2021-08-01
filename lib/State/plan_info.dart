import "package:flutter/material.dart";

class PlanInfo extends ChangeNotifier{
  String _planName;
  String _sDate;
  String _eDate;
  String _compCondition;
  String _authTime;

  void setPlanName(String planName) => this._planName = planName;
  void setSDate(String sDate) => this._sDate = sDate;
  void setEdate(String eDate) => this._eDate = eDate;
  void setCompCondition(String compCondition) => this._compCondition = compCondition;
  void setAuthTime(String authTime) => this._authTime = authTime;

  String getPlanName() => this._planName;
  String getSDate() => this._sDate;
  String getEDate() => this._eDate;
  String getCompCondition() => this._compCondition;
  String getAuthTime() => this._authTime;
}