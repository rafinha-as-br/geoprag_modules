# GeoPrag Modules 0.1.0

Primeira versão distribuível do pacote compartilhado que dá suporte ao Portal
Administrador e ao App Aplicador do GeoPrag.

## Autenticação e acesso

Login, recuperação de senha e navegação inicial ganharam um fluxo completo e
consistente nas duas aplicações. A tela de "Esqueci minha senha" está
disponível tanto para o Aplicador quanto para o Administrador/Sub-Administrador,
com feedback visual claro de sucesso ou falha ao tentar entrar. O carregamento
inicial passou a reconhecer a prefeitura (tenant) de cada acesso antes de
liberar a navegação, e as telas de verificação de código e de autorização de
redefinição de senha foram unificadas no mesmo padrão visual das demais telas
de autenticação.

## Padronização visual

As telas de lista, detalhe, formulário, cartão e conteúdo informativo do
sistema passaram a seguir um conjunto único de templates visuais, o que
elimina inconsistências de layout entre as diferentes áreas do produto e
corrige problemas de tela cortada (overflow) e falta de rolagem em telas de
detalhe que ocorriam antes. A navegação entre telas do Portal Administrador
também foi padronizada para um comportamento único e previsível.

## Gestão de Administradores

Novo módulo de Gerenciamento de Administradores: cadastro de Administradores e
Sub-Administradores com cargos definidos, criação restrita a quem tem
permissão, desativação/reativação de cadastro e promoção/rebaixamento de
cargo. A senha gerada automaticamente no cadastro agora é exibida para quem
está criando o acesso.

## Gestão de Aplicadores

A área antes chamada "Gestão de Aplicadores" foi renomeada para
"Gerenciamento de Aplicadores", com a atribuição de ponto de aplicação movida
para a área de Gestão de Aplicações. A terminologia "bairro/trecho" foi
substituída por "ponto de aplicação"/"subponto" em todo o produto. O cadastro
de Aplicador agora inclui endereço completo (rua, número, complemento, bairro,
cidade, UF), obrigatório para esse perfil, e o dashboard de Aplicadores ganhou
filtro por status e ações em massa.

---

Issues: GEOPRAG-20, GEOPRAG-24, GEOPRAG-27, GEOPRAG-30, GEOPRAG-36, GEOPRAG-39,
GEOPRAG-42, GEOPRAG-50, GEOPRAG-57, GEOPRAG-65, GEOPRAG-67, GEOPRAG-68,
GEOPRAG-69, GEOPRAG-70, GEOPRAG-72, GEOPRAG-78, GEOPRAG-79, GEOPRAG-80,
GEOPRAG-81, GEOPRAG-82, GEOPRAG-83, GEOPRAG-84, GEOPRAG-85, GEOPRAG-86,
GEOPRAG-87, GEOPRAG-89, GEOPRAG-93, GEOPRAG-95, GEOPRAG-96, GEOPRAG-100
