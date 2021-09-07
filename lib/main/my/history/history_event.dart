import 'dart:collection';
import 'dart:ui';

import 'package:speck_app/Time/return_auth_time.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryEvent {
  DateTime dateTime;
  int attendValue;
  Color color;
  int type;

  HistoryEvent(DateTime dateTime, int attendValue, int type) {
    this.dateTime = dateTime;
    this.attendValue = attendValue;
    this.color = (type == 0)?Color(0XFFE7535C):(attendValue == 1)?mainColor:greyD8D8D8;
    print(color);
  }
}

LinkedHashMap<DateTime, List<HistoryEvent>> getHistoryEvents(List<dynamic> infoList, int type) {
  if (infoList.isNotEmpty) {
    Map<DateTime, List<HistoryEvent>> events = LinkedHashMap<DateTime, List<HistoryEvent>>(
        equals: isSameDay,
        hashCode: hashCode
    );
    events.addAll(getHistoryEventSource(infoList, type));
    return events;
  }
  return LinkedHashMap();
}

Map<DateTime, List<HistoryEvent>> getHistoryEventSource(List<dynamic> infoList, int type) {
  Map<DateTime, List<HistoryEvent>> eventSource = Map.fromIterable(List.generate(infoList.length, (index) => index),
      key: (item) => DateTime.parse(infoList[item]["dateinfo"]),
      value: (item) {
        List<HistoryEvent> value = [];
        dynamic info = infoList[item];
        DateTime dateTime = DateTime.parse(info["dateinfo"]);
        int attendValue = info["attendvalue"];
        value.add(HistoryEvent(dateTime, attendValue, type));

        return value;
      }
  );
  return eventSource;
}

int hashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}