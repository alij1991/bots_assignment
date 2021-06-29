
import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../global_functions.dart';
import 'package:http/http.dart' as http;

import 'fl_chart_sample3.dart';


class LineChart1 extends StatelessWidget {
  final List<LineChartBarData> graphData;
  final String username;
  final List<double>dataMargins;
  final String graphTitle;
  const LineChart1({
    Key? key, required this.graphData, required this.dataMargins, required this.graphTitle, required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Theme.of(context).cardColor
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 4,
          ),
          Text(
            graphTitle,
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0,2,16,2),
              child: LineChart(
                sampleData(),
                swapAnimationDuration: const Duration(milliseconds: 250),
                swapAnimationCurve: Curves.easeInCubic,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8,0,8,8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: kBOTSDarkColor,
                  child: GestureDetector(
                    onTap: (){
                      showDetailDialog(context: context,title: graphTitle);
                    },
                    child: Icon(Icons.search),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: kBOTSDarkColor,
                  child: GestureDetector(
                    onTap: () async {
                      waitingCircularIndicator(context:context,show: true);
                      var response = await addGraph(username: username,
                          graph_name: graphTitle
                      );

                      if (response.statusCode == 200) {
                        var data = jsonDecode(response.body);
                        if (data['result'] == 'True') {
                          waitingCircularIndicator(context:context,show: false);
                          showMessage(context: context,
                              message: 'Successfully Done',
                              messageColor: kSuccessColor);
                        }
                        else {
                          waitingCircularIndicator(context:context,show: false);
                          showMessage(context: context,
                              message: data['error'],
                              messageColor: kErrorColor);
                        }
                      } else {
                        waitingCircularIndicator(context:context,show: false);
                        showMessage(context: context,
                            message: response.statusCode.toString(),
                            messageColor: kErrorColor);
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  void showDetailDialog({required BuildContext context,required String title})
  {
    double barWidth =20;
    List<int> xData = [0,1,2,3,4,5];
    final _random = Random();
    List<double> yData = [];
    for (int i=0;i<xData.length;i++) {
      yData.add(double.parse(((_random.nextDouble() * 100)-50).toStringAsFixed(2)));
    }
    double minY = yData.reduce((curr, next) => curr < next? curr: next);
    double maxY = yData.reduce((curr, next) => curr > next? curr: next);
    List <BarChartGroupData> profitData = [];
    List<double> bordersRadius = [0,0,0,0];

    for (int i =0;i<xData.length;i++)
      {
        if (yData[i]>0) {
          bordersRadius[0] = 4;
          bordersRadius[1] = 4;
          bordersRadius[2] = 0;
          bordersRadius[3] = 0;
        }
        else{
          bordersRadius[0] = 0;
          bordersRadius[1] = 0;
          bordersRadius[2] = 4;
          bordersRadius[3] = 4;
        }
        profitData.add(
          BarChartGroupData(
            x: xData[i],
            barRods: [
              BarChartRodData(
                y: yData[i],
                width: barWidth,
                colors: [yData[i]>0?kBOTSLightColor:kBOTSDarkColor],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(bordersRadius[0]),
                    topRight: Radius.circular(bordersRadius[1]),
                    bottomLeft: Radius.circular(bordersRadius[2]),
                    bottomRight: Radius.circular(bordersRadius[3]),
                ),

              ),
            ],
          )
        );
      }


    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16),bottomLeft: Radius.circular(0),bottomRight: Radius.circular(0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(title+' Profitability',style: TextStyle(
                      color: kBOTSDarkColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0,8,16,8),
                  child: BArChart1(graphData: profitData,dataMargins: [0,5,minY,maxY],barWidth: 20,),
                )
              ],
            ),
          );
        });
  }
  Future<http.Response> addGraph({username,graph_name})async{
    var headers = {
      'Authorization': 'Bearer<1a49fec40dc6387101622b82879ad5b6>',
    };
    var body = {
      'UserID': username,
      'BOTSID': graph_name
    };
    return http.post(Uri.parse('https://djangoapp.alijavdani.ir/add/'),headers: headers,body:jsonEncode(body));
  }
  LineChartData sampleData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      lineBarsData: graphData,
      minX: dataMargins[0],
      maxX: dataMargins[1],
      minY: dataMargins[2],
      maxY: dataMargins[3],
      titlesData: FlTitlesData(
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => TextStyle(
              color: kBOTSDarkColor, fontSize: 12),
          margin: 4,
        ),
        rightTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => TextStyle(
              color: kBOTSDarkColor, fontSize: 10),
          margin: 4,
        ),
        topTitles: SideTitles(showTitles: false),
      ),
      gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true
      ),
      borderData: FlBorderData(show: true),
    );
  }


}
