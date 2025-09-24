package com.sportsinfo.security;
import jakarta.servlet.*; import jakarta.servlet.http.*; import org.springframework.http.HttpHeaders; import org.springframework.security.authentication.UsernamePasswordAuthenticationToken; import org.springframework.security.core.context.SecurityContextHolder; import org.springframework.security.core.userdetails.*; import org.springframework.security.web.authentication.WebAuthenticationDetailsSource; import org.springframework.stereotype.Component; import org.springframework.web.filter.OncePerRequestFilter; import java.io.IOException;
@Component public class JwtAuthenticationFilter extends OncePerRequestFilter {
  private final JwtService jwt; private final UserDetailsService uds; public JwtAuthenticationFilter(JwtService jwt, UserDetailsService uds){ this.jwt=jwt; this.uds=uds; }
  @Override protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain) throws ServletException, IOException {
    String h = req.getHeader(HttpHeaders.AUTHORIZATION); if (h==null || !h.startsWith("Bearer ")) { chain.doFilter(req,res); return; }
    String token = h.substring(7); String username; try{ username = jwt.extractUsername(token);}catch(Exception e){ chain.doFilter(req,res); return; }
    if (username!=null && SecurityContextHolder.getContext().getAuthentication()==null){ UserDetails ud = uds.loadUserByUsername(username); if (jwt.isTokenValid(token, ud.getUsername())){ var auth = new UsernamePasswordAuthenticationToken(ud, null, ud.getAuthorities()); auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(req)); SecurityContextHolder.getContext().setAuthentication(auth);} }
    chain.doFilter(req,res);
  }
}
