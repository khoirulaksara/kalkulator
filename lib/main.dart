import 'package:flutter/material.dart';
import 'shake_detector.dart';
import 'storage_service.dart';
import 'calculator_logic.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  String _display = '0';
  String _equation = '';
  String _history = '';
  bool _showCustomText = false;
  String _customText = 'Custom Text';
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _currentOperation = '';
  double _firstNumber = 0;
  bool _isNewNumber = true;
  double _lastResult = 0;
  double _lastOperand = 0;
  String _lastOperation = '';
  bool _shakeFeatureEnabled = true;
  late ShakeDetector _shakeDetector;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load saved data
    _customText = await StorageService.loadCustomText();
    _shakeFeatureEnabled = await StorageService.loadShakeEnabled();

    // Initialize shake detector
    _shakeDetector = ShakeDetector(
      onShake: _onShakeDetected,
      enabled: _shakeFeatureEnabled,
    );
    _shakeDetector.startListening();

    setState(() {});
  }

  void _onShakeDetected() {
    print('Shake detected in main! Display: $_display');
    if (_display != '0') {
      setState(() {
        _showCustomText = true;
        _animationController.forward(from: 0);
      });
      print('Custom text shown: $_customText');
    } else {
      print('Display is 0, not showing custom text');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C' || buttonText == '⌫') {
        if (_display == '0' || _showCustomText) {
          _resetCalculator();
        } else {
          _handleBackspace();
        }
      } else if (buttonText == '±') {
        _handlePlusMinus();
      } else if (buttonText == '%') {
        _handlePercentage();
      } else if (buttonText == '=') {
        _handleEquals();
      } else if (['+', '-', '×', '÷'].contains(buttonText)) {
        _handleOperator(buttonText);
      } else {
        _handleNumberInput(buttonText);
      }
    });
  }

  void _resetCalculator() {
    _display = '0';
    _equation = '';
    _history = '';
    _currentOperation = '';
    _firstNumber = 0;
    _isNewNumber = true;
    _showCustomText = false;
    _lastResult = 0;
    _lastOperand = 0;
    _lastOperation = '';
  }

  void _handleBackspace() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
      _equation = _equation.substring(0, _equation.length - 1);
      _isNewNumber = false;
    } else {
      _display = '0';
      _equation = '';
      _isNewNumber = true;
    }
    _resetLastOperation();
  }

  void _handlePlusMinus() {
    if (_display != '0') {
      double number = double.parse(_display);
      _display = CalculatorLogic.formatNumber(-number);
    }
    _hideCustomText();
  }

  void _handlePercentage() {
    if (_display != '0') {
      double number = double.parse(_display);
      _display = CalculatorLogic.formatNumber(number / 100);
    }
    _hideCustomText();
  }

  void _handleEquals() {
    if (_equation == '1337') {
      _navigateToCustomTextEditor();
    } else if (_currentOperation.isNotEmpty) {
      _performCalculation();
    } else if (_lastOperation.isNotEmpty) {
      _repeatLastOperation();
    }
  }

  void _performCalculation() {
    double secondNumber = double.parse(_display);
    double result = CalculatorLogic.calculate(
        _firstNumber, secondNumber, _currentOperation);
    _history =
        '${CalculatorLogic.formatNumber(_firstNumber)} $_currentOperation ${CalculatorLogic.formatNumber(secondNumber)} =';
    _display = CalculatorLogic.formatNumber(result);

    _lastResult = result;
    _lastOperand = secondNumber;
    _lastOperation = _currentOperation;

    _currentOperation = '';
    _isNewNumber = true;
    _hideCustomText();
  }

  void _repeatLastOperation() {
    double result =
        CalculatorLogic.calculate(_lastResult, _lastOperand, _lastOperation);
    _history =
        '${CalculatorLogic.formatNumber(_lastResult)} $_lastOperation ${CalculatorLogic.formatNumber(_lastOperand)} =';
    _display = CalculatorLogic.formatNumber(result);
    _lastResult = result;
    _isNewNumber = true;
  }

  void _handleOperator(String operator) {
    if (_currentOperation.isEmpty) {
      _firstNumber = double.parse(_display);
      _currentOperation = operator;
      _history = '${CalculatorLogic.formatNumber(_firstNumber)} $operator';
      _isNewNumber = true;
      _hideCustomText();
    } else {
      double secondNumber = double.parse(_display);
      double result = CalculatorLogic.calculate(
          _firstNumber, secondNumber, _currentOperation);
      _firstNumber = result;
      _currentOperation = operator;
      _history = '${CalculatorLogic.formatNumber(result)} $operator';
      _display = CalculatorLogic.formatNumber(result);
      _isNewNumber = true;
      _hideCustomText();
    }
  }

  void _handleNumberInput(String number) {
    if (_isNewNumber || _showCustomText) {
      if (!CalculatorLogic.isValidNumberInput(_display, number)) {
        return;
      }
      _display = number;
      _isNewNumber = false;
      _hideCustomText();
    } else {
      if (!CalculatorLogic.isValidNumberInput(_display, number)) {
        return;
      }
      _display += number;
    }
    _equation += number;
  }

  void _hideCustomText() {
    _showCustomText = false;
  }

  void _resetLastOperation() {
    _lastResult = 0;
    _lastOperand = 0;
    _lastOperation = '';
  }

  void _navigateToCustomTextEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomTextEditor(
          initialText: _customText,
          onSave: (text) async {
            await StorageService.saveCustomText(text);
            setState(() {
              _customText = text;
              _isNewNumber = true;
            });
          },
        ),
      ),
    );
  }

  void _toggleShakeFeature() async {
    _shakeFeatureEnabled = !_shakeFeatureEnabled;
    await StorageService.saveShakeEnabled(_shakeFeatureEnabled);

    if (_shakeFeatureEnabled) {
      _shakeDetector = ShakeDetector(
        onShake: _onShakeDetected,
        enabled: true,
      );
      _shakeDetector.startListening();
    } else {
      _shakeDetector.setEnabled(false);
    }
  }

  Widget _buildButton(
    String text, {
    Color? color,
    Color? textColor,
    double? fontSize,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: AspectRatio(
          aspectRatio: text == '0' ? 2 : 1,
          child: text == '⌫' || text == 'C'
              ? GestureDetector(
                  onLongPress: _resetCalculator,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color ?? Colors.grey[800],
                      foregroundColor: textColor ?? Colors.white,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    onPressed: () => _onButtonPressed(text),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize ?? 28,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                )
              : text == '0'
                  ? GestureDetector(
                      onLongPress: _toggleShakeFeature,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color ?? Colors.grey[800],
                          foregroundColor: textColor ?? Colors.white,
                          shape: const StadiumBorder(),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        onPressed: () => _onButtonPressed(text),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: fontSize ?? 28,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color ?? Colors.grey[800],
                        foregroundColor: textColor ?? Colors.white,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      onPressed: () => _onButtonPressed(text),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: fontSize ?? 28,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _history,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_showCustomText)
                    FadeTransition(
                      opacity: _animation,
                      child: Text(
                        _customText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    )
                  else
                    Text(
                      _display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton(
                      (_display == '0' || _showCustomText) ? 'C' : '⌫',
                      color: Colors.grey[400],
                      textColor: Colors.black,
                    ),
                    _buildButton('±',
                        color: Colors.grey[400], textColor: Colors.black),
                    _buildButton('%',
                        color: Colors.grey[400], textColor: Colors.black),
                    _buildButton('÷', color: Colors.orange, fontSize: 32),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('×', color: Colors.orange, fontSize: 32),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('-', color: Colors.orange, fontSize: 32),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('+', color: Colors.orange, fontSize: 32),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: AspectRatio(
                          aspectRatio: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            onPressed: () => _onButtonPressed('0'),
                            child: const Text(
                              '0',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildButton('.'),
                    _buildButton('=', color: Colors.orange, fontSize: 32),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextEditor extends StatefulWidget {
  final String initialText;
  final Function(String) onSave;

  const CustomTextEditor({
    super.key,
    required this.initialText,
    required this.onSave,
  });

  @override
  State<CustomTextEditor> createState() => _CustomTextEditorState();
}

class _CustomTextEditorState extends State<CustomTextEditor> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Edit Custom Text',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              widget.onSave(_textController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          style: const TextStyle(color: Colors.white, fontSize: 24),
          decoration: const InputDecoration(
            hintText: 'Enter custom text',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ),
    );
  }
}
