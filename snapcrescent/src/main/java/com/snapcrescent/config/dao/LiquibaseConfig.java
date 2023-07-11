package com.snapcrescent.config.dao;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import liquibase.integration.spring.SpringLiquibase;

@Configuration
public class LiquibaseConfig {
	
	@Autowired
	private DataSource dataSource;
		
	@Bean
	public SpringLiquibase springLiquibase() {
		SpringLiquibase liquibase = new SpringLiquibase();
		
		liquibase.setDataSource(dataSource);
		liquibase.setChangeLog("db/changelog/master.changelog.xml");
		liquibase.setDatabaseChangeLogTable("database_change_log");
		liquibase.setDatabaseChangeLogLockTable("database_change_log_lock");
		
		return liquibase;
	}

}
