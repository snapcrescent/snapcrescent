

import 'package:snapcrescent_mobile/common/model/base_model.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail.dart';

class Album extends BaseUiBean {

  String? name;
  bool? publicAccess;
  int? albumType;

  Thumbnail? albumThumbnail;
  int? albumThumbnailId;

  Album(
      {
      bean,
      this.name,
      this.publicAccess,
      this.albumType,
      this.albumThumbnail,
      this.albumThumbnailId
      })
      : super(
            id: bean.id);

  static Album fromJsonModel(Map<String, dynamic> json) => Album.fromJson(json);

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      bean: BaseUiBean.fromJson(json),
      name: json['name'],
      publicAccess: json['publicAccess'],
      albumType: json['albumType'],
      albumThumbnail: json['albumThumbnail'] == null
          ? null
          : Thumbnail.fromJson(json['albumThumbnail']),
      albumThumbnailId: json['albumThumbnailId']
    );
  }

  factory Album.fromMap(Map<String, dynamic> map) {

    return Album(
      bean: BaseUiBean.fromMap(map),
      name: map['NAME'],
      publicAccess: map['PUBLIC_ACCESS'] == 1 ? true : false,
      albumType: map['ALBUM_TYPE'],
      albumThumbnailId: map['ALBUM_THUMBNAIL_ID']
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['NAME'] = name;
    map['PUBLIC_ACCESS'] = publicAccess == true ? 1 : 0;
    map['ALBUM_TYPE'] = albumType;
    map['ALBUM_THUMBNAIL_ID'] = albumThumbnailId;

    return map;
  }
}
