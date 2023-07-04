package com.snapcrescent.config.dao;

import javax.sql.DataSource;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import com.snapcrescent.config.EnvironmentProperties;

import jakarta.annotation.PostConstruct;

@Configuration
public class DataSourceConfig {

	@PostConstruct
	private void init() {

	}
	
	@Bean
	public DataSource dataSource(){
	    DriverManagerDataSource dataSource = new DriverManagerDataSource();
	    dataSource.setDriverClassName("com.mysql.cj.jdbc.Driver");
	    dataSource.setUrl(EnvironmentProperties.SQL_URL);
	    dataSource.setUsername(EnvironmentProperties.SQL_USER);
	    dataSource.setPassword(EnvironmentProperties.SQL_PASSWORD);
	    return dataSource;
	}

}
