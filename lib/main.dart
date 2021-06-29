import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'Page_graphs.dart';
import 'charts/fl_chart_sample1.dart';
import 'constants.dart';
import 'global_functions.dart';
import 'page_signup.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black
    ));
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Colors.black,
        buttonColor: Colors.white,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        )
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);



  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _username = "";
  String _password = "";
  late var allBots;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // saveCSRTTOKEN();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'backIcon',
            child: GestureDetector(
                onTap: ()=>SystemNavigator.pop(),
                child: Icon(Icons.arrow_back_outlined,color: Theme.of(context).buttonColor,)
            )
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Hero(
            tag: 'botIcon',
            child: Container(
              width: 80,
              height: 50,
              child: SvgPicture.asset("assets/images/BOTS_Icon.svg")),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LoginInput(hint_txt: 'Username',obscure_txt: false,
                  onTextChanged: (value)=>_username=value,
              ),
              SizedBox(
                height: 10,
              ),
              LoginInput(hint_txt: 'Password',obscure_txt: true,
                onTextChanged: (value)=>_password=value,
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 8),
                child: GestureDetector(
                  onTap: () async {
                    if(!CheckUserPassValidity.checkUserPasswordValidity(username: _username, password: _password)) {
                        showMessage(context:context,
                          message:'Username or password is empty!',
                        messageColor: kErrorColor);
                    }
                    else {
                      FocusScope.of(context).unfocus();
                      waitingCircularIndicator(context:context,show: true);
                      try {
                        var response = await login(username: _username,
                            password: _password
                        );

                        if (response.statusCode == 200) {
                          var data = jsonDecode(response.body);
                          if (data['result'] == 'True') {
                            var userBots = createUserBots(data['BOTSdata']);
                            var botResponse = await getBOTS();
                            waitingCircularIndicator(
                                context: context, show: false);
                            if (botResponse.statusCode == 200) {
                              var botData = jsonDecode(botResponse.body);
                              if (botData['result'] == 'True') {
                                allBots = botData['data'];
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: PageGraphs(username: _username,
                                      allBots: allBots,
                                      userBots: userBots,),
                                  ),
                                );
                              }
                            }
                            else {
                              showMessage(context: context,
                                  message: data['error'],
                                  messageColor: kErrorColor);
                            }
                          }
                          else {
                            waitingCircularIndicator(
                                context: context, show: false);
                            showMessage(context: context,
                                message: data['error'],
                                messageColor: kErrorColor);
                          }
                        } else {
                          waitingCircularIndicator(
                              context: context, show: false);
                          showMessage(context: context,
                              message: response.statusCode.toString(),
                              messageColor: kErrorColor);
                        }
                      }
                      catch(e){
                        waitingCircularIndicator(
                            context: context, show: false);
                        showMessage(context: context,
                            message: 'Connection problem',
                            messageColor: kErrorColor);
                      }
                    }

                  },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(8.0),
                      // border: Border.all(width: 2.0, color: Theme.of(context).primaryColorLight),
                      gradient: LinearGradient(
                          colors: [kBOTSDarkColor, kBOTSLightColor]),
                    ),
                    child: Center(
                      child: Text(
                        'Log in',
                        style: TextStyle(fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dont have an account? ',
                    style: TextStyle(
                        fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: PageSignUp(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<http.Response> login({username,password})async {
    var headers = {
      'UserID': username.toString(),
      'Password': password.toString(),
      'Authorization': 'Bearer<1a49fec40dc6387101622b82879ad5b6>',
      'Cache-Control':'no-cache'
    };
    try {
      return http.post(Uri.parse('https://djangoapp.alijavdani.ir/login/'),headers: headers).
      timeout(Duration(seconds: 5));
    } on TimeoutException catch (e) {
      throw Error();
    } on SocketException catch (e) {
      throw Error();
    } on Error catch (e) {
      throw Error();
    }
  }


}

class LoginInput extends StatelessWidget {
  const LoginInput({
    Key? key, this.hint_txt, this.obscure_txt, this.onTextChanged,
  }) : super(key: key);
  final String? hint_txt;
  final bool? obscure_txt;
  final Function? onTextChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          // border: Border.all(width: 2.0, color: Theme.of(context).primaryColorLight),
          gradient: LinearGradient(
              colors: [kBOTSDarkColor, kBOTSLightColor]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              // border: Border.all(width: 2.0, color: Theme.of(context).primaryColorLight),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: onTextChanged as void Function(String)?,
                style: TextStyle(color: kBOTSLightColor),
                obscureText: obscure_txt!,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    // enabledBorder: InputBorder.none,
                    // errorBorder: InputBorder.none,
                    // disabledBorder: InputBorder.none,
                    contentPadding:
                    EdgeInsets.all(8),
                    hintText: hint_txt,
                    hintStyle: TextStyle(color: kBOTSLightColor.withAlpha(0x66)),
                ),
              ),
            ),
          ),
        ),

      ),
    );
  }
}
