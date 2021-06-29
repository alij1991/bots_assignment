
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';

import 'constants.dart';
import 'global_functions.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
class PageSignUp extends StatefulWidget {
  PageSignUp({Key? key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

  @override
  _PageSignUpState createState() => _PageSignUpState();
}

class _PageSignUpState extends State<PageSignUp> {
  String _username = "";
  String _password = "";
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
              LoginInput(hint_txt: 'Choose a username',obscure_txt: false,
                onTextChanged: (value)=>_username=value,),
              SizedBox(
                height: 10,
              ),
              LoginInput(hint_txt: 'Choose a password',obscure_txt: true,
                onTextChanged: (value)=>_password=value,),
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
                      waitingCircularIndicator(context: context, show: true);
                      try {
                        var response = await signup(username: _username,
                            password: _password
                        );
                        waitingCircularIndicator(context: context, show: false);
                        if (response.statusCode == 200) {
                          var data = jsonDecode(response.body);
                          if (data['result'] == 'True') {
                            showMessage(context: context,
                                message: 'Successfully Done',
                                messageColor: kSuccessColor);
                            Navigator.pop(context, true);
                          }
                          else {
                            showMessage(context: context,
                                message: data['error'].toString(),
                                messageColor: kErrorColor);
                          }
                        } else {
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
                        'Sign up',
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
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: ()=>Navigator.pop(context,true),
                    child: Text(
                      'Log in',
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
  Future<http.Response> signup({username,password})async{
    var headers = {
      'Authorization': 'Bearer<1a49fec40dc6387101622b82879ad5b6>',
      'Content-Type':'application/json'
    };
    var body = {
      'UserID': username.toString(),
      'Password': password.toString(),
    };

    try {
      return http.post(Uri.parse('https://djangoapp.alijavdani.ir/signup/'),headers: headers,body: jsonEncode(body)).
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
