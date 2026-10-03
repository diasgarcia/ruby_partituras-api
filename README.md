# Partituras API (Ruby on Rails)

Recriação idiomática em Ruby on Rails da API original desenvolvida em Spring Boot ([diasgarcia/partituras-api](https://github.com/diasgarcia/partituras-api)).

O objetivo deste projeto é implementar o mesmo comportamento e os mesmos contratos HTTP/JSON da aplicação original, aplicando os padrões convencionais do ecossistema Rails (Rails Way, MVC e Active Record), sem reproduzir camadas artificiais de arquitetura corporativa Java.

---

## Stack

- **Ruby:** 3.4.11 (gerenciado via `mise`)
- **Rails:** 8.1.4 (em modo API)
- **Banco de Dados:** PostgreSQL 16 (executado em container Docker via Compose)
- **Servidor Web:** Puma 7+
- **Testes:** Minitest / Rails Test Runner e Bruno (OpenCollection YAML)

---

## Arquitetura

O projeto adota o padrão **Rails MVC + Active Record**:

```text
HTTP Request
      ↓
config/routes.rb
      ↓
PartiturasController
      ↓
Partitura (Active Record Model)
      ↓
PostgreSQL
```

Em vez de dispersar regras simples de CRUD entre Services, Use Cases, Repositories, Mappers, Request DTOs e Validators isolados:
- O **Controller** recebe requisições, delega parâmetros seguros (*strong parameters*) e responde HTTP.
- O **Model** (`Active Record`) encapsula regras de negócio, validações, ciclo de vida e persistência no banco de dados.
- O **Banco de Dados** mantém restrições de integridade estrutural (NOT NULL, check constraints e índices).

---

## Pré-requisitos

Certifique-se de que os seguintes utilitários estejam instalados no ambiente (ex: WSL Debian / Linux):

- **Ruby 3.4.11**
- **Rails 8.1.4**
- **Bundler**
- **Docker** e **Docker Compose**
- **Git**

---

## Instalação e Execução

### 1. Dependências Ruby

Instale as gems do projeto:

```bash
bundle install
```

### 2. Iniciar o Banco de Dados (PostgreSQL)

O banco de dados roda isolado no Docker via Compose, publicado na porta `5432`:

```bash
docker compose up -d
```

### 3. Preparar o Banco de Dados

Execute o comando que prepara o banco do ambiente atual, criando-o quando necessário e aplicando as migrations:

```bash
bin/rails db:prepare
```

Ao preparar uma base nova, o Rails também executa os seeds. Para carregar explicitamente as 24 partituras de exemplo (equivalente ao `data/insert.sql` original):

```bash
bin/rails db:seed
```

### 4. Executar os Testes

Execute a suíte de testes automatizados:

```bash
bin/rails test
```

### Testes de API com Bruno

A coleção está em `ruby_partituras-api.yml`. Importe esse arquivo no Bruno como
uma coleção OpenCollection e execute pelo **Runner**. A variável `baseUrl` da
coleção aponta para `http://localhost:3000`; a API precisa estar rodando nesse
endereço para o uso pelo aplicativo.

Os 20 cenários cobrem CRUD, campos opcionais, normalização de tonalidade,
validações, duplicidade, preservação da data e respostas 404. Cada requisição
cria seus próprios dados e remove somente esses registros ao terminar, mesmo
quando uma assertion falha. É possível executar um cenário sozinho, em qualquer
ordem e com o banco vazio. IDs são descobertos pela API, inclusive os dos testes
de 404, que criam e excluem uma fixture antes de consultá-la.

Para executar tudo automaticamente pelo terminal, instale **Node.js 22+** e a CLI
(já instalada se `bru --version` retornar `4.1.0`):

```bash
npm install -g @usebruno/cli@4.1.0
```

No WSL, dentro do projeto e com Ruby disponível no PATH:

```bash
bash script/test_bruno
```

Esse comando inicia o PostgreSQL do Compose, prepara o banco separado
`ruby_partituras_api_bruno_test` sem seeds, inicia uma API de testes na porta
`3001`, executa o Bruno e encerra essa API. O banco de desenvolvimento permanece
intacto. Com `mise`, também pode executar `mise exec -- bash script/test_bruno`.
A CLI instalada no Windows pode ser usada pelo WSL por meio de `node.exe`.

Para executar somente um cenário:

```bash
bash script/test_bruno update_duplicate
```

Também é possível testar uma API já iniciada, no PowerShell ou em Linux:

```bash
node script/test-bruno.cjs http://localhost:3000
node script/test-bruno.cjs http://localhost:3000 show_missing
```

O YAML exportado é a fonte única: o runner desmembra uma cópia temporária para a
CLI e a remove ao terminar. O relatório fica em `tmp/bruno-results.json`. O runner
faz uma tentativa adicional de limpeza se uma falha de transporte interromper os
scripts; se a API estiver indisponível, a limpeza é reportada como falha.

`BRUNO_PORT` muda a porta da API de testes; `DB_BRUNO_NAME` muda o nome do banco.
Use `BRUNO_SKIP_DOCKER=1` quando o PostgreSQL já for fornecido externamente. O
workflow de CI também executa a coleção em um banco separado e salva o relatório.

A API carrega apenas os componentes usados pelo CRUD e pelos testes. Foram
removidos os arquivos gerados de mailers, jobs, uploads, Solid Cache/Queue/Cable,
Kamal e Thruster, junto com suas dependências e configurações.

### 5. Iniciar o Servidor Rails

Inicie a aplicação:

```bash
bin/rails server
```

A API estará acessível em:
```text
http://localhost:3000
```

Para verificar o status da aplicação (*health check* nativo do Rails 8):
```text
http://localhost:3000/up
```

---

## Comandos Úteis

### Rotas

Para inspecionar as rotas registradas no sistema:

```bash
bin/rails routes
```

Rotas ativas:
```text
Prefix       Verb   URI Pattern             Controller#Action
partituras   GET    /partituras(.:format)     partituras#index
             POST   /partituras(.:format)     partituras#create
partitura    GET    /partituras/:id(.:format) partituras#show
             PUT    /partituras/:id(.:format) partituras#update
             DELETE /partituras/:id(.:format) partituras#destroy
```

### Qualidade de Código e Segurança

Verificação de estilo de código:
```bash
bin/rubocop
```

Auditoria estática de segurança:
```bash
bin/brakeman
```

---

## Comandos Docker

- **Subir o PostgreSQL em segundo plano:**
  ```bash
  docker compose up -d
  ```

- **Parar o container sem perder os dados:**
  ```bash
  docker compose down
  ```

- **Parar e remover volume (apaga todos os dados do banco):**
  ```bash
  docker compose down -v
  ```

> [!WARNING]
> O comando `docker compose down -v` remove o volume persistente do PostgreSQL, apagando todas as tabelas e dados existentes. Ao utilizá-lo, será necessário reexecutar `bin/rails db:prepare` e `bin/rails db:seed`.

---

## Endpoints da API

### 1. Listar Partituras

Retorna a lista resumida de partituras (sem campos detalhados como arranjador, bpm, tonalidade ou dataCriacao).

- **Método:** `GET`
- **URL:** `/partituras`
- **Status:** `200 OK`

**Exemplo com curl:**
```bash
curl -i http://localhost:3000/partituras
```

**Exemplo de Resposta:**
```json
[
  {
    "id": 1,
    "titulo": "Asturias (Leyenda)",
    "autor": "Isaac Albéniz",
    "avaliacao": 5
  },
  {
    "id": 2,
    "titulo": "Recuerdos de la Alhambra",
    "autor": "Francisco Tárrega",
    "avaliacao": 5
  }
]
```

---

### 2. Detalhar Partitura

Retorna todos os detalhes de uma partitura específica por ID.

- **Método:** `GET`
- **URL:** `/partituras/:id`
- **Status de Sucesso:** `200 OK`
- **Status se não existir:** `404 Not Found`

**Exemplo com curl (Sucesso):**
```bash
curl -i http://localhost:3000/partituras/1
```

**Exemplo de Resposta (200 OK):**
```json
{
  "id": 1,
  "titulo": "Asturias (Leyenda)",
  "autor": "Isaac Albéniz",
  "arranjador": "Andrés Segovia",
  "bpm": 120,
  "avaliacao": 5,
  "dataCriacao": "2026-10-03",
  "tonalidade": "Em"
}
```

**Exemplo com curl (Não encontrado):**
```bash
curl -i http://localhost:3000/partituras/99999
```

**Exemplo de Resposta (404 Not Found):**
```json
{
  "message": "partitura não encontrada"
}
```

---

### 3. Cadastrar Partitura

Cria uma nova partitura. O campo `dataCriacao` é definido automaticamente com a data corrente.

- **Método:** `POST`
- **URL:** `/partituras`
- **Status de Sucesso:** `201 Created` (corpo vazio, conforme API Spring)
- **Status de Erro (dados inválidos ou duplicidade):** `400 Bad Request`

**Exemplo com curl (Sucesso):**
```bash
curl -i -X POST http://localhost:3000/partituras \
  -H "Content-Type: application/json" \
  -d '{
    "titulo": "Lagrimas",
    "autor": "Francisco Tárrega",
    "arranjador": "Francisco Tárrega",
    "bpm": 75,
    "avaliacao": 4,
    "tonalidade": "E"
  }'
```

**Resposta:**
`HTTP/1.1 201 Created` com corpo vazio (`Content-Length: 0`).

**Exemplo com curl (Duplicidade - 400 Bad Request):**
```bash
curl -i -X POST http://localhost:3000/partituras \
  -H "Content-Type: application/json" \
  -d '{
    "titulo": "Lagrimas",
    "autor": "Francisco Tárrega",
    "arranjador": "Francisco Tárrega",
    "bpm": 75,
    "avaliacao": 4,
    "tonalidade": "E"
  }'
```

**Resposta (400 Bad Request):**
```json
{
  "message": "já existe uma partitura com esse nome e esse autor",
  "errors": [
    "já existe uma partitura com esse nome e esse autor"
  ]
}
```

---

### 4. Atualizar Partitura

Atualiza os dados de uma partitura existente. A data de criação original (`dataCriacao`) é preservada.

- **Método:** `PUT`
- **URL:** `/partituras/:id`
- **Status de Sucesso:** `204 No Content` (corpo vazio)
- **Status se não existir:** `404 Not Found`
- **Status de Validação/Duplicidade:** `400 Bad Request`

**Exemplo com curl (Sucesso):**
```bash
curl -i -X PUT http://localhost:3000/partituras/9 \
  -H "Content-Type: application/json" \
  -d '{
    "titulo": "Lágrima (Edição Revisada)",
    "autor": "Francisco Tárrega",
    "arranjador": "Francisco Tárrega",
    "bpm": 80,
    "avaliacao": 5,
    "tonalidade": "E"
  }'
```

**Resposta:**
`HTTP/1.1 204 No Content` com corpo vazio.

---

### 5. Excluir Partitura

Remove uma partitura pelo ID.

- **Método:** `DELETE`
- **URL:** `/partituras/:id`
- **Status de Sucesso:** `204 No Content` (corpo vazio)
- **Status se não existir:** `404 Not Found`

**Exemplo com curl (Sucesso):**
```bash
curl -i -X DELETE http://localhost:3000/partituras/1
```

**Resposta:**
`HTTP/1.1 204 No Content` com corpo vazio.

**Exemplo com curl (Não encontrado):**
```bash
curl -i -X DELETE http://localhost:3000/partituras/99999
```

**Resposta (404 Not Found):**
```json
{
  "message": "partitura não encontrada"
}
```

---

## Spring Boot original vs Rails

### Mapeamento de Responsabilidades

| Responsabilidade no Spring Boot | Classe no Spring Boot | Abordagem Idiomática no Rails | Justificativa |
| :--- | :--- | :--- | :--- |
| **Controller** | `PatituraController` | `PartiturasController` | Ambos gerenciam entrada HTTP e status. No Rails, actions usam métodos convencionais REST (`index`, `show`, `create`, `update`, `destroy`). |
| **Request DTO** | `AdicionarPartituraRequest`<br>`AtualizarPartituraRequest` | `params` + *Strong Parameters* | O Rails filtra e autoriza parâmetros nativamente via `params.permit(...)` sem necessidade de criar classes de transporte de dados adicionais. |
| **Response DTO** | `ListarPartituraResponse`<br>`DetalharPartituraResponse` | Serialização nativa (`as_json`) | O model `Partitura#as_json` expõe a estrutura necessária para cada endpoint (`summary` vs `detailed`), preservando as chaves JSON esperadas sem precisar de classes DTOs. |
| **Mapper** | `AdicionarPartituraMapper`<br>`AtualizarPartituraMapper`<br>`DetalharPartituraMapper`<br>`ListarPartituraMapper` | Atribuição direta + Active Record | O Rails mapeia atributos automaticamente a partir de hashes e gera JSON diretamente a partir de objetos do domínio. |
| **Validator** | `AdicionarPartituraValidator`<br>`AtualizarPartituraValidator` | Validações do Active Record | Validações como `validates :titulo, presence: true` e validações customizadas (`validar_duplicidade_*`) ficam no próprio model com `validate`. |
| **Repository** | `ParituraRepository` (Spring Data JPA) | `Active Record` (`Partitura`) | No padrão Active Record, o model já é a porta de acesso ao banco (`find`, `create!`, `where`, `exists?`, `destroy!`). |
| **Service** | `AdcionarPartituraService`<br>`AtualizarPartituraService`<br>`DetalharPartituraService`<br>`ListarPartituraService`<br>`DeletarPartituraService` | Não necessário (*Active Record Model* + *Controller*) | Para operações diretas de CRUD, o Rails não necessita de Service Objects artificiais. Inserir Services em CRUDs simples é considerado anti-pattern no Rails ("anemic domain model"). |
| **Entity** | `Partitura` (JPA Entity) | `Partitura < ApplicationRecord` | A entidade no Rails herda de `ApplicationRecord`, integrando schema, validações e persistência em uma única definição coesa. |

---

### Comparação Concreta de Fluxos

#### Fluxo 1: Criação de Partitura (`POST /partituras`)

```text
Spring Boot (Abordagem em Camadas):
HTTP POST
  ↓
PatituraController#adicionar
  ↓
AdcionarPartituraService#adicionar
  ↓
AdicionarPartituraValidator#validar (consulta ParituraRepository)
  ↓
AdicionarPartituraMapper#toEntity (converte Request DTO em Entity)
  ↓
ParituraRepository#save (grava via JPA / Hibernate)
  ↓
HTTP 201 Created (void)
```

```text
Ruby on Rails (Convention over Configuration):
HTTP POST
  ↓
PartiturasController#create
  ↓ (filtra com partitura_params)
Partitura.create!
  ↓ (executa callbacks before_validation e validações Active Record)
Active Record / PostgreSQL INSERT
  ↓
head :created (HTTP 201 Created sem corpo)
```

---

#### Fluxo 2: Atualização de Partitura (`PUT /partituras/:id`)

```text
Spring Boot:
HTTP PUT
  ↓
PatituraController#atualizar
  ↓
AtualizarPartituraService#atualizar
  ↓
AtualizarPartituraValidator#validar (valida ID e duplicidade via ParituraRepository)
  ↓
ParituraRepository#findById (carrega entidade ou 404)
  ↓
AtualizarPartituraMapper#toEntity (atualiza campos da entidade)
  ↓
ParituraRepository#save
  ↓
HTTP 204 No Content (void)
```

```text
Ruby on Rails:
HTTP PUT
  ↓
PartiturasController#update (set_partitura via Partitura.find -> 404 se ausente)
  ↓
@partitura.update!(partitura_params) (validações on: :update)
  ↓
Active Record / PostgreSQL UPDATE
  ↓
head :no_content (HTTP 204 No Content sem corpo)
```

---

### Resumo das Decisões de Design

1. **Eliminação de 15+ classes intermediárias:** A arquitetura Spring exigia 5 Services, 2 Validators, 4 Mappers, 2 Request DTOs, 2 Response DTOs e 1 Repository para um CRUD simples. Em Rails, toda essa infraestrutura foi substituída convencionalmente por 1 Controller (`PartiturasController`) e 1 Model (`Partitura`).
2. **Preservação estrita dos Contratos HTTP:** Os status HTTP (`200`, `201`, `204`, `400`, `404`), o corpo vazio em `POST`/`PUT`/`DELETE`, a formatação `dataCriacao` em camelCase e os campos da listagem resumida foram preservados fielmente.
3. **Mecanismo de Exceções Centralizado:** Em vez de blocos `try/catch` ou verificação manual em cada action, `ApplicationController` trata `ActiveRecord::RecordNotFound` e `ActiveRecord::RecordInvalid` centralizadamente através de `rescue_from`.
