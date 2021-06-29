import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'package:http/http.dart' as http;

void waitingCircularIndicator({BuildContext? context ,required bool show}){
  if(show) {
    showDialog(
        context: context!,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Center(
              child: Container(
                height: 60,
                width: 60,
                color: Colors.transparent,
                child: CircularProgressIndicator(
                  backgroundColor: kBOTSDarkColor,
                  valueColor: new AlwaysStoppedAnimation<Color>(kBOTSLightColor),
                ),
              ),
            ),
          );
        });
  }
  else{
    Navigator.of(context!).pop();
  }
}
void showMessage ({required BuildContext context, required String message,Color? messageColor})
{
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor:messageColor,
          duration: Duration(seconds: 2),
          content: Container(
            height: 40,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          )
      )
  );
}

HashMap createUserBots(var data)
{
  HashMap<String, List<double>> result = HashMap<String, List<double>>();
  if (data.toString().length>0) {
    var tempdata = jsonDecode(
        data.toString().replaceAll("[", "").replaceAll("]", ""));

    for (int j = 0; j < tempdata.length; j++) {
      List<double> templist = [];
      String botTitle = tempdata.keys.elementAt(j);
      var check = tempdata[botTitle].toString().split(",");
      for (int i = 0; i < check.length; i++) {
        templist.add(double.parse(check[i]));
      }
      result[botTitle] = templist;
    }

  }
  return result;
}

Future<http.Response> getBOTS()async{
  var headers = {
    'Authorization': 'Bearer<1a49fec40dc6387101622b82879ad5b6>',
  };
  return http.get(Uri.parse('https://djangoapp.alijavdani.ir/bots/'),headers: headers,);
}


class CheckUserPassValidity {
  static bool checkUserPasswordValidity({required String username,required String password})
  {
    if(username.length>0 && password.length>0)
      return true;
    else
      return false;
  }
}