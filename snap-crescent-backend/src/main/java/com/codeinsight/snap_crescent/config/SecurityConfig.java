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
	
	public static final String JWT_TOKEN_HEADER_PARAM = "Authorization";
	public static final String FORM_BASED_LOGIN_ENTRY_POINT = "/volredirect";
	public static final String TOKEN_BASED_AUTH_ENTRY_POINT = "/**";

	public static final String FORM_BASED_LOGOUT_EXIT_POINT = "/logout";

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
		
		http.csrf().disable();
		http.exceptionHandling().authenticationEntryPoint(authenticationEntryPoint);
		http.authorizeRequests().antMatchers(HttpMethod.OPTIONS).permitAll();
		http.sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);

		http.authorizeRequests().antMatchers("/user-exists").permitAll();
		http.authorizeRequests().antMatchers("/logout").permitAll();
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
