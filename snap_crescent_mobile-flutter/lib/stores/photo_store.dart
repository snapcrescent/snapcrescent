import 'package:mobx/mobx.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/models/photo_search_criteria.dart';
import 'package:snap_crescent/services/photo_service.dart';
import 'package:snap_crescent/services/thumbnail_service.dart';
import 'package:snap_crescent/services/toast_service.dart';

part 'photo_store.g.dart';

class PhotoStore = _PhotoStore with _$PhotoStore;

abstract class _PhotoStore with Store {
  _PhotoStore() {
    getPhotos(false);
  }

  @observable
  List<Photo> photoList = new List.empty();

  @action
  Future<void> getPhotos(bool forceReloadFromApi) async {
    photoList = new List.empty();

    if (forceReloadFromApi) {
      await getPhotosFromApi();
    } else {
      final newPhotos = await PhotoService().searchOnLocal();

      if (newPhotos.isNotEmpty) {
        for (Photo photo in newPhotos) {
          final thumbnail =
              await ThumbnailService().findByIdOnLocal(photo.thumbnailId!);
          photo.thumbnail = thumbnail;
        }

        photoList = newPhotos;
      } else {
        await getPhotosFromApi();
      }
    }
  }

  Future<void> getPhotosFromApi() async {
    try {
      final data = await PhotoService().searchAndSync(PhotoSearchCriteria.defaultCriteria());
      photoList = new List<Photo>.from(data);
    } catch (e) {
      ToastService.showError("Unable to reach server");
      print(e);
      return getPhotos(false);
    } 
  }

  Photo getPhotosAtIndex(int photoIndex) {
    return photoList[photoIndex];
  }
}
