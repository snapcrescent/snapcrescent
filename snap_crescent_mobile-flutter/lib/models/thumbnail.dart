import 'package:snap_crescent/models/base_model.dart';

class Thumbnail extends BaseUiBean {
  String? name;
  String? base64EncodedThumbnail;

  Thumbnail(
      {
      bean,
      this.name,
      this.base64EncodedThumbnail})
      : super(
            id: bean.id,
            version: bean.version,
            creationDatetime: bean.creationDatetime,
            lastModifiedDatetime: bean.lastModifiedDatetime,
            active: bean.active);

  factory Thumbnail.fromJson(Map<String, dynamic> json) {

    return Thumbnail(
        bean: BaseUiBean.fromJson(json),
        name: json['name'],
        base64EncodedThumbnail: json['base64EncodedThumbnail']);
  }

  factory Thumbnail.fromMap(Map<String, dynamic> map) {

    return Thumbnail(
        bean:  BaseUiBean.fromMap(map),
        name: map['NAME'],
        base64EncodedThumbnail: map['BASE_64_ENCODED_THUMBNAIL']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['NAME'] = name;
    map['BASE_64_ENCODED_THUMBNAIL'] = base64EncodedThumbnail;

    return map;
  }
}
