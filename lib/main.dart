import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _useRadians = false;

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  void updateTheme(ThemeMode mode) => setState(() => _themeMode = mode);

  void updateAngleUnit(bool radians) => setState(() => _useRadians = radians);

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
      title: 'Triangle Calculator Pro',
      debugShowCheckedModeBanner: false,
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
        onAngleUnitChange: updateAngleUnit,
        currentThemeMode: _themeMode,
        currentColorMode: _colorMode,
        currentColor: _seedColor,
        useRadians: _useRadians,
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChange;
  final Function(String, [Color?]) onColorChange;
  final Function(bool) onAngleUnitChange;
  final ThemeMode currentThemeMode;
  final String currentColorMode;
  final Color currentColor;
  final bool useRadians;

  const MainNavigationPage({
    super.key,
    required this.onThemeChange,
    required this.onColorChange,
    required this.onAngleUnitChange,
    required this.currentThemeMode,
    required this.currentColorMode,
    required this.currentColor,
    required this.useRadians,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TriangleCalculatorPage(useRadians: widget.useRadians),
      HistoryPage(key: ValueKey('history_${widget.useRadians}')),
      SettingsPage(
        onThemeChange: widget.onThemeChange,
        onColorChange: widget.onColorChange,
        onAngleUnitChange: widget.onAngleUnitChange,
        currentThemeMode: widget.currentThemeMode,
        currentColorMode: widget.currentColorMode,
        currentColor: widget.currentColor,
        useRadians: widget.useRadians,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Калькулятор',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'История',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}

// Глобальное хранилище истории
class HistoryStorage {
  static final List<CalculationHistory> _history = [];

  static void add(Map<String, double> input, Map<String, double> results) {
    _history.insert(
      0,
      CalculationHistory(
        timestamp: DateTime.now(),
        inputParams: Map.from(input),
        allResults: Map.from(results),
      ),
    );
    if (_history.length > 50) _history.removeLast();
  }

  static List<CalculationHistory> get all => _history;
  static void clear() => _history.clear();
  static void remove(int index) => _history.removeAt(index);
}

class CalculationHistory {
  final DateTime timestamp;
  final Map<String, double> inputParams;
  final Map<String, double> allResults;

  CalculationHistory({
    required this.timestamp,
    required this.inputParams,
    required this.allResults,
  });
}

// ===== РЕШАТЕЛЬ ТРЕУГОЛЬНИКОВ =====

class TriangleSolver {
  final Map<String, double> data = {};
  final List<String> steps = [];
  final int precision = 6;
  bool useRadians = false;
  bool isInvalid = false;
  String errorMessage = '';

  void clear() {
    data.clear();
    steps.clear();
    isInvalid = false;
    errorMessage = '';
  }

  void setValue(String name, double value) {
    if (name == 'A' || name == 'B' || name == 'C') {
      if (useRadians) {
        if (value <= 0 || value >= pi) return;
      } else {
        if (value <= 0 || value >= 180) return;
      }
    } else if (!name.startsWith('sin') &&
        !name.startsWith('cos') &&
        !name.startsWith('tan')) {
      if (value <= 0) return;
    }
    data[name] = _round(value);
  }

  double? get(String name) => data[name];
  bool has(String name) => data.containsKey(name);
  double _round(double value) => double.parse(value.toStringAsFixed(6));
  double _toRad(double degrees) => useRadians ? degrees : degrees * pi / 180;
  double _toDeg(double radians) => useRadians ? radians : radians * 180 / pi;

  void solve() {
    const maxIterations = 80;
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
    _validateTriangle();
  }

  void _validateTriangle() {
    if (has('a') && has('b') && has('c')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      if (a + b <= c || a + c <= b || b + c <= a) {
        isInvalid = true;
        errorMessage =
            'Треугольник с такими сторонами невозможен (нарушено неравенство треугольника)';
      }
    }
    if (has('A') && has('B') && has('C')) {
      final sum = get('A')! + get('B')! + get('C')!;
      final expected = useRadians ? pi : 180;
      if ((sum - expected).abs() > (useRadians ? 0.01 : 0.1)) {
        isInvalid = true;
        errorMessage =
            'Сумма углов должна равняться ${useRadians ? 'π' : '180°'}';
      }
    }
  }

  void _applyAngleSum() {
    final target = useRadians ? pi : 180;
    if (has('A') && has('B') && !has('C')) {
      setValue('C', target - get('A')! - get('B')!);
      steps.add('Вычислен угол C = $target - A - B');
    } else if (has('A') && has('C') && !has('B')) {
      setValue('B', target - get('A')! - get('C')!);
      steps.add('Вычислен угол B = $target - A - C');
    } else if (has('B') && has('C') && !has('A')) {
      setValue('A', target - get('B')! - get('C')!);
      steps.add('Вычислен угол A = $target - B - C');
    }
  }

  void _applyTrigIdentities() {
    for (final angleName in ['A', 'B', 'C']) {
      final sinName = 'sin$angleName';
      final cosName = 'cos$angleName';
      final tanName = 'tan$angleName';

      if (has(angleName)) {
        final angleRad = _toRad(get(angleName)!);
        if (!has(sinName)) {
          setValue(sinName, sin(angleRad));
          steps.add('Вычислен $sinName = sin($angleName)');
        }
        if (!has(cosName)) {
          setValue(cosName, cos(angleRad));
          steps.add('Вычислен $cosName = cos($angleName)');
        }
        if (!has(tanName)) {
          final c = cos(angleRad);
          if (c.abs() > 1e-12) {
            setValue(tanName, tan(angleRad));
            steps.add('Вычислен $tanName = tan($angleName)');
          }
        }
      }

      if (has(sinName) && !has(angleName)) {
        final sinVal = get(sinName)!;
        if (sinVal >= -1 && sinVal <= 1) {
          setValue(angleName, _toDeg(asin(sinVal)));
          steps.add('Вычислен угол $angleName = arcsin($sinName)');
        }
      }

      if (has(cosName) && !has(angleName)) {
        final cosVal = get(cosName)!;
        if (cosVal >= -1 && cosVal <= 1) {
          setValue(angleName, _toDeg(acos(cosVal)));
          steps.add('Вычислен угол $angleName = arccos($cosName)');
        }
      }

      if (has(sinName) && !has(cosName)) {
        final sinVal = get(sinName)!;
        if (sinVal.abs() <= 1) {
          setValue(cosName, sqrt(max(0, 1 - sinVal * sinVal)));
          steps.add('Вычислен $cosName по формуле sin²+cos²=1');
        }
      } else if (has(cosName) && !has(sinName)) {
        final cosVal = get(cosName)!;
        if (cosVal.abs() <= 1) {
          setValue(sinName, sqrt(max(0, 1 - cosVal * cosVal)));
          steps.add('Вычислен $sinName по формуле sin²+cos²=1');
        }
      }
    }
  }

  void _applySineCosineRules() {
    if (has('b') && has('c') && has('A') && !has('a')) {
      final b = get('b')!;
      final c = get('c')!;
      final cosA = cos(_toRad(get('A')!));
      final val = sqrt(max(0, b * b + c * c - 2 * b * c * cosA));
      setValue('a', val);
      steps.add(
        'Вычислена сторона a по теореме косинусов: a² = b² + c² - 2bc·cosA',
      );
    }

    if (has('a') && has('c') && has('B') && !has('b')) {
      final a = get('a')!;
      final c = get('c')!;
      final cosB = cos(_toRad(get('B')!));
      final val = sqrt(max(0, a * a + c * c - 2 * a * c * cosB));
      setValue('b', val);
      steps.add(
        'Вычислена сторона b по теореме косинусов: b² = a² + c² - 2ac·cosB',
      );
    }

    if (has('a') && has('b') && has('C') && !has('c')) {
      final a = get('a')!;
      final b = get('b')!;
      final cosC = cos(_toRad(get('C')!));
      final val = sqrt(max(0, a * a + b * b - 2 * a * b * cosC));
      setValue('c', val);
      steps.add(
        'Вычислена сторона c по теореме косинусов: c² = a² + b² - 2ab·cosC',
      );
    }

    if (has('a') && has('b') && has('c')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      if (!has('A')) {
        final denom = 2 * b * c;
        if (denom.abs() > 1e-12) {
          final cosA = ((b * b + c * c - a * a) / denom).clamp(-1.0, 1.0);
          setValue('A', _toDeg(acos(cosA)));
          steps.add(
            'Вычислен угол A по теореме косинусов: cosA = (b²+c²-a²)/(2bc)',
          );
        }
      }
      if (!has('B')) {
        final denom = 2 * a * c;
        if (denom.abs() > 1e-12) {
          final cosB = ((a * a + c * c - b * b) / denom).clamp(-1.0, 1.0);
          setValue('B', _toDeg(acos(cosB)));
          steps.add(
            'Вычислен угол B по теореме косинусов: cosB = (a²+c²-b²)/(2ac)',
          );
        }
      }
      if (!has('C')) {
        final denom = 2 * a * b;
        if (denom.abs() > 1e-12) {
          final cosC = ((a * a + b * b - c * c) / denom).clamp(-1.0, 1.0);
          setValue('C', _toDeg(acos(cosC)));
          steps.add(
            'Вычислен угол C по теореме косинусов: cosC = (a²+b²-c²)/(2ab)',
          );
        }
      }
    }

    if (has('a') && has('A')) {
      final ratio = get('a')! / sin(_toRad(get('A')!));
      if (!has('R') && ratio.abs() > 1e-12) {
        setValue('R', ratio / 2);
        steps.add('Вычислен радиус описанной окружности R = a/(2sinA)');
      }
      if (has('B') && !has('b')) {
        setValue('b', ratio * sin(_toRad(get('B')!)));
        steps.add('Вычислена сторона b по теореме синусов: b/sinB = a/sinA');
      }
      if (has('C') && !has('c')) {
        setValue('c', ratio * sin(_toRad(get('C')!)));
        steps.add('Вычислена сторона c по теореме синусов: c/sinC = a/sinA');
      }
    }
  }

  void _applyAreaFormulas() {
    if (has('a') && has('b') && has('C') && !has('S')) {
      setValue('S', 0.5 * get('a')! * get('b')! * sin(_toRad(get('C')!)));
      steps.add('Вычислена площадь S = (1/2)·a·b·sinC');
    }
    if (has('b') && has('c') && has('A') && !has('S')) {
      setValue('S', 0.5 * get('b')! * get('c')! * sin(_toRad(get('A')!)));
      steps.add('Вычислена площадь S = (1/2)·b·c·sinA');
    }

    if (has('a') && has('b') && has('c') && !has('S')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      final p = (a + b + c) / 2;
      setValue('p', p);
      final underSqrt = max(0, p * (p - a) * (p - b) * (p - c));
      setValue('S', sqrt(underSqrt));
      steps.add('Вычислена площадь по формуле Герона: S = √(p(p-a)(p-b)(p-c))');
    }

    if (has('a') && has('ha') && !has('S')) {
      setValue('S', 0.5 * get('a')! * get('ha')!);
      steps.add('Вычислена площадь S = (1/2)·a·ha');
    }

    if (has('p') && has('r') && !has('S')) {
      setValue('S', get('p')! * get('r')!);
      steps.add('Вычислена площадь S = p·r');
    }
  }

  void _applyRadiusFormulas() {
    if (has('S') && has('p') && !has('r')) {
      final p = get('p')!;
      if (p.abs() > 1e-12) {
        setValue('r', get('S')! / p);
        steps.add('Вычислен радиус вписанной окружности r = S/p');
      }
    }

    if (has('a') && has('b') && has('c') && has('S') && !has('R')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      final S = get('S')!;
      final denom = 4 * S;
      if (denom.abs() > 1e-12) {
        setValue('R', (a * b * c) / denom);
        steps.add('Вычислен радиус описанной окружности R = abc/(4S)');
      }
    }
  }

  void _applyHeightFormulas() {
    if (has('S') && has('a') && !has('ha')) {
      setValue('ha', 2 * get('S')! / get('a')!);
      steps.add('Вычислена высота ha = 2S/a');
    }
    if (has('S') && has('b') && !has('hb')) {
      setValue('hb', 2 * get('S')! / get('b')!);
      steps.add('Вычислена высота hb = 2S/b');
    }
    if (has('S') && has('c') && !has('hc')) {
      setValue('hc', 2 * get('S')! / get('c')!);
      steps.add('Вычислена высота hc = 2S/c');
    }

    if (has('b') && has('C') && !has('ha')) {
      setValue('ha', get('b')! * sin(_toRad(get('C')!)));
      steps.add('Вычислена высота ha = b·sinC');
    }
  }

  void _applyMedianFormulas() {
    if (has('a') && has('b') && has('c') && !has('ma')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      setValue('ma', 0.5 * sqrt(max(0, 2 * b * b + 2 * c * c - a * a)));
      steps.add('Вычислена медиана ma = (1/2)√(2b²+2c²-a²)');
    }

    if (has('a') && has('b') && has('c') && !has('mb')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      setValue('mb', 0.5 * sqrt(max(0, 2 * a * a + 2 * c * c - b * b)));
      steps.add('Вычислена медиана mb = (1/2)√(2a²+2c²-b²)');
    }

    if (has('a') && has('b') && has('c') && !has('mc')) {
      final a = get('a')!;
      final b = get('b')!;
      final c = get('c')!;
      setValue('mc', 0.5 * sqrt(max(0, 2 * a * a + 2 * b * b - c * c)));
      steps.add('Вычислена медиана mc = (1/2)√(2a²+2b²-c²)');
    }
  }

  void _applyBisectorFormulas() {
    if (has('b') && has('c') && has('A') && !has('la')) {
      final b = get('b')!;
      final c = get('c')!;
      final cosHalfA = cos(_toRad(get('A')! / 2));
      final denom = b + c;
      if (denom.abs() > 1e-12) {
        setValue('la', (2 * b * c * cosHalfA) / denom);
        steps.add('Вычислена биссектриса la = (2bc·cos(A/2))/(b+c)');
      }
    }
  }

  void _applyMidlineFormulas() {
    if (has('a') && !has('mla')) {
      setValue('mla', get('a')! / 2);
      steps.add('Вычислена средняя линия mla = a/2');
    }
    if (has('b') && !has('mlb')) {
      setValue('mlb', get('b')! / 2);
      steps.add('Вычислена средняя линия mlb = b/2');
    }
    if (has('c') && !has('mlc')) {
      setValue('mlc', get('c')! / 2);
      steps.add('Вычислена средняя линия mlc = c/2');
    }
  }

  void _applyPerimeterFormulas() {
    if (has('a') && has('b') && has('c') && !has('P')) {
      setValue('P', get('a')! + get('b')! + get('c')!);
      steps.add('Вычислен периметр P = a + b + c');
    }

    if (has('P') && !has('p')) {
      setValue('p', get('P')! / 2);
      steps.add('Вычислен полупериметр p = P/2');
    }
  }
}

// ===== КАЛЬКУЛЯТОР UI =====

class TriangleCalculatorPage extends StatefulWidget {
  final bool useRadians;
  const TriangleCalculatorPage({super.key, required this.useRadians});

  @override
  State<TriangleCalculatorPage> createState() => _TriangleCalculatorPageState();
}

class _TriangleCalculatorPageState extends State<TriangleCalculatorPage>
    with SingleTickerProviderStateMixin {
  final Map<String, double> _inputParameters = {};
  final TriangleSolver _solver = TriangleSolver();
  String _selectedCategory = 'Все';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addParameter(String type, double value) {
    setState(() {
      _inputParameters[type] = value;
      _recalculate();
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _removeParameter(String type) {
    setState(() {
      _inputParameters.remove(type);
      _recalculate();
    });
  }

  void _recalculate() {
    _solver.clear();
    _solver.useRadians = widget.useRadians;
    _inputParameters.forEach((key, val) => _solver.setValue(key, val));
    _solver.solve();

    if (_inputParameters.isNotEmpty &&
        _solver.data.length > _inputParameters.length) {
      HistoryStorage.add(_inputParameters, _solver.data);
    }

    setState(() {});
  }

  void _clearAll() {
    setState(() {
      _inputParameters.clear();
      _solver.clear();
    });
  }

  void _loadQuickPreset(Map<String, double> preset) {
    setState(() {
      _inputParameters.clear();
      _inputParameters.addAll(preset);
      _recalculate();
    });
  }

  void _exportResults() {
    final text = _generateExportText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Результаты скопированы в буфер обмена'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  String _generateExportText() {
    final buffer = StringBuffer();
    buffer.writeln('=== Triangle Calculator Pro ===\n');
    buffer.writeln('Введённые параметры:');
    _inputParameters.forEach(
      (k, v) => buffer.writeln('${_getParameterName(k)}: ${_formatNumber(v)}'),
    );
    buffer.writeln('\nВычисленные параметры:');
    _solver.data.entries
        .where((e) => !_inputParameters.containsKey(e.key))
        .forEach((e) {
          buffer.writeln(
            '${_getParameterName(e.key)}: ${_formatNumber(e.value)}',
          );
        });
    return buffer.toString();
  }

  void _showStepByStep() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StepByStepSheet(steps: _solver.steps),
    );
  }

  String _formatNumber(double value) {
    final rounded = double.parse(value.toStringAsFixed(3));
    final str = rounded.toString();
    return str.endsWith('.0') ? str.substring(0, str.length - 2) : str;
  }

  Map<String, List<MapEntry<String, double>>> _categorizeParameters(
    List<MapEntry<String, double>> params,
  ) {
    final categories = {
      'Стороны': <MapEntry<String, double>>[],
      'Углы': <MapEntry<String, double>>[],
      'Тригонометрия': <MapEntry<String, double>>[],
      'Высоты': <MapEntry<String, double>>[],
      'Медианы': <MapEntry<String, double>>[],
      'Биссектрисы': <MapEntry<String, double>>[],
      'Средние линии': <MapEntry<String, double>>[],
      'Площадь и периметр': <MapEntry<String, double>>[],
      'Радиусы': <MapEntry<String, double>>[],
    };

    for (final param in params) {
      if (['a', 'b', 'c'].contains(param.key)) {
        categories['Стороны']!.add(param);
      } else if (['A', 'B', 'C'].contains(param.key)) {
        categories['Углы']!.add(param);
      } else if (param.key.startsWith('sin') ||
          param.key.startsWith('cos') ||
          param.key.startsWith('tan')) {
        categories['Тригонометрия']!.add(param);
      } else if (param.key.startsWith('h')) {
        categories['Высоты']!.add(param);
      } else if (param.key.startsWith('m') && param.key.length == 2) {
        categories['Медианы']!.add(param);
      } else if (param.key.startsWith('l')) {
        categories['Биссектрисы']!.add(param);
      } else if (param.key.startsWith('ml')) {
        categories['Средние линии']!.add(param);
      } else if (['S', 'P', 'p'].contains(param.key)) {
        categories['Площадь и периметр']!.add(param);
      } else if (['R', 'r'].contains(param.key)) {
        categories['Радиусы']!.add(param);
      }
    }

    categories.removeWhere((key, value) => value.isEmpty);
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    var computed = _solver.data.entries
        .where((e) => !_inputParameters.containsKey(e.key))
        .toList();

    if (_searchQuery.isNotEmpty) {
      computed = computed
          .where(
            (e) => _getParameterName(
              e.key,
            ).toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    final categorized = _categorizeParameters(computed);
    final categories = ['Все', ...categorized.keys];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triangle Calculator Pro'),
        centerTitle: true,
        actions: [
          if (_inputParameters.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.auto_stories),
              onPressed: _showStepByStep,
              tooltip: 'Пошаговое решение',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportResults,
              tooltip: 'Экспорт',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Очистить всё?'),
                    content: const Text(
                      'Все введённые параметры будут удалены',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                      FilledButton(
                        onPressed: () {
                          _clearAll();
                          Navigator.pop(context);
                        },
                        child: const Text('Очистить'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Очистить',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Проверка корректности
          if (_solver.isInvalid) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                border: Border(
                  bottom: BorderSide(color: Colors.red.shade900, width: 2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade900,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _solver.errorMessage,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Статистика
          if (_inputParameters.isNotEmpty || computed.isNotEmpty)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      icon: Icons.input,
                      label: 'Введено',
                      value: _inputParameters.length.toString(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _StatCard(
                      icon: Icons.functions,
                      label: 'Вычислено',
                      value: computed.length.toString(),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    _StatCard(
                      icon: Icons.done_all,
                      label: 'Всего',
                      value: _solver.data.length.toString(),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),

          // Быстрый ввод
          if (_inputParameters.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Быстрый ввод:',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickPresetChip(
                        label: '3-4-5',
                        icon: Icons.looks_3,
                        onPressed: () =>
                            _loadQuickPreset({'a': 3, 'b': 4, 'c': 5}),
                      ),
                      _QuickPresetChip(
                        label: '5-12-13',
                        icon: Icons.looks_5,
                        onPressed: () =>
                            _loadQuickPreset({'a': 5, 'b': 12, 'c': 13}),
                      ),
                      _QuickPresetChip(
                        label: 'Равносторонний',
                        icon: Icons.change_history,
                        onPressed: () =>
                            _loadQuickPreset({'a': 10, 'A': 60, 'B': 60}),
                      ),
                      _QuickPresetChip(
                        label: 'Прямоугольный',
                        icon: Icons.square_outlined,
                        onPressed: () =>
                            _loadQuickPreset({'a': 3, 'b': 4, 'C': 90}),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Введённые параметры
          if (_inputParameters.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.input,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Введённые параметры',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
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
                    ).colorScheme.secondaryContainer,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.3),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 32, indent: 16, endIndent: 16),
          ],

          // Поиск
          if (computed.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск параметров...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          }),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

          // Фильтр категорий
          if (computed.isNotEmpty && _searchQuery.isEmpty) ...[
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) =>
                          setState(() => _selectedCategory = category),
                      avatar: isSelected
                          ? const Icon(Icons.check, size: 18)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],

          // Вычисленные параметры
          Expanded(
            child: computed.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calculate_outlined,
                            size: 80,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Добавьте параметры\nдля вычисления',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Нажмите кнопку "+" внизу',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children:
                          _selectedCategory == 'Все' && _searchQuery.isEmpty
                          ? categorized.entries
                                .map(
                                  (e) => _CategorySection(
                                    title: e.key,
                                    parameters: e.value,
                                    formatNumber: _formatNumber,
                                    getParameterName: _getParameterName,
                                  ),
                                )
                                .toList()
                          : _searchQuery.isNotEmpty
                          ? computed
                                .map(
                                  (e) => _ParameterCard(
                                    param: e,
                                    formatNumber: _formatNumber,
                                    getParameterName: _getParameterName,
                                  ),
                                )
                                .toList()
                          : [
                              if (categorized.containsKey(_selectedCategory))
                                _CategorySection(
                                  title: _selectedCategory,
                                  parameters: categorized[_selectedCategory]!,
                                  formatNumber: _formatNumber,
                                  getParameterName: _getParameterName,
                                )
                              else
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      'Нет параметров в категории',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ),
                                ),
                            ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => AddParameterSheet(
            onAdd: _addParameter,
            existingParameters: _inputParameters.keys.toList(),
            useRadians: widget.useRadians,
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  String _getParameterName(String key) {
    final unit = (key == 'A' || key == 'B' || key == 'C')
        ? (widget.useRadians ? ' (рад)' : ' (°)')
        : '';
    const names = {
      'a': 'Сторона a',
      'b': 'Сторона b',
      'c': 'Сторона c',
      'A': 'Угол A',
      'B': 'Угол B',
      'C': 'Угол C',
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
    return '${names[key] ?? key}$unit';
  }
}

// Виджет статистики
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: color.withOpacity(0.8)),
        ),
      ],
    );
  }
}

// Виджет быстрого пресета
class _QuickPresetChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _QuickPresetChip({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      ),
    );
  }
}

// Секция категории
class _CategorySection extends StatelessWidget {
  final String title;
  final List<MapEntry<String, double>> parameters;
  final String Function(double) formatNumber;
  final String Function(String) getParameterName;

  const _CategorySection({
    required this.title,
    required this.parameters,
    required this.formatNumber,
    required this.getParameterName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(title),
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        ...parameters.map(
          (param) => _ParameterCard(
            param: param,
            formatNumber: formatNumber,
            getParameterName: getParameterName,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Стороны':
        return Icons.straighten;
      case 'Углы':
        return Icons.architecture;
      case 'Тригонометрия':
        return Icons.functions;
      case 'Высоты':
        return Icons.height;
      case 'Медианы':
        return Icons.horizontal_split;
      case 'Биссектрисы':
        return Icons.call_split;
      case 'Средние линии':
        return Icons.line_axis;
      case 'Площадь и периметр':
        return Icons.square_foot;
      case 'Радиусы':
        return Icons.radio_button_unchecked;
      default:
        return Icons.info;
    }
  }
}

// Карточка параметра
class _ParameterCard extends StatelessWidget {
  final MapEntry<String, double> param;
  final String Function(double) formatNumber;
  final String Function(String) getParameterName;

  const _ParameterCard({
    required this.param,
    required this.formatNumber,
    required this.getParameterName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            param.key,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          getParameterName(param.key),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            formatNumber(param.value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

// Пошаговое решение
class StepByStepSheet extends StatelessWidget {
  final List<String> steps;
  const StepByStepSheet({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final visibleSteps = steps.where((s) => s.trim().isNotEmpty).toList();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.auto_stories,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Пошаговое решение',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: visibleSteps.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Нет доступных шагов для отображения',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: visibleSteps.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(visibleSteps[index]),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        final text = visibleSteps.join('\n');
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Шаги скопированы в буфер обмена'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_all),
                      label: const Text('Копировать'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Закрыть'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// === НОВЫЕ ВИДЖЕТЫ: HistoryPage, SettingsPage, AddParameterSheet ===

// HistoryPage: отображает историю вычислений и позволяет удалять/очищать
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<CalculationHistory> get _all => HistoryStorage.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История вычислений'),
        centerTitle: true,
        actions: [
          if (_all.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Очистить историю',
              onPressed: () async {
                final confirmed =
                    await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Очистить историю?'),
                        content: const Text(
                          'Все записи истории будут удалены.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Отмена'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Очистить'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (confirmed) {
                  setState(() {
                    HistoryStorage.clear();
                  });
                }
              },
            ),
        ],
      ),
      body: _all.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: 72,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Пусто',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Результаты вычислений будут отображаться здесь.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _all.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _all[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    isThreeLine: true,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.calculate,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      '${item.timestamp.toLocal()}'.split('.').first,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _formatHistorySubtitle(item),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          HistoryStorage.remove(index);
                        });
                      },
                    ),
                    onTap: () => _showDetails(item),
                  ),
                );
              },
            ),
    );
  }

  String _formatHistorySubtitle(CalculationHistory item) {
    final inputs = item.inputParams.entries
        .map((e) => '${e.key}=${_fmt(e.value)}')
        .join(', ');
    final outputs = item.allResults.entries
        .where((e) => !item.inputParams.containsKey(e.key))
        .take(3)
        .map((e) => '${e.key}=${_fmt(e.value)}')
        .join(', ');
    final tail = outputs.isNotEmpty ? ' • $outputs' : '';
    return '$inputs$tail';
  }

  String _fmt(double v) {
    final r = double.parse(v.toStringAsFixed(3));
    return r.toString();
  }

  void _showDetails(CalculationHistory item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final outputs = item.allResults.entries.toList();
        return Padding(
          padding: const EdgeInsets.only(
            top: 12,
            left: 12,
            right: 12,
            bottom: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Детали',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                fit: FlexFit.loose,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: const Text('Время'),
                      subtitle: Text(
                        '${item.timestamp.toLocal()}'.split('.').first,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Введённые параметры'),
                      subtitle: Text(
                        item.inputParams.entries
                            .map((e) => '${e.key}: ${_fmt(e.value)}')
                            .join('\n'),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Вычисленные параметры'),
                      subtitle: Text(
                        outputs
                            .map((e) => '${e.key}: ${_fmt(e.value)}')
                            .join('\n'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              // copy whole record
                              final buffer = StringBuffer();
                              buffer.writeln(
                                '=== Calculation at ${item.timestamp.toLocal()} ===',
                              );
                              buffer.writeln('Inputs:');
                              item.inputParams.forEach(
                                (k, v) => buffer.writeln('$k: ${_fmt(v)}'),
                              );
                              buffer.writeln('\nResults:');
                              item.allResults.forEach(
                                (k, v) => buffer.writeln('$k: ${_fmt(v)}'),
                              );
                              Clipboard.setData(
                                ClipboardData(text: buffer.toString()),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Скопировано')),
                              );
                            },
                            icon: const Icon(Icons.copy_all),
                            label: const Text('Скопировать'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Закрыть'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// SettingsPage: настройки темы, цвета и единиц измерения
class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChange;
  final Function(String, [Color?]) onColorChange;
  final Function(bool) onAngleUnitChange;
  final ThemeMode currentThemeMode;
  final String currentColorMode;
  final Color currentColor;
  final bool useRadians;

  const SettingsPage({
    super.key,
    required this.onThemeChange,
    required this.onColorChange,
    required this.onAngleUnitChange,
    required this.currentThemeMode,
    required this.currentColorMode,
    required this.currentColor,
    required this.useRadians,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeMode _themeMode;
  late String _colorMode;
  late Color _currentColor;
  late bool _useRadians;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentThemeMode;
    _colorMode = widget.currentColorMode;
    _currentColor = widget.currentColor;
    _useRadians = widget.useRadians;
  }

  void _pickCustomColor(Color color) {
    setState(() {
      _currentColor = color;
      _colorMode = 'custom';
    });
    widget.onColorChange('custom', color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Тема'),
            subtitle: const Text('Выберите светлую/тёмную/системную тему'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChoiceChip(
                label: const Text('Система'),
                selected: _themeMode == ThemeMode.system,
                onSelected: (_) {
                  setState(() => _themeMode = ThemeMode.system);
                  widget.onThemeChange(ThemeMode.system);
                },
              ),
              ChoiceChip(
                label: const Text('Светлая'),
                selected: _themeMode == ThemeMode.light,
                onSelected: (_) {
                  setState(() => _themeMode = ThemeMode.light);
                  widget.onThemeChange(ThemeMode.light);
                },
              ),
              ChoiceChip(
                label: const Text('Тёмная'),
                selected: _themeMode == ThemeMode.dark,
                onSelected: (_) {
                  setState(() => _themeMode = ThemeMode.dark);
                  widget.onThemeChange(ThemeMode.dark);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Цвет акцента'),
            subtitle: Text('Режим: $_colorMode'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  tooltip: 'Случайный цвет',
                  onPressed: () {
                    setState(() => _colorMode = 'random');
                    widget.onColorChange('random');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.circle),
                  color: _currentColor,
                  onPressed: () {
                    // quick cycle between few colors
                    final choices = [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                    ];
                    final idx = choices.indexWhere(
                      (c) => c.value == _currentColor.value,
                    );
                    final next = choices[(idx + 1) % choices.length];
                    _pickCustomColor(next);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _ColorChoiceChip(
                color: Colors.blue,
                selected: _currentColor == Colors.blue,
                onSelect: _pickCustomColor,
              ),
              _ColorChoiceChip(
                color: Colors.green,
                selected: _currentColor == Colors.green,
                onSelect: _pickCustomColor,
              ),
              _ColorChoiceChip(
                color: Colors.orange,
                selected: _currentColor == Colors.orange,
                onSelect: _pickCustomColor,
              ),
              _ColorChoiceChip(
                color: Colors.purple,
                selected: _currentColor == Colors.purple,
                onSelect: _pickCustomColor,
              ),
            ],
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.straighten_outlined),
            title: const Text('Единицы измерения'),
            subtitle: const Text('Выберите градусы или радианы'),
          ),
          SwitchListTile(
            title: Text(_useRadians ? 'Радианы' : 'Градусы'),
            value: _useRadians,
            onChanged: (v) {
              setState(() => _useRadians = v);
              widget.onAngleUnitChange(v);
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('О приложении'),
            subtitle: const Text(
              'GAPR — Geometric Analysis Program\nВерсия: 1.0.0',
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChoiceChip extends StatelessWidget {
  final Color color;
  final bool selected;
  final ValueChanged<Color> onSelect;

  const _ColorChoiceChip({
    required this.color,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: CircleAvatar(backgroundColor: color),
      label: const Text(''),
      selected: selected,
      onSelected: (_) => onSelect(color),
      selectedColor: color.withOpacity(0.3),
      backgroundColor: color.withOpacity(0.12),
    );
  }
}

// AddParameterSheet: диалог для добавления параметра и его значения
class AddParameterSheet extends StatefulWidget {
  final void Function(String, double) onAdd;
  final List<String> existingParameters;
  final bool useRadians;

  const AddParameterSheet({
    super.key,
    required this.onAdd,
    required this.existingParameters,
    required this.useRadians,
  });

  @override
  State<AddParameterSheet> createState() => _AddParameterSheetState();
}

class _AddParameterSheetState extends State<AddParameterSheet> {
  final _formKey = GlobalKey<FormState>();
  String _selectedParam = 'a';
  final TextEditingController _valueController = TextEditingController();

  static const List<String> _allParams = [
    'a',
    'b',
    'c',
    'A',
    'B',
    'C',
    'sinA',
    'sinB',
    'sinC',
    'cosA',
    'cosB',
    'cosC',
    'tanA',
    'tanB',
    'tanC',
    'S',
    'P',
    'p',
    'R',
    'r',
    'ha',
    'hb',
    'hc',
    'ma',
    'mb',
    'mc',
    'la',
    'lb',
    'lc',
    'mla',
    'mlb',
    'mlc',
  ];

  @override
  void initState() {
    super.initState();
    // choose first available param that is not in existingParameters
    _selectedParam = _allParams.firstWhere(
          (p) => !widget.existingParameters.contains(p),
      orElse: () => 'a',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  String _paramLabel(String key) {
    final unit = (key == 'A' || key == 'B' || key == 'C')
        ? (widget.useRadians ? ' (рад)' : ' (°)')
        : '';
    const names = {
      'a': 'Сторона a',
      'b': 'Сторона b',
      'c': 'Сторона c',
      'A': 'Угол A',
      'B': 'Угол B',
      'C': 'Угол C',
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
    return '${names[key] ?? key}$unit';
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final parsed = double.tryParse(
        _valueController.text.replaceAll(',', '.'),
      );
      if (parsed == null) return;
      widget.onAdd(_selectedParam, parsed);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = _allParams
        .where((p) => !widget.existingParameters.contains(p))
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.48,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Добавить параметр',
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedParam,
                          decoration: const InputDecoration(
                            labelText: 'Параметр',
                          ),
                          items: available
                              .map(
                                (p) =>
                                DropdownMenuItem(
                                  value: p,
                                  child: Text(_paramLabel(p)),
                                ),
                          )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _selectedParam = v);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _valueController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Значение',
                            hintText: 'Введите число',
                          ),
                          validator: (val) {
                            if (val == null || val
                                .trim()
                                .isEmpty)
                              return 'Укажите значение';
                            final v = double.tryParse(val.replaceAll(',', '.'));
                            if (v == null) return 'Неверный формат';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _submit,
                                child: const Text('Добавить'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Отмена'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
