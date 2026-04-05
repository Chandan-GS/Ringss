import 'dart:convert'; // Import for json.decode
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
// --- ADD GEMINI IMPORT ---
import 'package:google_generative_ai/google_generative_ai.dart';
// -------------------------
import 'package:project_a_b/controllers/source_controller.dart'; // To get pet name
import 'package:project_a_b/data/models/signal_comment_model.dart';
import 'package:project_a_b/data/models/signal_model.dart'; // Import SignalModel
import 'package:project_a_b/widgets/custom/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsController extends GetxController {
  // --- MODIFIED: Added signal ---
  final String signalId;
  final SignalModel signal;
  CommentsController({required this.signalId, required this.signal});

  final supabase = Supabase.instance.client;
  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;
  // --- ADDED: Find SourceController ---
  final SourceController sourceController = Get.find<SourceController>();

  // --- UI State ---
  var isLoading = true.obs;
  var selectedType = 'harmonize'.obs;
  final textController = TextEditingController();

  /// Holds only the TOP-LEVEL (depth 0) comments
  var comments = <SignalCommentModel>[].obs;

  /// Holds the comment we are currently replying to
  var replyingTo = Rx<SignalCommentModel?>(null);
  var selectedGifUrl = Rx<String?>(null);
  final String giphyApiKey = "jF8k7JHVblZ2RcgxzTCsmJX7Psuex1CF";

  // --- NEW: AI State ---
  var isAiLoading = true.obs;
  var isAiError = false.obs;
  var aiSuggestionCategory = ''.obs;
  var aiSuggestions = <String>[].obs;
  late final GenerativeModel _geminiModel;
  // --------------------

  @override
  void onInit() {
    super.onInit();
    // --- NEW: Initialize Gemini Model ---
    final geminiApiKey = "AIzaSyD6UURm5ES7zCXv1YawX0nuaOPS49fWz7E";
    _geminiModel = GenerativeModel(
      // --- THIS IS THE FIX ---
      // Use the "latest" alias for the model
      model: 'gemini-2.0-flash',
      // -----------------------
      apiKey: geminiApiKey,
    );

    fetchComments();
    fetchAiSuggestions(); // <-- Call new function
  }

  /// Changes the comment type (tab) and re-fetches
  void changeType(String newType) {
    selectedType.value = newType;
    fetchComments();
  }

  /// Sets or clears the comment we are replying to
  void setReplyingTo(SignalCommentModel? comment) {
    replyingTo.value = comment;
  }

  /// Fetches all comments and builds the 3-level tree
  Future<void> fetchComments() async {
    try {
      isLoading(true);
      replyingTo.value = null; // Clear reply state on refresh
      textController.clear();

      // Fetch all comments for this signal AND type
      final data = await supabase
          .from('signal_comments')
          .select('*, profiles(*), signal_comment_likes(user_id)')
          .eq('signal_id', signalId)
          .eq('comment_type', selectedType.value)
          .order('like_count', ascending: false);

      final allComments = data
          .map((map) => SignalCommentModel.fromMap(map, currentUserId))
          .toList();

      // --- Build the 3-level tree ---
      final Map<String?, List<SignalCommentModel>> commentsByParentId = {};
      for (var comment in allComments) {
        commentsByParentId
            .putIfAbsent(comment.parentCommentId, () => [])
            .add(comment);
      }

      // 1. Get top-level comments (depth 0)
      final topLevelComments = commentsByParentId[null] ?? [];

      // 2. Get replies (depth 1)
      for (var comment in topLevelComments) {
        comment.replies.value = commentsByParentId[comment.id] ?? [];

        // 3. Get replies of replies (depth 2)
        for (var reply in comment.replies) {
          reply.replies.value = commentsByParentId[reply.id] ?? [];
        }
      }

      comments.assignAll(topLevelComments);
    } catch (e) {
      Get.snackbar("Error", "Could not load comments: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  // --- NEW: Fetch AI Suggestions ---
  Future<void> fetchAiSuggestions() async {
    try {
      isAiLoading(true);
      isAiError(false); // Reset error

      final prompt =
          """
      Analyze the following social media post:
      Title: "${signal.title ?? "No Title"}"
      Content: "${signal.content}"

      Your task is to respond ONLY in JSON format.
      First, decide if the single most appropriate response category to this post is 'harmonize' (agree/support), 'clarify' (ask a question), or 'counter' (disagree/challenge).
      Second, based *only* on that single category, generate 3 brief, insightful comment suggestions (less than 15 words each).

      Return your response as a JSON object with this exact structure:
      {
        "category": "YourChosenCategory",
        "suggestions": [
          "Suggestion 1",
          "Suggestion 2",
          "Suggestion 3"
        ]
      }
      """;

      final content = [Content.text(prompt)];
      final response = await _geminiModel.generateContent(content);

      if (response.text == null) {
        throw Exception("AI returned no response.");
      }

      final cleanJson = response.text!
          .replaceAll("```json", "")
          .replaceAll("```", "")
          .trim();

      final decoded = json.decode(cleanJson);

      final category = decoded['category'] as String;
      final suggestions = (decoded['suggestions'] as List).cast<String>();

      aiSuggestionCategory.value = category.toLowerCase();
      aiSuggestions.value = suggestions;
    } catch (e) {
      print("AI Error: $e");
      isAiError(true);
    } finally {
      isAiLoading(false);
    }
  }
  // ---------------------------------

  Future<void> postComment() async {
    final content = textController.text.trim();
    if (content.isEmpty && selectedGifUrl.value == null) return;

    try {
      await supabase.from('signal_comments').insert({
        'signal_id': signalId,
        'owner_id': currentUserId,
        'parent_comment_id': replyingTo.value?.id,
        'comment_type': selectedType.value,
        'content': content.isEmpty ? null : content,
        'media_url': selectedGifUrl.value,
        'is_from_pet': false, // <-- ADDED
      });

      textController.clear();
      replyingTo.value = null;
      selectedGifUrl.value = null;

      fetchComments(); // Re-fetch to show the new comment
    } catch (e) {
      Get.snackbar("Error", "Could not post comment: ${e.toString()}");
    }
  }

  // --- NEW: Post AI Suggestion ---
  Future<void> postAiSuggestion(String suggestion) async {
    try {
      await supabase.from('signal_comments').insert({
        'signal_id': signalId,
        'owner_id': currentUserId,
        'parent_comment_id': null, // AI suggestions are always top-level
        'comment_type': aiSuggestionCategory.value, // Use the AI's category
        'content': suggestion,
        'media_url': null,
        'is_from_pet': true, // <-- SET TO TRUE
      });

      // Clear other inputs
      textController.clear();
      replyingTo.value = null;
      selectedGifUrl.value = null;

      // Re-fetch comments to show the new one
      // and fetch new suggestions
      fetchComments();
      fetchAiSuggestions();
    } catch (e) {
      Get.snackbar("Error", "Could not post AI comment: ${e.toString()}");
    }
  }
  // ---------------------------------

  /// --- UPDATED: GIPHY Picker Function ---
  Future<void> pickGif(BuildContext context) async {
    final theme = Theme.of(context); // Get the theme

    GiphyGif? gif = await GiphyGet.getGif(
      context: context,
      apiKey: giphyApiKey,
      lang: GiphyLanguage.english,

      // Your simple theme options
      tabColor: const Color.fromARGB(255, 255, 30, 30),
      textSelectedColor: const Color.fromARGB(255, 255, 30, 30),
      textUnselectedColor: theme.textTheme.bodyMedium?.color,

      // Your display options
      showGIFs: true,
      showStickers: true,
      showEmojis: true, // Make sure this is true
      modal: false,
      useRootNavigator: false,

      // --- YOUR CUSTOM APP BAR BUILDER ---
      searchAppBarBuilder:
          (context, focusNode, autofocus, textController, onClearSearch) {
            final theme = Theme.of(context);
            return CustomTextField(
              // Your custom widget
              child: TextField(
                cursorColor: theme.textTheme.bodyMedium?.color,
                controller: textController,
                focusNode: focusNode,
                autofocus: autofocus,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Search GIPHY",
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  // Your custom icon
                  suffixIcon: IconButton(
                    icon: SvgPicture.asset(
                      "lib/assets/icons/cancel_button.svg",
                      colorFilter: ColorFilter.mode(
                        theme.textTheme.bodyMedium?.color ?? Colors.black,
                        BlendMode.srcIn,
                      ),
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                    onPressed: () => onClearSearch(),
                  ),
                ),
              ),
            );
          },
      // ------------------------------------
    );

    if (gif != null) {
      selectedGifUrl.value = gif.images?.fixedHeightDownsampled?.url;
    }
  }

  /// Clears the selected GIF
  void clearGif() {
    selectedGifUrl.value = null;
  }

  /// Toggles a like on a comment
  Future<void> toggleLike(SignalCommentModel comment) async {
    try {
      final int likesChange = await supabase.rpc(
        'toggle_comment_like',
        params: {'comment_id_in': comment.id, 'user_id_in': currentUserId},
      );

      comment.likeCount.value += likesChange;
      comment.iHaveLiked.value = likesChange > 0;
    } catch (e) {
      Get.snackbar("Error", "Could not like comment: ${e.toString()}");
    }
  }
}
