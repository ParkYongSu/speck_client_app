import 'dart:collection';
import 'dart:ui';

import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryEvent {
  DateTime dateTime;
  int attendValue;
  Color color;

  HistoryEvent(DateTime dateTime, int attendValue) {
    this.dateTime = dateTime;
    this.attendValue = attendValue;
    this.color = (attendValue == 1)?mainColor:greyD8D8D8;
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
        int attendValue = info["attendValue"];
        if (dateTime.isAfter(DateTime(DateTime.now().year, DateTime.now().month))
            || isSameDay(dateTime, DateTime(DateTime.now().year, DateTime.now().month))) {
          value.add(HistoryEvent(dateTime, attendValue ));
        }
        return value;
      }
  );
  return eventSource;
}

int hashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}