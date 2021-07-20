// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AssetStore on _AssetStore, Store {
  final _$assetListAtom = Atom(name: '_AssetStore.assetList');

  @override
  List<Asset> get assetList {
    _$assetListAtom.reportRead();
    return super.assetList;
  }

  @override
  set assetList(List<Asset> value) {
    _$assetListAtom.reportWrite(value, super.assetList, () {
      super.assetList = value;
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
assetList: ${assetList}
    ''';
  }
}
