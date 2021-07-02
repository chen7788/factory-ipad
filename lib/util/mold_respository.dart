
import 'package:dio/dio.dart';
import 'package:flutter_pad_app/model/drop_model.dart';
import 'package:flutter_pad_app/model/failure_info.dart';
import 'package:flutter_pad_app/model/malfunction_model.dart';
import 'package:flutter_pad_app/model/material_model.dart';
import 'package:flutter_pad_app/model/person_info.dart';
import 'package:flutter_pad_app/model/product_info.dart';
import 'package:flutter_pad_app/model/report_model.dart';
import 'package:flutter_pad_app/model/turning_model.dart';
import 'dio_util.dart';
import 'dart:convert' as JSON;

//登录
Future<String> loginRequest(String account,String pwd) async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/user/selectByNameAndPassword',data: {'name':account,'password':pwd});
  final result = res.data['message'] as String;
  return result;
}
//获取下拉列表
Future<List<DropModel>> getDropList(String name) async{
  Response<Map<String, dynamic>> res = await formDio.post('/machineInfo/selectMachineInfo',data: {'factory':name});
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => DropModel.fromJsonMap(item)).toList();
}
//获取下拉列表
Future<List<MaterialModel>> getMaterialList(String materialId) async{
  Response<Map<String, dynamic>> res = await formDio.post('/material/selectMaterial?proId='+materialId,data: {"proId":materialId});
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => MaterialModel.fromJsonMap(item)).toList();
}
//获取品名下拉列表
Future<List<ProductInfo>> getProductList(String model) async{
  Response<Map<String, dynamic>> res = await formDio.post('/productInfo/selectProductInfo',data: {"proName":model});
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => ProductInfo.fromJsonMap(item)).toList();
}
//获取调机列表
Future<List<TurningModel>> getTurningList() async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/productionRecord/selectProductionRecord',data: null);
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => TurningModel.fromJsonMap(item)).toList();
}
//获取待生产机台列表
Future<List<TurningModel>> getWaitProductionList() async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/productionRecord/selectStayProductionRecord',data: null);
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => TurningModel.fromJsonMap(item)).toList();
}
//获取生产中机台列表
Future<List<TurningModel>> getProductionList() async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/productionRecord/selectWorkProductionRecord',data: null);
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => TurningModel.fromJsonMap(item)).toList();
}
//获取停机时间段列表
Future<List<MalfunctionModel>> getStopTimeList(String recordId) async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/vFault/selectByProRecordID',queryParameters: {"proRecordID":recordId});
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => MalfunctionModel.fromJsonMap(item)).toList();
}
//开始生产
Future<String> startProduction(String recordId,String code) async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/productionRecord/startWorkProductionRecord',queryParameters: {"id":recordId,"machineCode":code});
  final result = res.data['message'] as String;
  return result;
}
//开始生产
Future<String> stopProduction(String recordId,String code) async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/productionRecord/endWorkProductionRecord',queryParameters: {"id":recordId,"machineCode":code});
  final result = res.data['message'] as String;
  return result;
}
//开始调机
Future<String> startTurning(TurningModel model) async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/productionRecord/startProductionRecord',data: JSON.jsonEncode(model));
  final result = res.data['message'] as String;
  return result;
}
//更新调机列表
Future<List<TurningModel>> upDateTurning(String model) async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/productionRecord/updateProductionRecords',data: model);
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => TurningModel.fromJsonMap(item)).toList();
}
//提报故障
Future<String> reportFailure(ReportModel model) async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/faultInfo/faultReport',data: JSON.jsonEncode(model));
  final result = res.data['message'] as String;
  return result;
}
//故障列表
Future<List<FailureInfo>> getFailureList() async{
  Response<Map<String, dynamic>> res = await jsonDio.post('/faultInfo/selectFaultInfo',data: null);
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
Future<List<PersonModel>> getTurningPersonList(String name) async{
  Response<Map<String, dynamic>> res = await formDio.post('/staff/selectStaff',data: {'factory':name});
  final result = res.data['data'] as List<dynamic>;
  return result.map((item) => PersonModel.fromJsonMap(item)).toList();
}