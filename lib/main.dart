import 'dart:math';

import 'package:expressions/expressions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(242, 468), // Base design size for scaling
      builder: (context, child) {
        return MaterialApp(
          title: 'Scientific Calculator',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const CalculatorScreen(),
        );
      },
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  String input = "";
  String answer = "";

  void onButtonPressed(String value) {
    setState(() {
      if (value == 'sin' ||
          value == 'cos' ||
          value == 'tan' ||
          value == 'log' ||
          value == 'ln') {
        input += '$value(';
      } else if (value == '+-') {
        input += '-';
      } else if (value == 'π') {
        input += 'pi';
      } else if (value == '√') {
        input += 'sqrt(';
      } else if (value == 'x²') {
        input += '^2';
      } else if (value == 'xʸ') {
        input += '^';
      } else if (value == 'C') {
        input = ""; // Reset input when switching modes
        answer = "";
      } else if (value == '⬅') {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
      } else if (value == "=") {
        try {
          String processedString = processString(input);
          double total = evaluateExpression(processedString);
          String result = total.toString();
          if (result.contains('.')) {
            // Get the part after the decimal
            String decimalPart = result.split('.')[1];
            if (decimalPart.length > 6) {
              result = total.toStringAsFixed(6); // Round to six decimal places
            }
          }
          answer = result;
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
          answer = 'Error';
        }
      } else if (value == "⇌") {
        var orientation = MediaQuery.of(context).orientation;
        if (orientation == Orientation.portrait) {
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.landscapeLeft]);
        } else {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        }
        input = ""; // Reset input when switching modes
        answer = "";
      } else {
        input += value;
      }
    });
  }

// Helper function to convert degrees to radians
  double degToRad(double degrees) {
    return degrees * pi / 180;
  }

// Helper function to compute factorial
  int factorial(int n) {
    if (n < 0) {
      throw ArgumentError('Error');
    }
    return n == 0 ? 1 : n * factorial(n - 1);
  }

// Function to evaluate arithmetic expressions
  double evaluateExpression(String expression) {
    const evaluator = ExpressionEvaluator();
    final parsedExpression = Expression.parse(expression);

    return double.parse(evaluator.eval(parsedExpression, {}).toString());
  }

// Function to process and replace sin(), cos(), tan(), log10(), factorial, and power (^) calls with evaluated results
  String processString(String s) {
    // Replace implicit multiplication like 5(4-1) with 5 * (4-1)
    s = s.replaceAllMapped(RegExp(r'(\d+)\s*\(([^)]+)\)'), (match) {
      return '${match[1]} * (${match[2]})';
    });

    s = s.replaceAllMapped(RegExp(r'asin\((.*?)\)'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      if (value < -1 || value > 1) {
        throw ArgumentError(
            'Input for asin must be in the range [-1, 1]. Got: $value');
      }
      double result = asin(value) * 180 / pi; // Convert radians to degrees
      return result.toString();
    });

    s = s.replaceAllMapped(RegExp(r'acos\((.*?)\)'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      if (value < -1 || value > 1) {
        throw ArgumentError(
            'Input for acos must be in the range [-1, 1]. Got: $value');
      }
      double result = acos(value) * 180 / pi; // Convert radians to degrees
      return result.toString();
    });

    s = s.replaceAllMapped(RegExp(r'atan\((.*?)\)'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      double result = atan(value) * 180 / pi; // Convert radians to degrees
      return result.toString();
    });

    // Replace sin() and cos() with their evaluated results
    s = s.replaceAllMapped(RegExp(r'sin\((.*?)\)'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      double result = sin(degToRad(value));
      return result.toString();
    });

    s = s.replaceAllMapped(RegExp(r'cos\((.*?)\)'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      double result = cos(degToRad(value));
      return result.toString();
    });

    // Replace tan() with its evaluated result
    s = s.replaceAllMapped(RegExp(r'tan\((.*?)\)'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      double result = tan(degToRad(value));
      return result.toString();
    });

    // Replace log() with ln base log (log)
    s = s.replaceAllMapped(RegExp(r'ln\((.*?)\)'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      double result = log(value); // log base
      return result.toString();
    });

    // Replace log() with base-10 log (log10)
    s = s.replaceAllMapped(RegExp(r'log\((.*?)\)'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      double result = log(value) / log(10); // log base 10
      return result.toString();
    });

    s = s.replaceAllMapped(RegExp(r'sqrt\((.*?)\)'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      double result = sqrt(value);
      return result.toString();
    });

    // Replace the constant 'e' with 2.718281828
    s = s.replaceAll('e', '2.718281828');

    // Replace the constant 'pi' with its value
    s = s.replaceAll('pi', pi.toString());

    // Replace power (^) expressions like 5^2 with the evaluated result
    s = s.replaceAllMapped(RegExp(r'(\d+)\s*\^\s*(\d+)'), (match) {
      double base = double.parse(match[1]!);
      double exponent = double.parse(match[2]!);
      double result = pow(base, exponent).toDouble();
      return result.toString();
    });

    // Replace factorial (!) expressions like (2+3)! or 5! with the evaluated result
    s = s.replaceAllMapped(RegExp(r'\((.*?)\)!'), (match) {
      String inside = match[1]!;
      double value = evaluateExpression(inside);
      int result = factorial(value.toInt());
      return result.toString();
    });

    // Handle standalone factorials (e.g., 5!)
    s = s.replaceAllMapped(RegExp(r'(\d+)\s*!'), (match) {
      int number = int.parse(match[1]!);
      int result = factorial(number);
      return result.toString();
    });

    return s;
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 600.0;
    var orientation = MediaQuery.of(context).orientation;
    final Size screenSize = MediaQuery.of(context).size;
    if (screenSize.width > maxWidth && orientation == Orientation.portrait) {
      return Scaffold(
        appBar: AppBar(title: const Text('High Screen Size')),
        body: const Center(
          child: Text(
            'Screen size is too high!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.r),
                    child: TextField(
                      controller: TextEditingController(text: input),
                      style: TextStyle(fontSize: 24.h), // Responsive font size
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.r),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        answer,
                        style:
                            TextStyle(fontSize: 24.h), // Responsive font size
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                        width:
                            orientation == Orientation.landscape ? 30.w : 50.w,
                        height:
                            orientation == Orientation.landscape ? 25.h : 35.h),
                    SizedBox(
                      width: orientation == Orientation.landscape ? 30.w : 50.w,
                      height:
                          orientation == Orientation.landscape ? 25.h : 35.h,
                    ),
                    SizedBox(
                      width: orientation == Orientation.landscape ? 30.w : 50.w,
                      height:
                          orientation == Orientation.landscape ? 25.h : 35.h,
                    ),
                    if (orientation == Orientation.landscape)
                      Row(
                        children: [
                          SizedBox(
                            width: orientation == Orientation.landscape
                                ? 30.w
                                : 50.w,
                            height: orientation == Orientation.landscape
                                ? 25.h
                                : 35.h,
                          ),
                          SizedBox(
                            width: orientation == Orientation.landscape
                                ? 30.w
                                : 50.w,
                            height: orientation == Orientation.landscape
                                ? 25.h
                                : 35.h,
                          ),
                          SizedBox(
                            width: orientation == Orientation.landscape
                                ? 30.w
                                : 50.w,
                          ),
                        ],
                      ),
                    CalculatorButton(
                        label: '⬅', onPressed: () => onButtonPressed('⬅')),
                  ],
                ),
                SizedBox(
                  height: 2.w,
                ),
              ],
            ),
            if (orientation == Orientation.portrait) ...[
              buildStandardCalculator(),
            ] else ...[
              buildScientificCalculator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildStandardCalculator() {
    return Column(
      children: [
        buildNumberRow(['C', '+-', '%', '/']),
        buildNumberRow(['7', '8', '9', '*']),
        buildNumberRow(['4', '5', '6', '-']),
        buildNumberRow(['1', '2', '3', '+']),
        buildNumberRow(['⇌', '0', '.', '=']),
      ],
    );
  }

  Widget buildScientificCalculator() {
    return Column(
      children: [
        buildNumberRow(['2nd', 'Rad', '√', 'C', '(', ')', '%']),
        buildNumberRow(['sin', 'cos', 'tan', '7', '8', '9', '/']),
        buildNumberRow(['ln', 'log', '1/x', '4', '5', '6', '*']),
        buildNumberRow(['e', 'x²', 'xʸ', '1', '2', '3', '-']),
        buildNumberRow(['⇌', 'π', '!', '0', '.', '+', '=']),
      ],
    );
  }

  Widget buildNumberRow(List<String> labels) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.w), // Responsive padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels.map((label) {
          return CalculatorButton(
              label: label, onPressed: () => onButtonPressed(label));
        }).toList(),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: orientation == Orientation.landscape ? 35.h : 45.h,
        width: orientation == Orientation.landscape ? 30.w : 50.w,
        decoration: BoxDecoration(
          shape: orientation == Orientation.portrait
              ? BoxShape.circle
              : BoxShape.rectangle,
          color: Colors.amber,
          borderRadius: orientation == Orientation.portrait
              ? null
              : BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                fontSize: orientation == Orientation.portrait
                    ? 16.h
                    : 22.h), // Responsive font size
          ),
        ),
      ),
    );
  }
}
