import 'package:flutter/material.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _downloading = false;

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificate downloaded successfully')), 
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download certificate')),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDownload = _acceptTerms && _acceptPrivacy && !_downloading;
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Certificate of Completion', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text('Awarded to:'),
                      const SizedBox(height: 4),
                      Text('Learner', style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('For successfully completing course ${widget.courseId}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _acceptTerms,
                onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                title: const Text('I agree to the Terms of Service'),
              ),
              CheckboxListTile(
                value: _acceptPrivacy,
                onChanged: (v) => setState(() => _acceptPrivacy = v ?? false),
                title: const Text('I agree to the Privacy Policy'),
              ),
              const SizedBox(height: 16),
              if (_downloading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: canDownload ? _download : null,
                child: const Text('Download Certificate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


