package com.codeinsight.snap_crescent.config;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.codeinsight.snap_crescent.common.utils.Constant;

@Configuration
public class DBInitializeConfig implements CommandLineRunner {

	@Autowired
	private DataSource dataSource;
	
	@Autowired
	private PasswordEncoder passwordEncoder;
	
	@Override
	public void run(String... args) throws Exception {
		initialize();
	}
	
	public void initialize() {

		try {
			if (EnvironmentProperties.SQL_DB_TYPE.equalsIgnoreCase(Constant.DB_SQLITE)) {
				Resource resource = new ClassPathResource("schema-sqlite.sql");
				ResourceDatabasePopulator databasePopulator = new ResourceDatabasePopulator(resource);
				databasePopulator.execute(dataSource);
			} else {
				Resource resource = new ClassPathResource("schema-sql.sql");
				ResourceDatabasePopulator databasePopulator = new ResourceDatabasePopulator(resource);
				databasePopulator.execute(dataSource);
				
				
				
				Resource adminPasswordResource = new ByteArrayResource(("UPDATE user SET password='" + passwordEncoder.encode(EnvironmentProperties.ADMIN_PASSWORD)  + "' WHERE id = 1").getBytes());
				ResourceDatabasePopulator adminPasswordPopulator = new ResourceDatabasePopulator(adminPasswordResource);
				adminPasswordPopulator.execute(dataSource);
				
			}	
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
}
