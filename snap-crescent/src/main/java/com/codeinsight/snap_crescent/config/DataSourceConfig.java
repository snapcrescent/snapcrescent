package com.codeinsight.snap_crescent.config;

import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.orm.hibernate5.HibernateTemplate;
import org.springframework.orm.hibernate5.LocalSessionFactoryBean;

import com.codeinsight.snap_crescent.common.utils.Constant;

@Configuration
public class DataSourceConfig {

	@Autowired
	private Environment environment;
	
	private static final String HIBERNATE_SHOW_SQL = "false";
	private static final  String HIBERNATE_HBM2DDL_AUTO = "update";
	
	private String HIBERNATE_DIALECT;
	
	@Autowired
	private DaoSQLEntityInterceptor daoSQLEntityInterceptor;
	
	@PostConstruct
	private void init() {
		switch (System.getenv("ENV")) {
		case Constant.DB_MYSQL:
			HIBERNATE_DIALECT = "org.hibernate.dialect.MySQL5InnoDBDialect";
			break;
		case Constant.DB_SQLITE:
			HIBERNATE_DIALECT = "com.codeinsight.snap_crescent.config.SqliteDialect";
			break;
		default:
			break;
		}
	}

	@Bean
	public DataSource dataSource() {
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
	
	@Bean
	public HibernateTemplate hibernateTemplate(SessionFactory sessionFactory) {
		HibernateTemplate hibernateTemplate = new HibernateTemplate(sessionFactory);
		hibernateTemplate.setCheckWriteOperations(false);
		return hibernateTemplate;
	}
	
	@Bean
	public LocalSessionFactoryBean getSessionFactory(DataSource dataSource) {
		LocalSessionFactoryBean sessionFactoryBean = new LocalSessionFactoryBean();
		sessionFactoryBean.setDataSource(dataSource);
		sessionFactoryBean.setHibernateProperties(getHibernateProperties());
		sessionFactoryBean.setPhysicalNamingStrategy(new DaoSQLImprovedNamingStrategy());
		sessionFactoryBean.setPackagesToScan(new String[] { "com.codeinsight.snap_crescent" });
		sessionFactoryBean.setEntityInterceptor(daoSQLEntityInterceptor);
		return sessionFactoryBean;
	}

	@Bean
	public Properties getHibernateProperties() {
		Properties properties = new Properties();
		properties.put("hibernate.default_schema", "dbo");
		properties.put("hibernate.dialect", HIBERNATE_DIALECT);
		properties.put("hibernate.show_sql", HIBERNATE_SHOW_SQL);
		properties.put("hibernate.hbm2ddl.auto", HIBERNATE_HBM2DDL_AUTO);
		properties.put("hibernate.physical_naming_strategy", DaoSQLImprovedNamingStrategy.class.getPackage().getName() + "." + DaoSQLImprovedNamingStrategy.class.getSimpleName());
		properties.put("hibernate.enable_lazy_load_no_trans", "true");
		

		return properties;
	}
}
