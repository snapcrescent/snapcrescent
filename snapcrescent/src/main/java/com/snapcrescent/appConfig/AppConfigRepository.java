package com.snapcrescent.appConfig;

import java.util.List;

import jakarta.persistence.TypedQuery;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;

@Repository
public class AppConfigRepository extends BaseRepository<AppConfig> {

	public AppConfigRepository() {
		super(AppConfig.class);
	}

	public AppConfig findByConfigKey(String configKey) {
		String query = "SELECT appConfig FROM AppConfig appConfig WHERE appConfig.configKey = :configKey";
		
		TypedQuery<AppConfig> typedQuery = entityManager.createQuery(query,AppConfig.class);
		typedQuery.setParameter("configKey", configKey);
		List<AppConfig> results = typedQuery.getResultList();
		return results.isEmpty() ? null : results.get(0);
	}
}
