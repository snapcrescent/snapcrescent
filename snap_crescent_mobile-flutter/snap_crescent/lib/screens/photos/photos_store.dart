import 'package:mobx/mobx.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/services/photo_service.dart';
import 'package:snap_crescent/services/thumbnail_service.dart';

part 'photos_store.g.dart';

class PhotosStore = _PhotosStore with _$PhotosStore;

abstract class _PhotosStore with Store {
  
  _PhotosStore() {
    getPhotos(false);
  }

  @observable
  List<Photo> allPhotos = new List.empty();

  @action
  Future<void> getPhotos(bool forceReloadFromApi) async {
    allPhotos = new List.empty();

    if(forceReloadFromApi) {
        await getPhotosFromApi();
    } else {
      final newPhotos = await PhotoService().searchOnLocal();

    if (newPhotos.isNotEmpty) {        

        for(Photo photo in newPhotos) {
          final thumbnail = await ThumbnailService().findByIdOnLocal(photo.thumbnailId!);
          photo.thumbnail = thumbnail;
        }

        allPhotos = newPhotos;
         
    } else {
      await getPhotosFromApi();
    }
    }

    
  }

  Future<void> getPhotosFromApi() async {
    final data = await PhotoService().search();

    allPhotos = new List<Photo>.from(data.objects!);
    
    await PhotoService().saveOnLocal(allPhotos[0]);
    await PhotoService().saveOnLocal(allPhotos[1]);
    await PhotoService().saveOnLocal(allPhotos[2]);
  }

}