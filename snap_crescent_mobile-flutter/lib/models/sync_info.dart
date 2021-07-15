import 'package:snap_crescent/models/base_model.dart';

class SyncInfo extends BaseUiBean {
  SyncInfo({bean})
      : super(
            id: bean.id,
            version: bean.version,
            creationDatetime: bean.creationDatetime,
            lastModifiedDatetime: bean.lastModifiedDatetime,
            active: bean.active);

  static SyncInfo fromJsonModel(Map<String, dynamic> json) =>
      SyncInfo.fromJson(json);

  factory SyncInfo.fromJson(Map<String, dynamic> json) {
    return SyncInfo(bean: BaseUiBean.fromJson(json));
  }

  factory SyncInfo.fromMap(Map<String, dynamic> map) {
    return SyncInfo(bean: BaseUiBean.fromMap(map));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    return map;
  }
}
