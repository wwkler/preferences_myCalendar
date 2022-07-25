import 'package:calendar/model/dataModel.dart';
import 'package:calendar/showCalendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => DataList()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: ShowCalendar(),
          ),
        ),
      ));
}
