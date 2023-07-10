package com.snapcrescent.config.security.acl;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.security.CoreService;

@Aspect
@Component
public class EntityAccessAspect {
	
	@Autowired
	private EntityAccessService entityAccessService;
	
	@Autowired
	private CoreService coreService;
	
	@Before(value = "execution(public * *(..)) && @annotation(authorizeURL)", argNames = "authorizeURL")
	public void validate(JoinPoint joinPoint, AuthorizeURL authorizeURL) {

		try {
			Class<?> targetEntity = authorizeURL.targetEntity();
			
			if(joinPoint.getArgs()[0] instanceof Long)
			{
				Long targetEntityId = (Long) joinPoint.getArgs()[0];
				entityAccessService.checkHasAccess(targetEntity, targetEntityId);
			}
			else{
				throw new ClassCastException();
			}
			
		} catch (ClassCastException cce) {
			throw new ClassCastException(
					"Parameter at index 1 for the method on which the aspect is woven must be String and should be the entity ID for which we are authenticating");

		} catch (AccessDeniedException e) {
			throw new AccessDeniedException("Unauthorized access apttempted by user with ID :  " + coreService.getAppUser().getId());
		}

	}

}
