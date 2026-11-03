/// Gera a senha inicial padrão de um usuário (Aplicador, Administrador ou
/// Sub-Administrador), conforme "Regra de Negócio - Geração de Senhas para
/// Usuários Aplicadores" (GEOPRAG-61): data de nascimento (`DDMMAAAA`) +
/// iniciais do nome (primeira e última palavra de [nome], minúsculas) + `#`.
///
/// Se [nome] tiver uma única palavra, a mesma letra inicial é usada duas
/// vezes (não há sobrenome para compor a segunda inicial).
String gerarSenhaInicial({
  required String nome,
  required DateTime dataNascimento,
}) {
  final data = _formatarData(dataNascimento);
  final iniciais = _iniciais(nome);
  return '$data$iniciais#';
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final ano = data.year.toString().padLeft(4, '0');
  return '$dia$mes$ano';
}

String _iniciais(String nome) {
  final palavras = nome
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (palavras.isEmpty) return '';
  final primeira = palavras.first[0].toLowerCase();
  final ultima = palavras.last[0].toLowerCase();
  return '$primeira$ultima';
}
