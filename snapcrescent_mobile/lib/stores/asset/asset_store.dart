import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/models/asset/asset.dart';
import 'package:snapcrescent_mobile/models/asset/asset_search_criteria.dart';
import 'package:snapcrescent_mobile/models/metadata/metadata.dart';
import 'package:snapcrescent_mobile/models/unified_asset.dart';
import 'package:snapcrescent_mobile/repository/metadata_repository.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/asset_service.dart';
import 'package:snapcrescent_mobile/services/metadata_service.dart';
import 'package:snapcrescent_mobile/services/thumbnail_service.dart';
import 'package:snapcrescent_mobile/state/asset_state.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'dart:developer';



part 'asset_store.g.dart';

class AssetStore = _AssetStore with _$AssetStore;

class _AssetStore with Store {
 
  @observable
  AssetSearchProgress assetSearchProgress = AssetSearchProgress.IDLE;
  bool executionInProgress = false;

  AssetSearchCriteria getAssetSearchCriteria() {
    AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
    assetSearchCriteria.resultPerPage = 500;
    return assetSearchCriteria;
  }

  @action
  Future<void> initStore(int pageNumber) async {
    AssetSearchCriteria searchCriteria = getAssetSearchCriteria();
    searchCriteria.resultPerPage = 100;
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
    assetSearchProgress = AssetSearchProgress.PROCESSING;
    AssetState.instance.groupedAssets.clear();
    AssetState.instance.assetList = [];
    await _processAssetRequest(getAssetSearchCriteria());
  }

  Future<void> _processAssetRequest(AssetSearchCriteria searchCriteria) async {
    if (executionInProgress) {
      return;
    }

    
  
    executionInProgress = true;

    List<UniFiedAsset> _assetList = [];

    try {
      final newAssets =
          await AssetService.instance.searchOnLocal(searchCriteria);

      if (newAssets.isNotEmpty) {
        for (Asset asset in newAssets) {
          final thumbnail = await ThumbnailService.instance
              .findByIdOnLocal(asset.thumbnailId!);
          asset.thumbnail = thumbnail;

          final metadata =
              await MetadataService.instance.findByIdOnLocal(asset.metadataId!);
          asset.metadata = metadata;
        }

        await _getUnifiedAssetsFromCloudAssets(_assetList, newAssets);
      }

      

      
      if (await AppConfigService.instance.getFlag(Constants.appConfigShowDeviceAssetsFlag)) {
        List<String> selectedDeviceFolders = await AppConfigService.instance.getStringListConfig(Constants.appConfigShowDeviceAssetsFolders);

        

        
        final albums = await PhotoManager.getAssetPathList();
        albums.sort(
            (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));
            
        for (final album in albums) {
          if (selectedDeviceFolders.indexOf(album.id) != -1) {
            await _getUnifiedAssetsFromLocalAssets(_assetList, album);
          }
        }
      }
      
    } catch (ex) {
      throw Exception(ex.toString());
    }

    assetSearchProgress = AssetSearchProgress.PROCESSING;

    _assetList.sort((UniFiedAsset a, UniFiedAsset b) => b.assetCreationDate.compareTo(a.assetCreationDate));

    if (AssetState.instance.assetList.isEmpty) {
      AssetState.instance.assetList = [];
    }

    AssetState.instance.assetList.addAll(_assetList);

    for (var asset in AssetState.instance.assetList) {
      _addUnifiedAssetToGroup(asset.assetCreationDate, asset);
    }

    AssetState.instance.prepareGroupedMapKeysList();

    /*
    if (AssetState.instance.assetList.length > 0) {
      AssetState.instance.groupedAssets.keys.forEach((key) {
        AssetState.instance.groupedAssets[key]!.sort((UniFiedAsset a, UniFiedAsset b) =>
            b.assetCreationDate.compareTo(a.assetCreationDate));
      });

      assetSearchProgress = AssetSearchProgress.ASSETS_FOUND;
    } else {
      assetSearchProgress = AssetSearchProgress.IDLE;
    }
    */

    assetSearchProgress = AssetSearchProgress.ASSETS_FOUND;

    

    executionInProgress = false;
  }

  _getUnifiedAssetsFromLocalAssets(List<UniFiedAsset> _assetList, AssetPathEntity? album) async {
    
        
    if (album != null) {
      
      final allAssets = await album.getAssetListRange(
        start: 0, // start at index 0
        end: 100000, // end at a very big index (to get all the assets)
      );
       

      for (final asset in allAssets) {
        
       Metadata? metadata = await MetadataService.instance.findByLocalAssetId(asset.id);

       //Local asset is not found 
       if(metadata == null) {

          //Attempt to find by size as it might be a new asset
          File? assetFile = await asset.file;
          metadata = await MetadataService.instance.findByNameAndSize(asset.title!, assetFile!.lengthSync());

          //Found by name and size match. Update the db to save future processing time
          if(metadata != null) {
                metadata.localAssetId = asset.id;
                await MetadataService.instance.updateOnLocal(metadata);
          }

       }

        bool alreadyAdded = false;
        _assetList.forEach((unifiedAsset) {

          if(
            unifiedAsset.assetSource == AssetSource.DEVICE
            && unifiedAsset.assetEntity!.id == asset.id
          ) {
                alreadyAdded = true;
                return;
            }
        });

        if (metadata == null && alreadyAdded == false) {
          final assetDate = asset.createDateTime;

          AppAssetType assetType = asset.type == AssetType.image
              ? AppAssetType.PHOTO
              : AppAssetType.VIDEO;
          _assetList.add(new UniFiedAsset(
              assetType, AssetSource.DEVICE, assetDate,
              assetEntity: asset));
        }
      }
    }

   
  }

  _getUnifiedAssetsFromCloudAssets(List<UniFiedAsset> _assetList, List<Asset> newAssets) async {
    
    for (final asset in newAssets) {
      final assetDate = asset.metadata!.creationDateTime!;
      asset.thumbnail!.thumbnailFile =
          await ThumbnailService.instance.readThumbnailFile(asset.thumbnail!.name!);

      AppAssetType assetType = asset.assetType == AppAssetType.PHOTO.id
          ? AppAssetType.PHOTO
          : AppAssetType.VIDEO;
      _assetList.add(new UniFiedAsset(
          assetType, AssetSource.CLOUD, assetDate,
          asset: asset));
    }
  }

  _addUnifiedAssetToGroup(DateTime assetDate, UniFiedAsset asset) {
    String key = Constants.defaultYearFormatter.format(assetDate);

    if (AssetState.instance.groupedAssets.containsKey(key)) {
      List<UniFiedAsset> unifiedAssets = AssetState.instance.groupedAssets[key]!;

      bool assetAlreadyPresent = false;

      unifiedAssets.forEach((unifiedAsset) {
        if (asset.assetSource == AssetSource.DEVICE &&
            asset.assetSource == unifiedAsset.assetSource) {
          if (unifiedAsset.assetEntity!.id == asset.assetEntity!.id) {
            assetAlreadyPresent = true;
            return;
          }
        } else if (asset.assetSource == AssetSource.CLOUD &&
            asset.assetSource == unifiedAsset.assetSource) {
          if (unifiedAsset.asset!.id == asset.asset!.id) {
            assetAlreadyPresent = true;
            return;
          }
        }
      });

      if (!assetAlreadyPresent) {
        unifiedAssets.add(asset);
      }
    } else {
      List<UniFiedAsset> assets = [];
      assets.add(asset);
      AssetState.instance.groupedAssets.putIfAbsent(key, () => assets);
    }
  }

}
