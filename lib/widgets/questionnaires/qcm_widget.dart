import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:student_app/model/questionnaire_model.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/stores/dio_provider.dart';
import 'package:student_app/stores/student_provider.dart';

class QCMWidget extends ConsumerStatefulWidget {
  final QCMData data;
  final String activityId;
  final Future<Map<String, dynamic>?> Function(double score) onSubmit;
  final VoidCallback? onClose; // Callback pour fermer les cartes

  const QCMWidget({
    super.key,
    required this.data,
    required this.activityId,
    required this.onSubmit,
    this.onClose, // Optionnel
  });

  @override
  ConsumerState<QCMWidget> createState() => _QCMWidgetState();
}

class _QCMWidgetState extends ConsumerState<QCMWidget>
    with WidgetsBindingObserver {
  int _currentQuestionIndex = 0;
  final Map<int, String> _answers = {}; // Index -> Selected Option Text
  bool _isSecureMode = false;
  late List<QCMQuestion> _shuffledQuestions;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions = List<QCMQuestion>.from(widget.data.questions)
      ..shuffle();
    WidgetsBinding.instance.addObserver(this);
    _enableSecureMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disableSecureMode();
    super.dispose();
  }

  Future<void> _enableSecureMode() async {
    try {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      setState(() {
        _isSecureMode = true;
      });
    } catch (e) {
      debugPrint('Security mode not supported: $e');
    }
  }

  Future<void> _disableSecureMode() async {
    try {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    } catch (e) {
      debugPrint('Error clearing security flags: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // User left the app or switched context
      _handleSecurityBreach();
    }
  }

  void _handleSecurityBreach() {
    if (!mounted) return;

    // Auto-save empty answer or just skip
    if (!_answers.containsKey(_currentQuestionIndex)) {
      setState(() {
        _answers[_currentQuestionIndex] = "SKIP_SECURITY";
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Sécurité: Question passée car vous avez quitté l'écran.",
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );

    _nextQuestion();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _submitAnswer(String answer) {
    // If already answered, do not allow change?
    // User requirement: "s'il a propsé deja une reponse il ne pourra plus la modifié"
    if (_answers.containsKey(_currentQuestionIndex)) return;

    setState(() {
      _answers[_currentQuestionIndex] = answer;
    });

    // Auto-advance after short delay or wait for manual next?
    // User requirement: "faire defiler question par question"
    // Usually manual next is better UX, but let's stick to simple flow.
  }

  void _showCompletionDialog() {
    // Calculate final score
    num totalScore = 0;
    for (int i = 0; i < _shuffledQuestions.length; i++) {
      final question = _shuffledQuestions[i];
      final userAnswer = _answers[i];

      if (userAnswer != null) {
        // Find if this answer is correct in the options
        final correctOption = question.options.firstWhere(
          (o) => o.isCorrect,
          orElse: () => QCMOption(text: '', isCorrect: false),
        );

        if (correctOption.text == userAnswer) {
          totalScore += question.points;
        }
      }
    }

    Map<String, dynamic>? serverResponse;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("QCM Terminé"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (serverResponse == null) ...[
                const Text("Vous avez répondu à toutes les questions."),
                const SizedBox(height: 16),
                if (_isSubmitting) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text("Soumission en cours..."),
                ] else
                  const Text("Prêt à soumettre votre QCM."),
              ] else ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  serverResponse?['message'] ??
                      "Résolution soumise avec succès",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Extract score from the activities array in the response
                Builder(
                  builder: (context) {
                    try {
                      if (serverResponse?['data'] != null &&
                          serverResponse?['data']['activities'] != null) {
                        final activities =
                            serverResponse?['data']['activities'] as List;
                        // Find the activity that matches our activityId
                        final activity = activities.firstWhere(
                          (act) => act['_id'] == widget.activityId,
                          orElse: () => null,
                        );

                        if (activity != null &&
                            activity['resolutions'] != null &&
                            (activity['resolutions'] as List).isNotEmpty) {
                          final resolutions = activity['resolutions'] as List;
                          final lastResolution = resolutions.last;
                          final score = lastResolution['score'];

                          return Text(
                            "Votre score: $score",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      print("Error extracting score: $e");
                    }

                    return const Text(
                      "Score soumis avec succès",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          actions: [
            if (serverResponse == null)
              TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                child: const Text(
                  "Annuler",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (serverResponse == null)
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        setDialogState(() => _isSubmitting = true);
                        try {
                          final response = await widget.onSubmit(
                            totalScore.toDouble(),
                          );
                          if (mounted && response != null) {
                            setDialogState(() {
                              _isSubmitting = false;
                              serverResponse = response;
                            });
                          } else if (mounted) {
                            setDialogState(() => _isSubmitting = false);
                            _showError("Erreur: Aucune réponse du serveur");
                          }
                        } catch (e) {
                          if (mounted) {
                            setDialogState(() => _isSubmitting = false);
                            _showError("Erreur lors de la soumission: $e");
                          }
                        }
                      },
                child: const Text("Confirmer et Soumettre"),
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer la dialog
                  // Fermer toute la page activity et revenir à l'écran précédent
                  Navigator.of(context).pop();
                  // Appeler le callback pour fermer les cartes si fourni
                  widget.onClose?.call();
                },
                child: const Text("Fermer"),
              ),
          ],
        ),
      ),
    );
  }

  // Internal submit simplified to remove provider access, as onSubmit is now delegated
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledQuestions.isEmpty) {
      return const Center(child: Text("Aucune question dans ce QCM."));
    }

    final question = _shuffledQuestions[_currentQuestionIndex];
    final hasAnswered = _answers.containsKey(_currentQuestionIndex);

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _shuffledQuestions.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
              const SizedBox(height: 16),

              Text(
                "Question ${_currentQuestionIndex + 1}/${_shuffledQuestions.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Question Area (Sentence-based splitting for multi-line support)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _splitIntoLines(question.questionText).map((line) {
                    if (line.trim().isEmpty) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(
                          line,
                          textStyle: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                          mathStyle: MathStyle.text,
                          onErrorFallback: (err) => Text(
                            line,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Options
              ...question.options.map((option) {
                final isSelected =
                    _answers[_currentQuestionIndex] == option.text;
                Color tileColor = Colors.white;
                if (isSelected) {
                  tileColor = Colors.indigo.withOpacity(0.1);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    onTap: hasAnswered
                        ? null
                        : () => _submitAnswer(option.text),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tileColor,
                        border: Border.all(
                          color: isSelected ? Colors.indigo : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected ? Colors.indigo : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Math.tex(
                                option.text,
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                mathStyle: MathStyle.text,
                                onErrorFallback: (err) => Text(
                                  option.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              if (hasAnswered)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestionIndex < _shuffledQuestions.length - 1
                        ? "Question Suivante"
                        : "Terminer",
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _splitIntoLines(String text) {
    // Improved splitting: looks for dot, exclamation or question mark followed by space
    // or newline characters.
    final lines = text.split(RegExp(r'(?<=[.!?])\s+|\n+'));
    return lines.where((l) => l.trim().isNotEmpty).toList();
  }
}
