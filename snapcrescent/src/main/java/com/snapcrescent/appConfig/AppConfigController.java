package com.snapcrescent.appConfig;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.snapcrescent.common.beans.BaseResponseBean;

@RestController
public class AppConfigController {
	
	@Autowired
	private AppConfigService appConfigService;
	
	@GetMapping("/app-config")
	public BaseResponseBean<Long, UiAppConfig> search() {
		return appConfigService.search();
	}

}
