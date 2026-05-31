import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/design_system/design_system.dart';

const _kRecentSearches = [
  'election polling data',
  'infrastructure bill details',
  'local arts festival schedule',
];

const _kResults = [
  (
    badge: 'NEWS',
    filled: true,
    time: '2 hours ago',
    title: 'The Future of Concrete in Sustainable City Planning',
    excerpt:
        'Architects are rethinking traditional materials, finding that new high-density concrete blends\u2026',
    author: null as String?,
    replies: null as int?,
    likes: null as int?,
  ),
  (
    badge: 'COMMUNITY',
    filled: false,
    time: null as String?,
    title:
        'Debate: Should we preserve brutalist structures in the historic downtown district?',
    excerpt: null as String?,
    author: '@urbanist_jane',
    replies: 128,
    likes: 45,
  ),
  (
    badge: 'POLITICS',
    filled: false,
    time: 'Yesterday',
    title: 'City Council Approves New Zoning Laws for Mixed-Use Development',
    excerpt: 'The controversial bill passed 5-4 late Tuesday\u2026',
    author: null as String?,
    replies: null as int?,
    likes: null as int?,
  ),
];

/// Search screen with tabs ALL RESULTS | NEWS ONLY | COMMUNITY ONLY.
class SearchScreen extends HookWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchCtrl = useTextEditingController();
    final tabCtrl = useTabController(initialLength: 3);
    final query = useState('');

    useEffect(() {
      void listener() => query.value = searchCtrl.text;
      searchCtrl.addListener(listener);
      return () => searchCtrl.removeListener(listener);
    }, [searchCtrl]);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: const BackButton(),
        title: TextField(
          controller: searchCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: GoogleFonts.workSans(
              fontSize: 16,
              color: context.colorScheme.onSurfaceVariant,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            suffixIcon: query.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      searchCtrl.clear();
                    },
                  )
                : null,
          ),
          style: GoogleFonts.workSans(
            fontSize: 16,
            color: context.colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.colorScheme.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: GoogleFonts.workSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          tabs: const [
            Tab(text: 'ALL RESULTS'),
            Tab(text: 'NEWS ONLY'),
            Tab(text: 'COMMUNITY ONLY'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabCtrl,
        children: [
          _buildAllResults(context),
          _buildAllResults(context, filterBadge: 'NEWS'),
          _buildAllResults(context, filterBadge: 'COMMUNITY'),
        ],
      ),
    );
  }

  Widget _buildAllResults(BuildContext context, {String? filterBadge}) {
    final results = filterBadge == null
        ? _kResults
        : _kResults.where((r) => r.badge == filterBadge).toList();

    return ListView(
      children: [
        ...results.map((r) => _ResultTile(result: r)),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'RECENT SEARCHES',
            style: GoogleFonts.workSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ..._kRecentSearches.map((s) => _RecentSearchTile(term: s)),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result});

  final ({
    String badge,
    bool filled,
    String? time,
    String title,
    String? excerpt,
    String? author,
    int? replies,
    int? likes,
  })
  result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryBadge(result.badge, filled: result.filled),
              if (result.time != null) ...[
                const SizedBox(width: 8),
                Text(
                  result.time!,
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (result.author != null) ...[
                const SizedBox(width: 8),
                Text(
                  'Posted by ${result.author}',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            result.title,
            style: GoogleFonts.newsreader(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          if (result.excerpt != null) ...[
            const SizedBox(height: 4),
            Text(
              result.excerpt!,
              style: GoogleFonts.workSans(
                fontSize: 13,
                color: context.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
          if (result.replies != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 14,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${result.replies} replies',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.thumb_up_outlined,
                  size: 14,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${result.likes} likes',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentSearchTile extends StatelessWidget {
  const _RecentSearchTile({required this.term});
  final String term;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            size: 18,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              term,
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
          Transform.rotate(
            angle: -0.785,
            child: Icon(
              Icons.arrow_forward,
              size: 16,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
