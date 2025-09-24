package com.sportsinfo.config;
import io.swagger.v3.oas.models.*; import io.swagger.v3.oas.models.info.Info; import org.springframework.context.annotation.*;
@Configuration public class OpenApiConfig { @Bean public OpenAPI openAPI(){ return new OpenAPI().info(new Info().title("Sports Info API").version("v0.2.0").description("API para App de Informações Esportivas")); } }
