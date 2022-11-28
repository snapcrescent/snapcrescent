// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AssetStore on _AssetStore, Store {
  final _$assetSearchProgressAtom =
      Atom(name: '_AssetStore.assetSearchProgress');

  @override
  AssetSearchProgress get assetSearchProgress {
    _$assetSearchProgressAtom.reportRead();
    return super.assetSearchProgress;
  }

  @override
  set assetSearchProgress(AssetSearchProgress value) {
    _$assetSearchProgressAtom.reportWrite(value, super.assetSearchProgress, () {
      super.assetSearchProgress = value;
    });
  }

  final _$loadMoreAssetsAsyncAction = AsyncAction('_AssetStore.loadMoreAssets');

  @override
  Future<void> loadMoreAssets(int pageNumber) {
    return _$loadMoreAssetsAsyncAction
        .run(() => super.loadMoreAssets(pageNumber));
  }

  final _$getAssetsAsyncAction = AsyncAction('_AssetStore.getAssets');

  @override
  Future<void> getAssets(bool clearPreloadedAssets) {
    return _$getAssetsAsyncAction.run(() => super.getAssets(clearPreloadedAssets));
  }

  @override
  String toString() {
    return '''
assetSearchProgress: ${assetSearchProgress}
    ''';
  }
}
