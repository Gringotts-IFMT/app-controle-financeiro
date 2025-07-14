import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReceitasPorCategoriaPieChart extends StatelessWidget {
  final Map<String, double> receitasPorCategoria;

  const ReceitasPorCategoriaPieChart({
    Key? key,
    required this.receitasPorCategoria,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = receitasPorCategoria.values.fold(0.0, (a, b) => a + b);
    final categorias = receitasPorCategoria.keys.toList();
    final valores = receitasPorCategoria.values.toList();

    if (receitasPorCategoria.isEmpty) {
      return Center(child: Text('Nenhuma receita registrada.'));
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: List.generate(categorias.length, (i) {
                final percent = (valores[i] / total) * 100;
                return PieChartSectionData(
                  value: valores[i],
                  title: '${percent.toStringAsFixed(1)}%',
                  color: _getGreenColor(i),
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: List.generate(categorias.length, (i) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getGreenColor(i),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  categorias[i],
                  style: TextStyle(fontSize: 13),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Color _getGreenColor(int index) {
    // Tons de verde do mais escuro ao mais claro
    const colors = [
      Color(0xFF1B5E20), // Verde escuro
      Color(0xFF388E3C),
      Color(0xFF43A047),
      Color(0xFF4CAF50),
      Color(0xFF66BB6A),
      Color(0xFF81C784),
      Color(0xFFA5D6A7),
      Color(0xFFC8E6C9), // Verde claro
    ];
    return colors[index % colors.length];
  }
}
