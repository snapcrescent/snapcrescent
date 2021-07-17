import 'package:snap_crescent/models/base_model.dart';
import 'package:snap_crescent/models/location.dart';

class PhotoMetadata extends BaseUiBean {
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
      bean,
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
      this.base64EncodedPhoto})
      : super(
            id: bean.id,
            version: bean.version,
            creationDatetime: bean.creationDatetime,
            lastModifiedDatetime: bean.lastModifiedDatetime,
            active: bean.active);

  factory PhotoMetadata.fromJson(Map<String, dynamic> json) {
    return PhotoMetadata(
        bean: BaseUiBean.fromJson(json),
        name: json['name'],
        size: json['size'],
        fileTypeName: json['fileTypeName'],
        fileTypeLongName: json['fileTypeLongName'],
        mimeType: json['mimeType'],
        fileExtension: json['fileExtension'],
        model: json['model'],
        height: json['height'],
        width: json['width'],
        orientation: json['orientation'],
        fstop: json['fstop'],
        location: json['location'] == null
            ? null
            : Location.fromJson(json['location']),
        locationId: json['locationId'],
        base64EncodedPhoto: json['base64EncodedPhoto']);
  }

  factory PhotoMetadata.fromMap(Map<String, dynamic> map) {
    return PhotoMetadata(
        bean: BaseUiBean.fromMap(map),
        name: map['NAME'],
        size: map['SIZE'],
        fileTypeName: map['FILE_TYPE_NAME'],
        fileTypeLongName: map['FILE_TYPE_LONG_NAME'],
        mimeType: map['MIME_TYPE'],
        fileExtension: map['FILE_EXTENSION'],
        model: map['MODEL'],
        height: map['HEIGHT'],
        width: map['WIDTH'],
        orientation: map['ORIENTATION'],
        fstop: map['FSTOP'],
        locationId: map['LOCATION_ID']
        );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['NAME'] = name;
    map['SIZE'] = size;
    map['FILE_TYPE_NAME'] = fileTypeName;
    map['FILE_TYPE_LONG_NAME'] = fileTypeLongName;
    map['MIME_TYPE'] = mimeType;
    map['FILE_EXTENSION'] = fileExtension;
    map['MODEL'] = model;
    map['HEIGHT'] = height;
    map['WIDTH'] = width;
    map['ORIENTATION'] = orientation;
    map['FSTOP'] = fstop;
    map['LOCATION_ID'] = locationId;

    return map;
  }
}
