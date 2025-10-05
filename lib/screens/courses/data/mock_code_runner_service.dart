class CodeRunResult {
  final bool success;
  final String output;
  final String? error;

  CodeRunResult({required this.success, required this.output, this.error});
}

class MockCodeRunnerService {
  static Future<CodeRunResult> run({required String language, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (code.trim().isEmpty) {
      return CodeRunResult(success: false, output: '', error: 'No code provided');
    }
    if (code.contains('error')) {
      return CodeRunResult(success: false, output: '', error: 'Compilation error: unexpected token');
    }
    if (code.contains('timeout')) {
      return CodeRunResult(success: false, output: '', error: 'Runtime error: timeout');
    }
    return CodeRunResult(success: true, output: 'Program output for $language:\nHello from mock runner!', error: null);
  }
}
