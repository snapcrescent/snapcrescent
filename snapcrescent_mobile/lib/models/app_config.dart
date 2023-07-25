class AppConfig  {
  
  String? configKey;
  String? configValue;

  AppConfig  (
      {this.configKey,
      this.configValue,
      });


  factory AppConfig.fromMap(Map<String, dynamic> map) {
      return AppConfig(
        configKey : map['CONFIG_KEY'],
        configValue : map['CONFIG_VALUE']
      );

   }

  Map<String,dynamic> toMap() {
    Map<String,dynamic> map =  {};

    map['CONFIG_KEY'] = configKey;
    map['CONFIG_VALUE'] = configValue;

    return map;
  }
}
