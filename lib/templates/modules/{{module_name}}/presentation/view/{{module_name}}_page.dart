

import 'package:flutter/material.dart';

class {{page_name}} extends StatefulWidget {
  static const path = '/{{module_name}}';
  static const name = '{{page_name}}';
  const {{page_name}}({super.key});

  @override
  State<{{page_name}}> createState() => _{{page_name}}State();
}

class _{{page_name}}State extends State<{{page_name}}> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{page_name}} Page'),
      ),
      body: const Center(
        child: Text('This is the {{page_name}} page.'),
      ),
    );
  }
}