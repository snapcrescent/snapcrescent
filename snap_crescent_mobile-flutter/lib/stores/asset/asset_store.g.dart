// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AssetStore on _AssetStore, Store {
  final _$assetsCountAtom = Atom(name: '_AssetStore.assetsCount');

  @override
  int get assetsCount {
    _$assetsCountAtom.reportRead();
    return super.assetsCount;
  }

  @override
  set assetsCount(int value) {
    _$assetsCountAtom.reportWrite(value, super.assetsCount, () {
      super.assetsCount = value;
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
assetsCount: ${assetsCount}
    ''';
  }
}
