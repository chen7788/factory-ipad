class MalfunctionModel {

  String beginTime;
  String endTime;
  String faultName;
  String id;
  String mi;
  String proRecordID;
  bool isError;
  MalfunctionModel.fromJsonMap(Map<String, dynamic> map):
        beginTime = map["beginTime"],
        endTime = map["endTime"],
        faultName = map["faultName"],
        id = map["id"],
        mi = map["mi"],
        proRecordID = map["proRecordID"],
        isError = map["isError"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['beginTime'] = beginTime;
    data['endTime'] = endTime;
    data['faultName'] = faultName;
    data['id'] = id;
    data['mi'] = mi;
    data['proRecordID'] = proRecordID;
    data['isError'] = isError;
    return data;
  }
}