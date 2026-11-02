# Design System — geoprag_modules

## Padrões presentes

O Design System existente permanece implementado em `src/theme/` e `src/widgets/`. `geoprag_design_system.dart` é a entrada canônica para seus tokens, tema e componentes genéricos durante a migração gradual.

## Referências e reutilização

Reutilizar `GeopragColors`, `GeopragTheme`, `GeopragLogo`, inputs e widgets genéricos existentes antes de criar qualquer componente novo. Nesta etapa não há um novo componente reutilizável nem ID canônico de Design System confirmado.

## Limites e dependências

O Design System não depende de `features`, de `portal_administrador` ou de regras de ambiente. Cards, dialogs e botões que sabem o que é ponto, tenant ou homologação pertencem às respectivas features.

## Evolução e extração manual

Consolidar novos tokens e componentes genéricos pelo barrel deste diretório sem remover as fachadas legadas até os consumidores migrarem. Uma extração para package separado exigirá revisão explícita de pubspec, assets, imports e API pública; ela não é automática.
