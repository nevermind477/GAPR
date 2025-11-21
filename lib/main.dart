import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const GeometryCalculatorApp());
}

class GeometryCalculatorApp extends StatefulWidget {
  const GeometryCalculatorApp({super.key});

  @override
  State<GeometryCalculatorApp> createState() => _GeometryCalculatorAppState();
}

class _GeometryCalculatorAppState extends State<GeometryCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blue;
  String _colorMode = 'system';

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  void updateTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void updateColor(String mode, [Color? color]) {
    setState(() {
      _colorMode = mode;
      if (mode == 'random') {
        _seedColor = _generateRandomColor();
      } else if (mode == 'custom' && color != null) {
        _seedColor = color;
      } else if (mode == 'system') {
        _seedColor = Colors.blue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор Фигур',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MainNavigationPage(
        onThemeChange: updateTheme,
        onColorChange: updateColor,
        currentThemeMode: _themeMode,
        currentColorMode: _colorMode,
        currentColor: _seedColor,
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChange;
  final Function(String, [Color?]) onColorChange;
  final ThemeMode currentThemeMode;
  final String currentColorMode;
  final Color currentColor;

  const MainNavigationPage({
    super.key,
    required this.onThemeChange,
    required this.onColorChange,
    required this.currentThemeMode,
    required this.currentColorMode,
    required this.currentColor,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const TriangleCalculatorPage(),
      SettingsPage(
        onThemeChange: widget.onThemeChange,
        onColorChange: widget.onColorChange,
        currentThemeMode: widget.currentThemeMode,
        currentColorMode: widget.currentColorMode,
        currentColor: widget.currentColor,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.change_history),
            label: 'Треугольник',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}

// ===== ТРЕУГОЛЬНИК С ПРОДВИНУТЫМ РЕШАТЕЛЕМ =====

class TriangleCalculatorPage extends StatefulWidget {
  const TriangleCalculatorPage({super.key});

  @override
  State<TriangleCalculatorPage> createState() => _TriangleCalculatorPageState();
}

class _TriangleCalculatorPageState extends State<TriangleCalculatorPage> {
  final Map<String, double> _inputParameters = {};
  final TriangleSolver _solver = TriangleSolver();

  void _addParameter(String type, double value) {
    setState(() {
      _inputParameters[type] = value;
      _solver.clear();
      _inputParameters.forEach((key, val) {
        _solver.setValue(key, val);
      });
      _solver.solve();
    });
  }

  void _removeParameter(String type) {
    setState(() {
      _inputParameters.remove(type);
      _solver.clear();
      _inputParameters.forEach((key, val) {
        _solver.setValue(key, val);
      });
      _solver.solve();
    });
  }

  void _showAddParameterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddParameterSheet(
        onAdd: _addParameter,
        existingParameters: _inputParameters.keys.toList(),
      ),
    );
  }

  String _formatNumber(double value) {
    // Округляем до 3 знаков и убираем лишние нули
    final rounded = double.parse(value.toStringAsFixed(3));
    final str = rounded.toString();
    // Убираем .0 если это целое число
    if (str.endsWith('.0')) {
      return str.substring(0, str.length - 2);
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final computed = _solver.data.entries
        .where((e) => !_inputParameters.containsKey(e.key))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Треугольник'), centerTitle: true),
      body: Column(
        children: [
          // Введённые параметры
          if (_inputParameters.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Введённые параметры',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _inputParameters.entries.map((e) {
                      return Chip(
                        label: Text(
                          '${_getParameterName(e.key)}: ${_formatNumber(e.value)}',
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeParameter(e.key),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          Expanded(
            child: computed.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Добавьте параметры для вычисления',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Вычисленные параметры (${computed.length})',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...computed.map(
                      (e) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    child: ListTile(
                      title: Text(_getParameterName(e.key)),
                      trailing: Text(
                        _formatNumber(e.value),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
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
      'A': 'Угол A (°)',
      'B': 'Угол B (°)',
      'C': 'Угол C (°)',
      'sinA': 'sin A',
      'sinB': 'sin B',
      'sinC': 'sin C',
      'cosA': 'cos A',
      'cosB': 'cos B',
      'cosC': 'cos C',
      'tanA': 'tan A',
      'tanB': 'tan B',
      'tanC': 'tan C',
      'S': 'Площадь',
      'P': 'Периметр',
      'p': 'Полупериметр',
      'R': 'Радиус описанной',
      'r': 'Радиус вписанной',
      'ha': 'Высота ha',
      'hb': 'Высота hb',
      'hc': 'Высота hc',
      'ma': 'Медиана ma',
      'mb': 'Медиана mb',
      'mc': 'Медиана mc',
      'la': 'Биссектриса la',
      'lb': 'Биссектриса lb',
      'lc': 'Биссектриса lc',
      'mla': 'Средняя линия || a',
      'mlb': 'Средняя линия || b',
      'mlc': 'Средняя линия || c',
    };
    return names[key] ?? key;
  }
}

// ===== ПРОДВИНУТЫЙ РЕШАТЕЛЬ ТРЕУГОЛЬНИКОВ =====

class TriangleSolver {
  final Map<String, double> data = {};
  final int precision = 3;

  void clear() {
    data.clear();
  }

  void setValue(String name, double value) {
    // Углы от 0 до 180
    if (name == 'A' || name == 'B' || name == 'C') {
      if (value <= 0 || value >= 180) return;
    }
    // Остальные величины положительные (кроме тригонометрии)
    else if (!name.startsWith('sin') &&
        !name.startsWith('cos') &&
        !name.startsWith('tan')) {
      if (value <= 0) return;
    }
    data[name] = _round(value);
  }

  double? get(String name) => data[name];
  bool has(String name) => data.containsKey(name);

  double _round(double value) {
    return double.parse(value.toStringAsFixed(precision));
  }

  double _toRad(double degrees) => degrees * pi / 180;
  double _toDeg(double radians) => radians * 180 / pi;

  void solve() {
    const maxIterations = 50;
    for (int i = 0; i < maxIterations; i++) {
      final oldCount = data.length;

      _applyAngleSum();
      _applyTrigIdentities();
      _applySineCosineRules();
      _applyAreaFormulas();
      _applyRadiusFormulas();
      _applyHeightFormulas();
      _applyMedianFormulas();
      _applyBisectorFormulas();
      _applyMidlineFormulas();
      _applyPerimeterFormulas();

      if (data.length == oldCount) break;
    }
  }

  void _applyAngleSum() {
    // A + B + C = 180
    if (has('A') && has('B') && !has('C')) {
      setValue('C', 180 - get('A')! - get('B')!);
    } else if (has('A') && has('C') && !has('B')) {
      setValue('B', 180 - get('A')! - get('C')!);
    } else if (has('B') && has('C') && !has('A')) {
      setValue('A', 180 - get('B')! - get('C')!);
    }
  }

  void _applyTrigIdentities() {
    for (final angleName in ['A', 'B', 'C']) {
      final sinName = 'sin$angleName';
      final cosName = 'cos$angleName';
      final tanName = 'tan$angleName';

      // Если известен угол → вычисляем sin, cos, tan
      if (has(angleName)) {
        final angleRad = _toRad(get(angleName)!);
        if (!has(sinName)) setValue(sinName, sin(angleRad));
        if (!has(cosName)) setValue(cosName, cos(angleRad));
        if (!has(tanName)) setValue(tanName, tan(angleRad));
      }

      // sin → угол
      if (has(sinName) && !has(angleName)) {
        final sinVal = get(sinName)!;
        if (sinVal > 0 && sinVal <= 1) {
          setValue(angleName, _toDeg(asin(sinVal)));
        }
      }

      // cos → угол
      if (has(cosName) && !has(angleName)) {
        final cosVal = get(cosName)!;
        if (cosVal >= -1 && cosVal < 1) {
          setValue(angleName, _toDeg(acos(cosVal)));
        }
      }

      // tan → угол
      if (has(tanName) && !has(angleName)) {
        setValue(angleName, _toDeg(atan(get(tanName)!)));
      }

      // sin² + cos² = 1
      if (has(sinName) && !has(cosName)) {
        final sinVal = get(sinName)!;
        setValue(cosName, sqrt(1 - sinVal * sinVal));
      } else if (has(cosName) && !has(sinName)) {
        final cosVal = get(cosName)!;
        setValue(sinName, sqrt(1 - cosVal * cosVal));
      }

      // tan = sin / cos
      if (has(sinName) && has(cosName) && !has(tanName)) {
        setValue(tanName, get(sinName)! / get(cosName)!);
      }
    }
  }

  void _applySineCosineRules() {
    // Теорема косинусов: a² = b² + c² - 2bc·cosA
    if (has('b') && has('c') && has('A') && !has('a')) {
      final b = get('b')!;
      final c = get('c')!;
      final cosA = cos(_toRad(get('A')!));
      setValue('a', sqrt(b * b + c * c - 2 * b * c * cosA));
    }

    if (has('a') && has('c') && has('B') && !has('b')) {
      final a = get('a')!;
      final c = get('c')!;
      final cosB = cos(_toRad(get('B')!));
      setValue('b', sqrt(a * a + c * c - 2 * a * c * cosB));
    }

    if (has('a') && has('b') && has('C') && !has('c')) {
      final a = get('a')!;
      final b = get('b')!;
      final cosC = cos(_toRad(get('C')!));
      setValue('c', sqrt(a * a + b * b - 2 * a * b * cosC));
    }

    // Обратная теорема косинусов
    if (has('a') && has('b') && has('c')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      if (!has('A')) {
        final cosA = (b * b + c * c - a * a) / (2 * b * c);
        setValue('A', _toDeg(acos(cosA)));
      }
      if (!has('B')) {
        final cosB = (a * a + c * c - b * b) / (2 * a * c);
        setValue('B', _toDeg(acos(cosB)));
      }
      if (!has('C')) {
        final cosC = (a * a + b * b - c * c) / (2 * a * b);
        setValue('C', _toDeg(acos(cosC)));
      }
    }

    // Теорема синусов: a/sinA = b/sinB = c/sinC = 2R
    if (has('a') && has('A')) {
      final ratio = get('a')! / sin(_toRad(get('A')!));
      if (!has('R')) setValue('R', ratio / 2);
      if (has('B') && !has('b')) {
        setValue('b', ratio * sin(_toRad(get('B')!)));
      }
      if (has('C') && !has('c')) {
        setValue('c', ratio * sin(_toRad(get('C')!)));
      }
    }

    if (has('b') && has('B')) {
      final ratio = get('b')! / sin(_toRad(get('B')!));
      if (!has('R')) setValue('R', ratio / 2);
      if (has('A') && !has('a')) {
        setValue('a', ratio * sin(_toRad(get('A')!)));
      }
      if (has('C') && !has('c')) {
        setValue('c', ratio * sin(_toRad(get('C')!)));
      }
    }

    if (has('c') && has('C')) {
      final ratio = get('c')! / sin(_toRad(get('C')!));
      if (!has('R')) setValue('R', ratio / 2);
      if (has('A') && !has('a')) {
        setValue('a', ratio * sin(_toRad(get('A')!)));
      }
      if (has('B') && !has('b')) {
        setValue('b', ratio * sin(_toRad(get('B')!)));
      }
    }
  }

  void _applyAreaFormulas() {
    // S = (1/2)·a·b·sinC
    if (has('a') && has('b') && has('C') && !has('S')) {
      setValue('S', 0.5 * get('a')! * get('b')! * sin(_toRad(get('C')!)));
    }
    if (has('b') && has('c') && has('A') && !has('S')) {
      setValue('S', 0.5 * get('b')! * get('c')! * sin(_toRad(get('A')!)));
    }
    if (has('a') && has('c') && has('B') && !has('S')) {
      setValue('S', 0.5 * get('a')! * get('c')! * sin(_toRad(get('B')!)));
    }

    // Формула Герона
    if (has('a') && has('b') && has('c') && !has('S')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      final p = (a + b + c) / 2;
      setValue('p', p);
      setValue('S', sqrt(p * (p - a) * (p - b) * (p - c)));
    }

    // S = (1/2)·a·ha
    if (has('a') && has('ha') && !has('S')) {
      setValue('S', 0.5 * get('a')! * get('ha')!);
    }
    if (has('b') && has('hb') && !has('S')) {
      setValue('S', 0.5 * get('b')! * get('hb')!);
    }
    if (has('c') && has('hc') && !has('S')) {
      setValue('S', 0.5 * get('c')! * get('hc')!);
    }

    // S = p·r
    if (has('p') && has('r') && !has('S')) {
      setValue('S', get('p')! * get('r')!);
    }

    // S = abc/(4R)
    if (has('a') && has('b') && has('c') && has('R') && !has('S')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      final R = get('R')!;
      setValue('S', (a * b * c) / (4 * R));
    }
  }

  void _applyRadiusFormulas() {
    // r = S/p
    if (has('S') && has('p') && !has('r')) {
      setValue('r', get('S')! / get('p')!);
    }

    // R = abc/(4S)
    if (has('a') && has('b') && has('c') && has('S') && !has('R')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      final S = get('S')!;
      setValue('R', (a * b * c) / (4 * S));
    }

    // R = a/(2sinA)
    if (has('a') && has('A') && !has('R')) {
      setValue('R', get('a')! / (2 * sin(_toRad(get('A')!))));
    }
  }

  void _applyHeightFormulas() {
    // ha = 2S/a
    if (has('S') && has('a') && !has('ha')) {
      setValue('ha', 2 * get('S')! / get('a')!);
    }
    if (has('S') && has('b') && !has('hb')) {
      setValue('hb', 2 * get('S')! / get('b')!);
    }
    if (has('S') && has('c') && !has('hc')) {
      setValue('hc', 2 * get('S')! / get('c')!);
    }

    // ha = b·sinC
    if (has('b') && has('C') && !has('ha')) {
      setValue('ha', get('b')! * sin(_toRad(get('C')!)));
    }
    if (has('c') && has('B') && !has('ha')) {
      setValue('ha', get('c')! * sin(_toRad(get('B')!)));
    }

    if (has('a') && has('C') && !has('hb')) {
      setValue('hb', get('a')! * sin(_toRad(get('C')!)));
    }
    if (has('c') && has('A') && !has('hb')) {
      setValue('hb', get('c')! * sin(_toRad(get('A')!)));
    }

    if (has('a') && has('B') && !has('hc')) {
      setValue('hc', get('a')! * sin(_toRad(get('B')!)));
    }
    if (has('b') && has('A') && !has('hc')) {
      setValue('hc', get('b')! * sin(_toRad(get('A')!)));
    }
  }

  void _applyMedianFormulas() {
    if (has('a') && has('b') && has('c') && !has('ma')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      setValue('ma', 0.5 * sqrt(2 * b * b + 2 * c * c - a * a));
    }

    if (has('a') && has('b') && has('c') && !has('mb')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      setValue('mb', 0.5 * sqrt(2 * a * a + 2 * c * c - b * b));
    }

    if (has('a') && has('b') && has('c') && !has('mc')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      setValue('mc', 0.5 * sqrt(2 * a * a + 2 * b * b - c * c));
    }
  }

  void _applyBisectorFormulas() {
    // la = (2bc·cos(A/2))/(b+c)
    if (has('b') && has('c') && has('A') && !has('la')) {
      final b = get('b')!;
      final c = get('c')!;
      final cosHalfA = cos(_toRad(get('A')! / 2));
      setValue('la', (2 * b * c * cosHalfA) / (b + c));
    }

    if (has('a') && has('c') && has('B') && !has('lb')) {
      final a = get('a')!;
      final c = get('c')!;
      final cosHalfB = cos(_toRad(get('B')! / 2));
      setValue('lb', (2 * a * c * cosHalfB) / (a + c));
    }

    if (has('a') && has('b') && has('C') && !has('lc')) {
      final a = get('a')!;
      final b = get('b')!;
      final cosHalfC = cos(_toRad(get('C')! / 2));
      setValue('lc', (2 * a * b * cosHalfC) / (a + b));
    }
  }

  void _applyMidlineFormulas() {
    // mla = a/2
    if (has('a') && !has('mla')) setValue('mla', get('a')! / 2);
    if (has('b') && !has('mlb')) setValue('mlb', get('b')! / 2);
    if (has('c') && !has('mlc')) setValue('mlc', get('c')! / 2);

    // Обратно
    if (has('mla') && !has('a')) setValue('a', 2 * get('mla')!);
    if (has('mlb') && !has('b')) setValue('b', 2 * get('mlb')!);
    if (has('mlc') && !has('c')) setValue('c', 2 * get('mlc')!);
  }

  void _applyPerimeterFormulas() {
    // P = a + b + c
    if (has('a') && has('b') && has('c') && !has('P')) {
      setValue('P', get('a')! + get('b')! + get('c')!);
    }

    // p = P/2
    if (has('P') && !has('p')) setValue('p', get('P')! / 2);
    if (has('p') && !has('P')) setValue('P', 2 * get('p')!);
  }
}

// ===== ДИАЛОГ ДОБАВЛЕНИЯ ПАРАМЕТРА =====

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
    {'group': 'Углы (градусы)', 'params': 'A,B,C'},
    {'group': 'Синусы', 'params': 'sinA,sinB,sinC'},
    {'group': 'Косинусы', 'params': 'cosA,cosB,cosC'},
    {'group': 'Тангенсы', 'params': 'tanA,tanB,tanC'},
    {'group': 'Высоты', 'params': 'ha,hb,hc'},
    {'group': 'Медианы', 'params': 'ma,mb,mc'},
    {'group': 'Биссектрисы', 'params': 'la,lb,lc'},
    {'group': 'Средние линии', 'params': 'mla,mlb,mlc'},
    {'group': 'Прочее', 'params': 'S,P,p,R,r'},
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
      'A': 'Угол A (°)',
      'B': 'Угол B (°)',
      'C': 'Угол C (°)',
      'sinA': 'sin A',
      'sinB': 'sin B',
      'sinC': 'sin C',
      'cosA': 'cos A',
      'cosB': 'cos B',
      'cosC': 'cos C',
      'tanA': 'tan A',
      'tanB': 'tan B',
      'tanC': 'tan C',
      'S': 'Площадь',
      'P': 'Периметр',
      'p': 'Полупериметр',
      'R': 'Радиус описанной',
      'r': 'Радиус вписанной',
      'ha': 'Высота ha',
      'hb': 'Высота hb',
      'hc': 'Высота hc',
      'ma': 'Медиана ma',
      'mb': 'Медиана mb',
      'mc': 'Медиана mc',
      'la': 'Биссектриса la',
      'lb': 'Биссектриса lb',
      'lc': 'Биссектриса lc',
      'mla': 'Средняя линия || a',
      'mlb': 'Средняя линия || b',
      'mlc': 'Средняя линия || c',
    };
    return names[key] ?? key;
  }
}


// ===== НАСТРОЙКИ =====

class SettingsPage extends StatelessWidget {
  final Function(ThemeMode) onThemeChange;
  final Function(String, [Color?]) onColorChange;
  final ThemeMode currentThemeMode;
  final String currentColorMode;
  final Color currentColor;

  const SettingsPage({
    super.key,
    required this.onThemeChange,
    required this.onColorChange,
    required this.currentThemeMode,
    required this.currentColorMode,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки'), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Тема'),
            subtitle: Text(_getThemeName(currentThemeMode)),
            leading: const Icon(Icons.brightness_6),
            onTap: () => _showThemeDialog(context),
          ),
          const Divider(),
          ListTile(
            title: const Text('Цветовая схема'),
            subtitle: Text(_getColorModeName(currentColorMode)),
            leading: const Icon(Icons.palette),
            onTap: () => _showColorDialog(context),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Темная';
      case ThemeMode.system:
        return 'Как в системе';
    }
  }

  String _getColorModeName(String mode) {
    switch (mode) {
      case 'system':
        return 'Как в системе';
      case 'random':
        return 'Случайный';
      case 'custom':
        return 'Выбранный';
      default:
        return mode;
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите тему'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Светлая'),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  onThemeChange(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Темная'),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  onThemeChange(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Как в системе'),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  onThemeChange(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите цветовую схему'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Как в системе'),
              leading: Radio<String>(
                value: 'system',
                groupValue: currentColorMode,
                onChanged: (value) {
                  if (value != null) {
                    onColorChange(value);
                    Navigator.pop(context);
                  }
                },
              ),
              onTap: () {
                onColorChange('system');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Случайный'),
              leading: Radio<String>(
                value: 'random',
                groupValue: currentColorMode,
                onChanged: (value) {
                  if (value != null) {
                    onColorChange(value);
                    Navigator.pop(context);
                  }
                },
              ),
              onTap: () {
                onColorChange('random');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Выбрать из палитры'),
              leading: Radio<String>(
                value: 'custom',
                groupValue: currentColorMode,
                onChanged: (value) {},
              ),
              onTap: () {
                Navigator.pop(context);
                _showColorPicker(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите цвет'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  onColorChange('custom', colors[index]);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
