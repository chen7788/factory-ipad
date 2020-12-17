class ProductInfo {

  int cycleTime;
  String flowType;
  int id;
  String material;
  String mouldCode;
  String proName;
  int stdCavityQty;

  ProductInfo.fromJsonMap(Map<String, dynamic> map):
        cycleTime = map["cycleTime"],
        flowType = map["flowType"],
        id = map["id"],
        material = map["material"],
        mouldCode = map["mouldCode"],
        proName = map["proName"],
        stdCavityQty = map["stdCavityQty"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cycleTime'] = cycleTime;
    data['flowType'] = flowType;
    data['id'] = id;
    data['material'] = material;
    data['mouldCode'] = mouldCode;
    data['proName'] = proName;
    data['stdCavityQty'] = stdCavityQty;
    return data;
  }
}