import 'package:snap_crescent/models/base_model.dart';

class Location extends BaseUiBean {
  double? longitude;
  double? latitude;
  String? country;
  String? state;
  String? city;
  String? town;
  String? postcode;

  Location(
      {id,
      version,
      creationDatetime,
      lastModifiedDatetime,
      active,
      this.longitude,
      this.latitude,
      this.country,
      this.state,
      this.city,
      this.town})
      : super(
            id: id,
            version: version,
            creationDatetime: creationDatetime,
            lastModifiedDatetime: lastModifiedDatetime,
            active: active);

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
        id: json['id'],
        version: json['version'],
        creationDatetime: json['creationDatetime'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                json['creationDatetime']),
        lastModifiedDatetime: json['lastModifiedDatetime'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                json['lastModifiedDatetime']),
        active: json['active'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        country: json['country'],
        state: json['state'],
        city: json['city'],
        town: json['town']);
  }
}
