package com.codeinsight.snap_crescent.user;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.codeinsight.snap_crescent.common.beans.ResetPasswordRequest;

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
			exception.printStackTrace();
			return ResponseEntity.badRequest().body(exception.getLocalizedMessage());
		}

	}

	@PostMapping(path = "/reset-password")
	public @ResponseBody ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest resetRequest) {
		try {
			String successMessage = userService.resetPassword(resetRequest);
			return ResponseEntity.ok(successMessage);
		} catch (Exception exception) {
			exception.printStackTrace();
			return ResponseEntity.badRequest().body(exception.getLocalizedMessage());
		}
	}
	
	@GetMapping(path = "/user-exists")
	public @ResponseBody ResponseEntity<?> doesUserExist() {
		try {
			Boolean exist = userService.doesUserExists();
			return ResponseEntity.ok(exist);
		} catch (Exception exception) {
			exception.printStackTrace();
			return ResponseEntity.badRequest().body(exception.getLocalizedMessage());
		}
	}
}
