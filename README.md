# Sports Info – Back-end (Spring Boot + PostgreSQL)

Back-end do aplicativo de Informações Esportivas, construído em **Spring Boot 3** (Java 17), com **PostgreSQL** e versionamento de banco via **Flyway**. Oferece **autenticação JWT**, **usuários e favoritos**, **notificações SSE**, **comunidade** (discussões) e **endpoints por esporte** (MVP com dados mock prontos para trocar por provedores reais). Documentação via **Swagger/OpenAPI**.

---

## Recursos

- **Auth JWT**: registro/login e rotas protegidas
- **Usuários & Preferências**: tema claro/escuro
- **Favoritos**: times, atletas e competições
- **Comunidade**: criação e listagem de discussões
- **Notificações**: canal **SSE** simples
- **Esportes**: endpoints padronizados por modalidade (mock)
- **OpenAPI/Swagger**: documentação interativa

---

## Stack & Dependências

- **Linguagem**: Java 17
- **Framework**: Spring Boot 3.x
- **Módulos Spring**: Web, Security, Validation, Data JPA
- **Banco**: PostgreSQL
- **Migrações**: Flyway
- **JWT**: `io.jsonwebtoken (jjwt)`
- **OpenAPI**: `springdoc-openapi-starter-webmvc-ui`

> Principais artefatos no `pom.xml`:
```xml
<dependency> <groupId>org.postgresql</groupId> <artifactId>postgresql</artifactId> <scope>runtime</scope> </dependency>
<dependency> <groupId>org.flywaydb</groupId> <artifactId>flyway-core</artifactId> </dependency>
<dependency> <groupId>io.jsonwebtoken</groupId> <artifactId>jjwt-api</artifactId> <version>0.11.5</version> </dependency>
<dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-data-jpa</artifactId> </dependency>
<dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring-boot-starter-security</artifactId> </dependency>
<dependency> <groupId>org.springdoc</groupId> <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId> <version>2.5.0</version> </dependency>
```

***

## Como rodar (Modo de Uso)

### 1) Pré‑requisitos

*   **Java 17+**
*   **Maven 3.9+**
*   **PostgreSQL** (local ou via Docker)

### 2) Banco de dados

Com Docker (recomendado – pasta `sports-info-db`):

```bash
cd sports-info-db
docker compose up -d
# Postgres:  localhost:5432 (db: sportsdb, user: sports, pass: sports)
# pgAdmin:   http://localhost:5050 (admin@local / admin)
```

> O banco sobe já com **schema e seeds**; o mesmo conteúdo está nas migrações **Flyway** do projeto back-end.

### 3) Configuração

Arquivo: `src/main/resources/application.yml`

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/sportsdb
    username: sports
    password: sports
  jpa:
    hibernate:
      ddl-auto: validate
  flyway:
    enabled: true
    locations: classpath:db/migration

jwt:
  # base64 de uma chave secreta (troque em produção!)
  secret: c3VwZXItc2VjcmV0LXN1cGVyLXNlY3JldC1zdXBlci1zZWNyZXQxMjM0NTY3OA==
  expiration: 86400000
```

### 4) Build & Run

```bash
mvn clean package
mvn spring-boot:run
# ou:
java -jar target/sports-info-backend-*.jar
```

*   **API**: `http://localhost:8080`
*   **Swagger**: `http://localhost:8080/swagger-ui/index.html`

***

## Arquitetura



**Camadas:**

*   **Controllers**: contratos REST e DTOs
*   **Service**: regra de negócio (MVP simples, fácil de evoluir)
*   **Repository**: persistência (JPA)
*   **Security**: filtro de autenticação **JWT** stateless
*   **Flyway**: migrações versionadas

***

## Banco & Migrações

*   Migrações em: `src/main/resources/db/migration/`
    *   `V1__init.sql`: schema (sports, competitions, seasons, teams, athletes, matches, events, users, favorites, discussions etc.)
    *   `V2__seed.sql`: dados iniciais (modalidades, competição, times, partida exemplo, usuário demo)
*   **Hibernate `ddl-auto: validate`** para garantir que o schema do DB está em linha com as entidades.

***

## Segurança (JWT)

*   **Registro**: `POST /api/auth/register`
*   **Login**: `POST /api/auth/login` → retorna `{ token }`
*   Envie `Authorization: Bearer <token>` nas rotas protegidas.
*   **Troque** o `jwt.secret` (base64) para produção.

> **Obs.** No MVP, alguns `GET /api/**` estão públicos (ajuste no `SecurityConfig` se quiser exigir auth para tudo).

***

## Endpoints (resumo)

**Auth**

*   `POST /api/auth/register`
*   `POST /api/auth/login`

**Usuário & Favoritos**

*   `GET /api/users/me`
*   `PATCH /api/users/me/theme`
*   `POST /api/users/{userId}/favorites`
*   `GET /api/users/{userId}/favorites`
*   `DELETE /api/users/favorites/{favoriteId}`

**Comunidade**

*   `POST /api/community/discussions`
*   `GET /api/community/discussions`

**Notificações**

*   `GET /api/notifications/stream` (SSE)

**Esportes** *(MVP – mock)*

*   `GET /api/{sport}/matches/live`
*   `GET /api/{sport}/leagues`
*   `GET /api/{sport}/stats/top`
*   `GET /api/{sport}/extras`

`{sport} ∈ football | basketball | volleyball | f1 | cycling | handball | tennis | futsal | esports`

***

## Estrutura do Projeto

    src/main/java/com/sportsinfo
    ├─ auth/               
    ├─ common/             
    ├─ community/          
    ├─ config/            
    ├─ notification/      
    ├─ security/        
    ├─ sports/          
    └─ user/           

    src/main/resources
    └─ db/migration/      

***

## Teste Rápido (cURL)

```bash
# Registro
curl -s -X POST http://localhost:8080/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"name":"Paulo","email":"paulo@example.com","password":"123456"}'

# Login
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"paulo@example.com","password":"123456"}' | jq -r '.data.token')

# Me (protegido)
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/users/me

# Futebol ao vivo (público - mock)
curl http://localhost:8080/api/football/matches/live
```

***

## Roadmap (sugestões)

*   Integrar **provedores reais** por esporte (futebol, NBA, F1, etc.)
*   **WebSocket** por partida para tempo real
*   **Notificações personalizadas** por favoritos
*   **Cache** (Redis/Caffeine)
*   **Observabilidade** (Actuator + Prometheus/Grafana)
*   **Testes** (unitários/integrados) e **CI/CD**
*   Autorização por papéis nos módulos de comunidade

***

## ⚠️ Dicas de Produção

*   **Alterar** `jwt.secret` (base64 forte) e usar **profiles** (`application-prod.yml`)
*   **Pool de conexões** (Hikari) e parâmetros de performance do Postgres
*   **Métricas e logs estruturados**
*   **Cookies HttpOnly** no front (em vez de localStorage) para segurança do token
