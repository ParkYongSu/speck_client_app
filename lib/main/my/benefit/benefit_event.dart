import 'dart:collection';
import 'dart:ui';

import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:table_calendar/table_calendar.dart';

class BenefitEvent {
  int official;
  String galaxyName;
  int timeNum;
  int attCount;
  int absentCount;
  int totalCount;
  int deposit;
  DateTime attTime;
  int bookInfo;
  DateTime dateInfo;
  int myAccumReward;
  int totalReward;
  int unitReward;
  int myReward;
  int dailyDeposit;
  List<dynamic> prizeWithdrawal;

  BenefitEvent(int official, String galaxyName, int timeNum, int attCount, int absentCount, int totalCount,
  int deposit, DateTime attTime, int bookInfo, DateTime dateInfo, int myAccumReward, int totalReward, int unitReward, int myReward,
      int dailyDeposit, List<dynamic> prizeWithdrawal) {
    this.official = official;
    this.galaxyName = galaxyName;
    this.timeNum = timeNum;
    this.attCount = attCount;
    this.absentCount = absentCount;
    this.totalCount = totalCount;
    this.deposit = deposit;
    this.attTime = attTime;
    this.bookInfo = bookInfo;
    this.dateInfo = dateInfo;
    this.myAccumReward = myAccumReward;
    this.totalReward = totalReward;
    this.unitReward = unitReward;
    this.myReward = myReward;
    this.dailyDeposit = dailyDeposit;
    this.prizeWithdrawal = prizeWithdrawal;
  }
}

LinkedHashMap<DateTime, List<BenefitEvent>> getEvents(List<dynamic> infoList) {
  if (infoList.isNotEmpty) {
    Map<DateTime, List<BenefitEvent>> events = LinkedHashMap<DateTime, List<BenefitEvent>>(
        equals: isSameDay,
        hashCode: getHashCode
    );
    events.addAll(getEventSource(infoList));
    return events;
  }
  return LinkedHashMap();
}

Map<DateTime, List<BenefitEvent>> getEventSource(List<dynamic> infoList) {
  Map<DateTime, List<BenefitEvent>> eventSource = Map.fromIterable(List.generate(infoList.length, (index) => index),
      key: (item) => (infoList[item]["prizeWithdrawal"] != null)
          ? DateTime.parse(infoList[item]["prizeWithdrawal"][0]["prizeTime"]) // 어차피 다 같은 날짜임
          : DateTime.parse(infoList[item]["rewardDetailList"]["dateinfo"]),
      value: (item) {
        List<BenefitEvent> value = [];
        dynamic rewardDetailList = infoList[item]["rewardDetailList"];
        int official;
        String galaxyName;
        int timeNum;
        int attCount;
        int absentCount;
        int totalCount;
        int deposit;
        DateTime attTime;
        int bookInfo;
        DateTime dateInfo;
        int myAccumReward;
        int totalReward;
        int unitReward;
        int myReward;
        int dailyDeposit;
        List<dynamic> prizeWithdrawal;

        if (rewardDetailList != null) {
          official = rewardDetailList["official"];
          galaxyName = rewardDetailList["galaxyName"];
          timeNum = rewardDetailList["timeNum"];
          attCount = rewardDetailList["attCount"];
          absentCount = rewardDetailList["absentCount"];
          totalCount = rewardDetailList["totalCount"];
          deposit = rewardDetailList["deposit"];
          attTime = (rewardDetailList["attTime"] == null)?null:DateTime.parse(rewardDetailList["attTime"]);
          bookInfo = rewardDetailList["bookinfo"];
          dateInfo = DateTime.parse(rewardDetailList["dateinfo"]);
          myAccumReward = rewardDetailList["myAccumReward"];
          totalReward = rewardDetailList["totalReward"];
          unitReward = rewardDetailList["unitReward"];
          myReward = rewardDetailList["myReward"];
          dailyDeposit = rewardDetailList["daily_deposit"];
        }

        if (infoList[item]["prizeWithdrawal"] != null) {
          prizeWithdrawal = infoList[item]["prizeWithdrawal"];
        }

        value.add(BenefitEvent(official, galaxyName, timeNum, attCount, absentCount, totalCount,
            deposit, attTime, bookInfo, dateInfo, myAccumReward, totalReward, unitReward, myReward, dailyDeposit, prizeWithdrawal));
        return value;
      }
  );
  return eventSource;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}