import 'package:mobx/mobx.dart';
import 'package:snap_crescent/models/video.dart';
import 'package:snap_crescent/models/video_search_criteria.dart';
import 'package:snap_crescent/services/video_service.dart';
import 'package:snap_crescent/services/thumbnail_service.dart';

part 'video_store.g.dart';

class VideoStore = _VideoStore with _$VideoStore;

abstract class _VideoStore with Store {
  
  _VideoStore() {
    getVideos(false);
  }

  @observable
  List<Video> videoList = new List.empty();

  @action
  Future<void> getVideos(bool forceReloadFromApi) async {
    videoList = new List.empty();

    if(forceReloadFromApi) {
        await getVideosFromApi();
    } else {
      final newVideos = await VideoService().searchOnLocal();

    if (newVideos.isNotEmpty) {        

        for(Video video in newVideos) {
          final thumbnail = await ThumbnailService().findByIdOnLocal(video.thumbnailId!);
          video.thumbnail = thumbnail;
        }

        videoList = newVideos;
         
    } else {
      await getVideosFromApi();
    }
    }    
  }

  Future<void> getVideosFromApi() async {
    final data = await VideoService().search(VideoSearchCriteria.defaultCriteria());
    //final data = await VideoService().searchAndSync(VideoSearchCriteria.defaultCriteria());
    videoList = new List<Video>.from(data.objects!);
  }

  Video getVideosAtIndex(int videoIndex) {
    return videoList[videoIndex];
  }



}