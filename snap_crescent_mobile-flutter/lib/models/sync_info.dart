import 'package:snap_crescent/models/base_model.dart';

class SyncInfo extends BaseUiBean {
  SyncInfo({id, version, creationDatetime, lastModifiedDatetime, active})
      : super(
            id: id,
            version: version,
            creationDatetime: creationDatetime,
            lastModifiedDatetime: lastModifiedDatetime,
            active: active);

  static SyncInfo fromJsonModel(Map<String, dynamic> json) => SyncInfo.fromJson(json);

  factory SyncInfo.fromJson(Map<String, dynamic> json) {
    return SyncInfo(
        id: json['id'],
        version: json['version'],
        creationDatetime: json['creationDatetime'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                json['creationDatetime'] * 1000),
        lastModifiedDatetime: json['lastModifiedDatetime'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                json['lastModifiedDatetime'] * 1000),
        active: json['active']);
  }

  factory SyncInfo.fromMap(Map<String, dynamic> map) {
    return SyncInfo(
      id: map['ID'],
      version: map['VERSION'],
      creationDatetime:
          DateTime.fromMillisecondsSinceEpoch(map['CREATION_DATETIME'] * 1000),
      lastModifiedDatetime: DateTime.fromMillisecondsSinceEpoch(
          map['LAST_MODIFIED_DATETIME'] * 1000),
      active: map['ACTIVE'] == 1 ? true : false
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    return map;
  }
}
