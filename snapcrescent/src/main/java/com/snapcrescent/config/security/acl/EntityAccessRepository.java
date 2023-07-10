package com.snapcrescent.config.security.acl;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.common.BaseRepository;

import jakarta.persistence.TypedQuery;

@Repository
public class EntityAccessRepository extends BaseRepository<BaseEntity> {
	
	public EntityAccessRepository() {
		super(BaseEntity.class);
	}

	
	public boolean checkHasAccess(String query, Long targetEntityId , Long userId) {
		boolean hasAccess = false;
		if (!query.isEmpty()) {
			TypedQuery<Long> typedQuery = entityManager.createQuery(query,Long.class);
			typedQuery.setParameter("targetEntityId", targetEntityId);
			typedQuery.setParameter("userId", userId);

			if (typedQuery.getResultList().size() > 0) {
				hasAccess = true;
			}
		}
		return hasAccess;
	}

}
