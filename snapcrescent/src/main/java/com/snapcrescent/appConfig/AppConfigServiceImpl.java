package com.snapcrescent.appConfig;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.common.beans.BaseResponseBean;

@Service
public class AppConfigServiceImpl implements AppConfigService {

	@Autowired
	private AppConfigRepository appConfigRepository;

	@Override
	@Transactional
	public String getValue(String key) throws Exception {
		AppConfig value = appConfigRepository.findByConfigKey(key);
		if (value != null) {
			return value.getConfigValue();
		} else {
			return null;
		}
	}
	
	@Override
	@Transactional
	public BaseResponseBean<Long, UiAppConfig> search() {

		BaseResponseBean<Long, UiAppConfig> response = new BaseResponseBean<>();
		
		List<AppConfig> appConfigs = appConfigRepository.findAll();
		
		List<UiAppConfig> appConfigBeans = new ArrayList<>(appConfigs.size());
		
		for (AppConfig entity : appConfigs) {
			UiAppConfig bean = new UiAppConfig();
			
			bean.setConfigKey(entity.getConfigKey());
			bean.setConfigValue(entity.getConfigValue());
			
			appConfigBeans.add(bean);
		}
		
					
		response.setObjects(appConfigBeans);
		
		return response;
	}

}
