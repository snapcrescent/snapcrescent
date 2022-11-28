import 'package:snap_crescent/models/base_model.dart';

class Metadata extends BaseUiBean {
  DateTime? creationDateTime;
  DateTime? lastModifiedDateTime;
  String? name;
  String? internalName;
  String? mimeType;
  int? orientation;

  Metadata(
      {
      bean,
      this.creationDateTime,
      this.lastModifiedDateTime,
      this.name,
      this.internalName,
      this.mimeType,
      this.orientation
      })
      : super(
            id: bean.id,
            version: bean.version,
            active: bean.active);

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
        bean: BaseUiBean.fromJson(json),
        creationDateTime: json['creationDateTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['creationDateTime'])
            : null,
        lastModifiedDateTime: json['lastModifiedDateTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['lastModifiedDateTime'])
            : null,
        name: json['name'],
        internalName: json['internalName'],
        mimeType: json['mimeType'],
        orientation: json['orientation'],
        );
  }

  factory Metadata.fromMap(Map<String, dynamic> map) {
    return Metadata(
        bean: BaseUiBean.fromMap(map),
         creationDateTime: map['CREATION_DATE_TIME'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['CREATION_DATE_TIME'])
            : null,
        lastModifiedDateTime: map['LAST_MODIFIED_DATE_TIME'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['LAST_MODIFIED_DATE_TIME'])
            : null,
        name: map['NAME'],
        internalName: map['INTERNAL_NAME'],
        mimeType: map['MIME_TYPE'],
        orientation: map['ORIENTATION'],
        );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['CREATION_DATE_TIME'] = creationDateTime!.millisecondsSinceEpoch;
    map['LAST_MODIFIED_DATE_TIME'] =  lastModifiedDateTime!.millisecondsSinceEpoch;
    map['INTERNAL_NAME'] = name;
    map['NAME'] = internalName;
    map['MIME_TYPE'] = mimeType;
    map['ORIENTATION'] = orientation;

    return map;
  }
}
