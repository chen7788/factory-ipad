import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Row(
            children: [
              Container(
                child: Row(
                  children: [
                    Container(child: Text('登录信息'),),
                    buildRow(),
                  buildRow()
                  ],
                ),
              ),
              Container(child:Row(
                children: [
                  FlatButton(child: Text('登录'),),
                  FlatButton(child: Text('退出'),)
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(){
    return Row(
      children: [
        Text('登录账号'),
        Container(child: TextField(),)
      ],
    );
  }
}
