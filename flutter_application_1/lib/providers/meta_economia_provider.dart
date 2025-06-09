import 'package:flutter/foundation.dart';
import 'dart:async';
import '../Models/meta_economia.dart';
import '../enums/status_meta_economia.dart';
import '../services/database_service.dart';

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

  // Inicializar stream listener
  void inicializarListener() {
    _metasSubscription?.cancel();
    _metasSubscription = _databaseService.streamMetas().listen(
      (metas) {
        _metas = metas;
        _ordenarMetas();
        _erro = null;
        notifyListeners();
      },
      onError: (error) {
        _erro = 'Erro ao escutar mudanças: $error';
        notifyListeners();
      },
    );
  }

  // Carregar metas (método alternativo sem stream)
  Future<void> carregarMetas() async {
    _setLoading(true);
    try {
      _metas = await _databaseService.buscarMetas();
      _ordenarMetas();
      _erro = null;
    } catch (e) {
      _erro = 'Erro ao carregar metas: $e';
      print(_erro);
    } finally {
      _setLoading(false);
    }
  }

  // Adicionar nova meta
  Future<bool> adicionarMeta(MetaEconomia meta) async {
    _setLoading(true);
    try {
      final id = await _databaseService.inserirMeta(meta);
      if (id != null) {
        _erro = null;
        // Se não estiver usando stream, adicionar manualmente
        if (_metasSubscription == null) {
          final novaMeta = meta.copyWith(id: id);
          _metas.add(novaMeta);
          _ordenarMetas();
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _erro = 'Erro ao adicionar meta: $e';
      print(_erro);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar meta existente
  Future<bool> atualizarMeta(MetaEconomia meta) async {
    _setLoading(true);
    try {
      final sucesso = await _databaseService.atualizarMeta(meta);
      if (sucesso) {
        _erro = null;
        // Se não estiver usando stream, atualizar manualmente
        if (_metasSubscription == null) {
          final index = _metas.indexWhere((m) => m.id == meta.id);
          if (index != -1) {
            _metas[index] = meta.copyWith(dataAtualizacao: DateTime.now());
            _ordenarMetas();
            notifyListeners();
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      _erro = 'Erro ao atualizar meta: $e';
      print(_erro);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Excluir meta
  Future<bool> excluirMeta(String id) async {
    _setLoading(true);
    try {
      final sucesso = await _databaseService.excluirMeta(id);
      if (sucesso) {
        _erro = null;
        // Se não estiver usando stream, remover manualmente
        if (_metasSubscription == null) {
          _metas.removeWhere((meta) => meta.id == id);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _erro = 'Erro ao excluir meta: $e';
      print(_erro);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar valor atual da meta (método otimizado para Firebase)
  Future<bool> atualizarValorMeta(String id, double novoValor) async {
    try {
      // Usar método otimizado do Firebase para atualizar apenas o valor
      final sucesso = await _databaseService.atualizarValorAtualMeta(id, novoValor);
      
      if (sucesso) {
        // Verificar se a meta foi concluída
        final meta = buscarMetaPorId(id);
        if (meta != null && novoValor >= meta.valorMeta) {
          await _databaseService.atualizarStatusMeta(id, 'concluida');
        }
        _erro = null;
        return true;
      }
      return false;
    } catch (e) {
      _erro = 'Erro ao atualizar valor da meta: $e';
      return false;
    }
  }

  // Pausar meta
  Future<bool> pausarMeta(String id) async {
    return await _alterarStatusMeta(id, StatusMetaEconomia.pausada);
  }

  // Reativar meta
  Future<bool> reativarMeta(String id) async {
    return await _alterarStatusMeta(id, StatusMetaEconomia.ativa);
  }

  // Cancelar meta
  Future<bool> cancelarMeta(String id) async {
    return await _alterarStatusMeta(id, StatusMetaEconomia.cancelada);
  }

  // Buscar meta por ID
  MetaEconomia? buscarMetaPorId(String id) {
    try {
      return _metas.firstWhere((meta) => meta.id == id);
    } catch (e) {
      return null;
    }
  }

  // Buscar metas por categoria
  List<MetaEconomia> buscarMetasPorCategoria(String categoria) {
    return _metas
        .where((meta) => meta.categoria?.toLowerCase() == categoria.toLowerCase())
        .toList();
  }

  // Buscar metas que estão vencendo
  Future<List<MetaEconomia>> buscarMetasVencendo(int dias) async {
    try {
      return await _databaseService.buscarMetasVencendo(dias);
    } catch (e) {
      _erro = 'Erro ao buscar metas vencendo: $e';
      return [];
    }
  }

  // Calcular total economizado
  double get totalEconomizado {
    return _metas
        .where((meta) => meta.status == StatusMetaEconomia.concluida)
        .fold(0.0, (total, meta) => total + meta.valorAtual);
  }

  // Calcular total de metas ativas
  double get totalMetasAtivas {
    return metasAtivas.fold(0.0, (total, meta) => total + meta.valorMeta);
  }

  // Calcular progresso geral das metas ativas
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

  Future<bool> _alterarStatusMeta(String id, StatusMetaEconomia novoStatus) async {
    try {
      final sucesso = await _databaseService.atualizarStatusMeta(id, novoStatus.name);
      if (sucesso) {
        _erro = null;
        return true;
      }
      return false;
    } catch (e) {
      _erro = 'Erro ao alterar status da meta: $e';
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