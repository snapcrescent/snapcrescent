class BaseUiBean {
  int? id;
  

  BaseUiBean({
    this.id,
  });

  factory BaseUiBean.fromJson(Map<String, dynamic> json) {
    return BaseUiBean(
        id: json['id'],
        );
  }

  factory BaseUiBean.fromMap(Map<String, dynamic> map) {
    return BaseUiBean(
        id: map['ID'],
        );
  }

  

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
    };
  }
}
