package com.codeinsight.snap_crescent.config;

import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.orm.hibernate5.HibernateTemplate;
import org.springframework.orm.hibernate5.LocalSessionFactoryBean;

import com.codeinsight.snap_crescent.common.utils.Constant;

@Configuration
public class DataSourceConfig {

	
	private static final String HIBERNATE_SHOW_SQL = "false";
	private static final  String HIBERNATE_HBM2DDL_AUTO = "update";
	
	
	@Autowired
	private DaoSQLEntityInterceptor daoSQLEntityInterceptor;
	
	@PostConstruct
	private void init() {
		
	}

	@Bean
	public DataSource dataSource() {
		DataSourceBuilder<?> dataSourceBuilder = DataSourceBuilder.create();

		if (EnvironmentProperties.SQL_DB_TYPE.equalsIgnoreCase(Constant.DB_MYSQL)) {
			dataSourceBuilder.url(EnvironmentProperties.SQL_URL);
			dataSourceBuilder.username(EnvironmentProperties.SQL_USER);
			dataSourceBuilder.password(EnvironmentProperties.SQL_PASSWORD);

		} else {
			dataSourceBuilder.url(EnvironmentProperties.SQL_URL);
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
		
		String hibernateDialect = null;
		
		switch (EnvironmentProperties.SQL_DB_TYPE) {
		case Constant.DB_MYSQL:
			hibernateDialect = "org.hibernate.dialect.MySQL5InnoDBDialect";
			break;
		case Constant.DB_SQLITE:
			hibernateDialect = "com.codeinsight.snap_crescent.config.SqliteDialect";
			break;
		default:
			break;
		}
		
		properties.put("hibernate.dialect", hibernateDialect);
		
		properties.put("hibernate.show_sql", HIBERNATE_SHOW_SQL);
		properties.put("hibernate.hbm2ddl.auto", HIBERNATE_HBM2DDL_AUTO);
		properties.put("hibernate.physical_naming_strategy", DaoSQLImprovedNamingStrategy.class.getPackage().getName() + "." + DaoSQLImprovedNamingStrategy.class.getSimpleName());
		properties.put("hibernate.enable_lazy_load_no_trans", "true");
		

		return properties;
	}
}
