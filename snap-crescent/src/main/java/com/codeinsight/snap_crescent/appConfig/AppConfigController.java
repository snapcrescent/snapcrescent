package com.codeinsight.snap_crescent.appConfig;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.codeinsight.snap_crescent.utils.AppConfigKeys;
import com.codeinsight.snap_crescent.utils.Constant;

@RestController
public class AppConfigController {
	
	@Autowired
	private AppConfigService appConfigService;
	
	@GetMapping("/config-jwt")
	public ResponseEntity<String> getConfig(HttpServletRequest request) {
		try {
			String host = appConfigService.getValue(AppConfigKeys.APP_CONFIG_KEY_HOST_ADDRESS);
			if(host != null && host.equals(Constant.DEMO_ADDRESS)) {
				return new ResponseEntity<>(appConfigService.getValue(AppConfigKeys.APP_CONFIG_KEY_DEMO_JWT), HttpStatus.OK);
			} else {
				return new ResponseEntity<>(HttpStatus.OK);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

}
