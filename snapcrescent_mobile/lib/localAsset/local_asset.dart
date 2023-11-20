import 'package:snapcrescent_mobile/common/model/base_model.dart';

class LocalAsset extends BaseUiBean {
  static const tableName = 'LOCAL_ASSET';

  String? localAssetId;
  String? localAlbumId;
  DateTime? creationDateTime;
  bool? syncedToServer;

  LocalAsset({bean, this.localAssetId, this.localAlbumId, this.creationDateTime, this.syncedToServer}) : super(id: bean.id);

  factory LocalAsset.fromMap(Map<String, dynamic> map) {
    return LocalAsset(
      bean: BaseUiBean.fromMap(map),
      localAssetId: map['LOCAL_ASSET_ID'],
      localAlbumId: map['LOCAL_ALBUM_ID'],
      creationDateTime: map['CREATION_DATE_TIME'] != null ? DateTime.fromMillisecondsSinceEpoch(map['CREATION_DATE_TIME'] * 1000) : null,
      syncedToServer: map['SYNCED_TO_SERVER'] == 1 ? true : false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['LOCAL_ASSET_ID'] = localAssetId;
    map['LOCAL_ALBUM_ID'] = localAlbumId;
    map['CREATION_DATE_TIME'] = (creationDateTime!.millisecondsSinceEpoch) / 1000;
    map['SYNCED_TO_SERVER'] = syncedToServer == true ? 1 : 0;

    return map;
  }
}
