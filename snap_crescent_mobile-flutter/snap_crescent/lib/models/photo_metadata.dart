import 'package:snap_crescent/models/base_model.dart';
import 'package:snap_crescent/models/location.dart';

class PhotoMetadata extends BaseUiBean{
  String? name;
  String? size;
  String? fileTypeName;
	String? fileTypeLongName;
  String? mimeType;
  String? fileExtension;
  String? model;
	String? height;
	String? width;
	int? orientation;	
	String? fstop;
	Location? location;
  int? locationId;
  String? base64EncodedPhoto;

  PhotoMetadata(
    {
            id,
            version,
            creationDatetime,
            lastModifiedDatetime,
            active,
            this.name,
            this.size,
            this.fileTypeName,
            this.fileTypeLongName,
            this.mimeType,
            this.fileExtension,
            this.model,
            this.height,
            this.width,
            this.orientation,
            this.fstop,
            this.location,
            this.locationId,
            this.base64EncodedPhoto
            }): super(
            id: id,
            version: version,
            creationDatetime: creationDatetime,
            lastModifiedDatetime: lastModifiedDatetime,
            active: active);

    factory PhotoMetadata.fromJson(Map<String, dynamic> json) {
      return PhotoMetadata(
        id : json['id'],
        version : json['version'],
        creationDatetime : json['creationDatetime'],
        lastModifiedDatetime : json['lastModifiedDatetime'],
        active : json['active'],
        name : json['name'],
        size : json['size'],
        fileTypeName : json['fileTypeName'],
        fileTypeLongName : json['fileTypeLongName'],
        mimeType : json['mimeType'],
        fileExtension : json['fileExtension'],
        model : json['model'],
        height : json['height'],
        width : json['width'],
        orientation : json['orientation'],
        fstop : json['fstop'],
        location : json['location'] == null ? null : Location.fromJson(json['location']),
        locationId : json['locationId'],
        base64EncodedPhoto : json['base64EncodedPhoto']
      );
    }

    factory PhotoMetadata.fromMap(Map<String, dynamic> map) {
      return PhotoMetadata(
        id : map['ID'],
        version : map['VERSION'],
        creationDatetime : map['CREATION_DATETIME'],
        lastModifiedDatetime : map['LAST_MODIFIED_DATETIME'],
        active : map['ACTIVE'],
        name : map['NAME']
      );
   }

  Map<String,dynamic> toMap() {
    return {
      'ID':id,
      'VERSION':version,
      'CREATION_DATETIME':creationDatetime,
      'LAST_MODIFIED_DATETIME':lastModifiedDatetime,
      'ACTIVE':active,
      'NAME':name
    };
  }

}