import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/models/asset/asset.dart';
import 'package:snapcrescent_mobile/models/asset/asset_search_criteria.dart';
import 'package:snapcrescent_mobile/models/metadata/metadata.dart';
import 'package:snapcrescent_mobile/models/unified_asset.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/asset_service.dart';
import 'package:snapcrescent_mobile/services/metadata_service.dart';
import 'package:snapcrescent_mobile/services/thumbnail_service.dart';
import 'package:snapcrescent_mobile/state/asset_state.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';



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
      final newAssets =
          await AssetService().searchOnLocal(searchCriteria);

      if (newAssets.isNotEmpty) {
        for (Asset asset in newAssets) {
          final thumbnail = await ThumbnailService()
              .findByIdOnLocal(asset.thumbnailId!);
          asset.thumbnail = thumbnail;

          final metadata =
              await MetadataService().findById(asset.metadataId!);
          asset.metadata = metadata;
        }

        await _getUnifiedAssetsFromCloudAssets(assetList, newAssets);
      }

      

      
      if (await AppConfigService().getFlag(Constants.appConfigShowDeviceAssetsFlag)) {
        List<String> selectedDeviceFolders = await AppConfigService().getStringListConfig(Constants.appConfigShowDeviceAssetsFolders);

        

        
        final albums = await PhotoManager.getAssetPathList();
        albums.sort(
            (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));
            
        for (final album in albums) {
          if (selectedDeviceFolders.contains(album.id)) {
            await _getUnifiedAssetsFromLocalAssets(assetList, album);
          }
        }
      }
      
    } catch (ex) {
      throw Exception(ex.toString());
    }

    assetSearchProgress = AssetSearchProgress.PROCESSING;

    assetList.sort((UniFiedAsset a, UniFiedAsset b) => b.assetCreationDate.compareTo(a.assetCreationDate));

    if (AssetState().assetList.isEmpty) {
      AssetState().assetList = [];
    }

    AssetState().assetList.addAll(assetList);

    for (var asset in AssetState().assetList) {
      _addUnifiedAssetToGroup(asset.assetCreationDate, asset);
    }

    AssetState().prepareGroupedMapKeysList();

    /*
    if (AssetState().assetList.length > 0) {
      AssetState().groupedAssets.keys.forEach((key) {
        AssetState().groupedAssets[key]!.sort((UniFiedAsset a, UniFiedAsset b) =>
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

  _getUnifiedAssetsFromLocalAssets(List<UniFiedAsset> assetList, AssetPathEntity? album) async {
    
        
    if (album != null) {
      
      final allAssets = await album.getAssetListRange(
        start: 0, // start at index 0
        end: 100000, // end at a very big index (to get all the assets)
      );
       

      for (final asset in allAssets) {
        
       Metadata? metadata = await MetadataService().findByLocalAssetId(asset.id);

       //Local asset is not found 
       if(metadata == null) {

          //Attempt to find by name to avoid file size calculation
          List<Metadata>? matchingMetadataList = await MetadataService().findByName(asset.title!);
          
          if(matchingMetadataList != null && matchingMetadataList.isNotEmpty) {

            //Attempt to find by size as it might be a new asset
            File? assetFile = await asset.file;
            metadata = await MetadataService().findByNameAndSize(asset.title!, assetFile!.lengthSync());

            //Found by name and size match. Update the db to save future processing time
            if(metadata != null) {
                  metadata.localAssetId = asset.id;
                  await MetadataService().saveOrUpdate(metadata);
            }

          }
       }

        bool alreadyAdded = false;
        for (var unifiedAsset in assetList) {

          if(
            unifiedAsset.assetSource == AssetSource.DEVICE
            && unifiedAsset.assetEntity!.id == asset.id
          ) {
                alreadyAdded = true;
                continue;
            }
        }

        if (metadata == null && alreadyAdded == false) {
          final assetDate = asset.createDateTime;

          AppAssetType assetType = asset.type == AssetType.image
              ? AppAssetType.PHOTO
              : AppAssetType.VIDEO;
          assetList.add(UniFiedAsset(
              assetType, AssetSource.DEVICE, assetDate,
              assetEntity: asset));
        }
      }
    }

   
  }

  _getUnifiedAssetsFromCloudAssets(List<UniFiedAsset> assetList, List<Asset> newAssets) async {
    
    for (final asset in newAssets) {
      final assetDate = asset.metadata!.creationDateTime!;
      asset.thumbnail!.thumbnailFile =
          await ThumbnailService().readThumbnailFile(asset.thumbnail!.name!);

      AppAssetType assetType = asset.assetType == AppAssetType.PHOTO.id
          ? AppAssetType.PHOTO
          : AppAssetType.VIDEO;
      assetList.add(UniFiedAsset(
          assetType, AssetSource.CLOUD, assetDate,
          asset: asset));
    }
  }

  _addUnifiedAssetToGroup(DateTime assetDate, UniFiedAsset asset) {
    String key = Constants.defaultYearFormatter.format(assetDate);

    if (AssetState().groupedAssets.containsKey(key)) {
      List<UniFiedAsset> unifiedAssets = AssetState().groupedAssets[key]!;

      bool assetAlreadyPresent = false;

      for (var unifiedAsset in unifiedAssets) {
        if (asset.assetSource == AssetSource.DEVICE &&
            asset.assetSource == unifiedAsset.assetSource) {
          if (unifiedAsset.assetEntity!.id == asset.assetEntity!.id) {
            assetAlreadyPresent = true;
            continue;
          }
        } else if (asset.assetSource == AssetSource.CLOUD &&
            asset.assetSource == unifiedAsset.assetSource) {
          if (unifiedAsset.asset!.id == asset.asset!.id) {
            assetAlreadyPresent = true;
            continue;
          }
        }
      }

      if (!assetAlreadyPresent) {
        unifiedAssets.add(asset);
      }
    } else {
      List<UniFiedAsset> assets = [];
      assets.add(asset);
      AssetState().groupedAssets.putIfAbsent(key, () => assets);
    }
  }

}
