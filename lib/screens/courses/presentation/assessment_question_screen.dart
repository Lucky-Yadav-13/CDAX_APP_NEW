import 'package:flutter/material.dart';

import '../application/assessment_provider.dart';
import '../data/mock_assessment_repository.dart';

class AssessmentQuestionScreen extends StatefulWidget {
  const AssessmentQuestionScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<AssessmentQuestionScreen> createState() => _AssessmentQuestionScreenState();
}

class _AssessmentQuestionScreenState extends State<AssessmentQuestionScreen> {
  final _repo = const MockAssessmentRepository();
  final _provider = AssessmentProvider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<McqQuestion>>(
      future: _repo.getMcqsForCourse(widget.courseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: SafeArea(
              child: Center(child: Text('Failed to load questions')),
            ),
          );
        }
        final questions = snapshot.data ?? const <McqQuestion>[];
        if (questions.isEmpty) {
          return const Scaffold(body: SafeArea(child: Center(child: Text('No questions available'))));
        }

        final idx = _provider.currentIndex;
        final q = questions[idx];
        final selected = _provider.answers[idx];
        final total = questions.length;

        return Scaffold(
          appBar: AppBar(title: Text('Q${idx + 1}/$total')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.question, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...List<Widget>.generate(q.options.length, (i) {
                    return RadioListTile<int>(
                      value: i,
                      groupValue: selected,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _provider.submitAnswer(questionIndex: idx, selectedOptionIndex: v);
                        });
                      },
                      title: Text(q.options[i]),
                    );
                  }),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: idx > 0
                              ? () => setState(() => _provider.goToPrevQuestion())
                              : null,
                          child: const Text('Previous'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: selected == null
                              ? null
                              : () async {
                                  if (idx < total - 1) {
                                    setState(() => _provider.goToNextQuestion(total));
                                  } else {
                                    final corrects = questions.map((e) => e.correctIndex).toList(growable: false);
                                    try {
                                      final score = await _provider.computeScore(correctOptionIndexes: corrects);
                                      if (!mounted) return;
                                      Navigator.of(context).pushNamed(
                                        '/dashboard/courses/${widget.courseId}/assessment/score',
                                        arguments: score,
                                      );
                                    } catch (_) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to compute score')),
                                      );
                                    }
                                  }
                                },
                          child: Text(idx == total - 1 ? 'Finish' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


