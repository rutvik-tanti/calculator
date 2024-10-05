import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String input = '';
  String output = '';
  bool isScientificMode = false;

  int factorial(int n) {
    if (n == 0 || n == 1) {
      return 1;
    } else {
      return n * factorial(n - 1); // Recursive approach
    }
  }

  String processImplicitMultiplication(String expression) {
    String processedExpression = expression;

    // Regular expression to find cases where a number is followed by (
    processedExpression = processedExpression.replaceAllMapped(
        RegExp(r'(\d)(\()'), (match) => '${match.group(1)}*${match.group(2)}');

    // Regular expression to find cases where ) is followed by a number
    processedExpression = processedExpression.replaceAllMapped(
        RegExp(r'(\))(\d)'), (match) => '${match.group(1)}*${match.group(2)}');
    processedExpression = processedExpression.replaceAllMapped(
      RegExp(
          r'√(\d+(\.\d+)?)'), // Looks for √ followed by digits (and optional decimal)
      (match) => 'sqrt(${match.group(1)})', // Wraps the number in sqrt()
    );

    // Handle incomplete cases like 2^(3 and convert to pow(2, 3)
    processedExpression = processedExpression.replaceAllMapped(
      RegExp(
          r'(\d+|\d*\.\d+)\^(\d+|\d*\.\d+)$'), // Matches incomplete case: 2^3
      (match) => 'pow(${match.group(1)}, ${match.group(2)})',
    );

    processedExpression = processedExpression.replaceAllMapped(
      RegExp(r'(\d+)!'), // Match a number followed by !
      (match) {
        int number = int.parse(match.group(1)!);
        return factorial(number)
            .toString(); // Replace with the calculated factorial
      },
    );
    return processedExpression;
  }

  void buttonPressed(String value) {
    setState(() {
      if (value == '1/x') {
        input += '1÷';
      } else if (value == 'x!') {
        input += '!';
      } else if (value == 'xʸ') {
        input += '^(';
      } else if (value == 'AC') {
        input = '';
        output = '';
      } else if (value == '⌫') {
        input = input.isNotEmpty ? input.substring(0, input.length - 1) : '';
      } else if (value == '=') {
        try {
          String expression = processImplicitMultiplication(input);
          Parser p = Parser();
          Expression exp = p.parse(expression
              .replaceAll('×', '*')
              .replaceAll('÷', '/')
              .replaceAll('π', '3.14159'));
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          output = eval.toString();
        } catch (e) {
          output = 'Error';
        }
      } else if (value == '2nd') {
        // Handle '2nd' if needed for more complex operations
      } else if (value == '↻') {
        isScientificMode = !isScientificMode; // Toggle between modes
      } else {
        input += value;
      }
    });
  }

  Widget buildButton(String text, Color color, double size) {
    return Expanded(
      child: Container(
        height: isScientificMode ? 60 : 80,
        child: ElevatedButton(
          onPressed: () => buttonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNormalKeyboard() {
    return Column(
      children: [
        Row(
          children: [
            buildButton('AC', Colors.redAccent, 24),
            buildButton('⌫', Colors.blueAccent, 24),
            buildButton('%', Colors.blueAccent, 24),
            buildButton('÷', Colors.blueAccent, 24),
          ],
        ),
        Row(
          children: [
            buildButton('7', Colors.grey, 24),
            buildButton('8', Colors.grey, 24),
            buildButton('9', Colors.grey, 24),
            buildButton('×', Colors.blueAccent, 24),
          ],
        ),
        Row(
          children: [
            buildButton('4', Colors.grey, 24),
            buildButton('5', Colors.grey, 24),
            buildButton('6', Colors.grey, 24),
            buildButton('-', Colors.blueAccent, 24),
          ],
        ),
        Row(
          children: [
            buildButton('1', Colors.grey, 24),
            buildButton('2', Colors.grey, 24),
            buildButton('3', Colors.grey, 24),
            buildButton('+', Colors.blueAccent, 24),
          ],
        ),
        Row(
          children: [
            buildButton('↻', Colors.grey, 24),
            buildButton('0', Colors.grey, 24),
            buildButton('.', Colors.grey, 24),
            buildButton('=', Colors.greenAccent, 24),
          ],
        ),
      ],
    );
  }

  Widget buildScientificKeyboard() {
    return Column(
      children: [
        Row(
          children: [
            buildButton('2nd', Colors.grey, 18),
            buildButton('deg', Colors.grey, 18),
            buildButton('sin', Colors.blueAccent, 18),
            buildButton('cos', Colors.blueAccent, 18),
            buildButton('tan', Colors.blueAccent, 18),
          ],
        ),
        Row(
          children: [
            buildButton('xʸ', Colors.grey, 24), // Power function
            buildButton('lg', Colors.blueAccent, 24),
            buildButton('ln', Colors.blueAccent, 24),
            buildButton('(', Colors.grey, 24),
            buildButton(')', Colors.grey, 24),
          ],
        ),
        Row(
          children: [
            buildButton('√', Colors.grey, 24), // Square root
            buildButton('AC', Colors.redAccent, 24),
            buildButton('⌫', Colors.blueAccent, 24),
            buildButton('%', Colors.blueAccent, 24),
            buildButton('÷', Colors.blueAccent, 24),
          ],
        ),
        Row(
          children: [
            buildButton('x!', Colors.grey, 24), // Factorial
            buildButton('7', Colors.grey, 24),
            buildButton('8', Colors.grey, 24),
            buildButton('9', Colors.grey, 24),
            buildButton('×', Colors.blueAccent, 24),
          ],
        ),
        Row(
          children: [
            buildButton('1/x', Colors.grey, 24), // Reciprocal
            buildButton('4', Colors.grey, 24),
            buildButton('5', Colors.grey, 24),
            buildButton('6', Colors.grey, 24),
            buildButton('-', Colors.blueAccent, 24),
          ],
        ),
        Row(
          children: [
            buildButton('π', Colors.grey, 24), // Pi constant
            buildButton('1', Colors.grey, 24),
            buildButton('2', Colors.grey, 24),
            buildButton('3', Colors.grey, 24),
            buildButton('+', Colors.blueAccent, 24),
          ],
        ),
        Row(
          children: [
            buildButton('↻', Colors.grey, 24), // Toggle back
            buildButton('e', Colors.grey, 24), // Euler's number
            buildButton('0', Colors.grey, 24),
            buildButton('.', Colors.grey, 24),
            buildButton('=', Colors.greenAccent, 24),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Handle history action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    input,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    output,
                    style: TextStyle(fontSize: 32, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          isScientificMode ? buildScientificKeyboard() : buildNormalKeyboard(),
        ],
      ),
    );
  }
}
