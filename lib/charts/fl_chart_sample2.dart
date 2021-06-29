
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../global_functions.dart';
import 'package:http/http.dart' as http;
class LineChart2 extends StatelessWidget {
  final List<LineChartBarData> graphData;
  final String username;
  final List<double>dataMargins;
  final String graphTitle;
  final Function onDelete;
  const LineChart2({
    Key? key, required this.graphData, required this.dataMargins, required this.graphTitle, required this.username, required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: kBOTSDarkColor
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
                color: Colors.white,
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
              padding: const EdgeInsets.fromLTRB(8.0,0,12,0),
              child: LineChart(
                sampleData(),
                // isShowingMainData ? sampleData1() : sampleData2(),
                swapAnimationDuration: const Duration(milliseconds: 250),
                swapAnimationCurve: Curves.easeInCubic,
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8,0,8,8),
            child: Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: kBOTSLightColor,
                child: GestureDetector(
                  onTap: () async {
                    waitingCircularIndicator(context:context,show: true);
                    var response = await delete(username: username,
                        graph_name: graphTitle
                    );

                    if (response.statusCode == 200) {
                      var data = jsonDecode(response.body);
                      if (data['result'] == 'True') {
                        waitingCircularIndicator(context:context,show: false);
                        showMessage(context: context,
                            message: 'Successfully Done',
                            messageColor: kSuccessColor);
                        onDelete();

                      }
                      else {
                        waitingCircularIndicator(context:context,show: false);
                        showMessage(context: context,
                            message: data['error'],
                            messageColor: kErrorColor);
                      }
                    } else {
                      waitingCircularIndicator(context:context,show: false);
                      var responseString = response.body;
                      showMessage(context: context,
                          message: response.statusCode.toString(),
                          messageColor: kErrorColor);
                    }
                  },
                  child: Icon(Icons.remove,color: Colors.white,),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<http.Response> delete({username,graph_name})async{
    var headers = {
      'Authorization': 'Bearer<1a49fec40dc6387101622b82879ad5b6>',
    };
    var body = {
      'UserID': username,
      'BOTSID': graph_name
    };
    return http.post(Uri.parse('https://djangoapp.alijavdani.ir/delete/'),headers: headers,body:jsonEncode(body));
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
              color: Colors.white, fontSize: 12),
          margin: 4,
        ),
        rightTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => TextStyle(
              color: Colors.white, fontSize: 10),
          margin: 4,
        ),
        topTitles: SideTitles(showTitles: false),
      ),
      gridData: FlGridData(
          show: false,
          drawVerticalLine: false,
          drawHorizontalLine: false
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: Colors.white,
            width: 3,
          ),
          left: BorderSide(
            color: Colors.white,
            width: 3,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }


}
