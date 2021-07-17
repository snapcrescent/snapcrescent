import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/models/photo_search_criteria.dart';
import 'package:snap_crescent/services/photo_metadata_service.dart';
import 'package:snap_crescent/services/photo_service.dart';
import 'package:snap_crescent/services/thumbnail_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/utils/common_utils.dart';

part 'photo_store.g.dart';

class PhotoStore = _PhotoStore with _$PhotoStore;

abstract class _PhotoStore with Store {
  _PhotoStore() {
    getPhotos(false);
  }

  @observable
  List<Photo> photoList = new List.empty();

  Map<String, List<Photo>> groupedPhotos = new Map();

  @action
  Future<void> getPhotos(bool forceReloadFromApi) async {
    _updatePhotoList(new List.empty());

    if (forceReloadFromApi) {
      await getPhotosFromApi();
    } else {
      final newPhotos = await PhotoService().searchOnLocal();

      if (newPhotos.isNotEmpty) {
        for (Photo photo in newPhotos) {
          final thumbnail =
              await ThumbnailService().findByIdOnLocal(photo.thumbnailId!);
          photo.thumbnail = thumbnail;

          final photoMetadata = await PhotoMetadataService()
              .findByIdOnLocal(photo.photoMetadataId!);
          photo.photoMetadata = photoMetadata;
        }

        _updatePhotoList(newPhotos);
      } else {
        await getPhotosFromApi();
      }
    }
  }

  Future<void> getPhotosFromApi() async {
    try {
      final data = await PhotoService()
          .searchAndSync(PhotoSearchCriteria.defaultCriteria());
      _updatePhotoList(new List<Photo>.from(data));
    } catch (e) {
      ToastService.showError("Unable to reach server");
      print(e);
      return getPhotos(false);
    }
  }

  Photo getPhotosAtIndex(int photoIndex) {
    return photoList[photoIndex];
  }

  _updatePhotoList(List<Photo> newPhotos) {
    this.photoList = newPhotos;

    groupedPhotos.clear();
    final currentDateTime = DateTime.now();
    final DateFormat currentWeekFormatter = DateFormat('EEEE');
    final DateFormat currentYearFormatter = DateFormat('E, MMM dd');
    final DateFormat defaultYearFormatter = DateFormat('E, MMM dd, yyyy');
    photoList.forEach((photo) {
      final photoDate = photo.photoMetadata!.creationDatetime!;
      String key;
      if (currentDateTime.year == photoDate.year) {
        if (CommonUtils().weekNumber(currentDateTime) ==
            CommonUtils().weekNumber(photoDate)) {
          if (currentDateTime.day == photoDate.day) {
            key = 'Today';
          } else {
            key = currentWeekFormatter.format(photoDate);
          }
        } else {
          key = currentYearFormatter.format(photoDate);
        }
      } else {
        key = defaultYearFormatter.format(photoDate);
      }

      if (groupedPhotos.containsKey(key)) {
        groupedPhotos[key]!.add(photo);
      } else {
        List<Photo> photos = [];
        photos.add(photo);
        groupedPhotos.putIfAbsent(key, () => photos);
      }
    });
  }
}
