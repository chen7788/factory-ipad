class FailureInfo {
  String name;
  List<FailureItem> item;
  FailureInfo();
}

class FailureItem{
  String faultCode;
  int id;
  bool isCheck;
  String faultName;
  String faultType;

  FailureItem.fromJsonMap(Map<String, dynamic> map):
        faultCode = map["faultCode"],
        faultName = map["faultName"],
        id = map["id"],
        isCheck = map["isCheck"]==null?false:map["isCheck"],
        faultType = map["faultType"];


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['faultCode'] = faultCode;
    data['faultName'] = faultName;
    data['id'] = id;
    data['faultType'] = faultType;
    return data;
  }
}