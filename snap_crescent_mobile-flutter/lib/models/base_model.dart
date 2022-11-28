class BaseUiBean {
  int? id;
  int? version;
  bool? active;

  BaseUiBean({
    this.id,
    this.version,
    this.active,
  });

  factory BaseUiBean.fromJson(Map<String, dynamic> json) {
    return BaseUiBean(
        id: json['id'],
        version: json['version'],
        
        active: json['active']);
  }

  factory BaseUiBean.fromMap(Map<String, dynamic> map) {
    return BaseUiBean(
        id: map['ID'],
        version: map['VERSION'],
        active: map['ACTIVE'] == 1 ? true : false);
  }

  

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'VERSION': version,
      'ACTIVE': active == true ? 1 : 0
    };
  }
}
