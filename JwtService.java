package com.sportsinfo.security;
import io.jsonwebtoken.*; import io.jsonwebtoken.io.Decoders; import io.jsonwebtoken.security.Keys; import org.springframework.beans.factory.annotation.Value; import org.springframework.stereotype.Service; import java.security.Key; import java.util.*; import java.util.function.Function;
@Service public class JwtService { private final String secret; private final long expirationMs; public JwtService(@Value("${jwt.secret}") String secret, @Value("${jwt.expiration}") long expirationMs){ this.secret=secret; this.expirationMs=expirationMs; }
  public String generateToken(String subject, Map<String,Object> claims){ return Jwts.builder().setClaims(claims).setSubject(subject).setIssuedAt(new Date()).setExpiration(new Date(System.currentTimeMillis()+expirationMs)).signWith(getKey(), SignatureAlgorithm.HS256).compact(); }
  public String extractUsername(String token){ return extract(token, Claims::getSubject);} public <T> T extract(String token, Function<Claims,T> fn){ Claims c = Jwts.parserBuilder().setSigningKey(getKey()).build().parseClaimsJws(token).getBody(); return fn.apply(c);} public boolean isTokenValid(String token, String username){ return username.equals(extractUsername(token)) && extract(token, Claims::getExpiration).after(new Date()); }
  private Key getKey(){ return Keys.hmacShaKeyFor(Decoders.BASE64.decode(secret)); }
}
