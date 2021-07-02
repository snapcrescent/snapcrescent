class AppConfig  {
  
  String? configkey;
  String? configValue;

  AppConfig  (
      {this.configkey,
      this.configValue,
      });


  factory AppConfig.fromMap(Map<String, dynamic> map) {
      return AppConfig(
        configkey : map['CONFIG_KEY'],
        configValue : map['CONFIG_VALUE']
      );

   }

  Map<String,dynamic> toMap() {
    Map<String,dynamic> map =  new Map();

    map['CONFIG_KEY'] = configkey;
    map['CONFIG_VALUE'] = configValue;

    return map;
  }
}
