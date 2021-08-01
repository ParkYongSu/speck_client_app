import 'dart:collection';
import 'dart:ui';

import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  String time;
  DateTime dateTime;
  int official;
  String galaxyName;
  Color color;
  int attendValue;
  int groupNum;
  int bookInfo;
  int attendCount;
  int totalCount;
  int attRate;
  int totalDeposit;
  int myDeposit;
  int estimatePrize;
  int accumPrize;
  int totalDust;
  String placeCode;
  String placeName;
  String attendTime;
  int timeNum;
  int mannerTime;

  Event(DateTime dateTime, int official, String galaxyName, int groupNum, int bookInfo, int timeNum, [int attendCount,
  int totalCount, int attRate, int totalDeposit, int myDeposit, int estimatePrize, int accumPrize, int totalDust,
  String placeCode, String placeName, String attendTime, int mannerTime, int attendValue = 0]) {
    this.time = getAuthTime(timeNum);
    this.dateTime = dateTime;
    this.official = official;
    this.galaxyName = galaxyName;
    this.color = (attendValue == 1)?mainColor:greyD8D8D8;
    this.groupNum = groupNum;
    this.attendValue = attendValue;
    this.bookInfo = bookInfo;
    this.attendCount = attendCount;
    this.totalCount = totalCount;
    this.attRate = attRate;
    this.totalDeposit = totalDeposit;
    this.myDeposit = myDeposit;
    this.estimatePrize = estimatePrize;
    this.accumPrize = accumPrize;
    this.totalDust = totalDust;
    this.placeName = placeName;
    this.attendTime = attendTime;
    this.timeNum = timeNum;
    this.mannerTime = mannerTime;
  }
}

LinkedHashMap<DateTime, List<Event>> getEvents(List<dynamic> infoList, int index) {
  if (infoList.isNotEmpty) {
    Map<DateTime, List<Event>> events = LinkedHashMap<DateTime, List<Event>>(
        equals: isSameDay,
        hashCode: getHashCode
    );
    events.addAll(getEventSource(infoList, index));
    return events;
  }
  return LinkedHashMap();
}

Map<DateTime, List<Event>> getEventSource(List<dynamic> infoList, int index) {
  Map<DateTime, List<Event>> eventSource = Map.fromIterable(List.generate(infoList.length, (index) => index),
      // key: (item) => DateTime.parse(infoList[item]["calendar"]["dateinfo"]),
      key: (item) => (infoList[item]["calendar"] == null)?DateTime.parse(infoList[item]["dateinfo"]):DateTime.parse(infoList[item]["calendar"]["dateinfo"]),
      value: (item) {
        List<Event> value = [];
        if (infoList[item]["calendar"] == null) {
          dynamic calendar = infoList[item];
          int timeNum = calendar["timenum"];
          DateTime dateTime = DateTime.parse(calendar["dateinfo"]);
          int official = calendar["official"];
          String galaxyName = calendar["galaxyName"];
          int groupNum = calendar["groupnum"];
          int bookInfo = calendar["bookInfo"];
          value.add(Event(dateTime, official, galaxyName, groupNum, bookInfo, timeNum));

        }
        else {
          dynamic calendar = infoList[item]["calendar"];
          dynamic ticket = infoList[item]["ticket"];
          int timeNum = calendar["timenum"];
          DateTime dateTime = DateTime.parse(calendar["dateinfo"]);
          int official = calendar["official"];
          String galaxyName = calendar["galaxyName"];
          int attendValue = calendar["attendvalue"];
          int groupNum = calendar["groupnum"];
          int bookInfo = calendar["bookInfo"];
          int attendCount;
          int totalCount;
          int attRate;
          int totalDeposit;
          int myDeposit;
          int estimatePrize;
          int accumPrize;
          int totalDust;
          String placeCode;
          String placeName;
          String attendTime;
          int mannerTime;
          if (ticket != null) {
            attendCount = ticket["attendCount"];
            totalCount = ticket["totalCount"];
            attRate = ticket["attRate"];
            totalDeposit = ticket["totalDeposit"];
            myDeposit = ticket["myDeposit"];
            estimatePrize = ticket["estimatePrize"];
            accumPrize = ticket["accumPrize"];
            totalDust = ticket["totalDust"];
            placeCode = ticket["placeInfo"];
            placeName = ticket["placeName"];
            attendTime = ticket["attendTime"];
            mannerTime = ticket["mannerTime"];
          }
          value.add(Event(dateTime, official, galaxyName, groupNum, bookInfo,  timeNum,attendCount, totalCount, attRate,
              totalDeposit, myDeposit, estimatePrize, accumPrize, totalDust, placeCode, placeName, attendTime, mannerTime,attendValue));
        }

        return value;
      }
  );
  return eventSource;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}