import 'package:snap_crescent/models/base_model.dart';
import 'package:snap_crescent/models/photo_metadata.dart';
import 'package:snap_crescent/models/thumbnail.dart';

class Photo extends BaseUiBean {

  Thumbnail? thumbnail;
  int? thumbnailId;

  PhotoMetadata? photoMetadata;
  int? photoMetadataId;

  bool? favorite;

  Photo(
      {
      bean,
      this.thumbnail,
      this.thumbnailId,
      this.photoMetadata,
      this.photoMetadataId,
      this.favorite})
      : super(
            id: bean.id,
            version: bean.version,
            creationDatetime: bean.creationDatetime,
            lastModifiedDatetime: bean.lastModifiedDatetime,
            active: bean.active);

  static Photo fromJsonModel(Map<String, dynamic> json) => Photo.fromJson(json);

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      bean: BaseUiBean.fromJson(json),
      thumbnail: json['thumbnail'] == null
          ? null
          : Thumbnail.fromJson(json['thumbnail']),
      thumbnailId: json['thumbnailId'],
      photoMetadata: json['photoMetadata'] == null
          ? null
          : PhotoMetadata.fromJson(json['photoMetadata']),
      photoMetadataId: json['photoMetadataId'],
      favorite: json['favorite'],
    );
  }

  factory Photo.fromMap(Map<String, dynamic> map) {

    return Photo(
      bean: BaseUiBean.fromMap(map),
      thumbnailId: map['THUMBNAIL_ID'],
      photoMetadataId: map['PHOTO_METADATA_ID'],
      favorite: map['FAVORITE'] == 1 ? true : false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['THUMBNAIL_ID'] = thumbnailId;
    map['PHOTO_METADATA_ID'] = photoMetadataId;
    map['FAVORITE'] = favorite == true ? 1 : 0;

    return map;
  }
}
