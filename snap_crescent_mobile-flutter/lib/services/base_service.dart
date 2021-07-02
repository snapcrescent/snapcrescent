import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/utils/constants.dart';

class BaseService {
  
  Future<String> getServerUrl() async {
    final result =  await AppConfigResository.instance.findByKey(Constants.appConfigServerURL);
    return Future.value(result.configValue);
  }
  
}
