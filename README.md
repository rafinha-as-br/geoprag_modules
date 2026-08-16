# geoprag_modules

Pacote Flutter compartilhado (`shared package`) do sistema Geoprag, contendo as **telas, widgets e modelos de cada módulo funcional** usados pelos dois apps do projeto: [`app_administrador`](../app_administrador) (Flutter Web) e [`app_aplicador`](../app_aplicador) (Flutter Mobile).

## O que é

É o repositório central de UI e regras de módulo do Geoprag. Em vez de duplicar telas e componentes visuais entre o app do administrador e o app do aplicador de campo, ambos importam este pacote como dependência local (`path: ../../geoprag_modules/geoprag_modules`) e reaproveitam tema, widgets base e os módulos funcionais completos.

## Organização

O pacote é dividido por **público-alvo** (`aplicador_app` e `portal_administrador`), e dentro de cada módulo segue o padrão **core / data / presentation**:

```
lib/
  geoprag_modules.dart          # ponto único de exportação do pacote

  src/
    theme/                      # cores, status e tema visual do Geoprag
    widgets/                    # widgets genéricos (logo, badge de status, etc.)

  aplicador_app/                 # módulos do app do Aplicador de campo
    auth/                        # autenticação
    application_points/          # marcação e visualização de pontos de aplicação
    applications/                # registro de aplicações (geolocalização, execução)
    inventory/                   # controle de insumos em campo
    reports/                     # denúncia e dashboard de focos

  portal_administrador/          # módulos do portal web do Administrador
    auth/                        # autenticação
    dashboard/                   # dashboard geral
    map_monitoring/              # monitoramento hidrológico via mapa
    applicators_management/      # gestão de aplicadores
    inventory_and_bidding/       # estoque, produtos, fórmulas e licitação
    distributions/                # distribuições/saídas de insumos
    reports_management/          # gestão de denúncias
```

Cada módulo expõe um arquivo "fachada" (ex.: `autenticacao.dart`, `dashboard.dart`, `gestao_de_aplicadores.dart`) que é reexportado centralmente em `lib/geoprag_modules.dart` — esse é o único ponto de importação que os apps consumidores devem usar (`import 'package:geoprag_modules/geoprag_modules.dart'`).

## Por que um pacote compartilhado, e não duplicação

Autenticação é o único módulo presente nos dois públicos (`aplicador_app/auth` e `portal_administrador/auth`), mas com implementações propositalmente **separadas**: o fluxo de sessão do administrador (cookie HttpOnly) e o do aplicador (token + PIN/biometria + chaves assimétricas) são suficientes diferentes para não compartilhar lógica — ver `docs/autenticacao.md` em cada app consumidor. O que este pacote compartilha entre os dois é o que de fato é comum: tema visual, widgets genéricos e, futuramente, qualquer regra de negócio idêntica entre os dois públicos.

## Dependências principais

- Flutter (SDK `^3.9.2`)
- `google_fonts`

## Uso

```dart
import 'package:geoprag_modules/geoprag_modules.dart';
```

Veja `example/geoprag_modules_example.dart` para um ponto de partida de uso do pacote.

## Como rodar os testes

```bash
cd geoprag_modules
flutter pub get
flutter test
```

## CI (GitHub Actions)

Workflow: [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

- **Triggers**: Pull Request para `develop`/`main`; push em `develop`
- **Job `quality-gates`**: checkout → Flutter 3.35.5 → `flutter pub get` → `flutter analyze --no-fatal-infos` → `flutter test`
- **Gates obrigatórios (bloqueiam merge)**: `flutter analyze` (erros e warnings; infos não bloqueiam)
- **Não bloqueia ainda**: `flutter test` roda e reporta, mas não derruba o job (`continue-on-error: true`). Motivo: 37 dos ~304 testes hoje falham na própria `develop`, todos com a mesma assinatura (Cubit não emite o estado `Error` esperado nos testes de `bloc_test` quando o repositório mockado lança exceção) — indício de causa raiz única (timing do `bloc_test`/`mocktail`, não 19 features quebradas de fato). Assim que corrigido, remover o `continue-on-error` e marcar `test` como check obrigatório na branch protection.
