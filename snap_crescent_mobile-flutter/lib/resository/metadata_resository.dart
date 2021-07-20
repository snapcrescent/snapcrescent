import 'package:snap_crescent/resository/base_repository.dart';

class MetadataResository extends BaseResository {

  static final _tableName = 'METADATA'; 

  MetadataResository._privateConstructor():super(_tableName);
  static final MetadataResository instance = MetadataResository._privateConstructor();


}