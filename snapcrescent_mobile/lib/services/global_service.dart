

import 'package:snapcrescent_mobile/services/base_service.dart';

class GlobalService extends BaseService {

  GlobalService._privateConstructor():super();
  static final GlobalService instance = GlobalService._privateConstructor();

  int bottomNavigationBarIndex = 0;

  
}
