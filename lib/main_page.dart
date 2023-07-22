import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:iot_waterlevel/detile_data.dart';
import 'package:iot_waterlevel/services/notif_service.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List _dataAir = [];
  List _dataTable = [];
  String time = '';
  String current = '';
  //List<charts.Series<DataPoint, DateTime>> seriesList = [];
  List<DataPoint> data = [];

  void _ambildata() async{
    String url = "http://103.102.153.194:2200/WaterLevel/connection.php";
    //String url = "http://127.0.0.1/ambildata/connection.php";
    final res = await http.get(Uri.parse(url));
    _dataAir = json.decode(res.body);
    List<DataPoint> points = [];
    int startIndex = _dataAir.length - 5;

    if (startIndex < 0) startIndex = 0;
    for (var i = startIndex; i < _dataAir.length; i++) {
      final item = _dataAir[i];
      points.add(DataPoint(item['timestamp'], int.parse(item['data'])));
      //points.add(DataPoint(item['Time'], int.parse(item['data'])));
      current = item['data'].toString();
    }
    setState(() {
      data = points;
      if(int.parse(current) >= 160){
        NotificationService()
            .showNotification(title: 'DANGER!', body: 'Water Level Reach 160');
      }
    });
  }

  void _ambildatatable() async{
    String url = "http://103.102.153.194:2200/WaterLevel/datatable.php";
    //String url = "http://127.0.0.1/ambildata/datatable.php";
    final res = await http.get(Uri.parse(url));
    _dataTable = json.decode(res.body);
  }

  void updateTime() {
    String formattedDateTime =
    DateFormat('HH:mm:ss').format(DateTime.now());
    setState(() {
      time = formattedDateTime;
    });
    Future.delayed(Duration(seconds: 1), updateTime);
  }

  @override
  void initState() {
    super.initState();
    updateTime();
    _ambildata();
    _ambildatatable();
    Timer.periodic(Duration(seconds: 5), (_) => _ambildata());
    Timer.periodic(Duration(seconds: 5), (_) => _ambildatatable());
  }

  Widget build(BuildContext context) {

    List<charts.Series<DataPoint, String>> series = [
      charts.Series(
        id: 'Data',
        data: data,
        domainFn: (DataPoint point, _) => point.label,
        measureFn: (DataPoint point, _) => point.value,
        labelAccessorFn: (DataPoint point, _) => '${point.label}: ${point.value}',
        colorFn: (DataPoint data, _) => data.value >= 160
            ? charts.ColorUtil.fromDartColor(Colors.red)
            : charts.ColorUtil.fromDartColor(Colors.blue),
      ),

    ];

    return SafeArea(child: Scaffold(
      backgroundColor: Colors.lightBlue,
        appBar: AppBar(
          title: Text("Water Level"),
          actions: [
            Center(
              child: Text("$time WIB"),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blue ,
                              blurRadius: 2.0,
                              offset: Offset(2.0,2.0)
                          )
                        ]
                    ),
                    height: 100,
                    width: 250,
                    child: Column(
                      children: [
                        SizedBox(height: 15,),
                        Text("Current Water Level", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),),
                        SizedBox(height: 15,),
                        Stack(
                         children: [
                           Text(current, style: TextStyle(
                             fontSize: 28,
                             foreground: Paint()
                               ..style = PaintingStyle.stroke
                               ..strokeWidth = 3
                               ..color = Colors.grey[400]!,
                           ),),
                           Text(current,style: TextStyle(
                               fontSize: 28,
                               color: Colors.blue[800]
                           ),)
                         ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                      child: Row(
                        children: [
                          Text("Water Level Chart",style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                          ),),
                        ],
                      )
                  ),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.grey,
                            width: 1.0
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blue ,
                              blurRadius: 2.0,
                              offset: Offset(2.0,2.0)
                          )
                        ]
                    ),
                    height: 400,
                    child: charts.BarChart(
                      series,
                      animate: true,
                      //tambahan untuk menampilkan ketika di klik
                      behaviors: [
                        charts.SelectNearest(),
                        charts.DomainHighlighter()
                      ],
                      selectionModels: [
                        charts.SelectionModelConfig(
                          type: charts.SelectionModelType.info,
                          changedListener: (charts.SelectionModel model) {
                            if (model.hasDatumSelection) {
                              final selectedDatum = model.selectedDatum[0];
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(selectedDatum.datum.label),
                                    content: Text('Value: ${selectedDatum.datum.value}'),
                                    actions: [
                                      TextButton(
                                        child: Text('Close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                      //akhir tambahan untuk menampilkan ketika di klik
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: Row(
                      children: [
                        Text("Water Level Log",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                        ),),
                      ],
                    )
                  ),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.grey,
                            width: 1.0
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blue ,
                              blurRadius: 2.0,
                              offset: Offset(2.0,2.0)
                          )
                        ]
                    ),
                    height: 400,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        DataTable(
                            columns:<DataColumn>[
                              DataColumn(label: Text("Time")),
                              DataColumn(label: Text("Water Level"))
                            ],
                            rows: _dataTable.map((item) => DataRow(cells: <DataCell>[
                              DataCell(Text(item["timestamp"])),
                              //DataCell(Text(item["Time"])),
                              DataCell(Text(item["data"])),
                            ])).toList()
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>
                                DataDetile()));
                      },
                      child: Text("Detile",style: TextStyle(
                        color: Colors.black
                      ),),),

                  )
                ],
              ),
            ),
          ),
        )
    ));
  }
}

class DataPoint {
  final String label;
  final int value;

  DataPoint(this.label, this.value);
}
