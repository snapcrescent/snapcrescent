package com.codeinsight.snap_crescent.config.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
	
    @Autowired
    private RestLoginEntryPoint loginEntryPoint;
	
	@Autowired
	private RestLogoutSuccessHandler logoutSuccessHandler;

	@Autowired
	private CustomWebAuthenticationDetailsSource authenticationDetailsSource;

	@Autowired
	private RestLoginSuccessHandler restLoginSuccessHandler;

	@Autowired
	private RestLoginFailureHandler restLoginFailureHandler;
	
	@Autowired
	private JwtAuthorizationFilter jwtAuthorizationFilter;

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder(4);
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
	
	/*
	@Bean
    public WebSecurityCustomizer webSecurityCustomizer() {
        return (web) -> web.debug(true);
    }
    */

	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
		
		AuthenticationManagerBuilder authenticationManagerBuilder = http.getSharedObject(AuthenticationManagerBuilder.class);
		AuthenticationManager authenticationManager = authenticationManagerBuilder.build();
		
		http.authenticationManager(authenticationManager);
		
		http.cors();
		http.csrf().disable();
		
		http
        .authorizeHttpRequests((authz) -> 
        	authz
        	.antMatchers(HttpMethod.OPTIONS).permitAll()
        	.antMatchers("/").permitAll()
    		.antMatchers("/public/**").permitAll()
    		.antMatchers("/**/*.html").permitAll()
    		.antMatchers("/**/*.css").permitAll()
    		.antMatchers("/**/*.js").permitAll()
    		.antMatchers("/**/*.js.map").permitAll()
    		.antMatchers("/**/*.png").permitAll()
    		.antMatchers("/**/*.gif").permitAll()
    		.antMatchers("/login").permitAll()
    		.antMatchers("/logout").permitAll()
    		.antMatchers("/file/*").permitAll()
    		.antMatchers("/websocket/**").permitAll()
    		.anyRequest().authenticated()
        );		
	
		http.exceptionHandling().authenticationEntryPoint(loginEntryPoint);
		http.sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);
		
        http.formLogin().authenticationDetailsSource(authenticationDetailsSource).loginPage("/login").permitAll();
		http.logout().logoutUrl("/logout").logoutSuccessHandler(logoutSuccessHandler);
		
		http.addFilterAfter(jwtAuthorizationFilter,UsernamePasswordAuthenticationFilter.class);
		http.addFilterBefore(authenticationFilter(authenticationManager),UsernamePasswordAuthenticationFilter.class);

		
		return http.getOrBuild();
		
	}
	
	public RestUsernamePasswordAuthenticationFilter authenticationFilter(AuthenticationManager authenticationManager)
			throws Exception {

		RestUsernamePasswordAuthenticationFilter authFilter = new RestUsernamePasswordAuthenticationFilter();

		authFilter.setRequiresAuthenticationRequestMatcher(new AntPathRequestMatcher("/login", "POST"));
		authFilter.setAuthenticationManager(authenticationManager);
		authFilter.setAuthenticationSuccessHandler(restLoginSuccessHandler);
		authFilter.setAuthenticationFailureHandler(restLoginFailureHandler);
		authFilter.setUsernameParameter("username");
		authFilter.setPasswordParameter("password");
		authFilter.setAuthenticationDetailsSource(authenticationDetailsSource);

		return authFilter;
	}

	
}
