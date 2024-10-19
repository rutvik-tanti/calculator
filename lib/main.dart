import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// InAppLocalhostServer inAppLocalhostServer = InAppLocalhostServer(documentRoot: 'assets');

@JS('getAnswer')
external double getAnswer(String input);

const double size = 40;
const double size2 = 40;
const double pad = 2;
bool isScientific = false;
Widget s(double val) => SizedBox(
      height: val.h,
      width: val.w,
    );

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await inAppLocalhostServer.start();
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(242, 468),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Scientific Calculator',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: const CalculatorScreen(),
          );
        });
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
      if (value == 'x²') {
        input += '^2';
      } else if (value == 'xʸ') {
        input += '^';
      } else if (value == '⬅') {
        input = input.substring(0, input.length - 1);
      } else if (value == '+-') {
        input += '-';
      } else if (value == "C") {
        input = "";
        answer = "";
      } else if (value == "=") {
        answer = getAnswer(input).toString();
      } else if (value == "⇌") {
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: TextEditingController(text: input),
              style: const TextStyle(fontSize: 24.0),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                answer,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  s(isScientific ? size2 : size),
                  s(isScientific ? size2 : size),
                  s(isScientific ? size2 : size),
                  if (isScientific) s(isScientific ? size2 : size),
                  CalculatorButton(label: '⬅', onPressed: () => onButtonPressed('⬅')),
                ],
              ),
              s(2),
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
        buildNumberRow(['2nd', 'sin', 'cos', 'tan', 'xʸ']),
        buildNumberRow(['x²', 'log', 'in', '(', ')']),
        buildNumberRow(['√', 'C', 'e', '%', '/']),
        buildNumberRow(['!', '7', '8', '9', '*']),
        buildNumberRow(['1/', '4', '5', '6', '-']),
        buildNumberRow(['π', '1', '2', '3', '+']),
        buildNumberRow(['⇌', '4', '0', '.', '=']),
      ],
    );
  }

  Widget buildNumberRow(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.only(bottom: pad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels.map((label) {
          return CalculatorButton(label: label, onPressed: () => onButtonPressed(label));
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
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: isScientific ? size2.h : size.h,
        width: isScientific ? size2.w : size.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber,
        ),
        child: Center(child: Text(label)),
      ),
    );
  }
}

// class LocalHtmlWebView extends StatefulWidget {
//   @override
//   _LocalHtmlWebViewState createState() => _LocalHtmlWebViewState();
// }
//
// class _LocalHtmlWebViewState extends State<LocalHtmlWebView> {
//   late InAppWebViewController webViewController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Local HTML WebView")),
//       body: InAppWebView(
//         initialUrlRequest: URLRequest(url: WebUri("http://localhost:8080/web/index.html")),
//         initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
//         onWebViewCreated: (InAppWebViewController controller) {
//           webViewController = controller;
//         },
//       ),
//     );
//   }
// }
