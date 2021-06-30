package com.codeinsight.snap_crescent.common.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AuthenticationController {

	@Autowired
	private CoreService coreService;

	@GetMapping("/authentication")
	public @ResponseBody ResponseEntity<?> getAuthenticationInfoForSession() {

		try {
			return ResponseEntity.ok(coreService.getSessionInfo());
		} catch (Exception e) {
			return ResponseEntity.badRequest().body(e.getLocalizedMessage());

		}
	}
}
