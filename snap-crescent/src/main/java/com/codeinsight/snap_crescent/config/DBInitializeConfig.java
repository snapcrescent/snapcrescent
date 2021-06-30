package com.codeinsight.snap_crescent.config;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;

import com.codeinsight.snap_crescent.common.utils.Constant;

@Configuration
public class DBInitializeConfig {

	@Autowired
	private DataSource dataSource;
	
	@PostConstruct
	public void initialize() {

		try {
			if (System.getenv("ENV").equalsIgnoreCase(Constant.DB_SQLITE)) {
				Resource resource = new ClassPathResource("schema-sqlite.sql");
				ResourceDatabasePopulator databasePopulator = new ResourceDatabasePopulator(resource);
				databasePopulator.execute(dataSource);
			} else {
				Resource resource = new ClassPathResource("schema-sql.sql");
				ResourceDatabasePopulator databasePopulator = new ResourceDatabasePopulator(resource);
				databasePopulator.execute(dataSource);
			}	
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
}
