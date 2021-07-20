import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/resository/metadata_resository.dart';
import 'package:snap_crescent/resository/asset_resository.dart';
import 'package:snap_crescent/resository/thumbnail_resository.dart';
import 'package:snap_crescent/services/base_service.dart';
import 'package:snap_crescent/utils/constants.dart';

class AssetService extends BaseService {
  Future<BaseResponseBean<int, Asset>> search(
      AssetSearchCriteria searchCriteria) async {
    try {
      Dio dio = await getDio();
      final response =
          await dio.get('/asset', queryParameters: searchCriteria.toMap());

      return BaseResponseBean.fromJson(response.data, Asset.fromJsonModel);
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  save(ASSET_TYPE assetType,File file) async {
    Dio dio = await getDio();
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "assetType": assetType.index,
      "files": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    await dio.post("/asset/upload", data: formData);
    return Future.value(true);
  }

  Future<List<Asset>> searchAndSync(AssetSearchCriteria searchCriteria) async {
    final data = await AssetService().search(searchCriteria);
    await saveAllOnLocal(data.objects!);
    return new List<Asset>.from(data.objects!);
  }

  String getGenericRelativeAssetByIdUrl() {
    return '/asset/ASSET_ID/raw';
  }

  Future<String> getGenericAssetByIdUrl() async {
    final baseUrl = await getServerUrl();
    return '$baseUrl' + getGenericRelativeAssetByIdUrl();
  }

  String getAssetByIdUrl(String genericURL, int assetId) {
    return genericURL.replaceAll("ASSET_ID", assetId.toString());
  }

  Future<File> downloadAssetById(int assetId, String assetName) async {
    try {
      Dio dio = await getDio();
      final url = getAssetByIdUrl(getGenericRelativeAssetByIdUrl(), assetId);
      final response = await dio.get(url);
      Directory documentDirectory = await getApplicationDocumentsDirectory();
      File file = new File(join(documentDirectory.path, assetName));
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      return file;
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  Future<int> saveAllOnLocal(List<Asset> entities) async {
    entities.forEach((entity) {
      saveOnLocal(entity);
    });

    return Future.value(0);
  }

  Future<int> saveOnLocal(Asset entity) async {
    final assetExistsById =
        await AssetResository.instance.existsById(entity.id!);

    if (assetExistsById == false) {
      final thumbnailExistsById =
          await ThumbnailResository.instance.existsById(entity.thumbnailId!);

      if (thumbnailExistsById == false) {
        ThumbnailResository.instance.save(entity.thumbnail!);
      }

      final assetMetadataExistsById = await MetadataResository.instance
          .existsById(entity.metadataId!);

      if (assetMetadataExistsById == false) {
        MetadataResository.instance.save(entity.metadata!);
      }

      return AssetResository.instance.save(entity);
    } else {
      return Future.value(0);
    }
  }

  Future<List<Asset>> searchOnLocal(AssetSearchCriteria assetSearchCriteria) async {
    return AssetResository.instance.searchOnLocal(assetSearchCriteria);
  }
}
