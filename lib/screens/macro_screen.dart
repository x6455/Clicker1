// lib/screens/macro_screen.dart
import 'package:flutter/material.dart';
import '../services/accessibility_bridge.dart';
import '../services/macro_runner.dart';

class MacroScreen extends StatefulWidget {
  const MacroScreen({super.key});

  @override
  State<MacroScreen> createState() => _MacroScreenState();
}

class _MacroScreenState extends State<MacroScreen> {
  final _runner = MacroRunner();
  final _packageCtrl = TextEditingController();
  final _xCtrl = TextEditingController();
  final _yCtrl = TextEditingController();
  bool _serviceEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkService();
  }

  Future<void> _checkService() async {
    final enabled = await AccessibilityBridge.isServiceEnabled();
    setState(() => _serviceEnabled = enabled);
  }

  Future<void> _runSimpleTap() async {
    if (!_serviceEnabled) {
      _showServiceDialog();
      return;
    }

    final package = _packageCtrl.text.trim();
    final x = double.tryParse(_xCtrl.text.trim());
    final y = double.tryParse(_yCtrl.text.trim());

    if (package.isEmpty || x == null || y == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields')),
      );
      return;
    }

    setState(() {});

    await _runner.run(
      [
        MacroStep.launch(package),
        MacroStep.wait(2000),
        MacroStep.tap(x, y),
      ],
      onLog: (_) => setState(() {}),
    );

    setState(() {});
  }

  void _showServiceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enable Accessibility Service'),
        content: const Text(
          'This app needs Accessibility Service to perform taps on other apps. '
          'Please enable "Macro Runner" in Accessibility settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              AccessibilityBridge.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Macro Runner'),
        actions: [
          IconButton(
            icon: Icon(
              _serviceEnabled ? Icons.check_circle : Icons.warning_amber,
              color: _serviceEnabled ? Colors.green : Colors.orange,
            ),
            onPressed: () => AccessibilityBridge.openSettings(),
            tooltip: 'Accessibility Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_serviceEnabled)
              Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: const Text('Accessibility Service Required'),
                  subtitle: const Text('Tap here to enable'),
                  onTap: _showServiceDialog,
                ),
              ),

            const SizedBox(height: 16),

            // Configuration
            TextField(
              controller: _packageCtrl,
              decoration: const InputDecoration(
                labelText: 'Package Name',
                hintText: 'com.example.testapp',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _xCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'X',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _yCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Y',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _runner.isRunning ? null : _runSimpleTap,
              icon: Icon(_runner.isRunning ? Icons.hourglass_top : Icons.play_arrow),
              label: Text(_runner.isRunning ? 'Running...' : 'Run Tap'),
            ),

            const SizedBox(height: 16),
            const Divider(),
            Row(
              children: [
                const Text('Logs', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: () => setState(() => _runner.logs.clear()), child: const Text('Clear')),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _runner.logs.isEmpty
                    ? const Center(child: Text('No logs', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _runner.logs.length,
                        itemBuilder: (_, i) => Text(
                          _runner.logs[i],
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
