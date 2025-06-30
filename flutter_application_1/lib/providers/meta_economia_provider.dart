import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Importante: Para obter o ID do usuário
import '../models/meta_economia.dart';
import '../enums/status_meta_economia.dart';
import '../services/database_service.dart'; // Seu DatabaseService será ajustado em seguida
import 'package:controle_financeiro/Models/usuario.dart'; // Opcional, se precisar referenciar o modelo do Usuario aqui.


class MetaEconomiaProvider with ChangeNotifier {
  List<MetaEconomia> _metas = [];
  bool _isLoading = false;
  String? _erro;
  StreamSubscription<List<MetaEconomia>>? _metasSubscription;

  List<MetaEconomia> get metas => _metas;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  // Getter para metas ativas
  List<MetaEconomia> get metasAtivas =>
      _metas.where((meta) => meta.status == StatusMetaEconomia.ativa).toList();

  // Getter para metas concluídas
  List<MetaEconomia> get metasConcluidas =>
      _metas.where((meta) => meta.status == StatusMetaEconomia.concluida).toList();

  // Getter para metas vencidas
  List<MetaEconomia> get metasVencidas =>
      _metas.where((meta) => meta.metaVencida).toList();

  final DatabaseService _databaseService = DatabaseService();

  // Getter para o ID do usuário atual do Firebase Auth
  // Isso será o 'userId' que você usará nas metas.
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Inicializar stream listener
  void inicializarListener() {
    _metasSubscription?.cancel(); // Cancela qualquer listener anterior
    
    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para carregar metas. Por favor, faça login.';
      _metas = []; // Limpa metas se não houver usuário logado
      _isLoading = false; // Garante que o loading seja falso
      notifyListeners();
      return;
    }

    // Passa o userId para o DatabaseService para filtrar as metas
    _metasSubscription = _databaseService.streamMetas(userId).listen(
      (metasCarregadas) { // Nomeei a variável para evitar confusão com o getter 'metas'
        _metas = metasCarregadas;
        _ordenarMetas();
        _erro = null;
        _isLoading = false; // Quando os dados chegam, o loading deve ser falso
        notifyListeners();
      },
      onError: (error, stackTrace) { // Adicione stackTrace para melhor depuração
        _erro = 'Erro ao escutar mudanças nas metas: $error';
        _isLoading = false; // Garante que o loading seja falso
        notifyListeners();
        print('Erro no listener de metas: $error\n$stackTrace'); // Para debug mais completo
      },
      onDone: () {
        print('Stream de metas concluída.');
      },
    ) as StreamSubscription<List<MetaEconomia>>?;
    // O loading deve ser true enquanto espera o primeiro dado do stream
    if (!_isLoading && _metas.isEmpty) { // Apenas para o estado inicial
       _isLoading = true;
       notifyListeners();
    }
  }

  // Carregar metas (método alternativo sem stream)
  Future<void> carregarMetas() async {
    _setLoading(true);
    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para carregar metas.';
      _metas = [];
      _setLoading(false);
      return;
    }
    try {
      _metas = await _databaseService.buscarMetas(userId); // <--- Passando userId
      _ordenarMetas();
      _erro = null;
    } catch (e) {
      _erro = 'Erro ao carregar metas: $e';
      print('Erro ao carregar metas: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Adicionar nova meta
  Future<bool> adicionarMeta(MetaEconomia meta) async {
    _setLoading(true);
    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para adicionar meta.';
      _setLoading(false);
      return false;
    }
    try {
      // Cria uma cópia da meta com o userId do usuário logado antes de enviar ao DB
      // Isso garante que a meta que vai para o Firestore tenha o userId correto
      final metaComUserId = meta.copyWith(userId: userId); // <--- Adiciona o userId aqui
      await _databaseService.addOrUpdateMetaEconomia(metaComUserId, userId); // Passa a meta com userId e userId como argumento
      _erro = null;
      // Se o listener de stream estiver ativo, ele já atualizará a lista.
      // Se não, adiciona manualmente para atualização imediata na UI.
      if (_metasSubscription == null) {
        _metas.add(metaComUserId);
        _ordenarMetas();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _erro = 'Erro ao adicionar meta: $e';
      print('Erro ao adicionar meta: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar meta existente
  Future<bool> atualizarMeta(MetaEconomia meta) async {
    _setLoading(true);
    final userId = currentUserId;
    if (meta.id == null || userId == null) {
      _erro = 'ID da meta ou usuário não logado para atualização.';
      _setLoading(false);
      return false;
    }
    try {
      // Cria uma cópia da meta para atualização, garantindo o userId e dataAtualizacao
      final metaParaAtualizar = meta.copyWith(userId: userId, dataAtualizacao: DateTime.now());
      await _databaseService.atualizarStatusMeta(
        metaParaAtualizar.id!,
        metaParaAtualizar.status.name,
        userId,
      ); // <--- Passa id, status e userId
      _erro = null;
      // Se o listener de stream estiver ativo, ele já atualizará a lista.
      // Se não, atualiza manualmente.
      if (_metasSubscription == null) {
        final index = _metas.indexWhere((m) => m.id == meta.id);
        if (index != -1) {
          _metas[index] = metaParaAtualizar; // Usa a meta atualizada
          _ordenarMetas();
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _erro = 'Erro ao atualizar meta: $e';
      print('Erro ao atualizar meta: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Excluir meta
  Future<bool> excluirMeta(String id) async {
    _setLoading(true);
    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para excluir meta.';
      _setLoading(false);
      return false;
    }
    try {
      // Passa o userId para o DatabaseService para que ele possa validar a posse
      await _databaseService.deleteMetaEconomia(id, userId); // <--- Passando userId
      _erro = null;
      // Se o listener de stream estiver ativo, ele já removerá da lista.
      // Se não, remove manualmente.
      if (_metasSubscription == null) {
        _metas.removeWhere((meta) => meta.id == id);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _erro = 'Erro ao excluir meta: $e';
      print('Erro ao excluir meta: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar valor atual da meta (método otimizado para Firebase)
  Future<bool> atualizarValorMeta(String id, double novoValor) async {
    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para atualizar valor da meta.';
      notifyListeners();
      return false;
    }
    try {
      // Passa o userId para o DatabaseService para validação
      await _databaseService.atualizarValorAtualMeta(id, novoValor, userId); // <--- Passando userId
      
      // Considera sucesso se não lançar exceção
      _erro = null;
      // Após a atualização no DB, o stream listener (se ativo) vai atualizar a lista.
      // Se não tiver stream, você teria que buscar a meta e atualizar localmente.
      // Mas para a lógica de conclusão, podemos verificar a meta atual da lista
      // (que o stream já deve ter atualizado ou será atualizada em breve).
      final meta = buscarMetaPorId(id);
      if (meta != null && novoValor >= meta.valorMeta && meta.status != StatusMetaEconomia.concluida) {
        // Marca como concluída se o valor for atingido e ainda não estiver
        await _databaseService.atualizarStatusMeta(id, StatusMetaEconomia.concluida.name, userId); // <--- Passando userId
      }
      return true;
    } catch (e) {
      _erro = 'Erro ao atualizar valor da meta: $e';
      print('Erro ao atualizar valor da meta: $e');
      return false;
    }
  }

  // Pausar meta
  Future<bool> pausarMeta(String id) async {
    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para pausar meta.';
      notifyListeners();
      return false;
    }
    return await _alterarStatusMeta(id, StatusMetaEconomia.pausada, userId);
  }

  // Reativar meta
  Future<bool> reativarMeta(String id) async {
    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para reativar meta.';
      notifyListeners();
      return false;
    }
    return await _alterarStatusMeta(id, StatusMetaEconomia.ativa, userId);
  }

  // Cancelar meta
  Future<bool> cancelarMeta(String id) async {
    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para cancelar meta.';
      notifyListeners();
      return false;
    }
    return await _alterarStatusMeta(id, StatusMetaEconomia.cancelada, userId);
  }

  // Buscar meta por ID (na lista local, que é atualizada pelo stream ou carregamento manual)
  MetaEconomia? buscarMetaPorId(String id) {
    try {
      return _metas.firstWhere((meta) => meta.id == id);
    } catch (e) {
      // Não encontrou, o que é comum e não é um erro grave, apenas significa que não está na lista
      print('Meta com ID $id não encontrada na lista local.');
      return null;
    }
  }

  // Buscar metas por categoria (na lista local)
  List<MetaEconomia> buscarMetasPorCategoria(String categoria) {
    return _metas
        .where((meta) => meta.categoria?.toLowerCase() == categoria.toLowerCase())
        .toList();
  }

  // Buscar metas que estão vencendo (requer o userId para a query no DB)
  Future<List<Object>> buscarMetasVencendo(int dias) async {
    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para buscar metas vencendo.';
      notifyListeners();
      return [];
    }
    try {
      return await _databaseService.buscarMetasVencendo(dias, userId); // <--- Passando userId
    } catch (e) {
      _erro = 'Erro ao buscar metas vencendo: $e';
      print('Erro ao buscar metas vencendo: $e');
      return [];
    }
  }

  // Calcular total economizado (já ok)
  double get totalEconomizado {
    return _metas
        .where((meta) => meta.status == StatusMetaEconomia.concluida)
        .fold(0.0, (total, meta) => total + meta.valorAtual);
  }

  // Calcular total de metas ativas (já ok)
  double get totalMetasAtivas {
    return metasAtivas.fold(0.0, (total, meta) => total + meta.valorMeta);
  }

  // Calcular progresso geral das metas ativas (já ok)
  double get progressoGeralMetas {
    final metasAtivas = this.metasAtivas;
    if (metasAtivas.isEmpty) return 0.0;
    
    final totalMeta = metasAtivas.fold(0.0, (total, meta) => total + meta.valorMeta);
    final totalAtual = metasAtivas.fold(0.0, (total, meta) => total + meta.valorAtual);
    
    return totalMeta > 0 ? (totalAtual / totalMeta) * 100 : 0.0;
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _ordenarMetas() {
    _metas.sort((a, b) {
      // Prioridade: ativas primeiro, depois por data de fim
      if (a.status == StatusMetaEconomia.ativa && b.status != StatusMetaEconomia.ativa) {
        return -1;
      }
      if (b.status == StatusMetaEconomia.ativa && a.status != StatusMetaEconomia.ativa) {
        return 1;
      }
      return a.dataFim.compareTo(b.dataFim);
    });
  }

  // Método auxiliar para alterar status, agora recebendo userId
  Future<bool> _alterarStatusMeta(String id, StatusMetaEconomia novoStatus, String userId) async {
    try {
      await _databaseService.atualizarStatusMeta(id, novoStatus.name, userId); // <--- Passando userId
      _erro = null;
      return true;
    } catch (e) {
      _erro = 'Erro ao alterar status da meta: $e';
      print('Erro ao alterar status da meta: $e');
      return false;
    }
  }

  // Limpar erro
  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  // Limpar recursos ao descartar o provider
  @override
  void dispose() {
    _metasSubscription?.cancel();
    super.dispose();
  }
}