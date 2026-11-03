# Core — geoprag_modules

## Infraestrutura atual

`environment/build_environment.dart` lê e valida o ambiente de compilação. `network/` concentra o cliente HTTP, configuração, exceções e a composição legada de cliente. `security/`, `authorization/`, `ids/`, `errors/`, `logging/` e `presentation/` guardam os contratos técnicos compartilhados.

## Inicialização e reutilização

Core não guarda tenant ou regra de negócio. `ApiClientProvider` é a composição compartilhada da sessão HTTP e deve ser configurado pelo bootstrap do aplicativo antes do primeiro uso.

## Alterações compartilhadas

Alterar `ApiConfig` ou o ambiente afeta Portal e Aplicador. Manter os `dart-defines` documentados, preservar a normalização da URL e testar os cenários de valor ausente ou inválido antes de alterar contratos compartilhados.

## Limites

Core não importa `portal_administrador`, `aplicador_app` nem `features`. Não incluir autorização de negócio, disponibilidade de menu ou widgets neste diretório.
