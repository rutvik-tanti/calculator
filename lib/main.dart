import 'dart:js_interop';

import 'package:flutter/material.dart';

@JS('getStringLength')
external double getStringLength(String input);

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
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = "";
  String answer = "";
  bool isScientific = false;

  void onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        input = "";
        answer = "";
      } else if (value == "=") {
        answer = calculateResult(input);
      } else if (value == "Sci") {
        isScientific = !isScientific;
        input = ""; // Reset input when switching modes
        answer = "";
      } else {
        input += value;
      }
    });
  }

  String calculateResult(String expression) {
    // Basic expression evaluation logic (for demonstration purposes)
    try {
      return expression; // Replace this with your calculation logic
    } catch (e) {
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: TextEditingController(text: input),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Input',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CalculatorButton(label: 'Sci', onPressed: () => onButtonPressed('Sci')),
              CalculatorButton(label: 'Back', onPressed: () => onButtonPressed('Back')),
            ],
          ),
          if (!isScientific) ...[
            buildStandardCalculator(),
          ] else ...[
            buildScientificCalculator(),
          ],
        ],
      ),
    );
  }

  Widget buildStandardCalculator() {
    return Column(
      children: [
        buildNumberRow(['C', '(', '%', '/']),
        buildNumberRow(['7', '8', '9', '*']),
        buildNumberRow(['4', '5', '6', '-']),
        buildNumberRow(['1', '2', '3', '+']),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CalculatorButton(label: '0', onPressed: () => onButtonPressed('0')),
            CalculatorButton(label: '.', onPressed: () => onButtonPressed('.')),
            CalculatorButton(label: '=', onPressed: () => onButtonPressed('=')),
          ],
        ),
      ],
    );
  }

  Widget buildScientificCalculator() {
    return Column(
      children: [
        buildNumberRow(['2nd', 'deg', 'sin', 'cos']),
        buildNumberRow(['tan', 'x²', 'log', 'ln']),
        buildNumberRow(['√', 'C', 'b', '/']),
        buildNumberRow(['!', '1/x', 'π', '*']),
        buildNumberRow(['e', '0', '.', '=']),
      ],
    );
  }

  Row buildNumberRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: labels.map((label) {
        return CalculatorButton(label: label, onPressed: () => onButtonPressed(label));
      }).toList(),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CalculatorButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber,
        ),
        child: Center(child: Text(label)),
      ),
    );
  }
}
