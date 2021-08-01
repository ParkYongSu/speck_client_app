import 'dart:collection';

import 'package:speck_app/Time/return_auth_time.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationEvent {
  String time;
  DateTime dateTime;

  ReservationEvent(int timeNum, DateTime dateTime) {
    this.time = getAuthTime(timeNum);
    this.dateTime = dateTime;
  }
}

LinkedHashMap<DateTime, List<ReservationEvent>> getReservationEvents(List<dynamic> infoList) {
  if (infoList.isNotEmpty) {
    Map<DateTime, List<ReservationEvent>> events = LinkedHashMap<DateTime, List<ReservationEvent>>(
        equals: isSameDay,
        hashCode: hashCode
    );
    events.addAll(getReservationEventSource(infoList));
    return events;
  }
  return LinkedHashMap();
}

Map<DateTime, List<ReservationEvent>> getReservationEventSource(List<dynamic> infoList) {
  Map<DateTime, List<ReservationEvent>> eventSource = Map.fromIterable(List.generate(infoList.length, (index) => index),
      key: (item) => DateTime.parse(infoList[item]["dateinfo"]),
      value: (item) {
        List<ReservationEvent> value = [];
        dynamic info = infoList[item];
        int timeNum = info["timenum"];
        DateTime dateTime = DateTime.parse(info["dateinfo"]);
        if (dateTime.isAfter(DateTime(DateTime.now().year, DateTime.now().month))
            || isSameDay(dateTime, DateTime(DateTime.now().year, DateTime.now().month))) {
          value.add(ReservationEvent(timeNum, dateTime));
        }
        return value;
      }
  );
  return eventSource;
}

int hashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}