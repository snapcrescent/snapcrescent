package com.codeinsight.snap_crescent.appConfig;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

}
