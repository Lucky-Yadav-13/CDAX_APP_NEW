// ASSUMPTION: Simple form to edit name/phone; returns updated profile via Navigator.pop.

import 'package:flutter/material.dart';
import '../application/profile_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, this.initial});
  final UserProfile? initial;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial ?? const UserProfile(
      name: 'Jane Doe',
      email: 'jane@example.com',
      phone: '+1 555 0100',
      enrolledCoursesCount: 2,
      subscribed: true,
    );
    _name = TextEditingController(text: p.name);
    _phone = TextEditingController(text: p.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.initial ?? const UserProfile(
      name: 'Jane Doe',
      email: 'jane@example.com',
      phone: '+1 555 0100',
      enrolledCoursesCount: 2,
      subscribed: true,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                if (v.trim().length < 2) return 'Enter a valid name';
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: profile.email,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Phone is required';
                final d = v.replaceAll(RegExp('[^0-9]'), '');
                if (d.length < 10) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _saving = true);
                      final updated = profile.copyWith(
                        name: _name.text.trim(),
                        phone: _phone.text.trim(),
                      );
                      if (!mounted) return;
                      setState(() => _saving = false);
                      Navigator.of(context).pop<UserProfile>(updated);
                    },
              child: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}


