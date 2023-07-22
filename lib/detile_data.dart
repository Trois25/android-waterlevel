import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class DataDetile extends StatefulWidget {
  const DataDetile({Key? key}) : super(key: key);

  @override
  State<DataDetile> createState() => _DataDetileState();
}

class _DataDetileState extends State<DataDetile> {

  List<DataPoint> dataPoints = [];
  int total = 0;
  String time = '';

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://103.102.153.194:2200/WaterLevel/connection.php'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<DataPoint> newDataPoints = [];
      for (var item in jsonData) {
        final dataPoint = DataPoint(
          DateTime.parse(item['timestamp']),
          double.parse(item['data']),
        );
        newDataPoints.add(dataPoint);
        total++;
      }
      setState(() {
        dataPoints = newDataPoints;
      });
    }
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
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: Text("Detile Data"),
        actions: [
          Center(
            child: Text("$time WIB"),
          )
        ],
      ),
      body:SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white70,
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
                    Text("Total Data", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),),
                    SizedBox(height: 15,),
                    Stack(
                      children: [
                        Text(total.toString(), style: TextStyle(
                          fontSize: 28,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Colors.grey[400]!,
                        ),),
                        Text(total.toString(),style: TextStyle(
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
                decoration: BoxDecoration(
                    color: Colors.white70,
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
                child: charts.TimeSeriesChart(
                  _createData(),
                  animate: true,
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
                                title: Text(selectedDatum.datum.Time.toString()),
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
                ),
              ),
            ],
          ),
        )
      ),
    ));
  }
  List<charts.Series<DataPoint, DateTime>> _createData() {
    return [
      charts.Series<DataPoint, DateTime>(
        id: 'Data',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DataPoint data, _) => data.Time,
        measureFn: (DataPoint data, _) => data.value,
        data: dataPoints,
        labelAccessorFn: (DataPoint point, _) => '${point.Time}: ${point.value}',
      ),
    ];
  }
}

class DataPoint {
  final DateTime Time;
  final double value;

  DataPoint(this.Time, this.value);
}
