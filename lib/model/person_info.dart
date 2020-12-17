class PersonModel {

  String jobNo;
  String name;

  PersonModel.fromJsonMap(Map<String, dynamic> map):
        jobNo = map["jobNo"],
        name = map["name"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jobNo'] = jobNo;
    data['name'] = name;
    return data;
  }
}