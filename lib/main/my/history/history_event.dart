import 'dart:collection';

import 'package:speck_app/Time/return_auth_time.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryEvent {
  DateTime dateTime;

  HistoryEvent(DateTime dateTime) {
    this.dateTime = dateTime;
  }
}

LinkedHashMap<DateTime, List<HistoryEvent>> getHistoryEvents(List<dynamic> infoList) {
  if (infoList.isNotEmpty) {
    Map<DateTime, List<HistoryEvent>> events = LinkedHashMap<DateTime, List<HistoryEvent>>(
        equals: isSameDay,
        hashCode: hashCode
    );
    events.addAll(getHistoryEventSource(infoList));
    return events;
  }
  return LinkedHashMap();
}

Map<DateTime, List<HistoryEvent>> getHistoryEventSource(List<dynamic> infoList) {
  Map<DateTime, List<HistoryEvent>> eventSource = Map.fromIterable(List.generate(infoList.length, (index) => index),
      key: (item) => DateTime.parse(infoList[item]["dateinfo"]),
      value: (item) {
        List<HistoryEvent> value = [];
        dynamic info = infoList[item];
        DateTime dateTime = DateTime.parse(info["dateinfo"]);
        if (dateTime.isAfter(DateTime(DateTime.now().year, DateTime.now().month))
            || isSameDay(dateTime, DateTime(DateTime.now().year, DateTime.now().month))) {
          value.add(HistoryEvent(dateTime));
        }
        return value;
      }
  );
  return eventSource;
}

int hashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}