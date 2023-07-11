import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastService {

  ToastService._privateConstructor():super();
  static final ToastService instance = ToastService._privateConstructor();

  static showError(String message) {
    if(message.contains("Exception:")) {
      message = message.substring(11);
    }
    
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showSuccess(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green.shade50,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
