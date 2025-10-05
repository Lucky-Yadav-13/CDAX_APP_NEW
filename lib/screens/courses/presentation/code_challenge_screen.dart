import 'package:flutter/material.dart';

import '../data/mock_code_runner_service.dart';

class CodeChallengeScreen extends StatefulWidget {
  const CodeChallengeScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<CodeChallengeScreen> createState() => _CodeChallengeScreenState();
}

class _CodeChallengeScreenState extends State<CodeChallengeScreen> {
  static const List<String> _languages = <String>['Dart', 'Python', 'JavaScript'];
  String _language = _languages.first;
  final TextEditingController _codeCtrl = TextEditingController();
  bool _running = false;
  String? _output;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _runCode() async {
    setState(() {
      _running = true;
      _output = null;
      _error = null;
    });
    try {
      final res = await MockCodeRunnerService.run(language: _language, code: _codeCtrl.text);
      if (!mounted) return;
      setState(() {
        _running = false;
        _output = res.output;
        _error = res.error;
      });
      if (!res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.error ?? 'Run failed')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _running = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error running code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Code Challenge')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Language:', style: theme.textTheme.bodyLarge),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _language,
                    items: _languages
                        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                        .toList(growable: false),
                    onChanged: _running
                        ? null
                        : (v) => setState(() {
                              if (v != null) _language = v;
                            }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Prompt: Implement solution for course ${widget.courseId}', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _codeCtrl,
                minLines: 8,
                maxLines: 16,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write your code here...'
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _running ? null : _runCode,
                      child: const Text('Run Code'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _running
                          ? null
                          : () async {
                              await _runCode();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Code submitted')),
                              );
                            },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_running) const LinearProgressIndicator(),
              if (_output != null || _error != null) ...[
                const SizedBox(height: 12),
                Text('Output:', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error ?? _output ?? ''),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


