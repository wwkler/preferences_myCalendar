import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'model/dataModel.dart';

class ShowCalendar extends StatefulWidget {
  ShowCalendar({Key? key}) : super(key: key);

  @override
  State<ShowCalendar> createState() => _ShowCalendarState();
}

class _ShowCalendarState extends State<ShowCalendar> {
  late DateTime _selectedCalendarDate; // 선택한 날짜
  DateTime _focusedCalendarDate = DateTime.now(); // 그 날짜가 있는 페이지로 전환하는 역할
  final DateTime _lastCalendarDate = DateTime.utc(2022, 12, 31); // 끝 날짜
  final DateTime _initialCalendarDate = DateTime.utc(2022, 1, 1); // 시작 날짜

  late String fileDateName; // 각 요일마다 SharedPreference 파일에 접근할 고유한 날짜 이름

  @override
  void initState() {
    super.initState();
    print('initState() 실행');
    _selectedCalendarDate = _focusedCalendarDate;

    getAllElement(); // async 함수
  }

  // SharedPreference 파일에서 데이터를 가져오는 함수
  Future<void> getAllElement() async {
    fileDateName = _selectedCalendarDate
        .toString()
        .substring(0, 10); // sharedPreferences 파일을 구분할 이름

    DataList dL = context.read<DataList>();
    await dL.getAllElement(fileDateName);
  }

  @override
  Widget build(BuildContext context) {
    print('build() 실행');
    return Consumer<DataList>(builder: (context, dataList, child) {
      List<Data> collectData =
          dataList.collectData; // 중앙 집중식 관리 데이터를 가져온다. (call by reference)

      print('builder()를 잘 실행했습니다.');

      return Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(10.0),
                  elevation: 5.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    side: BorderSide(color: Colors.blueGrey, width: 2.0),
                  ),
                  child: myTableCalender(dataList),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    width: double.infinity,
                    height: 200,
                    child: Stack(
                      children: [
                        ShowListView(
                            collectData: collectData,
                            fileDateName: fileDateName),
                        MyElevatedButton(
                          addTask: addTask,
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      );
    });
  }

// TableCalender 본체
  TableCalendar<dynamic> myTableCalender(DataList collectData) {
    return TableCalendar(
      firstDay: _initialCalendarDate,
      lastDay: _lastCalendarDate,
      focusedDay: _focusedCalendarDate,
      locale: 'ko-KR',
      headerStyle: myHeaderStyle(),
      calendarStyle: myCalendarStyle(),
      selectedDayPredicate: (currentSelectedDate) {
        return (isSameDay(_selectedCalendarDate, currentSelectedDate));
      },
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) async {
        if (!isSameDay(_selectedCalendarDate, selectedDay)) {
          // 두 날짜가 같지 않으면 if문 실행
          _selectedCalendarDate = selectedDay;
          _focusedCalendarDate = focusedDay;

          // 각 날짜마다 sharedPreference에 저장할 파일 이름을 설정한다.
          fileDateName = _selectedCalendarDate.toString().substring(0, 10);

          // //sharedPreference에서 관련 데이터 가져오기 -> builder() 실행
          await collectData.getAllElement(fileDateName);
        }
      },
    );
  }

  // Custom Header Style
  HeaderStyle myHeaderStyle() {
    return HeaderStyle(
      headerMargin: EdgeInsets.only(left: 40, top: 10, right: 40, bottom: 10),
      headerPadding: EdgeInsets.all(15.0),
      titleCentered: true,
      formatButtonVisible: false,
      leftChevronIcon: Icon(
        Icons.arrow_left,
        size: 25.0,
      ),
      rightChevronIcon: Icon(
        Icons.arrow_right,
        size: 25.0,
      ),
      titleTextStyle: myTextStyle(),
    );
  }

  // Custom Text Style
  TextStyle myTextStyle() {
    return TextStyle(
        fontSize: 25.0, color: Colors.amber, fontWeight: FontWeight.bold);
  }

  // Custom Calendar Style
  CalendarStyle myCalendarStyle() {
    return CalendarStyle(
        weekendTextStyle: TextStyle(color: Colors.red),
        todayDecoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent),
        selectedDecoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent));
  }

  // 하단 오른쪽 "Add Event" Click시 처리하는 함수
  void addTask() {
    print('addTask() 실행했습니다.');

    String txt = "";
    TextEditingController text = TextEditingController();

    showDialog(
        useRootNavigator: false,
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text('Add Event Page'),
            //
            content: SizedBox(
              width: 200,
              height: 100,
              child: TextFormField(
                controller: text,
                onChanged: (String value) {
                  print('onChanged() 값 : ${value}');
                  txt = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '입력해주세요',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            actions: [
              TextButton(
                  onPressed: () async {
                    if (!txt.isEmpty) {
                      // 우리나라 시간대를 가져오기 위한 코드
                      print('추가 버튼을 눌렀습니다.');
                      DateTime currentTime = await NTP.now();
                      currentTime = currentTime.toUtc().add(Duration(hours: 9));

                      // Hour, Minute만 가져온다.
                      String hm = DateFormat('HH:mm').format(currentTime);

                      // SharedPreferences에 추가 데이터 반영 코드
                      DataList dd = context.read<DataList>();
                      dd.addElement(Data(txt, hm), fileDateName);

                      Navigator.pop(context);
                    } else {
                      showSnackBar(context);
                    }
                  },
                  child: Text('추가')),
              TextButton(
                  onPressed: () {
                    return Navigator.pop(context);
                  },
                  child: Text('취소'))
            ],
          );
        });
  }
}

// ListView를 보여주는 Widget
class ShowListView extends StatelessWidget {
  List<Data> collectData; // call by reference
  String fileDateName; // Preferences 파일 이름을 결정 짓는 역할

  ShowListView({
    required this.fileDateName,
    required this.collectData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: collectData.length,
        itemBuilder: (BuildContext context, int index) {
          Data data = collectData[index];

          return ListTile(
            leading: Text(
              data.content,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              data.datetime,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10.0,
              ),
            ),
            onTap: () {
              updateData(data, context);
            }, // 수정 Event
            onLongPress: () {
              removeData(data, context);
            }, // 삭제 Event
          );
        });
  }

  // ListTile를 한번 Tap 하면 수정하는 함수
  void updateData(Data data, BuildContext context) {
    String txt = "";
    TextEditingController text = TextEditingController();

    showDialog(
        useRootNavigator: false,
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text('Update Event Page'),
            //
            content: SizedBox(
              width: 200,
              height: 100,
              child: TextFormField(
                controller: text,
                onChanged: (String value) {
                  print('onChanged() 값 : ${value}');
                  txt = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '입력해주세요',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            actions: [
              TextButton(
                  onPressed: () async {
                    if (!txt.isEmpty) {
                      // 우리나라 시간대를 가져오기 위한 코드
                      print('추가 버튼을 눌렀습니다.');
                      DateTime currentTime = await NTP.now();
                      currentTime = currentTime.toUtc().add(Duration(hours: 9));

                      // Hour, Minute만 가져온다.
                      String hm = DateFormat('HH:mm').format(currentTime);

                      // Data element 값 수정 (Update)
                      data.content = txt;
                      data.datetime = hm;

                      // SharedPreferences 파일에도 Update
                      DataList dd = context.read<DataList>();
                      dd.updateElement(fileDateName);

                      Navigator.pop(context);
                    } else {
                      showSnackBar(context);
                    }
                  },
                  child: Text('수정')),
              TextButton(
                  onPressed: () {
                    return Navigator.pop(context);
                  },
                  child: Text('취소'))
            ],
          );
        });
  }

  // ListTile을 onLongPress 하면 실행하는 함수
  void removeData(Data data, BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text('Remove Event Page'),
            //
            content: SizedBox(
                width: 200,
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('"${data.content}"를 삭제하시겠습니까?'),
                )),

            actions: [
              TextButton(
                  onPressed: () {
                    DataList dd = context.read<DataList>();
                    dd.deleteElement(data, fileDateName);

                    Navigator.pop(context);
                  },
                  child: Text('삭제')),
              TextButton(
                  onPressed: () {
                    return Navigator.pop(context);
                  },
                  child: Text('취소'))
            ],
          );
        });
  }
}

// snackBar을 보여주는 함수
void showSnackBar(BuildContext context) {
  SnackBar snackbar = SnackBar(
    content: Text('빈 값 입니다.'),
    backgroundColor: Colors.black,
    duration: Duration(milliseconds: 4000), // 4초
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: "",
      onPressed: () {},
      textColor: Colors.white10,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

// ElevatedButton을 관리하는 widget
class MyElevatedButton extends StatelessWidget {
  final VoidCallback addTask;

  const MyElevatedButton({
    required this.addTask,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: ElevatedButton(
        onPressed: addTask,
        child: Text(
          'Add Event',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          )),
        ),
      ),
    );
  }
}
