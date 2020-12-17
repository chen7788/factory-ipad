
import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';



StreamSubscription<ConnectivityResult> _connectivitySubscription;

//网络初始状态
connectivityInitState(BuildContext context){
  _connectivitySubscription =
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        print(result.toString());
        if(result == ConnectivityResult.none){
          Fluttertoast.showToast(msg: "网络连接失败，请检查网络连接...",fontSize: 13);
        }
      });
}
//网络结束监听
connectivityDispose(){
  _connectivitySubscription.cancel();
}
//网络进行监听
Future<Null> initConnectivity() async {
  var connectionStatus = ConnectivityResult.none;
  //平台消息可能会失败，因此我们使用Try/Catch PlatformException。
  try {
    connectionStatus = (await Connectivity().checkConnectivity());

    if (connectionStatus == ConnectivityResult.mobile) {
      print(ConnectivityResult.mobile);
    } else if (connectionStatus == ConnectivityResult.wifi) {
      print(ConnectivityResult.wifi);
    }else{
      Fluttertoast.showToast(msg: "网络连接失败，请检查网络连接...",fontSize: 13);
    }
  } on PlatformException catch (e) {
    print(e.toString());
  }
}