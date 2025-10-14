import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'REMOVED_SECRET';
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-flash-lite-latest',
      apiKey: _apiKey,
    );
  }

  /// Generate description for events based on title and basic information
  Future<String> generateEventDescription({
    required String title,
    String? category,
    String? location,
    DateTime? date,
    String? additionalInfo,
  }) async {
    try {
      final prompt = _buildEventPrompt(
        title: title,
        category: category,
        location: location,
        date: date,
        additionalInfo: additionalInfo,
      );

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ??
          'Unable to generate description. Please try again.';
    } catch (e) {
      return 'Error generating description: ${e.toString()}';
    }
  }

  /// Generate description for announcements based on title and basic information
  Future<String> generateAnnouncementDescription({
    required String title,
    String? category,
    String? additionalInfo,
  }) async {
    try {
      final prompt = _buildAnnouncementPrompt(
        title: title,
        category: category,
        additionalInfo: additionalInfo,
      );

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ??
          'Unable to generate description. Please try again.';
    } catch (e) {
      return 'Error generating description: ${e.toString()}';
    }
  }

  String _buildEventPrompt({
    required String title,
    String? category,
    String? location,
    DateTime? date,
    String? additionalInfo,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
        'Generate a professional and engaging description for a mosque/Islamic organization event with the following details:');
    buffer.writeln('');
    buffer.writeln('Title: $title');

    if (category != null && category.isNotEmpty) {
      buffer.writeln('Category: $category');
    }

    if (location != null && location.isNotEmpty) {
      buffer.writeln('Location: $location');
    }

    if (date != null) {
      buffer.writeln('Date: ${date.toString().split(' ')[0]}');
    }

    if (additionalInfo != null && additionalInfo.isNotEmpty) {
      buffer.writeln('Additional Information: $additionalInfo');
    }

    buffer.writeln('');
    buffer.writeln('Please create a description that:');
    buffer.writeln('- Is appropriate for a mosque/Islamic community context');
    buffer.writeln('- Encourages participation and community engagement');
    buffer.writeln('- Is informative and welcoming');
    buffer.writeln('- Uses respectful and inclusive language');
    buffer.writeln('- Is between 100-200 words');
    buffer.writeln(
        '- Includes relevant Islamic greetings or phrases where appropriate');

    return buffer.toString();
  }

  String _buildAnnouncementPrompt({
    required String title,
    String? category,
    String? additionalInfo,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
        'Generate a professional and clear description for a mosque/Islamic organization announcement with the following details:');
    buffer.writeln('');
    buffer.writeln('Title: $title');

    if (category != null && category.isNotEmpty) {
      buffer.writeln('Category: $category');
    }

    if (additionalInfo != null && additionalInfo.isNotEmpty) {
      buffer.writeln('Additional Information: $additionalInfo');
    }

    buffer.writeln('');
    buffer.writeln('Please create a description that:');
    buffer.writeln('- Is appropriate for a mosque/Islamic community context');
    buffer.writeln('- Is clear and informative');
    buffer.writeln('- Uses respectful and professional language');
    buffer.writeln('- Is concise but comprehensive (50-150 words)');
    buffer.writeln(
        '- Includes relevant Islamic greetings or phrases where appropriate');
    buffer.writeln('- Provides clear call-to-action if needed');

    return buffer.toString();
  }
}
