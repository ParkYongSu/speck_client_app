import 'package:flutter/material.dart';
import 'package:speck_app/Main/notify/todo_note.dart';
import 'package:speck_app/State/notice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:speck_app/ui/ui_color.dart';
import 'package:speck_app/ui/ui_criteria.dart';
import 'todo_notice.dart';

class MainNotifyPage extends StatefulWidget {
  @override
  MainNotifyPageState createState() => MainNotifyPageState();
}

class MainNotifyPageState extends State<MainNotifyPage> {
  TodoNote _todoNote = new TodoNote();
  TodoNotice todoNotice = new TodoNotice();
  UICriteria _uiCriteria = new UICriteria();

  @override
  Widget build(BuildContext context) {
    Notice _notice = Provider.of<Notice>(context, listen: false);
    _uiCriteria.init(context);
    int noticeCount = _notice.getCount();
    //FlutterStatusbarcolor.setStatusBarColor(Colors.white);

    // return DefaultTabController(
    //     length: 3,
    //     initialIndex: 0,
    //     child: Container(
    //       decoration: BoxDecoration(
    //         color: Colors.white,
    //       ),
    //       child: Column(
    //         children: <Widget>[
    //           Container(
    //             decoration: BoxDecoration(
    //                 border: Border(bottom: BorderSide(color: Color(0XFFE3E3E3), width: 0.5))
    //             ),
    //             child: TabBar(
    //                 indicatorSize: TabBarIndicatorSize.tab,
    //                 onTap: (int index) async {
    //                   print(index);
    //                   setState(() {
    //                     _tabIndex = index;
    //                   });
    //                   if (index != 0) {
    //                     _notice.setZero();
    //                     _notice.clearNotRead();
    //                     _notice.clearWidgetList();
    //                     SharedPreferences sp = await SharedPreferences.getInstance();
    //                     String email = sp.getString("email");
    //                     String token = sp.getString("token");
    //                     // 알림리스트를 저장할 리스트 선언
    //                     List<dynamic> list;
    //                     // readFlag 가 false 인 알림의 id를 저장할 리스트 선언
    //                     List<int> falseList = [];
    //                     Notice notice = Provider.of<Notice>(context, listen: false);
    //                     // 서버에서 알림리스트를 받아옴
    //                     Future future = todoNotice.getNoticeList();
    //                     await future.then((value) => list = value,
    //                         onError: (e) => print(e));
    //                     // 알림리스트를 위젯으로 변경
    //                     if (list != null) {
    //                       for (int i = 0; i < list.length; i++) {
    //                         int id = list[i]["alarmId"];
    //                         String imagePath = list[i]["msg"]["imagePath"];
    //                         bool isRead = list[i]["readFlag"];
    //                         print(DateTime.now().add(Duration(hours: 9)).difference(DateTime.parse(list[i]["msg"]["transferTime"])).inHours);
    //                         print(DateTime.now().add(Duration(hours: 9)));
    //                         String transferTime = (DateTime.now().add(Duration(hours: 9)).difference(DateTime.parse(list[i]["msg"]["transferTime"])).inHours < 24)
    //                             ?DateTime.now().add(Duration(hours: 9)).difference(DateTime.parse(list[i]["msg"]["transferTime"])).inHours.toString() + "시간전"
    //                             :DateTime.now().difference(DateTime.parse(list[i]["msg"]["transferTime"])).inDays.toString() + "일전";
    //                         // 해당 알림을 읽지 않았다면
    //                         if (!isRead) {
    //                           // 읽지 않은 알림의 개수를 추가함
    //                           notice.add();
    //                           notice.addNotRead(id);
    //                           // 읽지 않은 알림의 id를 리스트에 추가함
    //                           falseList.add(id);
    //                         }
    //                         // 타입에 따라 위젯 생성
    //                         switch (list[i]["msg"]["type"]) {
    //                         // 시스템 알림
    //                           case "-1":
    //                             String content = list[i]["msg"]["content"];
    //                             notice.addWidget(id, todoNotice.systemNotice(context, id, imagePath, content, transferTime));
    //                             break;
    //                         // 친구요청
    //                           case "1":
    //                             String nickname = list[i]["msg"]["from"];
    //                             notice.addWidget(id, todoNotice.addFriendNotice(context, id, imagePath, nickname, transferTime));
    //                             break;
    //                         }
    //                       }
    //                     }
    //                     else {
    //                       list = [];
    //                     }
    //                     print(_notice.getNotRead());
    //                   }
    //                 },
    //                 indicatorColor: Color(0XFFFFED5A),
    //                 tabs: [
    //                   Container(height: 25, child: Text((noticeCount != 0)?"알림($noticeCount)":"알림", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: Colors.black))),
    //                   Container(height: 25, child: Text("친구 소식", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: Colors.black))),
    //                   Container(height: 25, child: Text("쪽지함", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: Colors.black))),
    //                 ]),
    //           ),
    //           Expanded(
    //               child: TabBarView(
    //                   children: <Widget>[
    //                     _noticeListView(),
    //                     _friendNewsListView(),
    //                     // _noteListView()
    //                     Container(
    //                         alignment: Alignment.topCenter,
    //
    //                         padding: EdgeInsets.only(top: 70.0),
    //                         child: Column(
    //                           mainAxisAlignment: MainAxisAlignment.start,
    //                           children: [
    //                             Text("새 알림이 없어요", style: TextStyle(fontSize: 16.0)),
    //                             SizedBox(
    //                               height: MediaQuery.of(context).size.height * 0.02,
    //                             ),
    //                             Text("(서비스 준비중입니다.)", style: TextStyle(fontSize: 16.0)),
    //                           ],
    //                         )
    //                     )
    //                   ]
    //               )
    //           )
    //         ],
    //       ),
    //     ),
    // );
    return _noticeListView();
  }

  List<Widget> _noticeList;
  List<Widget> _noteList;
  int _tabIndex;
  @override
  void initState() {
    super.initState();
    _noticeList = [];
    _noteList = [];
    _tabIndex = 0;
  }

  Widget _noticeListView() {
    print("hi");
    Notice notice = Provider.of<Notice>(context, listen: true);
    return (notice.getWidgetList().isNotEmpty)?
    Container(
      child: ListView.builder(
        itemCount: notice.getWidgetList().length,
        itemBuilder: (BuildContext context, int index) {
          _noticeList = notice.getWidgetList();
          print("noticeList: $_noticeList");
          return _noticeList[_noticeList.length - (index + 1)];
        },
      )
    )
    : Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(bottom: _uiCriteria.appBarHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("새 알림이 없어요", style: TextStyle(fontSize: _uiCriteria.textSize1, color: mainColor, fontWeight: FontWeight.bold)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text("(서비스 준비중입니다.)", style: TextStyle(fontSize: _uiCriteria.textSize1, color: mainColor, fontWeight: FontWeight.bold)),
          ],
        )
    );
  }

  Widget _friendNewsListView() {
    return Container(
        alignment: Alignment.topCenter,

        padding: EdgeInsets.only(top: 70.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("새 친구 소식이 없어요", style: TextStyle(fontSize: 16.0)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text("(서비스 준비중입니다.)", style: TextStyle(fontSize: 16.0)),
          ],
        )
    );
  }

  // Widget _noteListView() {
  //   print("쪽지함");
  //   _todoNote.addNoteList(context, _noteList);
  //   return (_noteList.length != 0)
  //       ? ListView.builder(
  //          itemCount: _noteList.length,
  //          itemBuilder: (BuildContext context, int index) {
  //            return _noteList[index];
  //          },
  //        )
  //       : Container(
  //       alignment: Alignment.topCenter,
  //
  //       padding: EdgeInsets.only(top: 70.0),
  //       child: Text("대화가 아직 없어요", style: TextStyle(fontSize: 13.0))
  //       );
  // }

}

