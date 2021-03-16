package com.codeinsight.snap_crescent.config;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import com.codeinsight.snap_crescent.utils.Constant;

@Configuration
public class DataSourceConfig {

	@Autowired
	private Environment environment;

	@Bean
	public DataSource getDataSource() {
		DataSourceBuilder<?> dataSourceBuilder = DataSourceBuilder.create();

		if (System.getenv("ENV").equalsIgnoreCase(Constant.DB_MYSQL)) {
			dataSourceBuilder.driverClassName(environment.getProperty("SQL_DRIVER"));
			dataSourceBuilder.url(System.getenv("SQL_URL"));
			dataSourceBuilder.username(System.getenv("SQL_USER"));
			dataSourceBuilder.password(System.getenv("SQL_PASSWORD"));

		} else {
			dataSourceBuilder.url(environment.getProperty("SQLITE_URL"));
			dataSourceBuilder.driverClassName(environment.getProperty("SQLITE_DRIVER"));
		}
		return dataSourceBuilder.build();
	}
}
