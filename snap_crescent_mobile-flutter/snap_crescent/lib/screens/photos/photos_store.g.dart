// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photos_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PhotosStore on _PhotosStore, Store {
  final _$allPhotosAtom = Atom(name: '_PhotosStore.allPhotos');

  @override
  List<Photo> get allPhotos {
    _$allPhotosAtom.reportRead();
    return super.allPhotos;
  }

  @override
  set allPhotos(List<Photo> value) {
    _$allPhotosAtom.reportWrite(value, super.allPhotos, () {
      super.allPhotos = value;
    });
  }

  final _$getPhotosAsyncAction = AsyncAction('_PhotosStore.getPhotos');

  @override
  Future<void> getPhotos(bool forceReloadFromApi) {
    return _$getPhotosAsyncAction
        .run(() => super.getPhotos(forceReloadFromApi));
  }

  @override
  String toString() {
    return '''
allPhotos: ${allPhotos}
    ''';
  }
}
