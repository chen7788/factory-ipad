class ReportModel {

  List faultCodes;
  String machineCode;
  int proReID;
  String proName;
  int musId;

  ReportModel();
  ReportModel.fromJsonMap(Map<String, dynamic> map):
        faultCodes = map["faultCodes"],
        machineCode = map["machineCode"],
        proReID = map["proReID"],
        musId = map["musId"],
        proName = map["proName"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['faultCodes'] = faultCodes;
    data['machineCode'] = machineCode;
    data['proReID'] = proReID;
    data['proName'] = proName;
    data['musId'] = musId;
    return data;
  }
}