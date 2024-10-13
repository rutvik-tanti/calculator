import 'dart:js' as js;
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({Key? key}) : super(key: key);

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _input = '';
  String _output = '';

  void _append(String value) {
    setState(() {
      _input += value;
    });
  }

  void _clear() {
    setState(() {
      _input = '';
      _output = '';
    });
  }

  void _backspace() {
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  void _calculate() {
    try {
      String modifiedInput = _input.replaceAll('π', (pi).toString());

      // Evaluate functions
      if (modifiedInput.contains('sin')) {
        _output = _evaluateFunction(modifiedInput, 'sin').toString();
      } else if (modifiedInput.contains('cos')) {
        _output = _evaluateFunction(modifiedInput, 'cos').toString();
      } else if (modifiedInput.contains('tan')) {
        _output = _evaluateFunction(modifiedInput, 'tan').toString();
      } else if (modifiedInput.contains('sqrt')) {
        _output = _evaluateFunction(modifiedInput, 'sqrt').toString();
      } else if (modifiedInput.contains('ln')) {
        _output = _evaluateFunction(modifiedInput, 'ln').toString();
      } else {
        // Handle normal arithmetic evaluation
        String expression = '2 * (3 + 5)';
        print('object');
        // Call the JavaScript function
        var result = js.context.callMethod('math.evaluate', [expression]);
        print(result);
        _output = result.toString();
      }
    } catch (e) {
      setState(() {
        _output = 'Error';
      });
    }
  }

  double _evaluateFunction(String input, String functionName) {
    // Create a regex pattern for the specific function
    final regex = RegExp('${functionName}\\(([^)]+)\\)');
    final match = regex.firstMatch(input);
    print(match?.group(1)!);
    print(regex);
    if (match != null) {
      final argument = double.parse(match.group(1)!);
      switch (functionName) {
        case 'sin':
          return sin(argument);
        case 'cos':
          return cos(argument);
        case 'tan':
          return tan(argument);
        case 'sqrt':
          return sqrt(argument);
        case 'ln':
          return log(argument);
        default:
          throw Exception('Unknown function');
      }
    }
    throw Exception('Function not found');
  }

  double _evaluateArithmetic(String input) {
    // You can use the `expressions` package here to evaluate arithmetic expressions.
    // For simplicity, let's use the Dart eval functions directly or a custom parser.

    // In this case, we will just do a basic evaluation using `eval`
    // This function is simplistic; in a production app, you'd want a more robust solution.
    return double.parse(input); // Just for demonstration; replace with actual arithmetic evaluation.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scientific Calculator')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
            alignment: Alignment.centerRight,
            child: Text(
              _input,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            alignment: Alignment.centerRight,
            child: Text(
              _output,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  children: _buildButtons(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildButtons() {
    final buttons = [
      {'label': '7', 'onTap': () => _append('7')},
      {'label': '8', 'onTap': () => _append('8')},
      {'label': '9', 'onTap': () => _append('9')},
      {'label': '/', 'onTap': () => _append('/')},
      {'label': '4', 'onTap': () => _append('4')},
      {'label': '5', 'onTap': () => _append('5')},
      {'label': '6', 'onTap': () => _append('6')},
      {'label': '*', 'onTap': () => _append('*')},
      {'label': '1', 'onTap': () => _append('1')},
      {'label': '2', 'onTap': () => _append('2')},
      {'label': '3', 'onTap': () => _append('3')},
      {'label': '-', 'onTap': () => _append('-')},
      {'label': '0', 'onTap': () => _append('0')},
      {'label': '.', 'onTap': () => _append('.')},
      {'label': 'C', 'onTap': _clear},
      {'label': '+', 'onTap': () => _append('+')},
      {'label': 'sin', 'onTap': () => _append('sin(')},
      {'label': 'cos', 'onTap': () => _append('cos(')},
      {'label': 'tan', 'onTap': () => _append('tan(')},
      {'label': 'sqrt', 'onTap': () => _append('sqrt(')},
      {'label': 'ln', 'onTap': () => _append('ln(')},
      {'label': 'e', 'onTap': () => _append('2.718281828459')},
      {'label': 'π', 'onTap': () => _append('π')},
      {'label': 'Ans', 'onTap': _calculate},
      {'label': 'Back', 'onTap': _backspace},
      {'label': ')', 'onTap': () => _append(')')},
    ];

    return buttons.map((button) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: button['onTap'] as void Function(),
          child: Text(button['label'] as String),
        ),
      );
    }).toList();
  }
}
