import 'package:bots_assignment/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BArChart1 extends StatefulWidget {
  final double barWidth;
  final List<BarChartGroupData> graphData;
  final List<double>dataMargins;
  const BArChart1({Key? key, required this.barWidth, required this.graphData, required this.dataMargins}) : super(key: key);
  @override
  State<StatefulWidget> createState() => BArChart1State();
}

class BArChart1State extends State<BArChart1> {

  int touchedIndex = -1;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: BarChart(
        BarChartData(
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: kBOTSDarkColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String month;
                    switch (group.x.toInt()) {
                      case 0:
                        month = 'Jan';
                        break;
                      case 1:
                        month = 'Feb';
                        break;
                      case 2:
                        month = 'Mar';
                        break;
                      case 3:
                        month = 'Apr';
                        break;
                      case 4:
                        month = 'Jun';
                        break;
                      case 5:
                        month = 'Jul';
                        break;
                      default:
                        throw Error();
                    }
                    return BarTooltipItem(
                      month + '\n',
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: (rod.y).toString(),
                          style: TextStyle(
                            color: kBOTSLightColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }),
              touchCallback: (barTouchResponse) {
                setState(() {
                  if (barTouchResponse.spot != null &&
                      barTouchResponse.touchInput is! PointerUpEvent &&
                      barTouchResponse.touchInput is! PointerExitEvent) {
                    touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  } else {
                    touchedIndex = -1;
                  }
                });
              },
            ),
          alignment: BarChartAlignment.center,
          maxY: widget.dataMargins[3],
          minY: widget.dataMargins[2],
          groupsSpace: 20,

          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (value) => const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
              margin: 10,
              rotateAngle: 0,
              getTitles: (double value) {
                switch (value.toInt()) {
                  case 0:
                    return 'Jan';
                  case 1:
                    return 'Feb';
                  case 2:
                    return 'Mar';
                  case 3:
                    return 'Apr';
                  case 4:
                    return 'Jun';
                  case 5:
                    return 'Jul';
                  default:
                    return '';
                }
              },
            ),

            leftTitles: SideTitles(
              showTitles: true,
              getTextStyles: (value) => const TextStyle(color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold),
              rotateAngle: 45,
              getTitles: (double value) {
                if (value == 0) {
                  return '0';
                }
                return '${value.toInt()}%';
              },
              interval: 5,
              margin: 8,
              reservedSize: 30,
            ),

          ),
          gridData: FlGridData(
            show: true,
            checkToShowHorizontalLine: (value) => value % 5 == 0,
            getDrawingHorizontalLine: (value) {
              if (value == 0) {
                return FlLine(color: const Color(0xff363753), strokeWidth: 3);
              }
              return FlLine(
                color: const Color(0xff2a2747),
                strokeWidth: 0.8,
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),

          barGroups: widget.graphData
        ),
      ),
    );
  }
}
