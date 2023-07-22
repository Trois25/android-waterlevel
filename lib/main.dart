import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iot_waterlevel/main_page.dart';
import 'services/notif_service.dart';


void main() async{
  //init local notif
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  //end init local notif
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner : false,
      title: 'Flutter Demo',
      home: MainPage(),
    );
  }
}