// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AssetStore on _AssetStore, Store {
  final _$assetsSearchProgressAtom =
      Atom(name: '_AssetStore.assetsSearchProgress');

  @override
  AssetSearchProgress get assetsSearchProgress {
    _$assetsSearchProgressAtom.reportRead();
    return super.assetsSearchProgress;
  }

  @override
  set assetsSearchProgress(AssetSearchProgress value) {
    _$assetsSearchProgressAtom.reportWrite(value, super.assetsSearchProgress,
        () {
      super.assetsSearchProgress = value;
    });
  }

  final _$getAssetsAsyncAction = AsyncAction('_AssetStore.getAssets');

  @override
  Future<void> getAssets(bool forceReloadFromApi) {
    return _$getAssetsAsyncAction
        .run(() => super.getAssets(forceReloadFromApi));
  }

  @override
  String toString() {
    return '''
assetsSearchProgress: ${assetsSearchProgress}
    ''';
  }
}
