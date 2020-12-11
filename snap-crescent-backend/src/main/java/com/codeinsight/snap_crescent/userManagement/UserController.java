package com.codeinsight.snap_crescent.userManagement;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.codeinsight.snap_crescent.userManagement.bean.ResetPasswordRequest;
import com.codeinsight.snap_crescent.userManagement.bean.UserLoginBean;

@RestController
public class UserController {

	@Autowired
	private UserService userService;

	@PostMapping(path = "/sign-up")
	public @ResponseBody ResponseEntity<?> save(@RequestBody User user) {
		try {
			User savedUser = userService.saveUser(user);
			return ResponseEntity.ok(savedUser);
		} catch (Exception exception) {
			return ResponseEntity.badRequest().body(exception.getLocalizedMessage());
		}

	}

	@PostMapping(path = "/login")
	public @ResponseBody ResponseEntity<?> login(@RequestBody UserLoginBean userLoginBean) {
		try {
			User user = userService.login(userLoginBean);
			return ResponseEntity.ok(user);
		} catch (Exception exception) {
			return ResponseEntity.badRequest().body(exception.getLocalizedMessage());
		}
	}

	@PutMapping(path = "reset-password")
	public @ResponseBody ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest resetRequest) {
		try {
			String successMessage = userService.resetPassword(resetRequest);
			return ResponseEntity.ok(successMessage);
		} catch (Exception exception) {
			return ResponseEntity.badRequest().body(exception.getLocalizedMessage());
		}
	}
}
