package com.codeinsight.snap_crescent.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.codeinsight.snap_crescent.security.UserAuthDetailsService;

@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

	@Autowired
	private RestAuthenticationEntryPoint authenticationEntryPoint;
	
	@Autowired
	private RestLogoutSuccessHandler logoutSuccessHandler;
	
	@Autowired
	private CustomWebAuthenticationDetailsSource authenticationDetailsSource;
	
	@Autowired
	private RestAuthenticationSuccessHandler restAuthenticationSuccessHandler;
	
	@Autowired
	private RestAuthenticationFailureHandler restAuthenticationFailureHandler;
	
	@Autowired
	private UserAuthDetailsService userDetailsService;
	@Override
	protected void configure(AuthenticationManagerBuilder auth) throws Exception {
		auth.userDetailsService(userDetailsService);
	}
	
	@Bean
	@Override
	public AuthenticationManager authenticationManagerBean() throws Exception {
		return super.authenticationManagerBean();
	}
	
	@Override
	protected void configure(HttpSecurity http) throws Exception {
		
		http
		.cors()
		.and()
		.csrf().disable()
		.exceptionHandling().authenticationEntryPoint(authenticationEntryPoint)
		.and()
		.sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
		.and()
		.authorizeRequests()
		.antMatchers(HttpMethod.OPTIONS).permitAll()
		.antMatchers("/").permitAll()
		.antMatchers("/*.html").permitAll()
		.antMatchers("/static/**").permitAll()
		.antMatchers("/favicon.ico").permitAll()
		.antMatchers("/manifest.json").permitAll()
		.antMatchers("/**/*.html").permitAll()
		.antMatchers("/**/*.css").permitAll()
		.antMatchers("/**/*.js").permitAll()
		.antMatchers("/**/*.js.map").permitAll()
		.antMatchers("/**/*.png").permitAll()
		.antMatchers("/**/*.gif").permitAll()
		.antMatchers("/user-exists").permitAll()
		.antMatchers("/sign-up").permitAll()
		.antMatchers("/logout").permitAll();
		http.formLogin().authenticationDetailsSource(authenticationDetailsSource).loginPage("/login").permitAll();

		http.logout().logoutUrl("/logout").logoutSuccessHandler(logoutSuccessHandler);

		http.authorizeRequests().anyRequest().authenticated();

		http.addFilter(jwtAuthorizationFilter());
		http.addFilterBefore(authenticationFilter(), UsernamePasswordAuthenticationFilter.class);
	}
	
	@Bean
	public JwtAuthorizationFilter jwtAuthorizationFilter() throws Exception {

		JwtAuthorizationFilter jwtAuthorizationFilter = new JwtAuthorizationFilter(authenticationManagerBean());

		return jwtAuthorizationFilter;
	}
	
	@Bean
	public RestUsernamePasswordAuthenticationFilter authenticationFilter() throws Exception {

		RestUsernamePasswordAuthenticationFilter authFilter = new RestUsernamePasswordAuthenticationFilter();

		authFilter.setRequiresAuthenticationRequestMatcher(new AntPathRequestMatcher("/login", "POST"));
		authFilter.setAuthenticationManager(authenticationManagerBean());
		authFilter.setAuthenticationSuccessHandler(restAuthenticationSuccessHandler);
		authFilter.setAuthenticationFailureHandler(restAuthenticationFailureHandler);
		authFilter.setUsernameParameter("username");
		authFilter.setPasswordParameter("password");
		authFilter.setAuthenticationDetailsSource(authenticationDetailsSource);

		return authFilter;
	}
	
	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}
	
	@Bean
	public WebMvcConfigurer corsConfigurer() {
		return new WebMvcConfigurer() {
			@Override
			public void addCorsMappings(CorsRegistry registry) {
				registry.addMapping("/**").allowedOrigins("*");
			}
		};
	}
}
