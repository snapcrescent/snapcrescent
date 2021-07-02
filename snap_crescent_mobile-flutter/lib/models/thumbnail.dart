import 'package:snap_crescent/models/base_model.dart';

class Thumbnail extends BaseUiBean {
  String? name;
  String? base64EncodedThumbnail;

  Thumbnail(
      {id,
      version,
      creationDatetime,
      lastModifiedDatetime,
      active,
      this.name,
      this.base64EncodedThumbnail})
      : super(
            id: id,
            version: version,
            creationDatetime: creationDatetime,
            lastModifiedDatetime: lastModifiedDatetime,
            active: active);

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
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
        active: json['active'],
        name: json['name'],
        base64EncodedThumbnail: json['base64EncodedThumbnail']);
  }

  factory Thumbnail.fromMap(Map<String, dynamic> map) {
    return Thumbnail(
        id: map['ID'],
        version: map['VERSION'],
        creationDatetime: DateTime.fromMillisecondsSinceEpoch(
            map['CREATION_DATETIME'] * 1000),
        lastModifiedDatetime: DateTime.fromMillisecondsSinceEpoch(
            map['LAST_MODIFIED_DATETIME'] * 1000),
        active: map['ACTIVE'] == 1 ? true : false,
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
