import '../models/comment_model.dart';
import '../models/post_model.dart';

/// Provides initial offline fallback sample data for discussions and comments.
/// Used exclusively when Supabase backend credentials are not configured or when testing offline.
class MockData {
  /// Initial collection of sample forum discussions and blog posts.
  static List<PostModel> get initialPosts => [
        PostModel(
          id: '1',
          authorId: 'user_2',
          authorName: 'Sarah Jenkins',
          authorHandle: '@sjenkins',
          title: 'The Architecture of Silence: Designing for Focus',
          content: "In an era defined by constant notification pings and algorithmic urgency, creating digital spaces that foster deep focus has become a radical act. We often talk about 'user engagement,' but rarely do we discuss 'user tranquility.'\n\nConsider the physical library. The architecture itself enforces a behavioral shift. High ceilings dampen sound, specific lighting arrangements delineate reading zones from stacks, and the overall volume of space demands a physical quietness. Can we replicate this in our interfaces?\n\nBy leveraging generous whitespace (what I prefer to call 'breathing room') and heavily restricting our color palettes, we can guide the user's eye without shouting at them. It's about designing islands of information rather than a sea of data.",
          community: 'design',
          tags: ['DesignTheory', 'UX', 'Minimalism'],
          imageUrls: [
            'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800&auto=format&fit=crop&q=80',
            'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&auto=format&fit=crop&q=80',
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        PostModel(
          id: '2',
          authorId: 'user_3',
          authorName: 'Elena Rostova',
          authorHandle: '@elena_design',
          title: 'The Art of Subtraction in UI Design',
          content: 'In a world cluttered with information, designing interfaces that prioritize clarity and focus is more critical than ever. We explore how removing elements can actually enhance the user experience.',
          community: 'design',
          tags: ['Design', 'Minimalism'],
          imageUrls: [
            'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&auto=format&fit=crop&q=80',
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        PostModel(
          id: '3',
          authorId: 'user_1',
          authorName: 'Alexander Wright',
          authorHandle: '@alex_wright',
          title: 'Building Scalable State Systems in Flutter',
          content: 'State management is at the core of dynamic cross-platform applications. Using clean Architecture principles alongside Provider allows for predictable, maintainable application state flow.',
          community: 'tech',
          tags: ['Flutter', 'Architecture', 'StateManagement'],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  /// Initial collection of sample discussion comments keyed by post ID.
  static Map<String, List<CommentModel>> get initialComments => {
        '1': [
          CommentModel(
            id: 'c1',
            postId: '1',
            authorId: 'user_4',
            authorName: 'David Chen',
            content: "Brilliant take on the library analogy. I think the challenge is convincing stakeholders that 'quiet' interfaces don't mean 'dead' interfaces. Engagement metrics often punish subtlety.",
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          CommentModel(
            id: 'c2',
            postId: '1',
            authorId: 'user_3',
            authorName: 'Elena Rostova',
            content: "Exactly this! We need better metrics for 'quality of time spent' rather than just 'duration'.",
            createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          ),
        ],
      };
}
