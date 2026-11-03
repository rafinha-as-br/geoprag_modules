/// Ações concretas do sistema controláveis pelo esquema de permissões por
/// capacidade (GEOPRAG-112) — não é restrito a um módulo: qualquer área do
/// Portal Administrador pode declarar suas próprias ações aqui. Adicionar
/// uma capacidade nova é um novo valor neste enum; quem pode executá-la é
/// decidido só em `capacidades_por_cargo.dart`.
enum Capacidade {
  criarPontoAplicacao,
  editarPontoAplicacao,
  cancelarPontoAplicacao,
  atribuirAplicador,
  ativarPontoAplicacao,
  desativarPontoAplicacao,
}
