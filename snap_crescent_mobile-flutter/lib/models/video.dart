import 'package:snap_crescent/models/base_model.dart';
import 'package:snap_crescent/models/thumbnail.dart';
import 'package:snap_crescent/models/video_metadata.dart';

class Video extends BaseUiBean {

  Thumbnail? thumbnail;
  int? thumbnailId;

  VideoMetadata? videoMetadata;
  int? videoMetadataId;

  bool? favorite;

  Video(
      {id,
      version,
      creationDatetime,
      lastModifiedDatetime,
      active,
      this.thumbnail,
      this.thumbnailId,
      this.videoMetadata,
      this.videoMetadataId,
      this.favorite})
      : super(
            id: id,
            version: version,
            creationDatetime: creationDatetime,
            lastModifiedDatetime: lastModifiedDatetime,
            active: active);

  static Video fromJsonModel(Map<String, dynamic> json) => Video.fromJson(json);

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      version: json['version'],
      creationDatetime: json['creationDatetime'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              json['creationDatetime']),
      lastModifiedDatetime: json['lastModifiedDatetime'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              json['lastModifiedDatetime']),
      active: json['active'],
      thumbnail: json['thumbnail'] == null
          ? null
          : Thumbnail.fromJson(json['thumbnail']),
      thumbnailId: json['thumbnailId'],
      videoMetadata: json['videoMetadata'] == null
          ? null
          : VideoMetadata.fromJson(json['videoMetadata']),
      videoMetadataId: json['videoMetadataId'],
      favorite: json['favorite'],
    );
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['ID'],
      version: map['VERSION'],
      creationDatetime:
          DateTime.fromMillisecondsSinceEpoch(map['CREATION_DATETIME']),
      lastModifiedDatetime: DateTime.fromMillisecondsSinceEpoch(
          map['LAST_MODIFIED_DATETIME']),
      active: map['ACTIVE'] == 1 ? true : false,
      thumbnailId: map['THUMBNAIL_ID'],
      videoMetadataId: map['VIDEO_METADATA_ID'],
      favorite: map['FAVORITE'] == 1 ? true : false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['THUMBNAIL_ID'] = thumbnailId;
    map['VIDEO_METADATA_ID'] = videoMetadataId;
    map['FAVORITE'] = favorite == true ? 1 : 0;

    return map;
  }
}
