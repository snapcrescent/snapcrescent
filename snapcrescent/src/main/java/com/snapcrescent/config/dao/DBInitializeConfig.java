package com.snapcrescent.config.dao;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;

import com.snapcrescent.common.utils.Constant;

@Configuration
public class DBInitializeConfig implements CommandLineRunner {

	@Autowired
	private DataSource dataSource;

	@Override
	public void run(String... args) throws Exception {
		initialize();
	}

	public void initialize() {
	
		try {
			Resource adminCreatedByUserIdResource = new ByteArrayResource(("UPDATE user SET created_by_user_id='"
					+ Constant.DEFAULT_ADMIN_USER_ID + "' WHERE id = 1").getBytes());
			ResourceDatabasePopulator adminPasswordPopulator = new ResourceDatabasePopulator(adminCreatedByUserIdResource);
			adminPasswordPopulator.execute(dataSource);

		} catch (Exception e) {
			e.printStackTrace();
		}

	}
}
