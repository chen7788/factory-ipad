import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pad_app/home_page.dart';
import 'util/const_number.dart' as constants;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_pad_app/util/mold_respository.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  FocusNode focusNodePassword = new FocusNode();
  FocusNode focusNodeCount = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Container(
          width: 1000,
          height: 600,
          child: Column(
              children: [
                Container(margin: EdgeInsets.only(top: 20,bottom: 50),child: Text('登录信息',style: constants.style30,),),
                Container(
                  child: Column(
                    children: [
                      buildRow(_accountController,'登录账号'),
                      buildRow(_pwdController,'登录密码')
                    ],
                  ),
                ),
                Container(margin: EdgeInsets.only(top: 100),child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(child: Container(
                      child: Center(child: Text('登录',style: constants.style30)),
                      color: Colors.white,
                      width: 650,
                      height: 60,
                      margin: EdgeInsets.only(left: 40),
                    ),onPressed: (){
                        _loginData();
                    },),
                    // FlatButton(child: Container(
                    //   child: Center(child: Text('退出',style: constants.style30)),
                    //   color: Colors.white,
                    //   width: 300,
                    //   height: 60,
                    //   margin: EdgeInsets.only(left: 40),
                    // ),onPressed: (){
                    //
                    // },)
                  ],
                ))
              ],
            ),
            decoration: BoxDecoration(
                border: Border.all(width: 10,color: Colors.white),
                borderRadius:BorderRadius.all(Radius.circular(15)),
                color: Colors.transparent
            )
        ),
      ),
    );
  }

  Widget buildRow(TextEditingController controller,String string){
    return Container(
        margin: EdgeInsets.only(top: 30,bottom: 30,left: 60),
        child: Row(
      children: [
        Text(string,style: constants.style20,),
        Container(margin: EdgeInsets.only(left: 20),width: 650,color: Colors.white,child: TextField(controller: controller,
          onSubmitted: (_){

          },
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(contentPadding: EdgeInsets.all(5),border: InputBorder.none,),
        ))
      ],
    ));
  }
  _loginData()async{

    if(_accountController.text == ''){
      Fluttertoast.showToast(msg: '请输入账号',fontSize: 13);
      return;
    }
    if(_pwdController.text == ''){
      Fluttertoast.showToast(msg: '请输入密码',fontSize: 13);
      return;
    }
    final result = await loginRequest(_accountController.text, _pwdController.text);
    if (result != null && result.length > 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_){
        return HomePage();
      }));
    }
  }
}
