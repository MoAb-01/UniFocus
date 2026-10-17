import '../../../core/models/study_room.dart';

/// Question banks for UniFocus synchronized multiplayer mini-games.
/// Extensible repository supplying 3 rounds per challenge type.
class MiniGameQuestions {
  static List<MiniGameQuestion> getQuestionsForGame(MiniGameType type) {
    switch (type) {
      case MiniGameType.quickQuiz:
        return const [
          MiniGameQuestion(
            prompt: 'Which planet in our solar system is known as the Red Planet?',
            options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
            correctIndex: 1,
            explanation: 'Mars has a reddish appearance due to iron oxide on its surface.',
          ),
          MiniGameQuestion(
            prompt: 'How many interlocking rings are on the official Olympic flag?',
            options: ['4', '5', '6', '7'],
            correctIndex: 1,
            explanation: 'The five rings represent the inhabited continents of the world.',
          ),
          MiniGameQuestion(
            prompt: 'What is the capital city of Australia?',
            options: ['Sydney', 'Melbourne', 'Canberra', 'Brisbane'],
            correctIndex: 2,
            explanation: 'Canberra was designated as the capital in 1908.',
          ),
        ];

      case MiniGameType.fastMath:
        return const [
          MiniGameQuestion(
            prompt: 'Speed Math: 17 + 28 = ?',
            options: ['43', '45', '47', '49'],
            correctIndex: 1,
            explanation: '17 + 28 = 45.',
          ),
          MiniGameQuestion(
            prompt: 'Speed Math: 120 ÷ 4 - 8 = ?',
            options: ['22', '24', '26', '28'],
            correctIndex: 0,
            explanation: '120 ÷ 4 = 30, and 30 - 8 = 22.',
          ),
          MiniGameQuestion(
            prompt: 'Speed Math: 8 × 9 + 15 = ?',
            options: ['85', '87', '89', '91'],
            correctIndex: 1,
            explanation: '8 × 9 = 72, and 72 + 15 = 87.',
          ),
        ];

      case MiniGameType.wordChallenge:
        return const [
          MiniGameQuestion(
            prompt: 'Unscramble this popular fruit: A P L E P',
            options: ['APPLE', 'PEARL', 'PLANE', 'PLEAT'],
            correctIndex: 0,
            explanation: 'A P L E P unscrambles to APPLE.',
          ),
          MiniGameQuestion(
            prompt: 'Which word is the opposite of "Ancient"?',
            options: ['Antique', 'Modern', 'Historic', 'Primeval'],
            correctIndex: 1,
            explanation: 'Modern refers to present or recent times.',
          ),
          MiniGameQuestion(
            prompt: 'Unscramble this ocean mammal: H I P N O L D',
            options: ['DOLPHIN', 'LEOPARD', 'PANTHER', 'CHEETAH'],
            correctIndex: 0,
            explanation: 'H I P N O L D unscrambles to DOLPHIN.',
          ),
        ];

      case MiniGameType.memoryMatch:
        return const [
          MiniGameQuestion(
            prompt: 'Remember: [Blue, Red, Yellow, Green]. Which was in the 3rd spot?',
            options: ['Red', 'Blue', 'Yellow', 'Green'],
            correctIndex: 2,
            explanation: 'Yellow occupied the 3rd position.',
          ),
          MiniGameQuestion(
            prompt: 'Remember digits: 7 · 4 · 2 · 9. Which was the second digit?',
            options: ['7', '4', '2', '9'],
            correctIndex: 1,
            explanation: '4 was the second digit in the sequence.',
          ),
          MiniGameQuestion(
            prompt: 'Remember: [Triangle, Circle, Star, Square]. Which was last?',
            options: ['Triangle', 'Star', 'Circle', 'Square'],
            correctIndex: 3,
            explanation: 'Square was the 4th and final shape.',
          ),
        ];
    }
  }
}
