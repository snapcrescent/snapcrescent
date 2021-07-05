// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PhotoStore on _PhotoStore, Store {
  final _$photoListAtom = Atom(name: '_PhotoStore.photoList');

  @override
  List<Photo> get photoList {
    _$photoListAtom.reportRead();
    return super.photoList;
  }

  @override
  set photoList(List<Photo> value) {
    _$photoListAtom.reportWrite(value, super.photoList, () {
      super.photoList = value;
    });
  }

  final _$getPhotosAsyncAction = AsyncAction('_PhotoStore.getPhotos');

  @override
  Future<void> getPhotos(bool forceReloadFromApi) {
    return _$getPhotosAsyncAction
        .run(() => super.getPhotos(forceReloadFromApi));
  }

  @override
  String toString() {
    return '''
photoList: ${photoList}
    ''';
  }
}
