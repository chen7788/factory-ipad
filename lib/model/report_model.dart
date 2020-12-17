class ReportModel {

  List faultCodes;
  String machineCode;
  int proReID;
  String proName;

  ReportModel();
  ReportModel.fromJsonMap(Map<String, dynamic> map):
        faultCodes = map["faultCodes"],
        machineCode = map["machineCode"],
        proReID = map["proReID"],
        proName = map["proName"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['faultCodes'] = faultCodes;
    data['machineCode'] = machineCode;
    data['proReID'] = proReID;
    data['proName'] = proName;
    return data;
  }
}