import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

final baseUrl = "http://192.168.70.12:8080";
//var options = BaseOptions(baseUrl: baseUrl);// // //http://192.168.70.12:8080

BaseOptions buildOptions(bool isJson) {
  var option = BaseOptions(baseUrl: baseUrl,contentType: isJson?"application/json ":"application/x-www-form-urlencoded",connectTimeout: 30000);
  return option;
}

var jsonDio = buildDio(buildOptions(true));
var formDio = buildDio(buildOptions(false));

Dio buildDio(BaseOptions option){
  var dio = Dio(option)
    ..interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      return options;
    }, onResponse: (Response response) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['code'] == 200) {
          return response;
        } else {
          Fluttertoast.showToast(msg: data['message'],fontSize: 13);
          if (response.statusCode == 401) {
            //RxBus.post(UnauthorizedEvent());
          }
          return DioError(error: data['message'], type: DioErrorType.CANCEL);
        }
      }
      return DioError(error: "数据格式错误", type: DioErrorType.CANCEL);
    }, onError: (DioError e) {
      if (e.type == DioErrorType.CANCEL) {
        Fluttertoast.showToast(msg: '${e.message}',fontSize: 13);
      } else {
        Fluttertoast.showToast(msg: '网络错误：${e.message}',fontSize: 13);
      }
    }))
    ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  return dio;
}


