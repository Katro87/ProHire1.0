import 'package:flutter/material.dart';
import 'package:mini_fiverr/screens/shared/security_questions_screen.dart' as shared;

class SecurityQuestionsScreen extends StatefulWidget {
  final bool isMandatory;

  const SecurityQuestionsScreen({super.key, this.isMandatory = false});

  @override
  State<SecurityQuestionsScreen> createState() => _SecurityQuestionsScreenState();
}

class _SecurityQuestionsScreenState extends State<SecurityQuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return shared.SecurityQuestionsScreen(isMandatory: widget.isMandatory);
  }
}
