import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/experience.dart';
import 'experience_service.dart';

/// Response model for chatbot interactions
class ChatbotResponse {
  final String text;
  final List<ExperienceRecommendation> recommendations;

  ChatbotResponse({
    required this.text,
    required this.recommendations,
  });
}

/// Model for experience recommendations with explanations
class ExperienceRecommendation {
  final Experience experience;
  final String explanation;

  ExperienceRecommendation({
    required this.experience,
    required this.explanation,
  });
}

class ChatbotService {
  static const String _apiKey =
      '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';
  static const String _apiUrl =
      'https://integrate.api.nvidia.com/v1/chat/completions';

  final ExperienceService _experienceService = ExperienceService();

  /// Send a message to the chatbot and get a suggestion based on available experiences
  Future<ChatbotResponse> sendMessage(
      String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      // Fetch all available experiences
      final experiences = await _experienceService.getExperiences();

      // Create a context string with all experiences
      final experiencesContext = _buildExperiencesContext(experiences);

      // Build the conversation with system context
      final messages =
          _buildMessages(userMessage, experiencesContext, conversationHistory);

      // Build request body
      final requestBody = jsonEncode({
        'model': 'openai/gpt-oss-120b',
        'messages': messages,
        'temperature': 0.5,
        'top_p': 1,
        'max_tokens': 1024,
        'stream': false,
      });

      // Make API call to NVIDIA - using Request to control content-type precisely
      final request = http.Request('POST', Uri.parse(_apiUrl));
      request.headers['accept'] = 'application/json';
      request.headers['content-type'] = 'application/json';
      request.headers['authorization'] = 'Bearer $_apiKey';
      request.body = requestBody;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];

        // Parse the response to extract experience IDs and recommendations
        return _parseResponse(aiResponse, experiences);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return ChatbotResponse(
          text: 'Sorry, I encountered an error. Please try again.',
          recommendations: [],
        );
      }
    } catch (e) {
      print('Error in chatbot service: $e');
      return ChatbotResponse(
        text:
            'Sorry, I encountered an error processing your request. Please try again.',
        recommendations: [],
      );
    }
  }

  /// Parse AI response to extract experience recommendations
  ChatbotResponse _parseResponse(
      String aiResponse, List<Experience> allExperiences) {
    final recommendations = <ExperienceRecommendation>[];

    // Create a map for quick experience lookup by ID
    final experienceMap = {for (var exp in allExperiences) exp.id: exp};

    // Try to find experience IDs in the response
    final idPattern =
        RegExp(r'Experience ID[:\s]+([a-zA-Z0-9_-]+)', caseSensitive: false);
    final matches = idPattern.allMatches(aiResponse);

    for (var match in matches) {
      final expId = match.group(1);
      if (expId != null && experienceMap.containsKey(expId)) {
        // Find the explanation for this experience
        final explanation = _extractExplanation(aiResponse, expId);
        recommendations.add(ExperienceRecommendation(
          experience: experienceMap[expId]!,
          explanation: explanation,
        ));
      }
    }

    // Remove Experience IDs and Titles from the text shown to user
    String cleanedText = aiResponse;
    cleanedText = cleanedText.replaceAll(
        RegExp(r'Experience ID[:\s]+[a-zA-Z0-9_-]+\s*', caseSensitive: false),
        '');
    cleanedText = cleanedText.replaceAll(
        RegExp(r'^Title[:\s]+.*$', multiLine: true, caseSensitive: false), '');
    cleanedText = cleanedText.replaceAll(
        RegExp(r'\n{3,}'), '\n\n'); // Remove excessive newlines
    cleanedText = cleanedText.trim();

    return ChatbotResponse(
      text: cleanedText,
      recommendations: recommendations,
    );
  }

  /// Extract explanation for a specific experience from the AI response
  String _extractExplanation(String response, String experienceId) {
    final lines = response.split('\n');
    final buffer = StringBuffer();
    bool capturing = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Start capturing after finding the experience ID
      if (line.contains(experienceId)) {
        capturing = true;
        continue;
      }

      // Stop capturing when we hit another Experience ID or empty line after content
      if (capturing) {
        if (line.trim().isEmpty && buffer.isNotEmpty) {
          break;
        }
        if (RegExp(r'Experience ID[:\s]+', caseSensitive: false)
            .hasMatch(line)) {
          break;
        }

        // Add the line to explanation
        if (line.trim().isNotEmpty &&
            !line.toLowerCase().contains('experience id') &&
            !line.toLowerCase().startsWith('title:')) {
          buffer.writeln(line.trim());
        }
      }
    }

    final explanation = buffer.toString().trim();
    return explanation.isNotEmpty
        ? explanation
        : 'This experience matches your preferences.';
  }

  /// Build the context string with all available experiences
  String _buildExperiencesContext(List<Experience> experiences) {
    final buffer = StringBuffer();
    buffer.writeln('Available Experiences:');
    buffer.writeln();

    for (var exp in experiences) {
      buffer.writeln('Experience ID: ${exp.id}');
      buffer.writeln('Title: ${exp.title}');
      buffer.writeln('Summary: ${exp.summary}');
      buffer.writeln('Department: ${exp.department}');
      buffer.writeln('Categories: ${exp.categories.join(", ")}');
      buffer.writeln('Languages: ${exp.languages.join(", ")}');
      buffer.writeln('Skills to Learn: ${exp.skillsToLearn.join(", ")}');
      buffer.writeln('Skills to Teach: ${exp.skillsToTeach.join(", ")}');
      buffer.writeln('Duration: ${exp.duration} hours');
      buffer.writeln('Price: \$${exp.priceCOP} COP');
      buffer.writeln('Group Size (max): ${exp.groupSizeMax}');
      buffer.writeln('Rating: ${exp.avgRating} (${exp.reviewsCount} reviews)');
      buffer.writeln('Active: ${exp.isActive}');
      buffer.writeln('---');
    }

    return buffer.toString();
  }

  /// Build the messages array for the API call
  List<Map<String, String>> _buildMessages(
    String userMessage,
    String experiencesContext,
    List<Map<String, String>> conversationHistory,
  ) {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            '''You are the TravelConnect assistant. Your ONLY domain is helping users discover, compare, and choose cultural experiences in Colombia that are available in our database.

Strict policy:
- Only talk about experiences, user trip preferences, and the app’s objective (helping users find experiences).
- Do NOT answer unrelated questions (e.g., history, politics, coding, news, math, general knowledge).
- Do NOT discuss how you, the app, or the chatbot are built/configured, models used, or any internal details. Politely refuse and steer back to experiences.
- IMPORTANT: Always respond in the SAME LANGUAGE the user writes in.

Here are the available experiences:

$experiencesContext

When suggesting experiences, you MUST follow this EXACT format for each recommendation:

Experience ID: [the actual ID]
Title: [the title]
[Your explanation of why this experience is a good match - 2-3 sentences]

Example format:
Experience ID: abc123
Title: Salsa Dancing in Cali
This experience is perfect for you because it offers authentic salsa lessons in the salsa capital of the world. You'll learn from professional dancers and experience the vibrant nightlife of Cali. The price fits your budget and it has excellent reviews.

Rules:
- Recommend 1-3 experiences that best match the user's interests, budget, location, or other preferences
- ALWAYS include "Experience ID:" followed by the actual ID on its own line
- ALWAYS include "Title:" followed by the actual title on the next line
- Follow with a clear explanation (2-3 sentences) of why it's a good match
- Be conversational and friendly in the user's language
- Only suggest experiences that are marked as active (Active: true)
- Mention key details like price, duration, rating, and what makes each experience unique
- If the user asks about something specific (price, location, duration, skills, etc.), prioritize those criteria
- If the user's request is OUTSIDE SCOPE or about internal/system details, respond with a brief refusal and re-focus on experiences. Use one of these templates based on language:
  - English: "Sorry, I can only help with TravelConnect experiences in Colombia. What kind of experience are you looking for (location, budget, duration, interests)?"
  - Spanish: "Lo siento, solo puedo ayudarte con experiencias de TravelConnect en Colombia. ¿Qué tipo de experiencia buscas (ubicación, presupuesto, duración, intereses)?"

If no experiences match the user's criteria, politely explain that in their language and suggest the closest alternatives.'''
      },
    ];

    // Add conversation history
    messages.addAll(conversationHistory);

    // Add current user message
    messages.add({
      'role': 'user',
      'content': userMessage,
    });

    return messages;
  }
}
