package com.codeinsight.snap_crescent.appConfig;

import java.util.Optional;

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
		Optional<AppConfig> value = appConfigRepository.findByConfigKey(key);
		if (value.isPresent()) {
			return value.get().getConfigValue();
		} else {
			return null;
		}
	}

}
