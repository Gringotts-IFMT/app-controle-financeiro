import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GastosPorCategoriaPieChart extends StatelessWidget {
  final Map<String, double> gastosPorCategoria;

  const GastosPorCategoriaPieChart({
    Key? key,
    required this.gastosPorCategoria,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = gastosPorCategoria.values.fold(0.0, (a, b) => a + b);
    final categorias = gastosPorCategoria.keys.toList();
    final valores = gastosPorCategoria.values.toList();

    if (gastosPorCategoria.isEmpty) {
      return Center(child: Text('Nenhum gasto registrado.'));
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
                  color: _getColor(i),
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
                    color: _getColor(i),
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

  Color _getColor(int index) {
    // Lista de cores para as fatias do gráfico
    const colors = [
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.brown,
      Colors.red,
      Colors.green,
      Colors.pink,
      Colors.cyan,
      Colors.indigo,
      Colors.teal,
      Colors.grey,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }
}
