import 'package:flutter/material.dart';
import 'package:flutter_pad_app/util/custom_behavior.dart';
import 'package:flutter_pad_app/util/mold_respository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'model/failure_info.dart';
import 'model/report_model.dart';
import 'model/turning_model.dart';
import 'util/const_number.dart' as constants;

class AbnormalPage extends StatefulWidget {
  final TurningModel turningModel;
  AbnormalPage(this.turningModel);

  @override
  _AbnormalPageState createState() => _AbnormalPageState();
}

class _AbnormalPageState extends State<AbnormalPage> {
  List<FailureInfo> _faultList;
  Map _checkMap = Map();
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
   return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            margin: EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 50),
            child: Column(
                children: <Widget>[
                  Container(
                    height: 40,
                    margin: EdgeInsets.only(left: 20,top: 10),
                    child: Row(
                      children: <Widget>[
                        Text('异常选择', style: constants.style30),
                      ],
                    ),
                  ),
                  Expanded(
                      child: ScrollConfiguration(
                        behavior: OverScrollBehavior(),
                        child: SmartRefresher(
                          enablePullDown: true,
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          header: WaterDropHeader(),
                          child: _faultList != null ? ListView.builder(itemBuilder: (context, index) {
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
                          ):Text(""),
                        ),
                      )),
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
                ])
        )
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
  _reportFault() async {

    if (_checkMap.length == 0 || _checkMap.keys.length == 0) {
      Fluttertoast.showToast(msg: '请选择故障类型', fontSize: 13);
      return;
    }
    if (widget.turningModel == null) {
      Fluttertoast.showToast(msg: '请前往调机操作界面选择机台...', fontSize: 13);
      return;
    }
    ReportModel model = ReportModel();
    model.faultCodes = _checkMap.keys.toList();
    model.machineCode = widget.turningModel.machineCode;
    model.proName = widget.turningModel.proName;
    model.proReID = widget.turningModel.id;
    model.musId = widget.turningModel.musId;

    final result = await reportFailure(model);
    if (result != null && result.length > 0) {
      Fluttertoast.showToast(msg: result, fontSize: 13);
      Navigator.of(context).pop(true);

    }
  }
  void _onRefresh() async {
    _faultListData();
    _refreshController.refreshCompleted();
  }
  _faultListData() async {
    final result = await getFailureList();
    if (result != null && result.length > 0) {
      setState(() {
        _faultList = result;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _faultListData();
  }

}
