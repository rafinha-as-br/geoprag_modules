import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/geoprag_modules.dart';
import 'package:geoprag_modules/aplicador_app/bootstrap.dart';
import 'package:geoprag_modules/portal_administrador/bootstrap.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class _MockAdapter extends Mock implements HttpClientAdapter {}

/// Resposta programada do servidor falso.
class _Resp {
  _Resp(this.status, [Object? corpo, this.atraso = Duration.zero])
    : corpo = corpo is String ? corpo : jsonEncode(corpo);

  final int status;
  final String? corpo;
  final Duration atraso;
}

void main() {
  late _MockAdapter adapter;
  late SessaoDeTokensEmMemoria sessao;
  late List<RequestOptions> chamadas;
  late int sessoesPerdidas;
  late ApiClient cliente;

  /// Roteia cada chamada ao adaptador pela função [rota].
  void servidor(FutureOr<Object> Function(RequestOptions) rota) {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer((inv) async {
      final opcoes = inv.positionalArguments[0] as RequestOptions;
      chamadas.add(opcoes);
      final resultado = await rota(opcoes);
      if (resultado is DioException) throw resultado;
      final resp = resultado as _Resp;
      if (resp.atraso > Duration.zero) await Future<void>.delayed(resp.atraso);
      return ResponseBody.fromString(
        resp.corpo ?? '',
        resp.status,
        headers: {
          Headers.contentTypeHeader: [
            resp.status >= 400
                ? 'application/problem+json'
                : 'application/json',
          ],
        },
      );
    });
  }

  DioException falhaDeRede(DioExceptionType tipo) => DioException(
    requestOptions: RequestOptions(path: ''),
    type: tipo,
    error: 'detalhe tecnico http://interno/segredo',
  );

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Stream<Uint8List>.empty());
  });

  setUp(() async {
    adapter = _MockAdapter();
    chamadas = [];
    sessoesPerdidas = 0;
    sessao = SessaoDeTokensEmMemoria();
    await sessao.salvar(accessToken: 'acesso-1', refreshToken: 'refresh-1');
    final dio = Dio()..httpClientAdapter = adapter;
    cliente = ApiClient(
      config: ApiConfig(baseUrl: 'http://api.test/'),
      sessao: sessao,
      dio: dio,
      aoPerderSessao: () => sessoesPerdidas++,
    );
  });

  group('ApiConfig', () {
    test('normaliza barra final e prefixo /api/v1', () {
      expect(
        ApiConfig(baseUrl: ' http://h:8080/ ').baseUrlDaApi,
        'http://h:8080/api/v1',
      );
      expect(ApiConfig(baseUrl: 'http://h/api/v1/').baseUrl, 'http://h');
    });

    test('URL vazia é recusada', () {
      expect(() => ApiConfig(baseUrl: '  '), throwsArgumentError);
    });

    test('doAmbiente sem API_BASE_URL falha com orientação', () {
      expect(ApiConfig.doAmbiente, throwsStateError);
    });
  });

  group('requisição', () {
    test('usa a URL base e envia o Bearer', () async {
      servidor((_) => _Resp(200, {'ok': true}));

      final corpo = await cliente.get('/sync/pull', query: {'desde': 'x'});

      expect(corpo, {'ok': true});
      final req = chamadas.single;
      expect(req.uri.toString(), 'http://api.test/api/v1/sync/pull?desde=x');
      expect(req.headers['Authorization'], 'Bearer acesso-1');
    });

    test('chamada não autenticada não envia Authorization', () async {
      servidor((_) => _Resp(200, {'accessToken': 'a'}));

      await cliente.post(
        '/auth/login',
        corpo: {'email': 'e'},
        autenticado: false,
      );

      expect(chamadas.single.headers.containsKey('Authorization'), isFalse);
      expect(chamadas.single.data, {'email': 'e'});
    });

    test('corpo vazio (204) vira null', () async {
      servidor((_) => _Resp(204));

      expect(await cliente.delete('/x/1'), isNull);
    });
  });

  group('renovação do token', () {
    test(
      '401 renova uma vez, refaz a chamada e guarda os novos tokens',
      () async {
        servidor((req) {
          if (req.path == '/auth/refresh') {
            expect(req.data, {'refreshToken': 'refresh-1'});
            return _Resp(200, {
              'accessToken': 'acesso-2',
              'refreshToken': 'refresh-2',
            });
          }
          return req.headers['Authorization'] == 'Bearer acesso-2'
              ? _Resp(200, {'ok': 1})
              : _Resp(401, {
                  'code': 'TOKEN_INVALIDO',
                  'detail': 'Token inválido.',
                });
        });

        final corpo = await cliente.get('/pontos');

        expect(corpo, {'ok': 1});
        expect(chamadas.map((c) => c.path), [
          '/pontos',
          '/auth/refresh',
          '/pontos',
        ]);
        expect(await sessao.accessToken(), 'acesso-2');
        expect(await sessao.refreshToken(), 'refresh-2');
        expect(sessoesPerdidas, 0);
      },
    );

    test(
      'várias chamadas com 401 simultâneo compartilham UMA renovação',
      () async {
        servidor((req) async {
          if (req.path == '/auth/refresh') {
            return _Resp(200, {
              'accessToken': 'acesso-2',
              'refreshToken': 'refresh-2',
            }, const Duration(milliseconds: 50));
          }
          return req.headers['Authorization'] == 'Bearer acesso-2'
              ? _Resp(200, {'path': req.path})
              : _Resp(401, {'code': 'TOKEN_INVALIDO'});
        });

        final resultados = await Future.wait([
          cliente.get('/a'),
          cliente.get('/b'),
          cliente.get('/c'),
          cliente.get('/d'),
        ]);

        expect(resultados.map((r) => (r as Map)['path']), [
          '/a',
          '/b',
          '/c',
          '/d',
        ]);
        expect(chamadas.where((c) => c.path == '/auth/refresh'), hasLength(1));
        expect(await sessao.accessToken(), 'acesso-2');
      },
    );

    test(
      'chamada que recebe 401 depois de outra já ter renovado não renova de novo',
      () async {
        final liberaLenta = Completer<void>();
        servidor((req) async {
          if (req.path == '/auth/refresh') {
            return _Resp(200, {
              'accessToken': 'acesso-2',
              'refreshToken': 'refresh-2',
            });
          }
          if (req.path == '/lenta' &&
              req.headers['Authorization'] == 'Bearer acesso-1') {
            await liberaLenta.future;
          }
          return req.headers['Authorization'] == 'Bearer acesso-2'
              ? _Resp(200, {'path': req.path})
              : _Resp(401, {'code': 'TOKEN_INVALIDO'});
        });

        final lenta = cliente.get('/lenta'); // sai com acesso-1 e fica pendente
        await cliente.get('/rapida'); // recebe 401 e renova para acesso-2
        liberaLenta.complete();

        expect(await lenta, {'path': '/lenta'});
        expect(chamadas.where((c) => c.path == '/auth/refresh'), hasLength(1));
      },
    );

    test(
      'só tenta refazer uma vez: 401 depois da renovação sobe NaoAutenticado',
      () async {
        servidor((req) {
          if (req.path == '/auth/refresh') {
            return _Resp(200, {
              'accessToken': 'acesso-2',
              'refreshToken': 'refresh-2',
            });
          }
          return _Resp(401, {
            'code': 'TOKEN_INVALIDO',
            'detail': 'Não autenticado.',
          });
        });

        await expectLater(
          cliente.get('/pontos'),
          throwsA(
            isA<NaoAutenticadoException>()
                .having((e) => e.codigo, 'codigo', 'TOKEN_INVALIDO')
                .having(
                  (e) => e.mensagemAmigavel,
                  'mensagem',
                  'Não autenticado.',
                ),
          ),
        );
        expect(chamadas.map((c) => c.path), [
          '/pontos',
          '/auth/refresh',
          '/pontos',
        ]);
      },
    );

    test('refresh recusado limpa a sessão e avisa o app', () async {
      servidor(
        (req) => req.path == '/auth/refresh'
            ? _Resp(401, {'code': 'REFRESH_INVALIDO'})
            : _Resp(401, {'code': 'TOKEN_INVALIDO'}),
      );

      await expectLater(
        cliente.get('/pontos'),
        throwsA(isA<NaoAutenticadoException>()),
      );

      expect(await sessao.accessToken(), isNull);
      expect(await sessao.refreshToken(), isNull);
      expect(sessoesPerdidas, 1);
    });

    test(
      'refresh recusado com várias chamadas pendentes avisa uma vez',
      () async {
        servidor(
          (req) async => req.path == '/auth/refresh'
              ? _Resp(401, {
                  'code': 'REFRESH_INVALIDO',
                }, const Duration(milliseconds: 30))
              : _Resp(401, {'code': 'TOKEN_INVALIDO'}),
        );

        final resultados = await Future.wait([
          cliente
              .get('/a')
              .then<Object?>((_) => null, onError: (Object e) => e),
          cliente
              .get('/b')
              .then<Object?>((_) => null, onError: (Object e) => e),
        ]);

        expect(resultados, everyElement(isA<NaoAutenticadoException>()));
        expect(sessoesPerdidas, 1);
      },
    );

    test(
      'sem refresh token (portal) um 401 encerra a sessão sem chamar o refresh',
      () async {
        await sessao.limpar();
        await sessao.salvar(accessToken: 'so-acesso');
        servidor((_) => _Resp(401, {'code': 'TOKEN_INVALIDO'}));

        await expectLater(
          cliente.get('/x'),
          throwsA(isA<NaoAutenticadoException>()),
        );

        expect(chamadas.map((c) => c.path), ['/x']);
        expect(sessoesPerdidas, 1);
        expect(await sessao.accessToken(), isNull);
      },
    );

    test(
      'falha de rede na renovação mantém a sessão (offline não desloga)',
      () async {
        servidor(
          (req) => req.path == '/auth/refresh'
              ? falhaDeRede(DioExceptionType.connectionError)
              : _Resp(401, {'code': 'TOKEN_INVALIDO'}),
        );

        await expectLater(
          cliente.get('/pontos'),
          throwsA(isA<FalhaDeConexaoException>()),
        );

        expect(await sessao.accessToken(), 'acesso-1');
        expect(await sessao.refreshToken(), 'refresh-1');
        expect(sessoesPerdidas, 0);
      },
    );

    test('5xx na renovação mantém a sessão', () async {
      servidor(
        (req) => req.path == '/auth/refresh'
            ? _Resp(503, {'detail': 'interno'})
            : _Resp(401, {'code': 'TOKEN_INVALIDO'}),
      );

      await expectLater(
        cliente.get('/pontos'),
        throwsA(isA<ErroDoServidorException>()),
      );

      expect(await sessao.refreshToken(), 'refresh-1');
      expect(sessoesPerdidas, 0);
    });

    test('resposta de refresh sem accessToken não derruba a sessão', () async {
      servidor(
        (req) => req.path == '/auth/refresh'
            ? _Resp(200, {'foo': 'bar'})
            : _Resp(401, {'code': 'TOKEN_INVALIDO'}),
      );

      await expectLater(
        cliente.get('/pontos'),
        throwsA(isA<ErroDoServidorException>()),
      );

      expect(await sessao.accessToken(), 'acesso-1');
    });

    test(
      'chamada não autenticada nunca dispara renovação (login errado)',
      () async {
        servidor(
          (_) => _Resp(401, {
            'code': 'CREDENCIAIS_INVALIDAS',
            'detail': 'E-mail ou senha inválidos.',
          }),
        );

        await expectLater(
          cliente.post('/auth/login', corpo: {}, autenticado: false),
          throwsA(
            isA<NaoAutenticadoException>()
                .having((e) => e.codigo, 'codigo', 'CREDENCIAIS_INVALIDAS')
                .having(
                  (e) => e.mensagemAmigavel,
                  'msg',
                  'E-mail ou senha inválidos.',
                ),
          ),
        );
        expect(chamadas, hasLength(1));
        expect(sessoesPerdidas, 0);
        expect(await sessao.accessToken(), 'acesso-1');
      },
    );

    test('refresh sem novo refreshToken mantém o antigo', () async {
      servidor((req) {
        if (req.path == '/auth/refresh') {
          return _Resp(200, {'accessToken': 'acesso-2'});
        }
        return req.headers['Authorization'] == 'Bearer acesso-2'
            ? _Resp(200, {})
            : _Resp(401, {});
      });

      await cliente.get('/x');

      expect(await sessao.refreshToken(), 'refresh-1');
    });
  });

  group('mapeamento de erros', () {
    Future<Object> falha(int status, Object? corpo) async {
      servidor((_) => _Resp(status, corpo));
      try {
        await cliente.get('/x');
      } catch (e) {
        return e;
      }
      fail('deveria lançar');
    }

    test('400 de validação traz os erros por campo', () async {
      final e = await falha(400, {
        'code': 'VALIDACAO_INVALIDA',
        'detail': 'Dados inválidos.',
        'errors': [
          {'field': 'latitude', 'message': 'deve ser <= 90'},
          {'field': 'id', 'message': 'obrigatório'},
          {'quebrado': true},
        ],
      });

      expect(e, isA<RequisicaoInvalidaException>());
      e as RequisicaoInvalidaException;
      expect(e.codigo, 'VALIDACAO_INVALIDA');
      expect(e.status, 400);
      expect(e.mensagemAmigavel, 'Dados inválidos.');
      expect(e.erros.map((x) => '${x.campo}:${x.mensagem}'), [
        'latitude:deve ser <= 90',
        'id:obrigatório',
      ]);
    });

    test('413 e 422 viram RequisicaoInvalida', () async {
      expect(
        await falha(413, {'code': 'LOTE_GRANDE_DEMAIS'}),
        isA<RequisicaoInvalidaException>(),
      );
      expect(
        await falha(422, {'code': 'REGRA'}),
        isA<RequisicaoInvalidaException>(),
      );
    });

    test('403', () async {
      final e = await falha(403, {
        'code': 'ACESSO_NEGADO',
        'detail': 'Sem permissão.',
      });
      expect(e, isA<AcessoNegadoException>());
      expect((e as AcessoNegadoException).mensagemAmigavel, 'Sem permissão.');
    });

    test('404 vira EntidadeNaoEncontradaException', () async {
      final e = await falha(404, {
        'code': 'NAO_ENCONTRADO',
        'detail': 'Ponto não encontrado.',
      });
      expect(e, isA<EntidadeNaoEncontradaException>());
      expect(
        (e as EntidadeNaoEncontradaException).mensagemAmigavel,
        'Ponto não encontrado.',
      );
    });

    test('409 vira OperacaoNaoPermitidaException', () async {
      final e = await falha(409, {
        'code': 'CONFLITO',
        'detail': 'Ponto já encerrado.',
      });
      expect(e, isA<OperacaoNaoPermitidaException>());
      expect(
        (e as OperacaoNaoPermitidaException).mensagemAmigavel,
        'Ponto já encerrado.',
      );
    });

    test('sem detail usa a mensagem padrão', () async {
      final e = await falha(409, '');
      expect(
        (e as OperacaoNaoPermitidaException).mensagemAmigavel,
        AppErrorMessages.operacaoNaoPermitida,
      );
    });

    test('5xx nunca repassa o texto do servidor', () async {
      final e = await falha(500, {
        'code': 'ERRO_INTERNO',
        'detail': 'NullPointerException em br.com.geoprag.Foo.bar(Foo.java:10)',
      });

      expect(e, isA<ErroDoServidorException>());
      e as ErroDoServidorException;
      expect(e.status, 500);
      expect(e.mensagemAmigavel, AppErrorMessages.erroDoServidor);
      expect(e.mensagemAmigavel, isNot(contains('NullPointer')));
    });

    test('corpo que não é JSON não quebra o mapeamento', () async {
      servidor((_) => _Resp(502, '<html>Bad Gateway</html>'));
      await expectLater(
        cliente.get('/x'),
        throwsA(isA<ErroDoServidorException>()),
      );
    });

    test('problem+json como texto é lido', () async {
      servidor((_) => _Resp(404, '{"detail":"Não achei."}'));
      await expectLater(
        cliente.get('/x'),
        throwsA(
          isA<EntidadeNaoEncontradaException>().having(
            (e) => e.mensagemAmigavel,
            'msg',
            'Não achei.',
          ),
        ),
      );
    });

    test('nenhuma exceção expõe DioException, URL ou token', () async {
      servidor((_) => falhaDeRede(DioExceptionType.connectionError));
      try {
        await cliente.get('/pontos');
        fail('deveria lançar');
      } on FalhaDeConexaoException catch (e) {
        expect(e.mensagemAmigavel, AppErrorMessages.semConexao);
        expect('$e', isNot(contains('segredo')));
        expect('$e', isNot(contains('acesso-1')));
      }
    });
  });

  group('falhas de conexão e timeouts', () {
    test('sem rede', () async {
      servidor((_) => falhaDeRede(DioExceptionType.connectionError));

      await expectLater(
        cliente.get('/x'),
        throwsA(
          isA<FalhaDeConexaoException>().having(
            (e) => e.tempoEsgotado,
            'tempoEsgotado',
            isFalse,
          ),
        ),
      );
    });

    test('tempo esgotado em cada fase', () async {
      for (final tipo in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        servidor((_) => falhaDeRede(tipo));
        await expectLater(
          cliente.get('/x'),
          throwsA(
            isA<FalhaDeConexaoException>()
                .having((e) => e.tempoEsgotado, 'tempoEsgotado', isTrue)
                .having(
                  (e) => e.mensagemAmigavel,
                  'msg',
                  AppErrorMessages.tempoEsgotado,
                ),
          ),
          reason: '$tipo',
        );
      }
    });

    test(
      'erro desconhecido e certificado ruim viram falha de conexão',
      () async {
        for (final tipo in [
          DioExceptionType.unknown,
          DioExceptionType.badCertificate,
        ]) {
          servidor((_) => falhaDeRede(tipo));
          await expectLater(
            cliente.get('/x'),
            throwsA(isA<FalhaDeConexaoException>()),
          );
        }
      },
    );

    test(
      'a primeira chamada usa o timeout longo e as seguintes o padrão',
      () async {
        servidor((_) => _Resp(200, {}));

        await cliente.get('/a');
        await cliente.get('/b');

        expect(chamadas[0].connectTimeout, const Duration(seconds: 60));
        expect(chamadas[0].receiveTimeout, const Duration(seconds: 60));
        expect(chamadas[1].connectTimeout, const Duration(seconds: 15));
        expect(chamadas[1].receiveTimeout, const Duration(seconds: 15));
      },
    );

    test(
      'enquanto o servidor não responde continua no timeout longo',
      () async {
        servidor((_) => falhaDeRede(DioExceptionType.connectionTimeout));
        await expectLater(
          cliente.get('/a'),
          throwsA(isA<FalhaDeConexaoException>()),
        );
        await expectLater(
          cliente.get('/b'),
          throwsA(isA<FalhaDeConexaoException>()),
        );

        expect(chamadas.map((c) => c.connectTimeout), [
          const Duration(seconds: 60),
          const Duration(seconds: 60),
        ]);
      },
    );

    test('um erro HTTP também prova que o servidor está de pé', () async {
      servidor((_) => _Resp(404, {}));
      await expectLater(
        cliente.get('/a'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
      await expectLater(
        cliente.get('/b'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );

      expect(chamadas[1].connectTimeout, const Duration(seconds: 15));
    });
  });

  group('ApiClientProvider', () {
    tearDown(ApiClientProvider.redefinir);

    test('configurar define a instância única compartilhada', () {
      ApiClientProvider.configurar(cliente);

      expect(ApiClientProvider.instancia, same(cliente));
      expect(const AplicadorBootstrap().buildApiClient(), same(cliente));
      expect(const AdminBootstrap().buildApiClient(), same(cliente));
    });

    test('sem configurar nem API_BASE_URL, falha de forma explícita', () {
      ApiClientProvider.redefinir();

      expect(() => ApiClientProvider.instancia, throwsStateError);
    });
  });

  group('SessaoDeTokensEmMemoria', () {
    test(
      'salvar sem refresh preserva o anterior; limpar apaga os dois',
      () async {
        final s = SessaoDeTokensEmMemoria();
        await s.salvar(accessToken: 'a', refreshToken: 'r');
        await s.salvar(accessToken: 'b');
        expect(await s.accessToken(), 'b');
        expect(await s.refreshToken(), 'r');

        await s.limpar();
        expect(await s.accessToken(), isNull);
        expect(await s.refreshToken(), isNull);
      },
    );
  });
}
