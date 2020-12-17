class DropModel {

  String isAuto;
  String machineCode;
  String machineName;

  DropModel.fromJsonMap(Map<String, dynamic> map):
        isAuto = map["isAuto"],
        machineCode = map["machineCode"],
        machineName = map["machineName"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isAuto'] = isAuto;
    data['machineCode'] = machineCode;
    data['machineName'] = machineName;
    return data;
  }
}