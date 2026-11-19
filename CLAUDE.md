# CLAUDE.md

Instrucciones para agentes de IA que trabajan en este repo. Se carga entero en cada sesión, así que mantenelo corto: acá va lo que hace falta para orientarse y trabajar (stack, comandos, estructura, convenciones, flujo). Las decisiones, limitaciones, incidentes y correcciones, con su porqué, van en `.claude/memory/`.

## Qué es esta gema

Gema `angus`: framework para construir servicios REST sobre Rack (routing con `angus-router`, parámetros y respuestas JSON, middleware de excepciones y generador `angus new` basado en thor). No se despliega; los servicios la consumen desde git.

## Stack y versiones

- Ruby `>= 2.5` (`required_ruby_version` del gemspec); `.ruby-version` en 3.4.0.
- Dependencias de runtime: `thor >= 1.2, < 2`, `angus-sdoc ~> 0.0, >= 0.0.7`, `angus-router ~> 0.0, >= 0.0.3` y `bigdecimal >= 3.1, < 4`. De desarrollo: `rspec ~> 3.0`, `rspec-its`, `faker`, `rack-test`, `simplecov` y `simplecov_json_formatter`.
- La CI prueba MRI 2.5 a 3.4 con rack 1.6.13 y JRuby 9.3.14.0, 9.4.1.0 y 9.4.5.0 (`.github/workflows/config.yml`).
- Sin base de datos ni servicios externos.

## Skills a cargar

Flujo de desarrollo: lo trae el plugin `bancard-agentic-framework` (BAF). Sus skills se activan solas: al iniciar la sesión el plugin inyecta `bancard-agentic-framework:using-baf`, que le dice al agente cuándo usar cada una. Todo cambio arranca en `bancard-agentic-framework:brainstorming`; si tiene varias partes, sigue con `bancard-agentic-framework:writing-plans` (el plan lo escribe el agente `planner` y lo revisa `plan-reviewer`), `bancard-agentic-framework:using-git-worktrees`, `bancard-agentic-framework:subagent-driven-development` o `bancard-agentic-framework:executing-plans`, `bancard:code-review-pr` y `bancard-agentic-framework:finishing-a-development-branch`. Un bug o un spec rojo arranca en `bancard-agentic-framework:systematic-debugging`. Ramas con `bancard:manage-branches`, commits con `bancard:make-commit` y tests con las convenciones de `bancard:add-tests`. Specs, planes y el registro de avance quedan en `.baf/`, que se ignora solo y no se commitea.

## Comandos

| Tarea | Comando |
|---|---|
| Tests en Docker, con un Ruby puntual | `docker build --build-arg RUBY_VERSION=3.4 -t angus . && docker run --rm angus bundle exec rspec` |
| Tests con rack 1.6.13 fijo | `docker build --build-arg RUBY_VERSION=2.5 --build-arg BUNDLE_GEMFILE=gemfiles/rack_1.gemfile -t angus:2.5 . && docker run --rm angus:2.5 bundle exec rspec` |
| Shell con `lib/` y `spec/` montados | `RUBY_VERSION=3.4 BUNDLE_GEMFILE=gemfiles/rack_1.gemfile ./run.sh` |
| Tests en JRuby (montaje read-only y copia) | `docker run --rm -e BUNDLE_GEMFILE=/work/gemfiles/rack_1.gemfile -v "$PWD":/src:ro jruby:9.4.5.0 bash -c 'cp -r /src /work && cd /work && bundle install && bundle exec rspec'` |
| Coverage | se genera en `coverage/` al correr los tests (config en `.simplecov`) |
| Lint | el repo no tiene linter configurado |

- `Gemfile.lock` no se commitea y Docker lo resuelve dentro de la imagen.
- La imagen JRuby no usa el `Dockerfile` del repo: monta el código en solo lectura y lo copia a `/work`.

## Estructura y dónde va cada cosa

| Qué | Dónde | Regla |
|---|---|---|
| Entrada | `lib/angus.rb` | solo requiere `json`, `rack` y `angus/base`; lo nuevo se requiere desde `lib/angus/` |
| Base del servicio y recursos | `lib/angus/base.rb`, `base_resource.rb`, `request_handler.rb` | `Angus::Base` arma el servicio; los recursos heredan de `BaseResource` |
| Request | `lib/angus/request/json_params.rb` | `get_json_param`, `get_json_integer`, `get_json_boolean` y `get_json_datetime` leen el body JSON |
| Respuestas | `lib/angus/responses.rb`, `response.rb`, `middleware/exception_handler.rb` | `build_success_response` y `build_data_response` quitan los campos opcionales; las excepciones se mapean a mensajes |
| Generador | `lib/angus/generator/`, `lib/angus/commands/`, `bin/angus` | `angus new`, `angus resource` y `angus scaffold` usan thor; las plantillas ERB están en `generator/templates/` |
| Gemfiles por rack | `gemfiles/rack_1.gemfile` | fija rack 1.6.13 y apunta al gemspec; la CI lo elige con `BUNDLE_GEMFILE` |
| Specs | `spec/angus/` y `spec/functional/` | los funcionales corren un servicio de ejemplo (`spec/functional/<caso>/`) |
| Paquete | `angus.gemspec` | `spec.files` es `Dir.glob('{lib}/**/*')`: solo `lib/` entra a la gema |

## Convenciones

- Es una dependencia interna: los servicios la declaran en su `Gemfile` desde git y el commit queda fijado en su `Gemfile.lock`. Un cambio llega a un servicio recién cuando actualiza ese lock, pero entonces le llega todo lo que haya en `master`. Por eso lo que entra a `master` tiene que funcionar para cualquier servicio que la use: no cambies ni saques clases, métodos o constantes públicas sin mantener compatibilidad, y no subas un piso del gemspec ni de Ruby sin revisar los `Gemfile.lock` de los servicios. Nunca se sube un piso para que un test pase.
- Lo que escribas tiene que correr en Ruby 2.5 a 3.4 y en JRuby 9.3 y 9.4; la matriz de CI lo verifica.
- Los rangos del gemspec tienen como piso la versión más vieja que usa algún consumidor y como techo el próximo major.
- Cada fix de compatibilidad en `lib/` lleva su spec.
- SimpleCov se configura en `.simplecov`, que se carga con `require 'simplecov'` al principio de `spec_helper.rb`. No llames a `SimpleCov.minimum_coverage`: si los tests fallan por coverage, la action no publica la medición. El piso (85%) lo exige `bancardsa/coverage-action` solo con `COVERAGE_ENFORCE=true`.

## Flujo de git y CI

- Rama principal y default: `master`.
- La rama de un ticket se llama exactamente como el ticket (`QBK-123`), nace de su `feature/<X>` y se integra ahí **por PR**. Nunca se trabaja ni se integra sobre `develop` o `master`. Reglas completas en `bancard:manage-branches`.
- El repo no tiene `develop`: las `feature/<X>` nacen de `master` y vuelven a `master` por PR, con merge commit.
- Commits: `[TICKET-123] - Imperative description`, en inglés (`bancard:make-commit`). Sin atribución a IA ni co-authors.
- CI: GitHub Actions (`.github/workflows/config.yml`, workflow «Gem Validations»), en cada PR y en cada push a `master`: `bundle exec rspec` en la matriz de MRI y JRuby sobre ubuntu-22.04; en Ruby 3.4 con rack 1 publica el coverage con `bancardsa/coverage-action`; el job `Run tests` agrega toda la matriz en un solo status. No construye ni publica imágenes.

## Sistemas externos

- Jira en `bancard.atlassian.net` (MCP de Atlassian del plugin `bancard`); el proyecto depende del ticket.
- Sentry: este repo no reporta a Sentry (no tiene gema `sentry-*`).
- Dynatrace: el código no tiene instrumentación OpenTelemetry.
- Despliegue: no se despliega; los servicios la consumen desde git.
- Incidentes: `bancard:incident-runbook`.

## Memoria y contexto no obvio

Las decisiones, limitaciones, incidentes pasados y correcciones viven en `.claude/memory/` (índice importado abajo; en Cursor, leé `.claude/memory/MEMORY.md` a mano).

@.claude/memory/MEMORY.md

- **Leer:** antes de cambiar un área, abrí las entradas del índice que la tocan.
- **Proponer (obligatorio):** si el usuario te da una regla, una corrección o una decisión con su razón («no hagas X porque Y»), aunque venga dentro de otra pregunta, o si descubrís un hecho que no se deriva del código ni del git (una limitación, un incidente), no alcanza con «tomo nota»: al final de tu respuesta, en una sección «¿Lo guardo en la memoria del equipo?», mostrá la entrada completa propuesta y esperá el OK antes de escribirla. Nunca inventes el **Por qué**; si no lo dijeron, preguntalo. Si ya hay una entrada que lo cubre, decilo en vez de proponer otra.
- **Formato:** un archivo `<tipo>-<slug>.md` con frontmatter (`name`, `description`, `tipo`, `revisado`), el **Por qué** y el **Cómo aplicarlo**, y una línea en `MEMORY.md`.
- **Mantener:** si una entrada contradice el código actual, avisá y proponé actualizarla (con `revisado` de hoy) o borrarla.
- Lo del equipo va acá aunque tu auto-memory personal te sugiera guardarlo allá; allá va solo lo personal.

## Modelo y permisos

- Modelo default del equipo: `sonnet` (fijado en `.claude/settings.json`). Equilibrio costo/calidad para el trabajo diario. Los agentes de BAF fijan su propio modelo por rol: `haiku` para explorar y verificar, `sonnet` para implementar, revisar e investigar, `opus` para planificar y revisar planes.
- Permisos compartidos en `.claude/settings.json`: lectura de git y `gh`, `bundle exec rspec`, `bundle install`, `bundle exec rake -T` y lectura de Jira y Confluence se auto-aprueban; `git push`, `gh pr create/merge/comment/review`, `gh api` y las escrituras en Jira (crear, comentar y editar issues) piden confirmación. Tus permisos personales van en `.claude/settings.local.json` (ignorado).
- El mismo archivo habilita los plugins `bancard` y `bancard-agentic-framework` para este repo y apaga `superpowers` (`enabledPlugins`): aunque los tengas apagados en tu `~/.claude/settings.json`, acá cargan igual. Superpowers se apaga porque BAF es su versión adaptada a las convenciones del equipo y usa los mismos nombres de skills (`brainstorming`, `writing-plans`...): con los dos cargados se mezclan los flujos. En Cursor no hay `enabledPlugins`: instalá los dos plugins y desinstalá superpowers.


## Hooks activos

Los trae el plugin `bancard` y corren antes de cada comando de shell del agente, en Claude Code y en Cursor. Solo bloquean lo que el equipo nunca hace; si uno te frena algo legítimo, es un bug del hook: abrí un issue en `bancard-agent-plugins` en lugar de apagarlo. No los apagues con `"disableAllHooks": true`, que también apaga el `SessionStart` de `bancard-agentic-framework`, ni deshabilites `bancard`, que es dependencia de BAF. Necesitan `python3` donde corre el agente, y en Windows también Git Bash; sin ellos, no hacen nada.

- `commit-guard`: antes de `git commit`, bloquea mensajes con atribución a IA (`Co-Authored-By: Claude` o `Anthropic`, "Generated with Claude", 🤖), también si el mensaje llega por `-F <archivo>` o dentro del mismo comando (heredoc); un mensaje que llega por una tubería (`cat msg | git commit -F -`) no lo ve.
- `push-guard`: antes de `git push`, bloquea pushes a `develop` o `master`; pushes forzados o `--delete` sobre `develop`, `master` o `feature/*`; y `--mirror`, `--prune` y `--all`. Mira la rama del repo donde corre el push, incluido un `cd <dir>` o `-C <dir>` en el mismo comando. Para reescribir tu rama de ticket usá `--force-with-lease`; `.claude/settings.json` deniega `git push --force …` y `git push -f …` (con el flag justo después de `push`).
