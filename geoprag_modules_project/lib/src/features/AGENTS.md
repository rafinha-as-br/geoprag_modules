# Features — geoprag_modules

## Capacidades e limites

As capacidades legadas continuam em `lib/portal_administrador` e `lib/aplicador_app` para preservar contratos dos consumidores. `auditoria/` e `atrasos/` já possuem `domain/` e `data/` canônicos; os antigos caminhos `src/auditoria` e `src/atraso` são apenas fachadas. A feature de homologação está em `homologacao/domain/` e define, de forma pura, a disponibilidade limitada do Portal Administrador e o tenant de teste `gaspar-sc-hml`.

## Estrutura proporcional

Criar `presentation/`, `data/` e `domain/` apenas quando a capacidade realmente os exigir. A política de homologação é uma regra sem UI nem fonte externa e, por isso, tem somente `domain`. O registro de simulação reutiliza a feature de Gestão de Aplicações: contrato de repositório, implementação HTTP e Cubit já existentes.

Entidades, DTOs, repositórios e datasources não devem ser criados como camadas vazias. Se for necessário separar domínio, ele não pode importar Flutter ou infraestrutura.

## Dependências e encapsulamento

Features podem consumir Core e Design System. Uma feature não deve importar detalhes de outra para fugir do seu contrato público; coordenação entre capacidades fica na camada Application.

## Estado, erros e testes

O portal usa Cubits e o contrato de feedback já existente. Toda ação assíncrona deve representar carregamento, sucesso e erro amigável. Cobrir regras puras, repositórios HTTP e ações críticas de Cubit com testes; usar widget tests para o caminho de apresentação quando houver interação.

## Adicionar feature

Começar pela capacidade confirmada, mapear seu consumidor e seus contratos atuais, e só então criar diretórios que recebam código real. Não transformar mocks legados em requisito de homologação: rotas mockadas devem ficar fora do menu e do guard de módulo HML.
