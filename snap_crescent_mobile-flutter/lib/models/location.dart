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
      {
      bean,
      this.longitude,
      this.latitude,
      this.country,
      this.state,
      this.city,
      this.town})
      : super(
            id: bean.id,
            version: bean.version,
            creationDatetime: bean.creationDatetime,
            lastModifiedDatetime: bean.lastModifiedDatetime,
            active: bean.active);

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
        bean: BaseUiBean.fromJson(json),
        longitude: json['longitude'],
        latitude: json['latitude'],
        country: json['country'],
        state: json['state'],
        city: json['city'],
        town: json['town']);
  }
}
