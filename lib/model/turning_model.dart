class TurningModel {

  String classes;
  String collectMac;
  int cycleTime;
  String debugPerson;
  String flowType;
  int id;
  bool isAuto;
  bool isError;
  bool isFinish;
  String machineCode;
  String material;
  String mouldCode;
  int mqty;
  int operating;
  String proDate;
  String proName;
  String proPerson;
  int qty;
  int stdCavityQty;
  int useCavityQty;
  int useCycleTime;
  int mQty;
  bool isProing;
  int musId;
  String factory;

  TurningModel.fromJsonMap(Map<String, dynamic> map):
        classes = map["classes"],
        collectMac = map["collectMac"],
        cycleTime = map["cycleTime"],
        debugPerson = map["debugPerson"],
        flowType = map["flowType"],
        id = map["id"],
        isAuto = map["isAuto"]!=null?map["isAuto"]:false,
        isError = map["isError"]!=null?map["isError"]:false,
        isFinish = map["isFinish"]!=null?map["isFinish"]:false,
        machineCode = map["machineCode"],
        material = map["material"],
        mouldCode = map["mouldCode"],
        mqty = map["mqty"],
        operating = map["operating"],
        proDate = map["proDate"],
        proName = map["proName"],
        proPerson = map["proPerson"],
        qty = map["qty"],
        stdCavityQty = map["stdCavityQty"],
        mQty = map["mQty"],
        useCavityQty = map["useCavityQty"],
        useCycleTime = map["useCycleTime"],
        isProing = map["isProing"],
        factory = "",
        musId = 0;


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['classes'] = classes;
    data['collectMac'] = collectMac;
    data['cycleTime'] = cycleTime;
    data['debugPerson'] = debugPerson;
    data['flowType'] = flowType;
    data['id'] = id;
    data['isAuto'] = isAuto;
    data['isError'] = isError;
    data['isFinish'] = isFinish;
    data['machineCode'] = machineCode;
    data['material'] = material;
    data['mouldCode'] = mouldCode;
    data['mqty'] = mqty;
    data['operating'] = operating;
    data['proDate'] = proDate;
    data['proName'] = proName;
    data['proPerson'] = proPerson;
    data['qty'] = qty;
    data['stdCavityQty'] = stdCavityQty;
    data['useCavityQty'] = useCavityQty;
    data['mQty'] = mQty;
    data['useCycleTime'] = useCycleTime;
    data['isProing'] = isProing;
    data['musId'] = musId;
    data['factory'] = factory;
    return data;
  }
}