import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/experience.dart';
import '../models/booking.dart';
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

  // Fallback messages to ensure we never return empty responses
  static const String _fallbackMessage =
      'I apologize, but I couldn\'t generate a proper response. Please try rephrasing your question or ask me about specific experiences in Colombia.';
  static const String _fallbackMessageSpanish =
      'Lo siento, no pude generar una respuesta adecuada. Por favor, intenta reformular tu pregunta o pregúntame sobre experiencias específicas en Colombia.';

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

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Connection timeout - Please check your internet connection');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate API response structure
        if (data == null ||
            data['choices'] == null ||
            data['choices'].isEmpty ||
            data['choices'][0]['message'] == null ||
            data['choices'][0]['message']['content'] == null) {
          debugPrint('Invalid API response structure');
          return ChatbotResponse(
            text: _getFallbackMessage(userMessage),
            recommendations: [],
          );
        }

        final aiResponse = data['choices'][0]['message']['content'] as String;

        // Validate that AI response is not empty
        if (aiResponse.trim().isEmpty) {
          debugPrint('AI returned empty response');
          return ChatbotResponse(
            text: _getFallbackMessage(userMessage),
            recommendations: [],
          );
        }

        // Parse the response to extract experience IDs and recommendations
        return _parseResponse(aiResponse, experiences, userMessage);
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return ChatbotResponse(
          text:
              'Sorry, I encountered an error. Please try again. (Error ${response.statusCode})',
          recommendations: [],
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('Network Error: $e');
      debugPrint('This usually means:');
      debugPrint('1. No internet connection');
      debugPrint('2. API endpoint is blocked or unreachable');
      debugPrint('3. SSL/Certificate issues');
      return ChatbotResponse(
        text:
            'Unable to connect to the server. Please check your internet connection and try again.',
        recommendations: [],
      );
    } catch (e, stackTrace) {
      debugPrint('Error in chatbot service: $e');
      debugPrint('Stack trace: $stackTrace');
      return ChatbotResponse(
        text:
            'Sorry, I encountered an error processing your request. Please try again.',
        recommendations: [],
      );
    }
  }

  /// Parse AI response to extract experience recommendations
  ChatbotResponse _parseResponse(
      String aiResponse, List<Experience> allExperiences, String userMessage) {
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

    // FAILSAFE: Ensure we never return an empty text response
    if (cleanedText.isEmpty) {
      debugPrint(
          'Warning: Cleaned text is empty after parsing. Using fallback.');
      cleanedText = _getFallbackMessage(userMessage);
    }

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

  /// Get appropriate fallback message based on detected language
  String _getFallbackMessage(String userMessage) {
    // Simple language detection: check for common Spanish words
    final spanishIndicators = [
      'hola',
      'qué',
      'cómo',
      'dónde',
      'cuánto',
      'por favor',
      'gracias',
      'experiencia',
      'precio',
      'busco',
      'quiero',
      'me gustaría',
      'necesito',
      'ayuda',
      'puedes'
    ];

    final lowerMessage = userMessage.toLowerCase();
    final isSpanish =
        spanishIndicators.any((word) => lowerMessage.contains(word));

    return isSpanish ? _fallbackMessageSpanish : _fallbackMessage;
  }

  /// Build the context string with all available experiences (includes ALL attributes)
  String _buildExperiencesContext(List<Experience> experiences) {
    final buffer = StringBuffer();
    buffer.writeln('Available Experiences:');
    buffer.writeln();

    for (var exp in experiences) {
      buffer.writeln('Experience ID: ${exp.id}');
      buffer.writeln('Title: ${exp.title}');
      buffer.writeln('Summary: ${exp.summary}');
      buffer.writeln('Host ID: ${exp.hostId}');
      buffer.writeln('Host Verified: ${exp.hostVerified}');
      buffer.writeln('Location: (${exp.location.latitude}, ${exp.location.longitude})');
      buffer.writeln('Department: ${exp.department}');
      buffer.writeln('Rating: ${exp.avgRating} (${exp.reviewsCount} reviews)');
      buffer.writeln('Duration: ${exp.duration} hours');
      buffer.writeln('Skills to Learn: ${exp.skillsToLearn.join(", ")}');
      buffer.writeln('Skills to Teach: ${exp.skillsToTeach.join(", ")}');
      buffer.writeln('Categories: ${exp.categories.join(", ")}');
      buffer.writeln('Languages: ${exp.languages.join(", ")}');
      buffer.writeln('Created At: ${exp.createdAt.toIso8601String()}');
      buffer.writeln('Price: \$${exp.priceCOP} COP');
      buffer.writeln('Group Size (max): ${exp.groupSizeMax}');
      buffer.writeln('Payment Options: ${exp.paymentOptions.join(", ")}');
      buffer.writeln('Accessibility Features: ${exp.accessibilityFeatures.join(", ")}');
      buffer.writeln('Active: ${exp.isActive}');
      buffer.writeln('---');
    }

    return buffer.toString();
  }

  /// Build context string for user's previous bookings with their experience details
  Future<String> _buildBookingsContext(List<Booking> bookings) async {
    if (bookings.isEmpty) {
      debugPrint('No bookings found for user');
      return '\n\nUser\'s Previous Bookings: None found. Please recommend popular experiences instead.';
    }

    final buffer = StringBuffer();
    buffer.writeln('\n\nUser\'s Previous Bookings (showing experiences they have enjoyed):');
    buffer.writeln();

    int successfulBookings = 0;
    for (var booking in bookings) {
      try {
        final experience = await _experienceService.getExperienceById(booking.experienceId);
        if (experience != null) {
          successfulBookings++;
          buffer.writeln('Previously Booked Experience:');
          buffer.writeln('  Experience ID: ${experience.id}');
          buffer.writeln('  Title: ${experience.title}');
          buffer.writeln('  Categories: ${experience.categories.join(", ")}');
          buffer.writeln('  Department: ${experience.department}');
          buffer.writeln('  Skills Learned: ${experience.skillsToLearn.join(", ")}');
          buffer.writeln('  Languages: ${experience.languages.join(", ")}');
          buffer.writeln('  Duration: ${experience.duration} hours');
          buffer.writeln('  Price Paid: \$${booking.amountCOP} COP');
          buffer.writeln('  People Count: ${booking.peopleCount}');
          buffer.writeln('  Booking Status: ${booking.status}');
          buffer.writeln('---');
        }
      } catch (e) {
        debugPrint('Error fetching experience for booking: $e');
      }
    }

    if (successfulBookings == 0) {
      return '\n\nUser\'s Previous Bookings: Could not load booking details. Please recommend popular experiences instead.';
    }

    debugPrint('Built context for $successfulBookings bookings');

    return buffer.toString();
  }

  /// Send a personalized recommendation message based on user's booking history
  Future<ChatbotResponse> sendPersonalizedRecommendation(
      List<Booking> userBookings,
      List<Map<String, String>> conversationHistory) async {
    try {
      debugPrint('Starting personalized recommendation with ${userBookings.length} bookings');
      
      // Fetch all available experiences
      final experiences = await _experienceService.getExperiences();
      debugPrint('Fetched ${experiences.length} experiences');

      // Create context with all experiences
      final experiencesContext = _buildExperiencesContext(experiences);

      // Build bookings context
      final bookingsContext = await _buildBookingsContext(userBookings);
      debugPrint('Bookings context length: ${bookingsContext.length} chars');

      // Create the personalized recommendation message
      const userMessage = 'Based on my previous bookings, what experience would you recommend for me? I\'m looking for something similar to what I\'ve enjoyed before.';

      // Build messages with booking context included in system message
      final messages = _buildMessagesWithBookings(
          userMessage, experiencesContext, bookingsContext, conversationHistory);

      // Build request body with higher token limit for complex responses
      final requestBody = jsonEncode({
        'model': 'openai/gpt-oss-120b',
        'messages': messages,
        'temperature': 0.7,
        'top_p': 1,
        'max_tokens': 2048,
        'stream': false,
      });

      debugPrint('Sending personalized recommendation request...');

      // Make API call to NVIDIA
      final request = http.Request('POST', Uri.parse(_apiUrl));
      request.headers['accept'] = 'application/json';
      request.headers['content-type'] = 'application/json';
      request.headers['authorization'] = 'Bearer $_apiKey';
      request.body = requestBody;

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw Exception(
              'Connection timeout - Please check your internet connection');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null ||
            data['choices'] == null ||
            data['choices'].isEmpty ||
            data['choices'][0]['message'] == null ||
            data['choices'][0]['message']['content'] == null) {
          debugPrint('Invalid API response structure: $data');
          return ChatbotResponse(
            text: 'I\'d love to give you personalized recommendations! Based on your bookings, I suggest exploring experiences in similar categories. What type of experience interests you most - cultural, outdoor, or culinary?',
            recommendations: [],
          );
        }

        final aiResponse = data['choices'][0]['message']['content'] as String;
        debugPrint('AI Response length: ${aiResponse.length} chars');

        if (aiResponse.trim().isEmpty) {
          debugPrint('AI returned empty response');
          return ChatbotResponse(
            text: 'Based on your booking history, I can help you find similar experiences! What aspects did you enjoy most - the location, the activities, or the cultural exchange?',
            recommendations: [],
          );
        }

        return _parseResponse(aiResponse, experiences, userMessage);
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return ChatbotResponse(
          text:
              'Sorry, I encountered an error getting personalized recommendations. Please try again or ask me about specific types of experiences you\'re interested in.',
          recommendations: [],
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in personalized recommendation: $e');
      debugPrint('Stack trace: $stackTrace');
      return ChatbotResponse(
        text:
            'I had trouble loading your personalized recommendations. You can try asking me about specific types of experiences like "outdoor adventures" or "cultural workshops".',
        recommendations: [],
      );
    }
  }

  /// Build messages array with booking history context for personalized recommendations
  List<Map<String, String>> _buildMessagesWithBookings(
    String userMessage,
    String experiencesContext,
    String bookingsContext,
    List<Map<String, String>> conversationHistory,
  ) {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            '''You are TravelConnect's personalized recommendation assistant. Analyze the user's booking history and suggest NEW experiences they would enjoy.

INSTRUCTIONS:
1. Look at their previous bookings to understand preferences (categories, location, price range, skills)
2. Recommend 2-3 DIFFERENT experiences (not ones they already booked)
3. Explain why each matches their interests based on booking history
4. Respond in the same language as the user

$bookingsContext

Available Experiences:
$experiencesContext

FORMAT each recommendation EXACTLY like this:
Experience ID: [actual_id]
Title: [title]
[2-3 sentences explaining why this matches their booking history]

Only recommend active experiences (Active: true). Be friendly and personal.'''
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
