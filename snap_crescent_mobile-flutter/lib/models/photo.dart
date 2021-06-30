import 'package:snap_crescent/models/base_model.dart';
import 'package:snap_crescent/models/photo_metadata.dart';
import 'package:snap_crescent/models/thumbnail.dart';

class Photo extends BaseUiBean {
  static Photo fromJsonModel(Map<String, dynamic> json) => Photo.fromJson(json);

  Thumbnail? thumbnail;
  int? thumbnailId;

  PhotoMetadata? photoMetadata;
  int? photoMetadataId;

  bool? favorite;

  Photo(
      {id,
      version,
      creationDatetime,
      lastModifiedDatetime,
      active,
      this.thumbnail,
      this.thumbnailId,
      this.photoMetadata,
      this.photoMetadataId,
      this.favorite})
      : super(
            id: id,
            version: version,
            creationDatetime: creationDatetime,
            lastModifiedDatetime: lastModifiedDatetime,
            active: active);

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      version: json['version'],
      creationDatetime: json['creationDatetime'],
      lastModifiedDatetime: json['lastModifiedDatetime'],
      active: json['active'],
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
        id : map['ID'],
        version : map['VERSION'],
        creationDatetime : map['CREATION_DATETIME'],
        lastModifiedDatetime : map['LAST_MODIFIED_DATETIME'],
        active : map['ACTIVE'] == 1 ? true : false,
        thumbnailId : map['THUMBNAIL_ID'],
        photoMetadataId : map['PHOTO_METADATA_ID'],
        favorite : map['FAVORITE'] == 1 ? true : false,
      );

   }

  @override
  Map<String,dynamic> toMap() {
    Map<String,dynamic> map =  super.toMap();

    map['THUMBNAIL_ID'] = thumbnailId;
    map['PHOTO_METADATA_ID'] = thumbnailId;
    map['FAVORITE'] = thumbnailId;

    return map;
  }
}
