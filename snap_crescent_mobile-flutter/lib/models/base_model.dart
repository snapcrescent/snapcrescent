class BaseUiBean {
  int? id;
	int? version;
  DateTime? creationDatetime;
	DateTime? lastModifiedDatetime;
  bool? active;

  
  BaseUiBean({
            this.id,
            this.version,
            this.creationDatetime,
            this.lastModifiedDatetime,
            this.active,
            });


  factory BaseUiBean.fromMap(Map<String, dynamic> map) {
      return BaseUiBean(
        id : map['ID'],
        version : map['VERSION'],
        creationDatetime : map['CREATION_DATETIME'],
        lastModifiedDatetime : map['LAST_MODIFIED_DATETIME'],
        active : map['ACTIVE'] == 1 ? true : false
      );
   }

  Map<String,dynamic> toMap() {
    return {
      'ID':id,
      'VERSION':version,
      'CREATION_DATETIME':creationDatetime!.millisecondsSinceEpoch,
      'LAST_MODIFIED_DATETIME':lastModifiedDatetime!.millisecondsSinceEpoch,
      'ACTIVE':active == true ? 1 : 0
    };
  }
            
}