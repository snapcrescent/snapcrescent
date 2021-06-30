import 'package:snap_crescent/models/base_model.dart';

class Thumbnail extends BaseUiBean{
  String? name;
  String? base64EncodedThumbnail;

   Thumbnail(
    {
            id,
            version,
            creationDatetime,
            lastModifiedDatetime,
            active,
            this.name,
            this.base64EncodedThumbnail
            }): super(
            id: id,
            version: version,
            creationDatetime: creationDatetime,
            lastModifiedDatetime: lastModifiedDatetime,
            active: active);

    factory Thumbnail.fromJson(Map<String, dynamic> json) {
      return Thumbnail(
        id : json['id'],
        version : json['version'],
        creationDatetime : json['creationDatetime'],
        lastModifiedDatetime : json['lastModifiedDatetime'],
        active : json['active'],
        name : json['name'],
        base64EncodedThumbnail : json['base64EncodedThumbnail']
      );
    }

    factory Thumbnail.fromMap(Map<String, dynamic> map) {
      return Thumbnail(
        id : map['ID'],
        version : map['VERSION'],
        creationDatetime : map['CREATION_DATETIME'],
        lastModifiedDatetime : map['LAST_MODIFIED_DATETIME'],
        active : map['ACTIVE'] == 1 ? true : false,
        name : map['NAME'],
        base64EncodedThumbnail : map['BASE_64_ENCODED_THUMBNAIL']
      );
   }

  Map<String,dynamic> toMap() {
    return {
      'ID':id,
      'VERSION':version,
      'CREATION_DATETIME':creationDatetime,
      'LAST_MODIFIED_DATETIME':lastModifiedDatetime,
      'ACTIVE':active == true ? 1 : 0,
      'NAME':name,
      'BASE_64_ENCODED_THUMBNAIL':base64EncodedThumbnail,
    };
  }
}