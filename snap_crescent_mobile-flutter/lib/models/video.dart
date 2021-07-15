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
      {bean,
      this.thumbnail,
      this.thumbnailId,
      this.videoMetadata,
      this.videoMetadataId,
      this.favorite})
      : super(
            id: bean.id,
            version: bean.version,
            creationDatetime: bean.creationDatetime,
            lastModifiedDatetime: bean.lastModifiedDatetime,
            active: bean.active);

  static Video fromJsonModel(Map<String, dynamic> json) => Video.fromJson(json);

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      bean: BaseUiBean.fromJson(json),
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
      bean: BaseUiBean.fromMap(map),
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
