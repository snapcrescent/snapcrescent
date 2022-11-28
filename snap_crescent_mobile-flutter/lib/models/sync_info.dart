import 'package:snap_crescent/models/base_model.dart';

class SyncInfo extends BaseUiBean {
  DateTime? creationDateTime;
  DateTime? lastModifiedDateTime;

  SyncInfo({
    bean,
    this.creationDateTime,
    this.lastModifiedDateTime,
  }) : super(
            id: bean.id,
            version: bean.version,
            active: bean.active);

  static SyncInfo fromJsonModel(Map<String, dynamic> json) =>
      SyncInfo.fromJson(json);

  factory SyncInfo.fromJson(Map<String, dynamic> json) {
    return SyncInfo(
      bean: BaseUiBean.fromJson(json),
      creationDateTime: json['creationDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['creationDateTime'])
          : null,
      lastModifiedDateTime: json['lastModifiedDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastModifiedDateTime'])
          : null,
    );
  }

  factory SyncInfo.fromMap(Map<String, dynamic> map) {
    return SyncInfo(
      bean: BaseUiBean.fromMap(map),
      creationDateTime: map['CREATION_DATE_TIME'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['CREATION_DATE_TIME'])
          : null,
      lastModifiedDateTime: map['LAST_MODIFIED_DATE_TIME'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['LAST_MODIFIED_DATE_TIME'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['CREATION_DATE_TIME'] = creationDateTime!.millisecondsSinceEpoch;
    map['LAST_MODIFIED_DATE_TIME'] =  lastModifiedDateTime!.millisecondsSinceEpoch;

    return map;
  }
}
