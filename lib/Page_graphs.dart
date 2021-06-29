import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:bots_assignment/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'charts/fl_chart_sample1.dart';
import 'charts/fl_chart_sample2.dart';
import 'global_functions.dart';

class PageGraphs extends StatefulWidget {
  final String username;
  var allBots;
  var userBots;
  PageGraphs({Key? key, required this.username, required this.allBots, required this.userBots}) : super(key: key);
  @override
  _PageGraphsState createState() => _PageGraphsState();
}

class _PageGraphsState extends State<PageGraphs> with SingleTickerProviderStateMixin{
  int _currentIndex = 1;
  String _currentTitle = 'Dashboard';
  List<Widget> _chartChildren = [];
  late TabController _tabController;
  late Function pages;
  List<Stream> datasStream =[];
  List<StreamSubscription> dataStreamSubscription = [];
  List<List<FlSpot>> dataPoints = [];

  Stream<List<double>> timedCounter({required Duration interval,required String botName,required int index,required List<double> data}) async* {
    double xVal = 0;
    double step =1;
    while (true) {
      await Future.delayed(interval);
      yield [index.toDouble(),xVal,data[index]];
      index++;
      xVal+=step;
      if(index==data.length)
        index=0;
    }
  }
  void startStreams({required HashMap data}) {
    if (dataStreamSubscription.length == 0) {
      for (int i = 0; i < data.length; i++) {
        dataPoints.add([]);
        datasStream.add(
            timedCounter(
                index: 0,
                botName: widget.userBots.keys.elementAt(i),
                data: widget.userBots[widget.userBots.keys.elementAt(i)],
                interval: Duration(milliseconds: 10)
            )
        );
        dataStreamSubscription.add(datasStream[i].listen((event) {
            while (dataPoints[i].length > data[data.keys.elementAt(0)].length-1) {
              dataPoints[i]=[];
            }
            setState(() {
              dataPoints[i].add(FlSpot(event[0], event[2]));
            });
            if (_currentIndex != 0) {
              print('Cancel Stream');
              dataStreamSubscription[i].cancel();
            }
          })
        );
      }
    }
    else {
      try {
        for (int i = 0; i < dataStreamSubscription.length; i++) {
          dataStreamSubscription[i].cancel();
        }
      }
      catch (e){
      }
      datasStream = [];
      dataStreamSubscription = [];
      dataPoints = [];
      startStreams(data: data);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 2,initialIndex: 1);

    pages = ({required allBots,required userBots,required String username}){
      return [
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: userBots.length,
          itemBuilder: (BuildContext context, int index) {
            String botTitle = userBots.keys.elementAt(index);
            double minX = 0;
            double maxX = userBots[botTitle].length.toDouble();
            String x = '';
            List<double> result = [];
            List<FlSpot> spots =  [];
            for(int i = 0; i < maxX; i++)
            {
              result.add(userBots[botTitle][i].toDouble());
              spots.add(FlSpot(i.toDouble(), result[i]));
            }
            double minY = result.reduce((curr, next) => curr < next? curr: next);
            double maxY = result.reduce((curr, next) => curr > next? curr: next);

            LineChartBarData lineChartBarData = LineChartBarData(
              spots: dataPoints[index],
              isCurved: false,
              isStrokeCapRound: false,

              barWidth: 2,
              belowBarData: BarAreaData(
                show: false,
              ),
              colors: [
                kBOTSDarkColor,
              ],
              dotData: FlDotData(show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(radius: 1,
                        color: kBOTSLightColor.withOpacity(1),
                    // strokeColor: Colors.white.withOpacity(1),
                    strokeWidth: 0),
              ),

              show: true,
              // showingIndicators: [-1,0,1],

            );
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart2(
                graphTitle: botTitle,
                dataMargins: [minX,maxX,minY,max(maxY,1)],
                graphData: [lineChartBarData],
                username: username,
                onDelete: (){
                  _currentIndex = 1;
                  _tabController.animateTo(1);
                  _currentTitle = 'Dashboard';
                  setState(() {

                  });
                },
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>  SizedBox(height: 40,),
        ),

        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: allBots.length,
          itemBuilder: (BuildContext context, int index) {
            String botTitle = allBots.keys.elementAt(index);
            double minX = 0;
            double maxX = allBots[botTitle].length.toDouble();
            String x = '';
            List<double> result = [];
            List<FlSpot> spots =  [];
            for(int i = 0; i < maxX; i++)
            {
              result.add(allBots[botTitle][i]);
              spots.add(FlSpot(i.toDouble(), result[i]));
            }
            double minY = result.reduce((curr, next) => curr < next? curr: next);
            double maxY = result.reduce((curr, next) => curr > next? curr: next);

            LineChartBarData lineChartBarData = LineChartBarData(
              spots: spots,
              isCurved: true,
              colors: [
                kBOTSLightColor,
              ],
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: false,
              ),
              show: true,
              showingIndicators: [-1,0,1],

            );
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart1(
                graphTitle: botTitle,
                dataMargins: [minX,maxX,minY,max(maxY,1)],
                graphData: [lineChartBarData],
                username: username,
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>  SizedBox(height: 40,),
        )
      ];
    };
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
        Hero(
            tag: 'backIcon',
            child: GestureDetector(
                onTap: ()=>Navigator.pop(context,true),
                child: Icon(Icons.arrow_back_outlined,color: Theme.of(context).buttonColor,)
            )
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  // child: SvgPicture.asset("assets/images/BOTS_Icon.svg")
                  child: Text(_currentTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Hero(
              tag: 'botIcon',
              child: Container(
                  width: 80,
                  height: 50,
                  child: SvgPicture.asset("assets/images/BOTS_Icon.svg")),
            ),
          ),
        ],
      ),
      bottomNavigationBar:  BottomAppBar(
        elevation: 8,
        child: Container(
          color: kBOTSDarkColor,
          child: TabBar(
            onTap: (int index) async {
              _currentIndex = index;
              if(index==0) {
                _currentTitle = "My Bots";
                waitingCircularIndicator(context:context,show: true);
                var response = await getUserGraph(username: widget.username,);
                if (response.statusCode == 200) {

                  var data = jsonDecode(response.body);
                  if (data['result'] == 'True') {
                    widget.userBots = createUserBots(data['BOTSdata']);
                    waitingCircularIndicator(context:context,show: false);

                    startStreams(data: widget.userBots);
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
              }
              else if (index==1) {
                _currentTitle = 'Dashboard';
                waitingCircularIndicator(context:context,show: true);
                var botResponse = await getBOTS();
                waitingCircularIndicator(context:context,show: false);
                if (botResponse.statusCode == 200) {
                  var botData = jsonDecode(botResponse.body);
                  if (botData['result'] == 'True') {
                    widget.allBots = botData['data'];
                  }
                }
                else {
                  showMessage(context: context,
                      message: jsonDecode(botResponse.body)['error'],
                      messageColor: kErrorColor);
                }
              }
              setState(() {

              });
            },

            indicator: BoxDecoration(color: kBOTSLightColor),
            tabs: <Widget>[
              Tab(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle_sharp,
                    color: _currentIndex==0?Colors.white: Colors.black,),
                  Text("My Bots", style: TextStyle(fontSize: 12,
                      color:_currentIndex==0?Colors.white: Colors.black,)),
                ],
              )),
              Tab(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dashboard_sharp,
                    color: _currentIndex==1?Colors.white: Colors.black,),
                  Text("Dashboard", style: TextStyle(fontSize: 12,
                      color:_currentIndex==1?Colors.white: Colors.black,)),
                ],
              )),
            ],
            controller: _tabController,
          ),
        ),
      ),
      body: Center(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: pages(allBots : widget.allBots,userBots:widget.userBots,username:widget.username)[_currentIndex]
        ),
      ),
    );
  }

  Future<http.Response> getUserGraph({required String username})async{
    var headers = {
      'Authorization': 'Bearer<1a49fec40dc6387101622b82879ad5b6>',
      'UserID': username,
    };
    var body = {

    };
    return http.post(Uri.parse('https://djangoapp.alijavdani.ir/userbots/'),headers: headers,body:jsonEncode(body));
  }

}

