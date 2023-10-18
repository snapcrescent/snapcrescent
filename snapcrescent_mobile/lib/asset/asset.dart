import 'package:snapcrescent_mobile/common/model/base_model.dart';
import 'package:snapcrescent_mobile/metadata/metadata.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail.dart';

class Asset extends BaseUiBean {

  bool? active;

  Thumbnail? thumbnail;
  int? thumbnailId;

  Metadata? metadata;
  int? metadataId;

  int? assetType;
  bool? favorite;

  String? token;

  Asset(
      {
      bean,
      this.active,
      this.thumbnail,
      this.thumbnailId,
      this.metadata,
      this.metadataId,
      this.favorite,
      this.assetType,
      this.token
      })
      : super(
            id: bean.id);

  static Asset fromJsonModel(Map<String, dynamic> json) => Asset.fromJson(json);

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      bean: BaseUiBean.fromJson(json),
      active: json['active'],
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
      token: json['token'],
    );
  }

  factory Asset.fromMap(Map<String, dynamic> map) {

    return Asset(
      bean: BaseUiBean.fromMap(map),
      active: map['ACTIVE'] == 1 ? true : false,
      thumbnailId: map['THUMBNAIL_ID'],
      metadataId: map['METADATA_ID'],
      favorite: map['FAVORITE'] == 1 ? true : false,
      assetType: map['ASSET_TYPE'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['ACTIVE'] = active == true ? 1 : 0;
    map['THUMBNAIL_ID'] = thumbnailId;
    map['METADATA_ID'] = metadataId;
    map['FAVORITE'] = favorite == true ? 1 : 0;
    map['ASSET_TYPE'] = assetType;

    return map;
  }
}
