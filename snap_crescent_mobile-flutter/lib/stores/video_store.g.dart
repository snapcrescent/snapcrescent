// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VideoStore on _VideoStore, Store {
  final _$videoListAtom = Atom(name: '_VideoStore.videoList');

  @override
  List<Video> get videoList {
    _$videoListAtom.reportRead();
    return super.videoList;
  }

  @override
  set videoList(List<Video> value) {
    _$videoListAtom.reportWrite(value, super.videoList, () {
      super.videoList = value;
    });
  }

  final _$getVideosAsyncAction = AsyncAction('_VideoStore.getVideos');

  @override
  Future<void> getVideos(bool forceReloadFromApi) {
    return _$getVideosAsyncAction
        .run(() => super.getVideos(forceReloadFromApi));
  }

  @override
  String toString() {
    return '''
videoList: ${videoList}
    ''';
  }
}
