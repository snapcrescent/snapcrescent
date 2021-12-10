// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_process_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SyncProcessStore on _SyncProcessStore, Store {
  final _$syncProgressStateAtom =
      Atom(name: '_SyncProcessStore.syncProgressState');

  @override
  SyncProgress get syncProgressState {
    _$syncProgressStateAtom.reportRead();
    return super.syncProgressState;
  }

  @override
  set syncProgressState(SyncProgress value) {
    _$syncProgressStateAtom.reportWrite(value, super.syncProgressState, () {
      super.syncProgressState = value;
    });
  }

  final _$startSyncProcessAsyncAction =
      AsyncAction('_SyncProcessStore.startSyncProcess');

  @override
  Future<SyncProgress> startSyncProcess() {
    return _$startSyncProcessAsyncAction.run(() => super.startSyncProcess());
  }

  @override
  String toString() {
    return '''
syncProgressState: ${syncProgressState}
    ''';
  }
}
