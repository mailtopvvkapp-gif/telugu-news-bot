import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsHomeScreen extends StatefulWidget {
  const NewsHomeScreen({super.key});

  @override
  State<NewsHomeScreen> createState() => _NewsHomeScreenState();
}

class _NewsHomeScreenState extends State<NewsHomeScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  String selectedLanguage = 'telugu';
  late TabController _tabController;

  final List<String> categories = ['movies', 'sports', 'politics', 'regional'];

  // తెలుగు కేటగిరీ పేర్లు
  final Map<String, String> categoryLabels = {
    'movies': 'సినిమా',
    'sports': 'క్రీడలు',
    'politics': 'రాజకీయాలు',
    'regional': 'ప్రాంతీయం',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  // Supabase నుండి వార్తలను ఫిల్టర్ చేసి తేవడం
  Future<List<Map<String, dynamic>>> fetchNews(String category) async {
    final data = await supabase
        .from('news_articles')
        .select()
        .eq('language', selectedLanguage)
        .eq('category', category)
        .order('published_at', ascending: false)
        .limit(30);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('తాజా వార్తలు'),
        actions: [
          // లాంగ్వేజ్ సెలెక్టర్
          DropdownButton<String>(
            value: selectedLanguage,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'telugu', child: Text('తెలుగు')),
              DropdownMenuItem(value: 'hindi', child: Text('हिन्दी')),
              DropdownMenuItem(value: 'english', child: Text('English')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => selectedLanguage = val);
              }
            },
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((cat) => Tab(text: categoryLabels[cat] ?? cat)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((cat) => NewsListTab(category: cat, fetchNews: fetchNews)).toList(),
      ),
    );
  }
}

class NewsListTab extends StatelessWidget {
  final String category;
  final Future<List<Map<String, dynamic>>> Function(String) fetchNews;

  const NewsListTab({super.key, required this.category, required this.fetchNews});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchNews(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('ప్రస్తుతం వార్తలు అందుబాటులో లేవు'));
        }

        final articles = snapshot.data!;
        return ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final item = articles[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: ListTile(
                title: Text(
                  item['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item['source_name'] ?? 'News',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () async {
                  final url = Uri.parse(item['source_url']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.inAppWebView);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
