package com.snapcrescent.config;

import java.util.Properties;

import javax.sql.DataSource;

import org.hibernate.boot.model.naming.CamelCaseToUnderscoresNamingStrategy;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.dao.annotation.PersistenceExceptionTranslationPostProcessor;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.JpaVendorAdapter;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import jakarta.annotation.PostConstruct;

@Configuration
@EnableTransactionManagement
public class DataSourceConfig {

	@PostConstruct
	private void init() {

	}
	
	@Bean
	public LocalContainerEntityManagerFactoryBean entityManagerFactory() {
		LocalContainerEntityManagerFactoryBean entityManagerFactoryBean = new LocalContainerEntityManagerFactoryBean();
		entityManagerFactoryBean.setDataSource(dataSource());
		entityManagerFactoryBean.setPackagesToScan("com.snapcrescent");
		
		
		JpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
		entityManagerFactoryBean.setJpaVendorAdapter(vendorAdapter);
		entityManagerFactoryBean.setJpaProperties(hibernateProperties());

		return entityManagerFactoryBean;
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
	
	@Bean
	public PlatformTransactionManager transactionManager() {
	    JpaTransactionManager transactionManager = new JpaTransactionManager();
	    transactionManager.setEntityManagerFactory(entityManagerFactory().getObject());

	    return transactionManager;
	}

	@Bean
	public PersistenceExceptionTranslationPostProcessor exceptionTranslation(){
	    return new PersistenceExceptionTranslationPostProcessor();
	}

	Properties hibernateProperties() {
	    Properties properties = new Properties();
	    properties.setProperty("hibernate.hbm2ddl.auto", "validate");
	    properties.setProperty("hibernate.dialect", "org.hibernate.dialect.MySQL8Dialect");
	    properties.setProperty("hibernate.ejb.interceptor", DaoSQLEntityInterceptor.class.getPackage().getName() + "." + DaoSQLEntityInterceptor.class.getSimpleName());
        properties.put("hibernate.physical_naming_strategy", CamelCaseToUnderscoresNamingStrategy.class.getPackage().getName() + "." + CamelCaseToUnderscoresNamingStrategy.class.getSimpleName());
	       
	    return properties;
	}

}
