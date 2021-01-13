package com.codeinsight.snap_crescent.appConfig;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;

@RepositoryRestResource(exported = false)
public interface AppConfigRepository extends JpaRepository<AppConfig, Long>, QuerydslPredicateExecutor<AppConfig> {

	@RestResource(exported = false)
	public Optional<AppConfig> findByConfigKey(@Param("configKey") String configKey);
}
