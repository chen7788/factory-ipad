
import 'package:dio/dio.dart';
import 'package:flutter_pad_app/model/drop_model.dart';
import 'package:flutter_pad_app/model/failure_info.dart';
import 'package:flutter_pad_app/model/person_info.dart';
import 'package:flutter_pad_app/model/product_info.dart';
import 'package:flutter_pad_app/model/report_model.dart';
import 'package:flutter_pad_app/model/turning_model.dart';
import 'dio_util.dart';
import 'dart:convert' as JSON;

//获取下拉列表
Future<List<DropModel>> getDropList() async{
  Response<Map<String, dynamic>> res = await dio.post('/machineInfo/selectMachineInfo',data: null);
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => DropModel.fromJsonMap(item)).toList();
}

//获取品名下拉列表
Future<List<ProductInfo>> getProductList(String model) async{
  Response<Map<String, dynamic>> res = await dio.post('/productInfo/selectProductInfo',data: {"proName":model});
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => ProductInfo.fromJsonMap(item)).toList();
}
//获取调机列表
Future<List<TurningModel>> getTurningList() async{
  Response<Map<String, dynamic>> res = await dio.post('/productionRecord/selectProductionRecord',data: null);
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => TurningModel.fromJsonMap(item)).toList();
}
//开始调机
Future<String> startTurning(TurningModel model) async{
  Response<Map<String, dynamic>> res = await dio.post('/productionRecord/startProductionRecord',data: JSON.jsonEncode(model));
  final result = res.data['message'] as String;
  return result;
}
//更新调机列表
Future<List<TurningModel>> upDateTurning(String model) async{
  Response<Map<String, dynamic>> res = await dio.post('/productionRecord/updateProductionRecords',data: model);
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => TurningModel.fromJsonMap(item)).toList();
}
//提报故障
Future<String> reportFailure(ReportModel model) async{
  Response<Map<String, dynamic>> res = await dio.post('/faultInfo/faultReport',data: JSON.jsonEncode(model));
  final result = res.data['message'] as String;
  return result;
}
//故障列表
Future<List<FailureInfo>> getFailureList() async{
  Response<Map<String, dynamic>> res = await dio.post('/faultInfo/selectFaultInfo',data: null);
  final result = res.data['data'] as List<dynamic>;
  List<FailureInfo> list = List();
  if(result.length >0){
    for(Map<String,dynamic> model in result){
      FailureInfo info = FailureInfo();
      model.forEach((key, value) {
        info.name = key;
        final result = value as List<dynamic>;
        info.item = result.map((item) => FailureItem.fromJsonMap(item)).toList();
      });
      list.add(info);
    }
  }
  return list;
}
//故障列表
Future<List<PersonModel>> getTurningPersonList() async{
  Response<Map<String, dynamic>> res = await dio.post('/staff/selectStaff',data: null);
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => PersonModel.fromJsonMap(item)).toList();
}