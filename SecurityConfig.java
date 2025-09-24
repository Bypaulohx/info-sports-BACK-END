package com.sportsinfo.config;
import com.sportsinfo.security.JwtAuthenticationFilter; import org.springframework.context.annotation.*; import org.springframework.http.HttpMethod; import org.springframework.security.authentication.AuthenticationManager; import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration; import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity; import org.springframework.security.config.annotation.web.builders.HttpSecurity; import org.springframework.security.config.http.SessionCreationPolicy; import org.springframework.security.core.userdetails.UserDetailsService; import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder; import org.springframework.security.crypto.password.PasswordEncoder; import org.springframework.security.web.SecurityFilterChain; import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
@Configuration @EnableMethodSecurity public class SecurityConfig {
  private final JwtAuthenticationFilter jwtFilter; private final UserDetailsService uds;
  public SecurityConfig(JwtAuthenticationFilter jwtFilter, UserDetailsService uds){ this.jwtFilter=jwtFilter; this.uds=uds; }
  @Bean public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http.csrf(csrf->csrf.disable())
      .sessionManagement(sm->sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
      .authorizeHttpRequests(auth->auth
        .requestMatchers("/api/auth/**","/v3/api-docs/**","/swagger-ui.html","/swagger-ui/**","/actuator/health").permitAll()
        .requestMatchers(HttpMethod.GET, "/api/**").permitAll()
        .anyRequest().authenticated())
      .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
    return http.build();
  }
  @Bean public PasswordEncoder passwordEncoder(){ return new BCryptPasswordEncoder(); }
  @Bean public AuthenticationManager authenticationManager(AuthenticationConfiguration c) throws Exception { return c.getAuthenticationManager(); }
}
