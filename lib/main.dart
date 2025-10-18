import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io' show Platform;

void main() {
  runApp(const TriangleCalculatorApp());
}

class TriangleCalculatorApp extends StatelessWidget {
  const TriangleCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор Треугольника',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _getSeedColor(),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _getSeedColor(),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TriangleCalculatorPage(),
    );
  }

  Color _getSeedColor() {
    try {
      if (Platform.isAndroid) {
        return Colors.blue; // На Android будет использоваться системная тема
      }
    } catch (e) {
      // Для веб или других платформ
    }
    // Для iOS - случайный цвет
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}

class TriangleCalculatorPage extends StatefulWidget {
  const TriangleCalculatorPage({super.key});

  @override
  State<TriangleCalculatorPage> createState() => _TriangleCalculatorPageState();
}

class _TriangleCalculatorPageState extends State<TriangleCalculatorPage> {
  final Map<String, double?> _parameters = {};
  final TriangleCalculator _calculator = TriangleCalculator();

  void _addParameter(String type, double value) {
    setState(() {
      _parameters[type] = value;
      _calculator.calculate(_parameters);
    });
  }

  void _removeParameter(String type) {
    setState(() {
      _parameters.remove(type);
      _calculator.calculate(_parameters);
    });
  }

  void _showAddParameterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddParameterSheet(
        onAdd: _addParameter,
        existingParameters: _parameters.keys.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculated = _calculator.results;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор Треугольника'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_parameters.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Добавьте параметры треугольника',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Введенные параметры
                if (_parameters.isNotEmpty) ...[
                  Text(
                    'Введенные параметры',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._parameters.entries.map(
                    (e) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(_getParameterName(e.key)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e.value!.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeParameter(e.key),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Вычисленные параметры
                if (calculated.isNotEmpty) ...[
                  Text(
                    'Вычисленные параметры',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...calculated.entries
                      .where((e) => !_parameters.containsKey(e.key))
                      .map(
                        (e) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          child: ListTile(
                            title: Text(_getParameterName(e.key)),
                            trailing: Text(
                              e.value.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddParameterDialog,
        icon: const Icon(Icons.add),
        label: const Text('Добавить параметр'),
      ),
    );
  }

  String _getParameterName(String key) {
    const names = {
      'a': 'Сторона a',
      'b': 'Сторона b',
      'c': 'Сторона c',
      'alpha': 'Угол α',
      'beta': 'Угол β',
      'gamma': 'Угол γ',
      'ha': 'Высота ha',
      'hb': 'Высота hb',
      'hc': 'Высота hc',
      'ma': 'Медиана ma',
      'mb': 'Медиана mb',
      'mc': 'Медиана mc',
      'la': 'Биссектриса la',
      'lb': 'Биссектриса lb',
      'lc': 'Биссектриса lc',
      'mab': 'Средняя линия mab',
      'mbc': 'Средняя линия mbc',
      'mac': 'Средняя линия mac',
      'P': 'Периметр',
      'S': 'Площадь',
      'sin_alpha': 'sin α',
      'sin_beta': 'sin β',
      'sin_gamma': 'sin γ',
      'cos_alpha': 'cos α',
      'cos_beta': 'cos β',
      'cos_gamma': 'cos γ',
    };
    return names[key] ?? key;
  }
}

class AddParameterSheet extends StatefulWidget {
  final Function(String, double) onAdd;
  final List<String> existingParameters;

  const AddParameterSheet({
    super.key,
    required this.onAdd,
    required this.existingParameters,
  });

  @override
  State<AddParameterSheet> createState() => _AddParameterSheetState();
}

class _AddParameterSheetState extends State<AddParameterSheet> {
  String? _selectedParameter;
  final _controller = TextEditingController();

  final List<Map<String, String>> _parameterGroups = [
    {'group': 'Стороны', 'params': 'a,b,c'},
    {'group': 'Углы (градусы)', 'params': 'alpha,beta,gamma'},
    {'group': 'Высоты', 'params': 'ha,hb,hc'},
    {'group': 'Медианы', 'params': 'ma,mb,mc'},
    {'group': 'Биссектрисы', 'params': 'la,lb,lc'},
    {'group': 'Средние линии', 'params': 'mab,mbc,mac'},
    {'group': 'Прочее', 'params': 'P,S'},
    {'group': 'Синусы', 'params': 'sin_alpha,sin_beta,sin_gamma'},
    {'group': 'Косинусы', 'params': 'cos_alpha,cos_beta,cos_gamma'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Добавить параметр',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedParameter,
            decoration: const InputDecoration(
              labelText: 'Выберите параметр',
              border: OutlineInputBorder(),
            ),
            items: _parameterGroups.expand((group) {
              final params = group['params']!.split(',');
              return [
                DropdownMenuItem<String>(
                  enabled: false,
                  child: Text(
                    group['group']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...params
                    .where((p) => !widget.existingParameters.contains(p))
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(_getParameterName(p)),
                        ),
                      ),
                    ),
              ];
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedParameter = value;
              });
            },
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Значение',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          FilledButton(
            onPressed: _selectedParameter == null
                ? null
                : () {
                    final value = double.tryParse(_controller.text);
                    if (value != null && _selectedParameter != null) {
                      widget.onAdd(_selectedParameter!, value);
                      Navigator.pop(context);
                    }
                  },
            child: const Text('Добавить'),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getParameterName(String key) {
    const names = {
      'a': 'Сторона a',
      'b': 'Сторона b',
      'c': 'Сторона c',
      'alpha': 'Угол α',
      'beta': 'Угол β',
      'gamma': 'Угол γ',
      'ha': 'Высота ha',
      'hb': 'Высота hb',
      'hc': 'Высота hc',
      'ma': 'Медиана ma',
      'mb': 'Медиана mb',
      'mc': 'Медиана mc',
      'la': 'Биссектриса la',
      'lb': 'Биссектриса lb',
      'lc': 'Биссектриса lc',
      'mab': 'Средняя линия mab',
      'mbc': 'Средняя линия mbc',
      'mac': 'Средняя линия mac',
      'P': 'Периметр',
      'S': 'Площадь',
      'sin_alpha': 'sin α',
      'sin_beta': 'sin β',
      'sin_gamma': 'sin γ',
      'cos_alpha': 'cos α',
      'cos_beta': 'cos β',
      'cos_gamma': 'cos γ',
    };
    return names[key] ?? key;
  }
}

class TriangleCalculator {
  Map<String, double> results = {};

  void calculate(Map<String, double?> params) {
    results.clear();

    // Копируем введенные параметры
    params.forEach((key, value) {
      if (value != null) results[key] = value;
    });

    // Конвертируем углы в радианы для вычислений
    final alpha = params['alpha'] != null ? params['alpha']! * pi / 180 : null;
    final beta = params['beta'] != null ? params['beta']! * pi / 180 : null;
    final gamma = params['gamma'] != null ? params['gamma']! * pi / 180 : null;

    // Вычисление через три стороны
    if (params['a'] != null && params['b'] != null && params['c'] != null) {
      final a = params['a']!;
      final b = params['b']!;
      final c = params['c']!;

      results['P'] = a + b + c;
      final p = results['P']! / 2;
      results['S'] = sqrt(p * (p - a) * (p - b) * (p - c));

      // Углы через теорему косинусов
      results['alpha'] = acos((b * b + c * c - a * a) / (2 * b * c)) * 180 / pi;
      results['beta'] = acos((a * a + c * c - b * b) / (2 * a * c)) * 180 / pi;
      results['gamma'] = acos((a * a + b * b - c * c) / (2 * a * b)) * 180 / pi;

      // Высоты
      results['ha'] = 2 * results['S']! / a;
      results['hb'] = 2 * results['S']! / b;
      results['hc'] = 2 * results['S']! / c;

      // Медианы
      results['ma'] = sqrt(2 * b * b + 2 * c * c - a * a) / 2;
      results['mb'] = sqrt(2 * a * a + 2 * c * c - b * b) / 2;
      results['mc'] = sqrt(2 * a * a + 2 * b * b - c * c) / 2;

      // Средние линии
      results['mab'] = c / 2;
      results['mbc'] = a / 2;
      results['mac'] = b / 2;

      // Синусы и косинусы
      results['sin_alpha'] = sin(results['alpha']! * pi / 180);
      results['sin_beta'] = sin(results['beta']! * pi / 180);
      results['sin_gamma'] = sin(results['gamma']! * pi / 180);
      results['cos_alpha'] = cos(results['alpha']! * pi / 180);
      results['cos_beta'] = cos(results['beta']! * pi / 180);
      results['cos_gamma'] = cos(results['gamma']! * pi / 180);
    }
    // Два угла и сторона
    else if (alpha != null && beta != null && params['a'] != null) {
      final a = params['a']!;
      final g = pi - alpha - beta;
      results['gamma'] = g * 180 / pi;

      results['b'] = a * sin(beta) / sin(alpha);
      results['c'] = a * sin(g) / sin(alpha);

      calculate(results);
    }
    // Две стороны и угол между ними
    else if (params['a'] != null && params['b'] != null && gamma != null) {
      final a = params['a']!;
      final b = params['b']!;

      results['c'] = sqrt(a * a + b * b - 2 * a * b * cos(gamma));
      calculate(results);
    }
    // Периметр и площадь
    else if (params['P'] != null && params['S'] != null) {
      // Сложный случай, требует дополнительных данных
    }
    // Вычисление через площадь и сторону
    else if (params['S'] != null && params['a'] != null) {
      final s = params['S']!;
      final a = params['a']!;
      results['ha'] = 2 * s / a;
    }
  }
}
