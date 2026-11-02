# Application — geoprag_modules

## Composições presentes

`admin_portal_runtime.dart` compõe a configuração técnica do build com a política funcional do Portal Administrador. Ele não contém telas, rotas concretas nem regras de persistência.

## Integração e inicialização

`AdminPortalRuntime.atual` é criado a partir de `GEOPRAG_ENV`. A instância expõe quais seções do Portal podem aparecer e se a simulação de aplicação está habilitada. Os consumidores devem usá-la tanto na composição da sidebar quanto nos guards das rotas de módulo; esconder um item de menu não substitui autorização no servidor.

## Navegação e entradas

O package não possui `main.dart` nem roteador. `AdminPortalRuntime.permiteRotaDeModulo` é uma política para os guards existentes nos consumidores, não um roteador próprio.

## Limites e evolução

Não adicionar service locator global ou duplicar providers aqui. Composição conecta capabilities existentes; uma tela, cubit ou repositório novo pertence à feature responsável.
