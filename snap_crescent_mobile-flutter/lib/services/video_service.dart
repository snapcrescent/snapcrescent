import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/video.dart';
import 'package:snap_crescent/models/video_search_criteria.dart';
import 'package:snap_crescent/resository/video_resository.dart';
import 'package:snap_crescent/resository/thumbnail_resository.dart';
import 'package:snap_crescent/services/base_service.dart';

class VideoService extends BaseService {
  
  Future<BaseResponseBean<int, Video>> search(VideoSearchCriteria searchCriteria) async {
    final baseUrl = await getServerUrl();
    final String queryString = getQueryString(searchCriteria.toMap());

    Response response = await get(Uri.parse('''$baseUrl/video?$queryString'''));
    
    if (response.statusCode == 200) {
      return BaseResponseBean.fromJson(jsonDecode(response.body), Video.fromJsonModel);
    } else {
      throw "Unable to retrieve videos.";
    }
  }

  Future<List<Video>> searchAndSync(VideoSearchCriteria searchCriteria) async{
      final data = await VideoService().search(searchCriteria);
      await saveAllOnLocal(data.objects!);
      return new List<Video>.from(data.objects!);
  }

  Future<String> getGenericVideoByIdUrl() async {
    final baseUrl = await getServerUrl();
    return '''$baseUrl/video/VIDEO_ID/raw''';
  }

  String getVideoByIdUrl(String genericURL, int videoId)  {
    return genericURL.replaceAll("VIDEO_ID", videoId.toString());
  }

  Future<File> downloadVideoById(int videoId,String videoName) async{
    final _genericVideoByIdUrl =  await getGenericVideoByIdUrl();
    final url = getVideoByIdUrl(_genericVideoByIdUrl, videoId);
    final response = await get(Uri.parse(url));
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    File file = new File(join(documentDirectory.path, videoName));
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  Future<int> saveAllOnLocal(List<Video> entities) async {
    entities.forEach((entity) {
      saveOnLocal(entity);
     });

    return Future.value(0);

  }

  Future<int> saveOnLocal(Video entity) async {
    final videoExistsById = await VideoResository.instance.existsById(entity.id!);

    if(videoExistsById == false) {
      final thumbnailExistsById = await ThumbnailResository.instance.existsById(entity.thumbnailId!);

      if(thumbnailExistsById == false) {
          ThumbnailResository.instance.save(entity.thumbnail!);
      }
      
      return VideoResository.instance.save(entity);
    } else {
      return Future.value(0);
    } 
  }

  Future<List<Video>> searchOnLocal() async {
    final localVideosMap =  await VideoResository.instance.findAll();
    return new List<Video>.from(localVideosMap.map((videoMap) => Video.fromMap(videoMap)).toList());
  }
}
