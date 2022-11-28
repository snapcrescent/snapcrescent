import 'package:snap_crescent/models/base_model.dart';
import 'package:snap_crescent/models/metadata.dart';
import 'package:snap_crescent/models/thumbnail.dart';

class Asset extends BaseUiBean {

  Thumbnail? thumbnail;
  int? thumbnailId;

  Metadata? metadata;
  int? metadataId;

  int? assetType;
  bool? favorite;

  Asset(
      {
      bean,
      this.thumbnail,
      this.thumbnailId,
      this.metadata,
      this.metadataId,
      this.favorite,
      this.assetType})
      : super(
            id: bean.id,
            version: bean.version,
            active: bean.active);

  static Asset fromJsonModel(Map<String, dynamic> json) => Asset.fromJson(json);

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      bean: BaseUiBean.fromJson(json),
      thumbnail: json['thumbnail'] == null
          ? null
          : Thumbnail.fromJson(json['thumbnail']),
      thumbnailId: json['thumbnailId'],
      metadata: json['metadata'] == null
          ? null
          : Metadata.fromJson(json['metadata']),
      metadataId: json['metadataId'],
      favorite: json['favorite'],
      assetType: json['assetType'],
    );
  }

  factory Asset.fromMap(Map<String, dynamic> map) {

    return Asset(
      bean: BaseUiBean.fromMap(map),
      thumbnailId: map['THUMBNAIL_ID'],
      metadataId: map['METADATA_ID'],
      favorite: map['FAVORITE'] == 1 ? true : false,
      assetType: map['ASSET_TYPE'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['THUMBNAIL_ID'] = thumbnailId;
    map['METADATA_ID'] = metadataId;
    map['FAVORITE'] = favorite == true ? 1 : 0;
    map['ASSET_TYPE'] = assetType;

    return map;
  }
}
