# Core — geoprag_modules

## Infraestrutura atual

`environment/build_environment.dart` lê e valida o ambiente de compilação. `network/api_config.dart` é a localização canônica da configuração de URL e timeout HTTP. `errors/` e `logging/` guardam os contratos técnicos compartilhados; os caminhos antigos em `src/errors/` são somente reexports de compatibilidade.

## Inicialização e reutilização

Core não guarda tenant, sessão de usuário ou regra de negócio. `ApiClientProvider` continua sendo a composição legada da sessão HTTP até sua migração planejada, e deve ser configurado pelo bootstrap do aplicativo antes do primeiro uso.

## Alterações compartilhadas

Alterar `ApiConfig` ou o ambiente afeta Portal e Aplicador. Manter os `dart-defines` documentados, preservar a normalização da URL e testar os cenários de valor ausente ou inválido antes de alterar contratos compartilhados.

## Limites

Core não importa `portal_administrador`, `aplicador_app` nem `features`. Não incluir autorização de negócio, disponibilidade de menu ou widgets neste diretório.
