package com.snapcrescent.appConfig;

import com.snapcrescent.common.beans.BaseResponseBean;

public interface AppConfigService {
	
	public String getValue(String key) throws Exception;

	BaseResponseBean<Long, UiAppConfig> search();

}
