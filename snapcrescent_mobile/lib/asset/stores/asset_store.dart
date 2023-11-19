import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/asset/asset.dart';
import 'package:snapcrescent_mobile/asset/asset_search_criteria.dart';
import 'package:snapcrescent_mobile/asset/asset_service.dart';
import 'package:snapcrescent_mobile/asset/state/asset_state.dart';
import 'package:snapcrescent_mobile/asset/unified_asset.dart';
import 'package:snapcrescent_mobile/localAsset/local_asset_service.dart';
import 'package:snapcrescent_mobile/metadata/metadata.dart';
import 'package:snapcrescent_mobile/metadata/metadata_service.dart';
import 'package:snapcrescent_mobile/appConfig/app_config_service.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'dart:developer' as developer;

part 'asset_store.g.dart';

class AssetStore = _AssetStore with _$AssetStore;

class _AssetStore with Store {
  @observable
  AssetSearchProgress assetSearchProgress = AssetSearchProgress.IDLE;
  bool executionInProgress = false;

  AssetSearchCriteria getAssetSearchCriteria() {
    AssetSearchCriteria assetSearchCriteria =
        AssetSearchCriteria.defaultCriteria();
    assetSearchCriteria.resultPerPage = 100;
    return assetSearchCriteria;
  }

  @action
  Future<void> initStore(int pageNumber) async {
    AssetSearchCriteria searchCriteria = getAssetSearchCriteria();
    searchCriteria.pageNumber = pageNumber;
    await _processAssetRequest(searchCriteria);
  }

  @action
  Future<void> loadMoreAssets(int pageNumber) async {
    AssetSearchCriteria searchCriteria = getAssetSearchCriteria();
    searchCriteria.pageNumber = pageNumber;
    await _processAssetRequest(searchCriteria);
  }

  @action
  Future<void> refreshStore() async {
    executionInProgress = false;
    assetSearchProgress = AssetSearchProgress.PROCESSING;
    AssetState().groupedAssets.clear();
    AssetState().assetList = [];
    await _processAssetRequest(getAssetSearchCriteria());
  }

  Future<void> _processAssetRequest(AssetSearchCriteria searchCriteria) async {
    if (executionInProgress) {
      return;
    }

    executionInProgress = true;

    List<UniFiedAsset> assetList = [];

    try {
      final newAssets = await AssetService().searchOnLocal(searchCriteria);
      
      
      if (newAssets.isNotEmpty) {
        for (Asset asset in newAssets) {
          final thumbnail = await ThumbnailService().findByIdOnLocal(asset.thumbnailId!);
          asset.thumbnail = thumbnail;

          final metadata = await MetadataService().findById(asset.metadataId!);
          asset.metadata = metadata;
        }
        

        await _getUnifiedAssetsFromCloudAssets(assetList, newAssets);
      }

      if (await AppConfigService()
          .getFlag(Constants.appConfigShowDeviceAssetsFlag)) {
        List<String> selectedDeviceFolders = await AppConfigService()
            .getStringListConfig(Constants.appConfigShowDeviceAssetsFolders);

        final albums = await PhotoManager.getAssetPathList();
        for (final album in albums) {
          if (selectedDeviceFolders.contains(album.id)) {

            

          

            await _getUnifiedAssetsFromLocalAssets(
                searchCriteria, assetList, album);
          }
        }
      }
    } catch (ex) {
      throw Exception(ex.toString());
    }

    assetSearchProgress = AssetSearchProgress.PROCESSING;

    assetList.sort((UniFiedAsset a, UniFiedAsset b) =>
        b.assetCreationDate.compareTo(a.assetCreationDate));

    for (var asset in assetList) {
      AssetState().addAsset(asset);
    }

    AssetState().prepareGroupedMapKeysList();

    assetSearchProgress = AssetSearchProgress.ASSETS_FOUND;

    executionInProgress = false;
  }

  _getUnifiedAssetsFromLocalAssets(AssetSearchCriteria searchCriteria,
      List<UniFiedAsset> assetList, AssetPathEntity? album) async {
    if (album != null) {

      //Look for latest entry in LOCAL_ASSET table for this album
      DateTime latestLoggedLocalAsset = await LocalAssetService().getMaxAssetDateByAlbum(album.id);

      
      FilterOptionGroup filterOption = FilterOptionGroup();
      filterOption.createTimeCond = DateTimeCond(min: latestLoggedLocalAsset, max: Constants.highDate);

      album = AssetPathEntity(id: album.id, name: album.name, filterOption: filterOption);

      final allAssets = await album.getAssetListRange(start: 0, end: 10000);

      for (final asset in allAssets) {
        
        bool metadataExists =
            await MetadataService().existByLocalAssetId(asset.id);

        //Local asset is not found
        if (metadataExists == false) {
          //Attempt to find by name to avoid file size calculation
          bool matchingMetadataList =
              await MetadataService().existByName(asset.title!);

          if (matchingMetadataList == true) {
            //Attempt to find by size as it might be a new asset
            File? assetFile = await asset.file;
            Metadata? metadata = await MetadataService()
                .findByNameAndSize(asset.title!, assetFile!.lengthSync());

            //Found by name and size match. Update the db to save future processing time
            if (metadata != null) {
              metadata.localAssetId = asset.id;
              await MetadataService().saveOrUpdate(metadata);
            }
          }
        }

        bool alreadyAdded = false;
        for (var unifiedAsset in assetList) {
          if (unifiedAsset.assetSource == AssetSource.DEVICE &&
              unifiedAsset.assetEntity!.id == asset.id) {
            alreadyAdded = true;
            continue;
          }
        }

        if (metadataExists == false && alreadyAdded == false) {
          final assetDate = asset.createDateTime;

          AppAssetType assetType = asset.type == AssetType.image
              ? AppAssetType.PHOTO
              : AppAssetType.VIDEO;
          assetList.add(UniFiedAsset(
              assetType, AssetSource.DEVICE, assetDate, asset.duration,
              assetEntity: asset, width: asset.width, height: asset.height));
        }
      }
    }
  }

  _getUnifiedAssetsFromCloudAssets(
      List<UniFiedAsset> assetList, List<Asset> newAssets) async {
    for (final asset in newAssets) {
      final assetDate = asset.metadata!.creationDateTime!;

      try {
        asset.thumbnail!.thumbnailFile =
            await ThumbnailService().readThumbnailFile(asset.thumbnail!.name!);
      } catch (ex) {
        developer.log("Something went wrong!", error: ex);
      }

      AppAssetType assetType = asset.assetType == AppAssetType.PHOTO.id
          ? AppAssetType.PHOTO
          : AppAssetType.VIDEO;
      assetList.add(UniFiedAsset(
          assetType, AssetSource.CLOUD, assetDate, asset.metadata!.duration!,
          asset: asset));
    }
  }
}
