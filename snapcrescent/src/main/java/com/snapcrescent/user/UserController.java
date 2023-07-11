package com.snapcrescent.user;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.DeleteMapping;
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
import com.snapcrescent.common.utils.Constant;

@RestController
public class UserController extends BaseController{

	@Autowired
	private UserService userService;
	
	@Autowired
	private UserValidator userValidator;
	
	@PreAuthorize(Constant.HAS_ROLE_ADMIN)
	@GetMapping("/user")
	public @ResponseBody BaseResponseBean<Long, UiUser> search(@RequestParam Map<String, String> searchParams) {
		UserSearchCriteria searchCriteria = new UserSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		return userService.search(searchCriteria);

	}
	
	private void parseSearchParams(Map<String, String> searchParams, UserSearchCriteria searchCriteria) {

		parseCommonSearchParams(searchParams, searchCriteria);

	}
	
	@PreAuthorize(Constant.HAS_ROLE_ADMIN)
	@GetMapping("/user/{id}")
	public @ResponseBody BaseResponseBean<Long, UiUser> get(@PathVariable Long id) {
		BaseResponseBean<Long, UiUser> response = new BaseResponseBean<>();

		try {
			response.setObjectId(id);
			response.setObject(userService.getById(id));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return response;
	}

	@PreAuthorize(Constant.HAS_ROLE_ADMIN)
	@PostMapping(path = "/user")
	public @ResponseBody BaseResponseBean<Long, UiUser> save(@RequestBody UiUser user) {
		BaseResponseBean<Long, UiUser> response = new BaseResponseBean<>();
		
		try {
			UiUser savedUser = userService.save(user);
			
			response.setObjectId(savedUser.getId());
			response.setObject(userService.getById(savedUser.getId()));
		} catch (Exception exception) {
			exception.printStackTrace();
			response.setSuccess(false);
		}
		
		return response;

	}
	
	@PreAuthorize(Constant.HAS_ROLE_ADMIN)
	@PutMapping(value = "/user/{id}")
	public @ResponseBody BaseResponseBean<Long, UiUser> update(@PathVariable Long id, @RequestBody UiUser user) {
		BaseResponseBean<Long, UiUser> response = new BaseResponseBean<>();

		try {
			user.setId(id);
			userService.update(user);

			response.setObjectId(id);
			response.setObject(userService.getById(id));

		} catch (Exception e) {
			e.printStackTrace();
			response.setSuccess(false);
		}
		return response;

	}
	
	@PreAuthorize(Constant.HAS_ROLE_ADMIN)
	@DeleteMapping(value = "/user/{id}")
	public BaseResponseBean<Long, UiUser> delete(@PathVariable Long id) {
		BaseResponseBean<Long, UiUser> response = new BaseResponseBean<>();

		try {
			userService.delete(id);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return response;
	}
	
	@PreAuthorize(Constant.HAS_ROLE_ADMIN)
	@PostMapping(value = "/user/validate")
	public BaseResponseBean<Long, ObjectError> validate(@RequestBody UiUser user, BindingResult result) {
		BaseResponseBean<Long, ObjectError> response = new BaseResponseBean<>();

		try {
			userValidator.validate(user, result);

			response.setSuccess(!result.hasErrors());
			response.setObjects(result.getAllErrors());
		
		} catch (Exception e) {
			e.printStackTrace();
			response.setSuccess(false);
		}
		return response;
	}
	
	@PutMapping(value = "/user/{id}/reset-password")
	public BaseResponseBean<Long, Boolean> resetPassword(@PathVariable Long id, @RequestBody UiUser user) {
		BaseResponseBean<Long, Boolean> response = new BaseResponseBean<>();

		try {
			user.setId(id);
			userService.resetPassword(user);

		} catch (Exception e) {
			e.printStackTrace();
			response.setSuccess(false);
		}
		return response;
	}
}
