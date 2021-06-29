import 'package:bots_assignment/global_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bots_assignment/main.dart';

void main() {
  test('Empty User Pass Test', () {
    var result = CheckUserPassValidity.checkUserPasswordValidity(username: '',password: "");
    expect(result, false);
  });
}
