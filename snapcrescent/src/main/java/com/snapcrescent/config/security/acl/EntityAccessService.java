package com.snapcrescent.config.security.acl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.common.services.BaseService;

@Service
public class EntityAccessService extends BaseService{

	@Autowired
	private EntityAccessRepository entityAccessRepository;

	@Transactional(readOnly = true)
	public void checkHasAccess(Class<?> targetEntity, Long targetEntityId) throws AccessDeniedException {

		boolean hasAccess = false;

		if (targetEntity.getSuperclass().equals(BaseEntity.class)) {
			
			String query = targetEntity.getAnnotation(AccessControlQuery.class).query();
			
			hasAccess = entityAccessRepository.checkHasAccess(query, targetEntityId, coreService.getAppUserId());
			 
		}

		if (hasAccess == false) {
			throw new AccessDeniedException("");
		}
	}
}
