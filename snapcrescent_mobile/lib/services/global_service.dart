

import 'package:isolate_pool_2/isolate_pool_2.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';

class GlobalService extends BaseService {

  GlobalService._privateConstructor():super();
  static final GlobalService instance = GlobalService._privateConstructor();

  int bottomNavigationBarIndex = 0;
  var pool = IsolatePool(6);
  

  
}
