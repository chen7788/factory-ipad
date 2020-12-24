class MaterialModel {

  int id;
  int proId;
  String materialName;

  MaterialModel.fromJsonMap(Map<String, dynamic> map):
        id = map["id"],
        proId = map["proId"],
        materialName = map["materialName"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['proId'] = proId;
    data['materialName'] = materialName;
    return data;
  }
}