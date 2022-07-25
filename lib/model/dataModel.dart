import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 근본 Model
class Data {
  String content;
  String datetime;

  Data(this.content, this.datetime);

  // Data -> Map (SharedPreferences에 맞는 파일로 전환할 떄 쓰인다.)
  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "datetime": datetime,
    };
  }

  // Map -> Data (Model에 맞는 파일로 전환할 떄 쓰인다.)
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      json["content"]!,
      json["datetime"]!,
    );
  }
}

class DataList extends ChangeNotifier {
  // 중앙 집중식 관리 데이터 (지금은 Test용 Dummy 데이터) (call by reference)
  List<Data> collectData = [
    Data('밥먹기', DateTime.now().toString()),
    Data('잠자기', DateTime.now().toString()),
    Data('축구보기', DateTime.now().toString()),
    Data('선풍기틀기', DateTime.now().toString()),
    Data('지하철타기', DateTime.now().toString()),
    Data('컴퓨터하기', DateTime.now().toString()),
  ];

  // SharedPreferences 전용 데이터, 실행 변수
  List<String> sharedPreferencesData = [];
  SharedPreferences? prefs;

  // 전체 데이터 가져오기
  Future<void> getAllElement(String fileDateName) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    // SharedPreference 파일에서 데이터 가져오기
    sharedPreferencesData = prefs!.getStringList(fileDateName) ?? [];

    print('sharedPreferencesData 파일 데이터 : ${sharedPreferencesData}');

    // SharedPreferences 파일 형식 ->  중앙 집중식 관리 데이터 (List<Data>) 로 만들기 위한 과정
    collectData = [];

    for (int i = 0; i < sharedPreferencesData.length; i++) {
      Map<String, dynamic> jsonMap = jsonDecode(sharedPreferencesData[i]);

      Data data = Data.fromJson(jsonMap);

      collectData.add(data);
    }
    print('sharedPreference에서 파일을 가져온후 collectData : ${collectData}');

    // builder() 실행
    notifyListeners();
  }

  // 추가
  Future<void> addElement(Data element, String fileDateName) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    // 중앙 집중식 관리 데이터에 element 추가
    collectData.add(element);

    // 중앙 집중식 관리 데이터 형태 -> SharedPreference 파일에 적합한 데이터 형태로 만들기 (List<String> 형태)
    sharedPreferencesData = [];

    for (int i = 0; i < collectData.length; i++) {
      String jsonString = jsonEncode(collectData[i].toJson());
      sharedPreferencesData.add(jsonString);
    }

    print('collectData : ${collectData}');
    print('sharedPreferencesData : ${sharedPreferencesData}');

    //SharedPreference 파일에 데이터 저장하기
    prefs!.setStringList(fileDateName, sharedPreferencesData);

    //builder 함수 실행 (SharedPreferences 파일을 최신 업로드만 하고, 본래 model인 collectData를 사용한다.)
    notifyListeners();
  }

  // 수정
  void updateElement(String fileDateName) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    // 중앙 집중식 관리 데이터 형태 -> SharedPreference 파일에 적합한 데이터 형태로 만들기 (List<String> 형태)
    sharedPreferencesData = [];

    for (int i = 0; i < collectData.length; i++) {
      String jsonString = jsonEncode(collectData[i].toJson());
      sharedPreferencesData.add(jsonString);
    }

    // SharedPrefernce 파일에도 반영 (업데이트)
    prefs!.setStringList(fileDateName, sharedPreferencesData);

    notifyListeners();
  }

  // 삭제
  void deleteElement(Data element, String fileDateName) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    // data Element 삭제
    collectData.remove(element);

    // 중앙 집중식 관리 데이터 형태 -> SharedPreference 파일에 적합한 데이터 형태로 만들기 (List<String> 형태)
    sharedPreferencesData = [];

    for (int i = 0; i < collectData.length; i++) {
      String jsonString = jsonEncode(collectData[i].toJson());
      sharedPreferencesData.add(jsonString);
    }

    // SharedPrefrence 파일에도 반영 (업데이트)
    prefs!.setStringList(fileDateName, sharedPreferencesData);

    notifyListeners();
  }
}
