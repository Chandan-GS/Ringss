import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/controllers/comments_controller.dart';
import 'package:project_a_b/data/models/signal_comment_model.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart'; // Import CustomBgCard
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_profile_icon.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({super.key, required this.comment, required this.depth});

  final SignalCommentModel comment;
  final int depth; // 0, 1, or 2

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _isExpanded = false;
  final CommentsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double indentation = widget.depth * 20.0;

    // --- NEW: Check if this is a comment from the current user's pet ---
    final bool isMyPet =
        widget.comment.isFromPet &&
        widget.comment.ownerId == controller.currentUserId;

    // Get the pet name from the SourceController
    final String petName =
        controller.sourceController.currentUserProfile.value?.petType ??
        "My Pet";

    // Use pet name or author's username
    final String displayName = isMyPet
        ? petName
        : widget.comment.author.username;

    // Use pet icon or author's icon
    final String? displayIconUrl = isMyPet
        ? null
        : widget.comment.author.profilePicUrl;
    final String displayIconAsset = isMyPet
        ? "lib/assets/icons/pet_paw.svg" // <-- Assumed Pet Icon
        : "lib/assets/icons/profile.svg";
    final String displayId = isMyPet
        ? "pet_${widget.comment.id}"
        : widget.comment.author.id;
    // -----------------------------------------------------------------

    return Dismissible(
      key: Key(widget.comment.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        child: SvgPicture.asset(
          width: 25,
          "lib/assets/icons/reply.svg",
          colorFilter: ColorFilter.mode(
            theme.textTheme.bodyMedium?.color ?? Colors.black,
            BlendMode.srcIn,
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        controller.setReplyingTo(widget.comment);
        return false;
      },
      onDismissed: (_) {},
      child: Padding(
        padding: EdgeInsets.only(left: indentation, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dotted line for replies
                Expanded(
                  child: Stack(
                    children: [
                      // Shadow
                      Positioned.fill(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Content Card
                      Container(
                        margin: const EdgeInsets.only(left: 4, bottom: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Card Header ---
                            Container(
                              decoration: BoxDecoration(
                                // Your UI: color: theme.cardColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // --- DYNAMIC ICON ---
                                  Transform.scale(
                                    scale: 0.7,
                                    child: CustomProfileIcon(
                                      onTapped: () {},
                                      imageUrl: displayIconUrl,
                                      iconAsset: displayIconAsset,
                                      userId: displayId,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    displayName, // <-- DYNAMIC NAME
                                    style: GoogleFonts.pixelifySans(
                                      fontWeight: FontWeight.normal,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  const Spacer(),
                                  // "View Replies" Button
                                  if ((widget.depth == 0) &&
                                      widget.comment.replies.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isExpanded = !_isExpanded;
                                        });
                                      },
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            top: 2.5,
                                            right: 2.5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 2.5,
                                              left: 2.5,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  theme.scaffoldBackgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: Row(
                                              children: [
                                                Obx(() {
                                                  int totalReplies = 0;
                                                  totalReplies += widget
                                                      .comment
                                                      .replies
                                                      .length;
                                                  for (var reply
                                                      in widget
                                                          .comment
                                                          .replies) {
                                                    totalReplies +=
                                                        reply.replies.length;
                                                  }
                                                  return Text(
                                                    "$totalReplies",
                                                    style:
                                                        GoogleFonts.pixelifySans(
                                                          color: theme
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.color,
                                                        ),
                                                  );
                                                }),
                                                const SizedBox(width: 10),
                                                SvgPicture.asset(
                                                  _isExpanded
                                                      ? "lib/assets/icons/up.svg"
                                                      : "lib/assets/icons/down.svg",
                                                  width: 20,
                                                  colorFilter: ColorFilter.mode(
                                                    theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color ??
                                                        Colors.black,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 5),
                                  // Like Button
                                  Obx(
                                    () => Transform.scale(
                                      scale: 0.7,
                                      child: CustomIconButton(
                                        borderColor: Colors.transparent,
                                        iconAsset:
                                            widget.comment.iHaveLiked.value
                                            ? "lib/assets/icons/like_button_filled.svg"
                                            : "lib/assets/icons/like_button.svg",
                                        iconColor:
                                            widget.comment.iHaveLiked.value
                                            ? Colors.red
                                            : null,
                                        onTapped: () => controller.toggleLike(
                                          widget.comment,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        "${widget.comment.likeCount.value}",
                                        style: GoogleFonts.pixelifySans(
                                          color:
                                              theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // --- Card Body ---
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 3,
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- DISPLAY GIF ---
                                  if (widget.comment.mediaUrl != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.network(
                                            widget.comment.mediaUrl!,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // --- Check for null or empty ---
                                  if (widget.comment.content != null &&
                                      widget.comment.content!.isNotEmpty)
                                    Text(
                                      widget.comment.content!,
                                      style: TextStyle(
                                        color:
                                            theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- Conditional Replies Section ---
            Visibility(
              visible: (widget.depth == 0 && _isExpanded) || widget.depth == 1,
              maintainState: true,
              child: Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.comment.replies.length,
                  itemBuilder: (context, index) {
                    final reply = widget.comment.replies[index];
                    return CommentCard(comment: reply, depth: widget.depth + 1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
