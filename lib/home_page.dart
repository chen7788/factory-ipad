
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pad_app/model/drop_model.dart';
import 'package:flutter_pad_app/model/failure_info.dart';
import 'package:flutter_pad_app/model/malfunction_model.dart';
import 'package:flutter_pad_app/model/product_info.dart';
import 'package:flutter_pad_app/model/report_model.dart';
import 'package:flutter_pad_app/model/turning_model.dart';
import 'package:flutter_pad_app/util/custom_behavior.dart';
import 'package:flutter_pad_app/util/mold_respository.dart';
import 'package:flutter_pad_app/util/network_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'util/const_number.dart' as constants;
import 'dart:convert' as JSON;
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum TableType {
  waitProduction,
  production,
  stopTime,
}

class HomePage extends StatefulWidget {
  final String name;

  HomePage(this.name);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  var _machineValue;
  var _turningValue;
  var _produceValue;
  var _materialValue;
  var _autoCheckValue = false;
  List<DropModel> _machineDropList;
  List _personDropList;
  List<ProductInfo> _productList;
  List<ProductInfo> _productAllList;
  ProductInfo _productInfo;
  List _turningList;
  List _waitList;
  List _productionList;
  List _materialList;
  final productController = TextEditingController();
  final holesController = TextEditingController();
  final cycleController = TextEditingController();
  final moldController = TextEditingController();
  bool _isLeftPage = true;
  TurningModel _turnModel;
  List<FailureInfo> _faultList;
  Map _checkMap = Map();
  bool isSelected = false;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(153, 153, 153, 1),
      body: Container(
        margin: EdgeInsets.only(left: 20, top: 20, right: 30, bottom: 10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: buildLeftView(),
            ),
            // Container(
            //   height: 60,
            //   margin: EdgeInsets.only(top: 20),
            //   child: Row(
            //     children: <Widget>[
            //         Expanded(
            //           child: Container(
            //       margin: EdgeInsets.only(right: 20),
            //             child: FlatButton(
            //               child: Container(
            //                 margin: EdgeInsets.only(right: 20),
            //                 alignment: Alignment.center,
            //                 child: Text('调机操作',style: constants.style30),
            //                 height: 60,
            //               ),
            //               onPressed: (){
            //                 if(!_isLeftPage){
            //                   setState(() {
            //                     _isLeftPage = true;
            //                   });
            //                 }
            //               },
            //               color: _isLeftPage?Color.fromRGBO(13, 103, 151, 1):Color.fromRGBO(204, 204, 204, 1),
            //             ),
            //           )
            //         ),
            //       Expanded(
            //         flex: 2,
            //         child: FlatButton(
            //           child: Container(
            //             alignment: Alignment.center,
            //             child: Text('提报故障',style: constants.style30),
            //             height: 60,
            //           ),
            //           onPressed: (){
            //             if(_faultList == null){
            //               _faultListData();
            //             }
            //             if(_isLeftPage){
            //               setState(() {
            //                 _isLeftPage = false;
            //               });
            //               _checkMap.clear();
            //
            //               }
            //           },
            //           color: _isLeftPage?Color.fromRGBO(204, 204, 204, 1):Color.fromRGBO(13, 103, 151, 1),
            //         ),
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Widget buildLeftView() {
    var mouldCode = "";
    if (_productInfo?.mouldCode != null){
      mouldCode = "";
    }
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 20),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                buildHeader(true, '调机'),
                buildDrop('机台'),
                buildText(true, '品名', productController, '', false),
                buildDrop('用料'),
                // buildText(false,'用料',null,_productInfo !=null?_productInfo.material:'',false),
                buildText(false, '模号', moldController,
                    _productInfo != null ? mouldCode : '', false),
                buildText(false, '穴数', null, _productInfo != null
                    ? _productInfo.stdCavityQty.toString()
                    : '', false),
                buildText(false, '生产穴数', holesController, '', true),
                buildTextAndTextF(),
                buildText(false, '流道类型', null,
                    _productInfo != null ? _productInfo.flowType : '', false),
                buildDrop('调机职员'),
                buildDrop('生产职员'),
                Container(
                  width: 200,
                  margin: EdgeInsets.only(top: 30),
                  child: FlatButton(
                    child: Text('开始调机', style: constants.style20),
                    onPressed: () {
                      _verificationStartTurning();
                    },
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      color: Color.fromRGBO(243, 243, 243, 1),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(color: Colors.white
              ,
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child:
              Column(children: [
                buildTableTitleButton(),
                buildTable(true, _isLeftPage ? TableType.production : TableType
                    .waitProduction),
                Expanded(child: ScrollConfiguration(
                  behavior: OverScrollBehavior(),
                  child: SmartRefresher(
                    enablePullDown: true,
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    header: WaterDropHeader(),
                    child: SingleChildScrollView(
                      child: buildTable(false,
                          _isLeftPage ? TableType.production : TableType
                              .waitProduction),
                    ),),
                )
                )
              ],)
          ),
        )
      ],
    );
  }

  Widget buildTableTitleButton() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                child: FlatButton(
                  child: Container(
                    margin: EdgeInsets.only(right: 20),
                    alignment: Alignment.center,
                    child: Text('生产中', style: constants.style30),
                    height: 60,
                  ),
                  onPressed: () {
                    if (!_isLeftPage) {
                      if(_productionList == null){
                        _getMachineList();
                      }
                      _turningList = _productionList;
                      setState(() {
                        _isLeftPage = true;
                      });
                    }
                  },
                  color: _isLeftPage ? Color.fromRGBO(13, 103, 151, 1) : Color
                      .fromRGBO(204, 204, 204, 1),
                ),
              )
          ),
          Expanded(
            child: FlatButton(
              child: Container(
                alignment: Alignment.center,
                child: Text('待生产', style: constants.style30),
                height: 60,
              ),
              onPressed: () {
                if (_waitList == null) {
                  _waitProductionList();
                }
                _turningList = _waitList;
                if (_isLeftPage) {
                  setState(() {
                    _isLeftPage = false;
                  });
                }
              },
              color: _isLeftPage ? Color.fromRGBO(204, 204, 204, 1) : Color
                  .fromRGBO(13, 103, 151, 1),
            ),
          )
        ],
      ),
    );
  }

  Table buildTable(bool isTitle, TableType type) {
    var map = Map<int, TableColumnWidth>();
    if (type == TableType.stopTime) {
      map[0] = FixedColumnWidth(280.0);
      map[1] = FixedColumnWidth(270.0);
      map[2] = FixedColumnWidth(200.0);
      map[4] = FixedColumnWidth(220.0);
    } else if (type == TableType.production) {
      map[0] = FixedColumnWidth(160.0);
      map[2] = FixedColumnWidth(130.0);
      map[3] = FixedColumnWidth(130.0);
      map[4] = FixedColumnWidth(210.0);
      map[5] = FixedColumnWidth(210.0);
    } else {
      map[0] = FixedColumnWidth(180.0);
      map[2] = FixedColumnWidth(150.0);
      map[3] = FixedColumnWidth(150.0);
      map[4] = FixedColumnWidth(230.0);
    }
    return Table(columnWidths: map,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
          color: Colors.black, width: 1.0, style: BorderStyle.solid),
      children: isTitle ? [buildTableRow(null, type)] : buildItemList(
          type),
    );
  }

  List<TableRow> buildItemList(TableType type) {
    List<TableRow> list = List();
    // if (type == TableType.stopTime) {
    //   _turningList = _stopTimeList;
    // }else if(type == TableType.production) {
    //   _turningList = _productionList;
    // }else{
    //   _turningList = _stopTimeList;
    // }
    if (_turningList == null) {
      return list;
    }
    _turningList.forEach((element) {
        list.add(buildTableRow(element, type));

    });
    return list;

  }

  TableRow buildTableRow(Object model, TableType type) {
    TurningModel turnModel;
    MalfunctionModel malModel;
    if(model is TurningModel){
      turnModel = model;
    }
    if(model is MalfunctionModel){
      malModel = model;
    }
    var  mouldCode = "";
    if(turnModel?.mouldCode != null){
      mouldCode = turnModel?.mouldCode;
    }

    if (type == TableType.production) {
      return TableRow(
          children: [
            buildTableCell(turnModel == null ? '机台编号' : turnModel.machineCode,
                turnModel == null ? true : false),
            buildTableCell(turnModel == null ? '品号' : turnModel.proName,
                turnModel == null ? true : false),
            buildTableCell(
                turnModel == null ? '可用穴数' : turnModel.useCavityQty.toString(),
                turnModel == null ? true : false),
            buildTableCell(model == null ? '模号' : mouldCode,
                turnModel == null ? true : false),
            buildTableCellButton('操作', turnModel, type),
            buildTableCellButton('故障', turnModel, type),
          ]
      );
    } else if (type == TableType.waitProduction) {
      return TableRow(
          children: [
            buildTableCell(turnModel == null ? '机台编号' : turnModel.machineCode,
                turnModel == null ? true : false),
            buildTableCell(turnModel == null ? '品号' : turnModel.proName,
                turnModel == null ? true : false),
            buildTableCell(
                turnModel == null ? '可用穴数' : turnModel.useCavityQty.toString(),
                turnModel == null ? true : false),
            buildTableCell(turnModel == null ? '模号' : mouldCode,
                turnModel == null ? true : false),
            buildTableCellButton('操作', turnModel, type),
          ]
      );
    } else {

      return TableRow(
          children: [
            buildTableCell(malModel == null ? '开始停机时间' : getBeginTime(malModel.beginTime),
                malModel == null ? true : false),
            buildTableCell(malModel == null ? '结束停机时间' : getBeginTime(malModel.endTime),
                malModel == null ? true : false),
            buildTableCell(malModel == null ? '停机时长(M)' : malModel.mi,
                malModel == null ? true : false),
            buildTableCell(malModel == null ? '故障' : malModel.faultName,
                malModel == null ? true : false),
            buildTableCellButton('操作', malModel, type),
          ]
      );
    }
  }

 String getBeginTime(String time){
    if(time == null || time == ""){
      return "";
    }
    String str1 = time.substring(0,10);
    String str2 = time.substring(11,19);
    return str1 + " " + str2;
  }

  intWithBool(bool isError) {
    if (isError == null) {
      return 0;
    }
    if (isError) {
      return 1;
    }
    return 0;
  }

  buildRightView() {

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(
            builder:(BuildContext context, void Function(void Function()) setState) {
              return Dialog(
                  backgroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child:
                  Container(
                    // height: 400,
                    // width: 600,
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 40,
                            margin: EdgeInsets.only(left: 20,top: 10),
                            child: Row(
                              children: <Widget>[
                                Text('异常选择', style: constants.style30),
                                // Container(
                                //   height: 45,
                                //   width: 300,
                                //   margin: EdgeInsets.only(left: 30),
                                //   alignment: Alignment.centerLeft,
                                //   padding: EdgeInsets.only(left: 10),
                                //   decoration: BoxDecoration(
                                //       border: Border.all(width: 1,
                                //           color: Colors.black),
                                //       color: Colors.white
                                //   ),
                                //   child: Text(_turnModel == null ? '' : _turnModel
                                //       .machineCode, style: constants.style30),
                                // )
                              ],
                            ),
                          ),
                          Expanded(
                            child:
                            ListView.builder(itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 30, bottom: 10),
                                      height: 40,
                                      child: Text(_faultList[index].name,
                                          style: constants.blueStyle30),
                                    ),
                                    Expanded(
                                        child:
                                        Container(
                                          margin: EdgeInsets.only(left: 20, right: 20),
                                          child: GridView.builder(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 6,
                                                mainAxisSpacing: 13,
                                                crossAxisSpacing: 0,
                                                childAspectRatio: 15 / 2
                                            ),
                                            itemBuilder: (context, innerIndex) {
                                              return Row(
                                                children: <Widget>[
                                                  Checkbox(
                                                    value: _checkMap[_faultList[index].item[innerIndex].faultCode] ?? false,
                                                    onChanged: (value) {
                                                      if (value) {
                                                        _checkMap[_faultList[index].item[innerIndex].faultCode] = value;
                                                      } else {
                                                        if (_checkMap.containsKey(_faultList[index].item[innerIndex].faultCode)) {
                                                          _checkMap.remove(_faultList[index].item[innerIndex].faultCode);
                                                        }
                                                      }
                                                      setState(() {

                                                      });
                                                    },
                                                  ),
                                                  Container(padding: EdgeInsets.zero,
                                                      margin: EdgeInsets.zero,
                                                      child: Text(
                                                        _faultList[index].item[innerIndex].faultName, style: constants.style20,))
                                                ],
                                              );
                                            },
                                            itemCount: _faultList[index].item.length,
                                            physics: NeverScrollableScrollPhysics(),),
                                        )
                                    ),
                                  ],
                                ),
                                height: rightListViewCellHeight(
                                    _faultList[index], 6),
                              );
                            },
                              itemCount: 4,
                            ),
                          ),
                          // Container(
                          //   constraints: BoxConstraints.expand(height: 135),
                          //   margin: EdgeInsets.only(top: 20),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: <Widget>[
                          //       Expanded(
                          //         child: Container(
                          //           height: 135,
                          //           margin: EdgeInsets.only(right: 100),
                          //           color: Colors.black,
                          //           child: Column(
                          //             crossAxisAlignment: CrossAxisAlignment.start,
                          //             children: <Widget>[
                          //               Container(
                          //                 margin: EdgeInsets.only(
                          //                     left: 30, top: 15),
                          //                 height: 35,
                          //                 child: Text(
                          //                     _faultList[_faultList.length - 1]
                          //                         .name,
                          //                     style: constants.blueStyle30),
                          //               ),
                          //               buildGridView(
                          //                   _faultList[_faultList.length - 1]),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //
                          //     ],
                          //   ),
                          // ),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              constraints: BoxConstraints.expand(height: 60),
                              child: FlatButton(
                                child: Text('提交', style: constants.style30,),
                                onPressed: () {
                                  _reportFault();
                                },
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius
                                      .circular(5)),
                                  color: Colors.grey
                              )
                          )
                        ],
                      )
                  )
              );
            }
          );
        }
    );

    // if(_faultList == null || _faultList.length==0){
    //   return Container(
    //       width: 1920,
    //       color: Colors.white,
    //       child: Center(child: Text('没有数据'),),
    //   );
    // }
  }

  Widget buildGridView(FailureInfo info) {
    return Expanded(
        child:
        Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 13,
                crossAxisSpacing: 0,
                childAspectRatio: 15 / 2
            ),
            itemBuilder: (context, index) {
              return Row(
                children: <Widget>[
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      if (value) {
                        _checkMap[info.item[index].faultCode] = value;
                      } else {
                        if (_checkMap.containsKey(info.item[index].faultCode)) {
                          _checkMap.remove(info.item[index].faultCode);
                        }
                      }
                      isSelected = value;
                      setState(() {

                      });
                    },
                  ),
                  Container(padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      child: Text(
                        info.item[index].faultName, style: constants.style20,))
                ],
              );
            },
            itemCount: info.item.length,
            physics: NeverScrollableScrollPhysics(),),
        )
    );
  }

  Widget buildTableCell(String name, bool isTitle) {
    return Container(height: isTitle ? 60 : 55,
        child: Center(child: Text(name==null?"":name, style: constants.style20)),
        color: isTitle ? Colors.grey : Colors.white);
  }

  Widget buildTableCellButton(String name, Object model,TableType type) {
    TurningModel turnModel;
    MalfunctionModel malModel;
    if(model is TurningModel){
      turnModel = model;
    }
    if(model is MalfunctionModel){
      malModel = model;
    }
      if (model == null) {
        return Container(height: 60,
            child: Center(child: Text(name, style: constants.style20)),
            color: model == null ? Colors.grey : Colors.white);
      }


    String title = '';
    var btnColor = Colors.white;
    if (name == '操作') {
      if (type == TableType.stopTime) {
        // if(malModel.isError){
        //   title = '解除';
        // }else {
          title = '提报';
        // }
        btnColor = Colors.grey;
      } else if (type == TableType.production){
        if (turnModel.operating == 1) {
          title = '结束生产';
          btnColor = Colors.green;
        } else {
          title = '开始生产';
          btnColor = Colors.red;
        }
      }else{
        if (turnModel.isProing) {
          title = '结束生产';
          btnColor = Colors.red;
        } else {
          title = '安排生产';
          btnColor = Colors.green;
        }
      }
    } else {
      // if(model.isError){
      //   title = '解除';
      // }else{
      title = '停机时间段';
      btnColor = Colors.grey;
      // }
    }
    return Container(width: 150,
        alignment: Alignment.center,
        child: InkWell(child: Container(width: 150,
            alignment: Alignment.center,
            child: Text(title, style: constants.style20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: btnColor
            )), onTap: () {
            if (title == '停机时间段') {
              _turnModel = turnModel;
              _loadStopTimeList(turnModel.id.toString(),true);
            }else if(title == "提报"){

              _checkMap.clear();
                _faultListData();

            }else if(title == "异常"){

            }else{
              buildPopView(title, turnModel, type);
            }

          //
          // if(title == '停机时间段'){
          //
          //   // setState(() {
          //   //   _isLeftPage = false;
          //   // });
          //   // if(_faultList == null){
          //
          //   // }
          //
          // }else{
          //
          //   buildPopView(title,model,type);
          // }
        })
    );
  }

  buildStopTimeView() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child:
              Container(
                // height: 400,
                // width: 600,
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child:
                  Column(children: [
                    buildTable(true, TableType.stopTime),
                    Expanded(child: ScrollConfiguration(
                      behavior: OverScrollBehavior(),
                      child: SmartRefresher(
                        enablePullDown: true,
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        header: WaterDropHeader(),
                        child: SingleChildScrollView(
                          child: buildTable(false, TableType.stopTime),
                        ),),
                    )
                    )
                  ]
                  )
              )
          );
        }
    );
  }

  double rightListViewCellHeight(FailureInfo info, int col) {
    int count = info.item.length;
    int row = count ~/ col;
    int num = count % col;
    if (row == 3 && num > 0) {
      return 280;
    }
    return 230;
  }

  Widget buildHeader(bool isBottom, String title) {
    return Container(margin: EdgeInsets.only(bottom: isBottom ? 15 : 0),
        height: 50,
        alignment: Alignment.center,
        width: double.infinity,
        color: Colors.blue,
        child: Text(title, style: constants.style20));
  }

  Widget buildTextAndTextF() {
    return Container(
        margin: EdgeInsets.only(left: 30, right: 30, top: 23),
        height: 45,
        child: Row(
          children: <Widget>[
            Text('周期', style: constants.style20),
            Expanded(
                child: Container(
                  height: 45,
                  margin: EdgeInsets.only(left: 30),
                  padding: EdgeInsets.only(left: 10, top: 7),
                  child: Text(_productInfo != null
                      ? _productInfo.cycleTime.toString()
                      : '', style: constants.style20,),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      color: Colors.grey
                  ),
                )
            ),
            Expanded(
                child: Container(
                  height: 45,
                  margin: EdgeInsets.only(left: 10),
                  padding: EdgeInsets.only(left: 10),
                  child: TextField(textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(border: InputBorder.none),
                    controller: cycleController,
                    style: constants.style20,
                    keyboardType: TextInputType.numberWithOptions(),
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                )
            ),
            Container(margin: EdgeInsets.only(left: 5),
                child: Text('可调±5%', style: TextStyle(fontSize: 25))),
            Container(padding: EdgeInsets.only(left: 3),
                child: Text(
                    '*', style: TextStyle(color: Colors.red, fontSize: 25))),
          ],
        )
    );
  }

  Widget buildText(bool isPop, String title, TextEditingController controller,
      String name, bool isNum) {
    return Container(
        margin: EdgeInsets.only(left: 30, right: 30, top: 23),
        height: 45,
        child: Row(
          children: <Widget>[
            Text(title, style: constants.style20),
            Expanded(
                child: Container(
                  height: 45,
                  margin: EdgeInsets.only(left: 30),
                  padding: EdgeInsets.only(left: 10),
                  child: controller != null ? TextField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(border: InputBorder.none),
                      controller: controller,
                      style: constants.style20,
                      onSubmitted: (value) {
                        controller.text = value;
                        if (title == '品名' && value != '') {
                          if (value.length > 24) {
                            Fluttertoast.showToast(
                                msg: '品名长度应大于0小于24', fontSize: 13);
                            return;
                          }
                          //_productSelectedData(true);
                        }
                      },
                      onChanged: (value) {
                        if (title == '品名') {
                          if (value.isEmpty || value == "") {
                            setState(() {
                              _productList = _productAllList;
                            });
                          } else {
                            var list = List<ProductInfo>();
                            for (ProductInfo info in _productAllList) {
                              if (info.proName.contains(value)) {
                                list.add(info);
                              }
                            }
                            setState(() {
                              _productList = list;
                            });
                          }
                        }
                      },
                      keyboardType: isNum
                          ? TextInputType.numberWithOptions()
                          : TextInputType.text,
                      inputFormatters: isNum ? [
                        WhitelistingTextInputFormatter.digitsOnly
                      ] : []) : Container(
                    child: Text(name, style: constants.style20,),
                    padding: EdgeInsets.only(top: 7),),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      color: controller != null ? Colors.white : Colors.grey
                  ),
                )
            ),
            isPop ? Container(
              height: 45,
              margin: EdgeInsets.only(left: 30),
              child: PopupMenuButton(
                  icon: Image.asset("res/images/201.png"),
                  onSelected: (result) {
                    productController.text = result;
                    if (_productList != null) {
                      _materialSelectedData(result);
                      for (ProductInfo product in _productList) {
                        if (product.proName == result) {
                          setState(() {
                            _productInfo = product;
                            holesController.text = product.stdCavityQty
                                .toString();
                            cycleController.text = product.cycleTime.toString();
                          });
                          break;
                        }
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return buildPopMenuItems();
                  }
              ),
            ) : Text(''),
            controller != null
                ? Container(padding: EdgeInsets.only(left: 3),
                child: Text(
                    '*', style: TextStyle(color: Colors.red, fontSize: 25)))
                : Text(''),
          ],
        )
    );
  }

  bool validateInput() {
    if (moldController.text == '') {
      Fluttertoast.showToast(msg: '模号不能为空，请重新输入...', fontSize: 13);
      return true;
    }
    if (moldController.text.length > 100) {
      Fluttertoast.showToast(msg: '模号长度不能大于100...', fontSize: 13);
      return true;
    }
    if (holesController.text == '') {
      Fluttertoast.showToast(msg: '生产穴数应大于0小于等于穴数', fontSize: 13);
      return true;
    }
    if (int.parse(holesController.text) != _productInfo.stdCavityQty) {
      if (0 > int.parse(holesController.text) ||
          int.parse(holesController.text) > _productInfo.stdCavityQty) {
        Fluttertoast.showToast(msg: '生产穴数应大于0小于等于穴数', fontSize: 13);
        return true;
      }
    }
    if (cycleController.text == '') {
      Fluttertoast.showToast(msg: '周期超过可调±5%范围', fontSize: 13);
      return true;
    }
    int cycleV = int.parse(cycleController.text);
    if (cycleV != _productInfo.cycleTime) {
      int maxValue = _productInfo.cycleTime +
          (_productInfo.cycleTime * 0.05).toInt();
      int minValue = _productInfo.cycleTime -
          (_productInfo.cycleTime * 0.05).toInt();
      if (cycleV < minValue || cycleV > maxValue) {
        Fluttertoast.showToast(msg: '周期超过可调±5%范围', fontSize: 13);
        return true;
      }
    }
    return false;
  }

  buildDialog(List<ProductInfo> productInfoList) {
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text('请选择品名', style: constants.style30),
        content: Container(
          height: 700,
          width: 600,
          padding: EdgeInsets.only(left: 30),
          color: Colors.white,
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            separatorBuilder: (context, index) {
              return Divider(height: 1, color: Colors.grey);
            },
            itemCount: productInfoList.length,
            itemBuilder: (context, index) {
              return FlatButton(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                      productInfoList[index].proName, style: constants.style30),
                  height: 60,
                ),
                onPressed: () {
                  _materialSelectedData(productInfoList[index].proName);
                  Navigator.of(context).pop();
                  setState(() {
                    productController.text = productInfoList[index].proName;
                    _productInfo = productInfoList[index];
                  });
                },
                color: _isLeftPage ? Color.fromRGBO(204, 204, 204, 1) : Color
                    .fromRGBO(13, 103, 151, 1),
              );
              // return InkWell(
              //   highlightColor:Colors.grey,
              //   child: Container(
              //     padding: EdgeInsets.all(10),
              //     color: Colors.yellow,
              //     child: Text(productInfoList[index].proName,style: constants.style20),
              //   ),
              //   onTap: (){
              //     print(index);
              //   },
              // );
            },
          ),
        ),

        actions: <Widget>[
          Container(
            height: 50,
            width: 150,
            margin: EdgeInsets.only(bottom: 30, right: 30),
            child: FlatButton(
              color: Colors.blue,
              child: Text('关闭', style: constants.style30,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      );
    });
  }

  List<PopupMenuEntry> buildPopMenuItems() {
    List<PopupMenuItem> list = List();
    if (_productList == null) {
      return list;
    }
    _productList.forEach((element) {
      PopupMenuItem popupMenuItem = PopupMenuItem(
        value: element.proName,
        child: Text(element.proName, style: TextStyle(fontSize: 20)),
      );
      list.add(popupMenuItem);
    });
    return list;
  }

  List<DropdownMenuItem> buildDropMenuItems(String type) {
    List<DropdownMenuItem> list = List();
    if (type == '机台') {
      if (_machineDropList == null) {
        return list;
      } else {
        _machineDropList.forEach((element) {
          DropdownMenuItem dropdownMenuItem = DropdownMenuItem(child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(element.machineCode, style: constants.style20,)),
            value: element.machineCode,);
          list.add(dropdownMenuItem);
        });
      }
    } else if (type == '用料') {
      if (_materialList == null) {
        return list;
      } else {
        _materialList.forEach((element) {
          DropdownMenuItem dropdownMenuItem = DropdownMenuItem(child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(element.materialName, style: constants.style20,)),
            value: element.materialName,);
          list.add(dropdownMenuItem);
        });
      }
    } else {
      if (_personDropList == null) {
        return list;
      } else {
        _personDropList.forEach((element) {
          DropdownMenuItem dropdownMenuItem = DropdownMenuItem(child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(element.name, style: constants.style20,)),
            value: element.name,);
          list.add(dropdownMenuItem);
        });
      }
    }

    return list;
  }

  getValueWithTitle(String title) {
    if (title == '机台') {
      return _machineValue;
    } else if (title == '调机职员') {
      return _turningValue;
    } else if (title == '生产职员') {
      return _produceValue;
    } else {
      return _materialValue;
    }
  }

  getHintWithTitle(String title) {
    if (title == '机台') {
      return '下拉选择机台';
    } else if (title == '调机职员') {
      return '下拉选择调机职员';
    } else if (title == '生产职员') {
      return '下拉选择生产职员';
    } else {
      return '下拉选择用料';
    }
  }

  Widget buildDrop(String title) {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 20),
      height: 50,
      child: Row(
        children: <Widget>[
          Text(title, style: constants.style20),
          Expanded(
            child: Container(
              height: 50,
              margin: EdgeInsets.only(left: 30),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(items: buildDropMenuItems(title),
                    value: getValueWithTitle(title),
                    hint: Container(padding: EdgeInsets.only(left: 10),
                        child: Text(getHintWithTitle(title),
                            style: constants.hintStyle20)),
                    onChanged: (value) {
                      setState(() {
                        if (title == '机台') {
                          _machineValue = value;
                          if (_machineDropList != null) {
                            for (DropModel model in _machineDropList) {
                              if (model.machineCode == value) {
                                setState(() {
                                  _autoCheckValue =
                                  model.isAuto == '1' ? true : false;
                                });
                                break;
                              }
                            }
                          }
                        } else if (title == '调机职员') {
                          _turningValue = value;
                        } else if (title == '生产职员') {
                          _produceValue = value;
                        } else {
                          _materialValue = value;
                        }
                      });
                    }),
              ),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black)
              ),
            ),
          ),
          Container(padding: EdgeInsets.only(left: 3),
              child: Text(
                  '*', style: TextStyle(color: Colors.red, fontSize: 25))),
          title == '机台' ? Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Checkbox(
                  activeColor: Colors.yellow,
                  tristate: false,
                  value: _autoCheckValue,
                  onChanged: null,
                ),
                Text('全自动', style: TextStyle(fontSize: 23)),
              ],
            ),
          ) : Text('')
        ],
      ),
    );
  }

  buildPopView(String title, TurningModel model, TableType type) {
    String name = '';
    if (title == '结束生产') {
      name = '现在是否结束生产？';
    } else if (title == '开始生产') {
      name = '现在是否开始生产？';
    } else if (title == '解除') {
      name = '故障是否已处理完成？';
    }else if (title == '安排生产') {
      name = '现在是否安排生产？';
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Container(
              height: 400,
              width: 600,
              child: Column(
                children: [
                  Container(margin: EdgeInsets.only(top: 30, bottom: 30),
                    child: Text('提示', style: constants.style30),),
                  Container(margin: EdgeInsets.only(top: 30, bottom: 30),
                      child: Text(name, style: constants.style20)),
                  Container(margin: EdgeInsets.only(top: 30), child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        child: Container(width: 200,
                            height: 60,
                            child: Center(child: Text(
                                '确定', style: constants.style30),),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: Colors.blue),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)),
                                color: Colors.blue
                            )),
                        onPressed: () =>
                        {
                          if(type == TableType.production){
                            if(title == '结束生产'){
                              model.isFinish = true,
                            } else if(title == '开始生产'){
                                model.operating = 1
                              },
                            _updateTurning(model, title),
                            Navigator.pop(context)
                          } else
                            if (type == TableType.waitProduction){
                              if(title == '安排生产'){
                                _loadStartProduction(
                                    model.id.toString(), model.machineCode),
                                Navigator.pop(context)
                              } else
                                if(title == '结束生产'){
                                  _loadStopProduction(
                                      model.id.toString(), model.machineCode),
                                  Navigator.pop(context)
                                }

                            }else{
                              if(title == '解除'){
                                  _turnModel.isError = false,
                                _updateTurning(_turnModel, title),
                                Navigator.pop(context)
                              },
                            }
                        },
                      ),
                      FlatButton(
                        child: Container(width: 200,
                            height: 60,
                            child: Center(child: Text(
                                '取消', style: constants.style30),),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: Colors.blue),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)),
                                color: Colors.blue
                            )),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ))
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _getMachineList();
  }

  _machineSelectedData() async {
    final result = await getDropList(widget.name);
    if (result != null && result.length > 0) {
      setState(() {
        _machineDropList = result;
      });
      _productSelectedData(false);
      _personSelectedData();
    }
  }

  _productSelectedData(bool isKey) async {
    final result = await getProductList(productController.text);
    if (result != null) {
      if (isKey) {
        buildDialog(result);
      } else {
        setState(() {
          _productList = result;
          _productAllList = result;
        });
      }
    } else {
      Fluttertoast.showToast(msg: '未找到品名...', fontSize: 13);
    }
  }

  _personSelectedData() async {
    final result = await getTurningPersonList(widget.name);
    if (result != null) {
      setState(() {
        _personDropList = result;
      });
    }
  }

  _materialSelectedData(String materialId) async {
    var id = 0;
    for (ProductInfo model in _productList) {
      if (model.proName == materialId) {
        id = model.id;
      }
    }

    final result = await getMaterialList(id.toString());
    if (result != null) {
      setState(() {
        _materialList = result;
        _materialValue = null;
      });
    }
  }

  _getMachineList() async {
    final result = await getProductionList();
    if (result != null) {
      _productionList = result;
      setState(() {
        _turningList = result;
      });
      _machineSelectedData();
    }
  }

  _waitProductionList() async {
    final result = await getWaitProductionList();
    if (result != null) {
      _waitList = result;
      setState(() {
        _turningList = result;
      });
      _machineSelectedData();
    }
  }

  _loadStopTimeList(String recordId,bool isPop) async {
    final result = await getStopTimeList(recordId);
    if (result != null) {
      if(isPop){
        buildStopTimeView();
      }
      _turningList = result;
      if(!isPop){
        setState(() {

        });
      }
    }
  }
    _getStartTurning() async {
      TurningModel model = TurningModel.fromJsonMap({});
      model.cycleTime = _productInfo.cycleTime;
      model.debugPerson = _turningValue;
      model.flowType = _productInfo.flowType;
      model.id = _productInfo.id;
      model.isAuto = _autoCheckValue;
      model.machineCode = _machineValue;
      model.material = _materialValue;
      model.proName = productController.text;
      model.proPerson = _produceValue;
      model.mouldCode = moldController.text;
      model.stdCavityQty = _productInfo.stdCavityQty;
      model.useCavityQty = int.parse(holesController.text);
      model.useCycleTime = int.parse(cycleController.text);

      final result = await startTurning(model);
      if (result == '调机成功。') {
        Fluttertoast.showToast(msg: '调机成功', fontSize: 13);
        productController.text = "";
        _getMachineList();
      } else {
        Fluttertoast.showToast(msg: '调机失败', fontSize: 13);
      }
    }
    _verificationStartTurning() {
      if (_machineValue == null || _machineValue == '') {
        Fluttertoast.showToast(msg: '请选择机台', fontSize: 13);
        return;
      }
      if (productController.text == '') {
        Fluttertoast.showToast(msg: '请选择品名', fontSize: 13);
        return;
      }

      if (validateInput()) {
        return;
      }
      if (_materialValue == null || _materialValue == '') {
        Fluttertoast.showToast(msg: '请选择用料', fontSize: 13);
        return;
      }
      if (_turningValue == null || _turningValue == '') {
        Fluttertoast.showToast(msg: '请选择调机职员', fontSize: 13);
        return;
      }
      if (_produceValue == null || _produceValue == '') {
        Fluttertoast.showToast(msg: '请选择生产职员', fontSize: 13);
        return;
      }
      _getStartTurning();
    }
    _updateTurning(TurningModel model, String title) async {
      String str = '[' + JSON.jsonEncode(model) + ']';
      final result = await upDateTurning(str);
      if (result != null && result.length > 0) {
        List list = List();
        for (TurningModel item in _turningList) {
          TurningModel temp = result[0];
          if (item.id == temp.id) {
            if (!item.isFinish) {
              list.add(temp);
            }
          } else {
            list.add(item);
          }
        }
        Fluttertoast.showToast(msg: '操作成功...', fontSize: 13);
        setState(() {
          _turningList = list;
        });
        _machineSelectedData();
      }
    }
    _loadStartProduction(String recordId, String code) async {

      final result = await startProduction(recordId, code);
      if (result != null && result.length > 0) {
        Fluttertoast.showToast(msg: '操作成功...', fontSize: 13);
        for (TurningModel item in _waitList) {
          TurningModel temp = _waitList[0];
          if (item.id == temp.id) {
            _waitList.remove(item);
            break;
          }
        }
        _getMachineList();
        setState(() {
          _isLeftPage = true;
        });
        //_machineSelectedData();
      }
    }
    _loadStopProduction(String recordId, String code) async {

      final result = await stopProduction(recordId, code);
      if (result != null && result.length > 0) {
        Fluttertoast.showToast(msg: '操作成功...', fontSize: 13);
        for (TurningModel item in _waitList) {
          TurningModel temp = _waitList[0];
          if (item.id == temp.id) {
            item.isFinish = true;
            break;
          }
        }
        setState(() {
          _turningList = _waitList;
        });
        //_machineSelectedData();
      }
    }
    _faultListData() async {
      final result = await getFailureList();
      if (result != null && result.length > 0) {
        _faultList = result;
        buildRightView();
      }
    }
    _reportFault() async {

      if (_checkMap.length == 0 || _checkMap.keys.length == 0) {
        Fluttertoast.showToast(msg: '请选择故障类型', fontSize: 13);
        return;
      }
      if (_turnModel == null) {
        Fluttertoast.showToast(msg: '请前往调机操作界面选择机台...', fontSize: 13);
        return;
      }
      ReportModel model = ReportModel();
      model.faultCodes = _checkMap.keys.toList();
      model.machineCode = _turnModel.machineCode;
      model.proName = _turnModel.proName;
      model.proReID = _turnModel.id;

      final result = await reportFailure(model);
      if (result != null && result.length > 0) {
        Fluttertoast.showToast(msg: result, fontSize: 13);
        Navigator.of(context).pop('确定');
        _loadStopTimeList(_turnModel.id.toString(), false);
        //_getMachineList();
      }
    }
    void _onRefresh() async {
      // monitor network fetch
      await _getMachineList();
      // if failed,use refreshFailed()
      _refreshController.refreshCompleted();
    }
    @override
    void dispose() {
      connectivityDispose();
      super.dispose();
    }
  }
