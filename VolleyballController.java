package com.sportsinfo.sports;
import com.sportsinfo.common.ApiResponse; import com.sportsinfo.common.LeagueTableDTO; import com.sportsinfo.common.LiveMatchDTO; import org.springframework.http.ResponseEntity; import org.springframework.web.bind.annotation.*; import java.time.OffsetDateTime; import java.util.List; import java.util.Map;
@RestController @RequestMapping("/api/volleyball") public class VolleyballController {
  @GetMapping("/matches/live") public ResponseEntity<ApiResponse<List<LiveMatchDTO>>> live(){ LiveMatchDTO m = new LiveMatchDTO("Vôlei","Superliga","Time A","Time B","LIVE","1-0",OffsetDateTime.now(), Map.of("notes","Dados de exemplo - substituir por integração real")); return ResponseEntity.ok(ApiResponse.ok(List.of(m))); }
  @GetMapping("/leagues") public ResponseEntity<ApiResponse<List<LeagueTableDTO>>> table(){ LeagueTableDTO t = new LeagueTableDTO("Superliga", List.of(new LeagueTableDTO.Row(1,"Time A",10,7,2,1,23), new LeagueTableDTO.Row(2,"Time B",10,7,1,2,22))); return ResponseEntity.ok(ApiResponse.ok(List.of(t))); }
  @GetMapping("/stats/top") public ResponseEntity<ApiResponse<Map<String,Object>>> topStats(){ return ResponseEntity.ok(ApiResponse.ok(Map.of("leaders", List.of(Map.of("name","Atleta 1","metric","valor"), Map.of("name","Atleta 2","metric","valor"))))); }
  @GetMapping("/extras") public ResponseEntity<ApiResponse<Map<String,Object>>> extras(){ return ResponseEntity.ok(ApiResponse.ok(Map.of("example","Conteúdo extra específico de Vôlei"))); }
}
