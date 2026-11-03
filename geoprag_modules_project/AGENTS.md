# geoprag_modules — orientação do package

## Finalidade e estado atual

`geoprag_modules` é o package Flutter compartilhado do Geoprag. Ele concentra capacidades reutilizadas pelo Portal Administrador Web e pelo aplicativo de campo, sem assumir o ciclo de vida, as rotas ou a configuração de execução dos aplicativos consumidores.

`lib/src/` contém exclusivamente quatro camadas reais: `application/`, `features/`, `core/` e `design_system/`. Não existem caminhos históricos nem fachadas de compatibilidade dentro de `src`; imports internos e consumidores devem usar a localização canônica.

## Consumidores e tecnologias

Os consumidores conhecidos são `app_administrador` (Flutter Web) e `app_aplicador` (Flutter Mobile), ambos fora deste repositório. Este package usa Flutter/Dart, `flutter_bloc`, `dio`, `flutter_secure_storage` e as dependências declaradas em `pubspec.yaml`.

O portal recebe a URL da API por `--dart-define=API_BASE_URL=...` e o ambiente por `--dart-define=GEOPRAG_ENV=desenvolvimento|homologacao|producao`. A URL nunca é versionada no package. Homologação habilita somente as áreas necessárias ao piloto e a simulação de aplicação; produção não as habilita.

## Navegação e responsabilidades

Antes de editar uma camada, ler seu documento local; não presumir carregamento automático:

- [Application](lib/src/application/AGENTS.md): composições e política de execução do portal.
- [Features](lib/src/features/AGENTS.md): capacidades funcionais e regras de homologação.
- [Core](lib/src/core/AGENTS.md): infraestrutura técnica reutilizável.
- [Design System](lib/src/design_system/AGENTS.md): padrões visuais reutilizáveis.

`lib/geoprag_modules.dart` é a entrada pública principal. Os aplicativos consumidores mantêm seus próprios `main.dart`, `GoRouter` e injeção de `BlocProvider`; o package fornece `AdminPortalRuntime` para que o consumidor aplique a mesma política de ambiente aos guards de rota.

## API e imports

`lib/geoprag_modules.dart` é a entrada pública para contratos compartilhados. Os módulos de Portal e Aplicador mantêm suas próprias entradas públicas em `lib/portal_administrador/` e `lib/aplicador_app/`; código novo não deve importar caminhos legados nem criar reexports de transição em `src/`.

O fluxo de homologação usa `POST /api/v1/pontos/{id}/simulacao-aplicacao`. Essa rota deve ser implementada pela API, restrita ao perfil de homologação e auditada no servidor; o cliente não cria coordenadas nem registros de GPS artificiais.

## Comandos e validação

Executar neste diretório: `flutter pub get`, `dart format --set-exit-if-changed .`, `flutter analyze --no-fatal-infos` e `flutter test`. O verificador estrutural temporário da skill também deve ser executado a partir de uma cópia fora do repositório.

## Adicionar funcionalidades

Adicionar regra de negócio em uma feature, deixando `domain` independente de Flutter quando a regra justificar isolamento. Widgets de fluxo continuam na feature; componentes visuais reutilizáveis ficam no Design System. Core não importa feature e o Design System não depende de negócio. Toda mudança comportamental nova precisa de teste proporcional.
