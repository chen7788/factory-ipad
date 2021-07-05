import 'package:flutter/material.dart';
import 'package:flutter_pad_app/Abnormal_page.dart';
import 'package:flutter_pad_app/util/custom_behavior.dart';
import 'package:flutter_pad_app/util/mold_respository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'model/malfunction_model.dart';
import 'model/report_model.dart';
import 'model/turning_model.dart';
import 'util/const_number.dart' as constants;

class TimePage extends StatefulWidget {
  final TurningModel turningModel;

  TimePage(this.turningModel);

  @override
  _TimePageState createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  List _list;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
    body: Container(
    margin: EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 50),
    child: Column(
    children: <Widget>[

      buildTable(true),
      Expanded(
          child: ScrollConfiguration(
            behavior: OverScrollBehavior(),
            child: SmartRefresher(
              enablePullDown: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              header: WaterDropHeader(),
              child: SingleChildScrollView(
                child: buildTable(false),
              ),
            ),
          ))
      ])
    )
    );
    return Container(
        // height: 400,
        // width: 600,
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(children: [

        ]));
  }

  Table buildTable(bool isTitle) {
    var map = Map<int, TableColumnWidth>();
    map[0] = FixedColumnWidth(290.0);
    map[1] = FixedColumnWidth(290.0);
    map[2] = FixedColumnWidth(200.0);
    map[4] = FixedColumnWidth(220.0);

    return Table(
      columnWidths: map,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
          color: Colors.black, width: 1.0, style: BorderStyle.solid),
      children: isTitle ? [buildTableRow(null)] : buildItemList(),
    );
  }

  List<TableRow> buildItemList() {
    List<TableRow> rowList = List();
    if (_list == null) {
      return rowList;
    }
    _list.forEach((element) {
      rowList.add(buildTableRow(element));
    });
    return rowList;
  }

  TableRow buildTableRow(MalfunctionModel malModel) {
    return TableRow(children: [
      buildTableCell(
          malModel == null ? '开始停机时间' : getBeginTime(malModel.beginTime),
          malModel == null ? true : false),
      buildTableCell(
          malModel == null ? '结束停机时间' : getBeginTime(malModel.endTime),
          malModel == null ? true : false),
      buildTableCell(malModel == null ? '停机时长(M)' : malModel.mi,
          malModel == null ? true : false),
      buildTableCell(malModel == null ? '故障' : malModel.faultName,
          malModel == null ? true : false),
      buildTableCellButton('操作', malModel),
    ]);
  }

  Widget buildTableCell(String name, bool isTitle) {
    return Container(
        height: isTitle ? 60 : 55,
        child: Center(
            child: Text(name == null ? "" : name, style: constants.style20)),
        color: isTitle ? Colors.grey : Colors.white);
  }

  Widget buildTableCellButton(String name, MalfunctionModel model) {
    if (model == null) {
      return Container(
          height: 60,
          child: Center(child: Text(name, style: constants.style20)),
          color: model == null ? Colors.grey : Colors.white);
    }

    String title = '';
    var btnColor = Colors.white;
    if (name == '操作') {
      title = '提报';
      btnColor = Colors.grey;
    }
    return Container(
        width: 150,
        alignment: Alignment.center,
        child: InkWell(
            child: Container(
                width: 150,
                alignment: Alignment.center,
                child: Text(title, style: constants.style20),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: btnColor)),
            onTap: () {
              if (title == "提报") {
                widget.turningModel.musId = int.parse(model.id);
                withJobInputType();
              }
            }));
  }

  withJobInputType() async {
    bool rst = await showDialog(
        context: context,
        builder: (context) => AbnormalPage(widget.turningModel));
    if(rst != null){
      _loadStopTimeList(widget.turningModel.id.toString());
    }
  }

  void _onRefresh() async {
    _loadStopTimeList(widget.turningModel.id.toString());
    _refreshController.refreshCompleted();
  }

  String getBeginTime(String time) {
    if (time == null || time == "") {
      return "";
    }
    String str1 = time.substring(0, 10);
    String str2 = time.substring(11, 19);
    return str1 + " " + str2;
  }

  _loadStopTimeList(String recordId) async {
    final result = await getStopTimeList(recordId);
    if (result != null) {
      setState(() {
        _list = result;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadStopTimeList(widget.turningModel.id.toString());
  }
}
