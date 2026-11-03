# Design System — geoprag_modules

## Padrões presentes

`theme/` contém tokens, estados e tema. `components/` concentra widgets visuais genéricos e `validation/` as regras de validação de formulário reutilizáveis. `geoprag_design_system.dart` é a entrada canônica desses contratos.

## Referências e reutilização

Reutilizar `GeopragColors`, `GeopragTheme`, `GeopragLogo`, inputs e widgets genéricos existentes antes de criar qualquer componente novo. Nesta etapa não há um novo componente reutilizável nem ID canônico de Design System confirmado.

## Limites e dependências

O Design System não depende de `features`, de `portal_administrador` ou de regras de ambiente. Cards, dialogs e botões que sabem o que é ponto, tenant ou homologação pertencem às respectivas features.

## Evolução e extração manual

Consolidar novos tokens e componentes genéricos pelo barrel deste diretório. Uma extração para package separado exigirá revisão explícita de pubspec, assets, imports e API pública; ela não é automática.
