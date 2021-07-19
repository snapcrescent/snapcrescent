// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_asset_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LocalAssetStore on _LocalAssetStore, Store {
  final _$groupedAssetsAtom = Atom(name: '_LocalAssetStore.groupedAssets');

  @override
  Map<String, List<AssetEntity>> get groupedAssets {
    _$groupedAssetsAtom.reportRead();
    return super.groupedAssets;
  }

  @override
  set groupedAssets(Map<String, List<AssetEntity>> value) {
    _$groupedAssetsAtom.reportWrite(value, super.groupedAssets, () {
      super.groupedAssets = value;
    });
  }

  final _$getAssetsAsyncAction = AsyncAction('_LocalAssetStore.getAssets');

  @override
  Future<void> getAssets() {
    return _$getAssetsAsyncAction.run(() => super.getAssets());
  }

  @override
  String toString() {
    return '''
groupedAssets: ${groupedAssets}
    ''';
  }
}
