// lib/services/macro_runner.dart
import 'accessibility_bridge.dart';

class MacroStep {
  final MacroAction action;
  final Map<String, dynamic>? params;

  const MacroStep(this.action, [this.params]);

  // Factory helpers
  factory MacroStep.wait(int ms) => MacroStep(MacroAction.wait, {'ms': ms});
  factory MacroStep.tap(double x, double y) =>
      MacroStep(MacroAction.tap, {'x': x, 'y': y});
  factory MacroStep.launch(String package) =>
      MacroStep(MacroAction.launch, {'package': package});
  factory MacroStep.back() => MacroStep(MacroAction.back);
  factory MacroStep.home() => MacroStep(MacroAction.home);
  factory MacroStep.text(String text) =>
      MacroStep(MacroAction.text, {'text': text});
}

enum MacroAction {
  launch,
  tap,
  wait,
  back,
  home,
  text,
  swipe,
}

class MacroRunner {
  final List<String> logs = [];
  bool isRunning = false;

  void log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    logs.add('[$timestamp] $message');
  }

  Future<void> run(List<MacroStep> steps,
      {Function(String)? onLog}) async {
    isRunning = true;
    logs.clear();

    for (final step in steps) {
      try {
        switch (step.action) {
          case MacroAction.launch:
            final pkg = step.params!['package'] as String;
            log('Launching $pkg');
            await AccessibilityBridge.launchApp(pkg);
            await Future.delayed(const Duration(seconds: 2));
            break;

          case MacroAction.tap:
            final x = step.params!['x'] as double;
            final y = step.params!['y'] as double;
            log('Tapping at ($x, $y)');
            await AccessibilityBridge.tap(x, y);
            await Future.delayed(const Duration(milliseconds: 300));
            break;

          case MacroAction.wait:
            final ms = step.params!['ms'] as int;
            log('Waiting ${ms}ms');
            await Future.delayed(Duration(milliseconds: ms));
            break;

          case MacroAction.back:
            log('Pressing back');
            await AccessibilityBridge.pressBack();
            await Future.delayed(const Duration(milliseconds: 300));
            break;

          case MacroAction.home:
            log('Pressing home');
            await AccessibilityBridge.pressHome();
            await Future.delayed(const Duration(milliseconds: 300));
            break;

          case MacroAction.text:
            final text = step.params!['text'] as String;
            log('Typing: $text');
            await AccessibilityBridge.inputText(text);
            await Future.delayed(const Duration(milliseconds: 200));
            break;

          case MacroAction.swipe:
            await AccessibilityBridge.swipe(
              x1: step.params!['x1'],
              y1: step.params!['y1'],
              x2: step.params!['x2'],
              y2: step.params!['y2'],
              duration: step.params!['duration'] ?? 300,
            );
            break;
        }
        onLog?.call(logs.last);
      } catch (e) {
        log('Error: $e');
        onLog?.call(logs.last);
      }
    }

    log('Macro finished');
    isRunning = false;
  }
}
