


import 'package:snapcrescent_mobile/common/model/base_model.dart';

class Metadata extends BaseUiBean {
  DateTime? creationDateTime;
  String? name;
  String? internalName;
  String? mimeType;
  int? orientation;
  int? size;
  String? localAssetId;
  int? duration;

  Metadata(
      {
      bean,
      this.creationDateTime,
      this.name,
      this.internalName,
      this.mimeType,
      this.orientation,
      this.size,
      this.localAssetId,
      this.duration
      })
      : super(
            id: bean.id);

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
        bean: BaseUiBean.fromJson(json),
        creationDateTime: json['creationDateTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['creationDateTime'])
            : null,
        name: json['name'],
        internalName: json['internalName'],
        mimeType: json['mimeType'],
        orientation: json['orientation'],
        size : json['size'],
        duration : json['duration']
        );
  }

  factory Metadata.fromMap(Map<String, dynamic> map) {
    return Metadata(
        bean: BaseUiBean.fromMap(map),
         creationDateTime: map['CREATION_DATE_TIME'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['CREATION_DATE_TIME'])
            : null,
        name: map['NAME'],
        internalName: map['INTERNAL_NAME'],
        mimeType: map['MIME_TYPE'],
        orientation: map['ORIENTATION'],
        size : map['SIZE'],
        localAssetId: map['LOCAL_ASSET_ID'],
        duration: map['DURATION'],
        );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['CREATION_DATE_TIME'] = creationDateTime!.millisecondsSinceEpoch;
    map['NAME'] = name;
    map['INTERNAL_NAME'] = internalName;
    map['MIME_TYPE'] = mimeType;
    map['ORIENTATION'] = orientation;
    map['SIZE'] = size;
    map['LOCAL_ASSET_ID'] = localAssetId;
    map['DURATION'] = duration;

    return map;
  }
}
