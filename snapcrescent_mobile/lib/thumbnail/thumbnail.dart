import 'dart:io';

import 'package:snapcrescent_mobile/common/model/base_model.dart';


class Thumbnail extends BaseUiBean {
  String? name;
  File? thumbnailFile;  


  Thumbnail(
      {
      bean,
      this.name
      })
      : super(
            id: bean.id);

  factory Thumbnail.fromJson(Map<String, dynamic> json) {

    return Thumbnail(
        bean: BaseUiBean.fromJson(json),
        name: json['name']
        );
  }

  factory Thumbnail.fromMap(Map<String, dynamic> map) {

    return Thumbnail(
        bean:  BaseUiBean.fromMap(map),
        name: map['NAME']
        );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['NAME'] = name;
    
    return map;
  }
}
