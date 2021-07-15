class BaseUiBean {
  int? id;
  int? version;
  DateTime? creationDatetime;
  DateTime? lastModifiedDatetime;
  bool? active;

  BaseUiBean({
    this.id,
    this.version,
    this.creationDatetime,
    this.lastModifiedDatetime,
    this.active,
  });

  factory BaseUiBean.fromMap(Map<String, dynamic> map) {
    return BaseUiBean(
        id: map['ID'],
        version: map['VERSION'],
        creationDatetime: map['CREATION_DATETIME'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['CREATION_DATETIME'])
            : null,
        lastModifiedDatetime: map['LAST_MODIFIED_DATETIME'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['LAST_MODIFIED_DATETIME'])
            : null,
        active: map['ACTIVE'] == 1 ? true : false);
  }

  factory BaseUiBean.fromJson(Map<String, dynamic> json) {
    return BaseUiBean(
        id: json['id'],
        version: json['version'],
        creationDatetime: json['creationDatetime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['creationDatetime'])
            : null,
        lastModifiedDatetime: json['lastModifiedDatetime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['lastModifiedDatetime'])
            : null,
        active: json['active']);
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'VERSION': version,
      'CREATION_DATETIME': creationDatetime!.millisecondsSinceEpoch,
      'LAST_MODIFIED_DATETIME': lastModifiedDatetime!.millisecondsSinceEpoch,
      'ACTIVE': active == true ? 1 : 0
    };
  }
}
