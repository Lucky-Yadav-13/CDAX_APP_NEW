import 'package:flutter/material.dart';

class ScorePreviewScreen extends StatefulWidget {
  const ScorePreviewScreen({super.key, required this.courseId, required this.score});
  final String courseId;
  final int score;

  @override
  State<ScorePreviewScreen> createState() => _ScorePreviewScreenState();
}

class _ScorePreviewScreenState extends State<ScorePreviewScreen> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canProceed = _acceptedTerms && _acceptedPrivacy;
    return Scaffold(
      appBar: AppBar(title: const Text('Score Preview')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Score: ${widget.score}', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _acceptedTerms,
                onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                title: const Text('I agree to the Terms of Service'),
              ),
              CheckboxListTile(
                value: _acceptedPrivacy,
                onChanged: (v) => setState(() => _acceptedPrivacy = v ?? false),
                title: const Text('I agree to the Privacy Policy'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: canProceed
                    ? () {
                        Navigator.of(context).pushNamed('/dashboard/courses/${widget.courseId}/certificate', arguments: widget.score);
                      }
                    : null,
                child: const Text('Proceed to Certificate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


