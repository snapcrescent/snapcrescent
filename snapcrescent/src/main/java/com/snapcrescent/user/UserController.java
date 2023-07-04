package com.snapcrescent.user;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.snapcrescent.common.BaseController;
import com.snapcrescent.common.beans.BaseResponseBean;

@RestController
public class UserController extends BaseController{

	@Autowired
	private UserService userService;
	
	@GetMapping("/user")
	public @ResponseBody BaseResponseBean<Long, UiUser> search(@RequestParam Map<String, String> searchParams) {
		UserSearchCriteria searchCriteria = new UserSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		return userService.search(searchCriteria);

	}
	
	private void parseSearchParams(Map<String, String> searchParams, UserSearchCriteria searchCriteria) {

		parseCommonSearchParams(searchParams, searchCriteria);

	}

	@PostMapping(path = "/user")
	public @ResponseBody ResponseEntity<?> save(@RequestBody UiUser user) {
		try {
			UiUser savedUser = userService.save(user);
			return ResponseEntity.ok(savedUser);
		} catch (Exception exception) {
			exception.printStackTrace();
			return ResponseEntity.badRequest().body(exception.getLocalizedMessage());
		}

	}
	
	@PutMapping(value = "/user/{id}")
	public @ResponseBody ResponseEntity<?> update(@PathVariable Long id, @RequestBody UiUser user) {
		try {
			userService.update(user);
			return ResponseEntity.ok(user);
		} catch (Exception exception) {
			exception.printStackTrace();
			return ResponseEntity.badRequest().body(exception.getLocalizedMessage());
		}

	}
}
