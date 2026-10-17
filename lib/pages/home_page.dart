import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sqlite_demo_page.dart';

class JobPost {
  final String title;
  final String location;
  final String category;
  final DateTime postedDate;
  final Map<String, String> details;

  const JobPost({
    required this.title,
    required this.location,
    required this.category,
    required this.postedDate,
    required this.details,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userEmail;
  String dynamicText = 'Find the best jobs matching your skills!';
  String? activeFilter;
  final Set<int> expandedCards = {};

  final DateFormat postedDateFormat = DateFormat('d MMM yyyy');

  final List<JobPost> jobs = [
    JobPost(
      title: 'Web Developer Intern',
      location: 'Bangalore',
      category: 'internship',
      postedDate: DateTime(2026, 9, 12),
      details: {
        'Company': 'Tech Solutions',
        'Duration': '6 months',
        'Stipend': '₹15,000/month',
      },
    ),
    JobPost(
      title: 'Software Developer',
      location: 'Chennai',
      category: 'fresher',
      postedDate: DateTime(2026, 9, 15),
      details: {
        'Company': 'Tech Solutions',
        'Duration': '6 months',
        'Salary': '₹30,000/month',
      },
    ),
    JobPost(
      title: 'Web Designer',
      location: 'Hyderabad',
      category: 'fresher',
      postedDate: DateTime(2026, 9, 18),
      details: {
        'Company': 'Tech Solutions',
        'Duration': '6 months',
        'Salary': '₹25,000/month',
      },
    ),
    JobPost(
      title: 'Java Developer',
      location: 'Pune',
      category: 'experienced',
      postedDate: DateTime(2026, 9, 20),
      details: {
        'Company': 'Tech Solutions',
        'Experience': '3+ years',
        'Salary': '₹50,000/month',
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');

    if (savedEmail != null && mounted) {
      setState(() => userEmail = savedEmail);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');

    if (mounted) {
      setState(() => userEmail = null);
    }
  }

  void filterJobs(String category) {
    setState(() {
      activeFilter = activeFilter == category ? null : category;
    });
  }

  void toggleDetails(int index) {
    setState(() {
      if (expandedCards.contains(index)) {
        expandedCards.remove(index);
      } else {
        expandedCards.add(index);
      }
    });
  }

  String getRandomUselessJoke() {
    final jokes = [
      'Why did the resume go to therapy? Too many unresolved gaps.',
      "I applied for 99 jobs... and the interviewer said 'still none'.",
      'My cover letter has more drama than a soap opera.',
      'Job hunting: the only sport where rejection is the trophy.',
    ];
    jokes.shuffle();
    return jokes.first;
  }

  @override
  Widget build(BuildContext context) {
    final visibleJobs = activeFilter == null
        ? jobs
        : jobs.where((job) => job.category == activeFilter).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildNav(context),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userEmail != null) _buildWelcomeBar(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SqliteDemoPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.storage),
                        label: const Text('Open SQLite Local Demo'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Category',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _postDemoJob,
                      icon: const Icon(Icons.add),
                      label: const Text('Post Demo Job'),
                    ),
                    const SizedBox(height: 10),
                    _buildCategoryRow(),
                    const SizedBox(height: 24),
                    const Text(
                      'Featured Jobs',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(visibleJobs.length, (i) {
                      final job = visibleJobs[i];
                      final realIndex = jobs.indexOf(job);
                      return _buildJobCard(job, realIndex);
                    }),
                    const SizedBox(height: 24),
                    const Text(
                      'Live Jobs from Firebase',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildFirebaseJobs(),
                  ],
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _postDemoJob() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      await FirebaseFirestore.instance.collection('jobs').add({
        'title': 'Demo Flutter Developer',
        'company': 'JobConnect Demo',
        'category': 'Internship',
        'salary': '₹20,000/month',
        'postedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo job added to Firestore!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add job: $error')),
        );
      }
    }
  }
  Widget _buildFirebaseJobs() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Firebase error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!.docs;

        if (documents.isEmpty) {
          return const Text('No jobs found in Firestore.');
        }

        return Column(
          children: documents.map((document) {
            final data = document.data();
            final title = (data['title'] ?? 'Untitled job').toString();
            final company = (data['company'] ?? 'Company not listed').toString();
            final category =
            (data['category'] ?? 'Category not listed').toString();
            final salary = data['salary']?.toString();

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.cloud_outlined,
                        color: Color(0xFF1E3799),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Company: $company'),
                  Text('Category: $category'),
                  if (salary != null && salary.isNotEmpty)
                    Text('Salary: $salary'),
                  const SizedBox(height: 6),
                  const Text(
                    'Source: Cloud Firestore',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWelcomeBar() {
    return Row(
      children: [
        const FaIcon(
          FontAwesomeIcons.solidCircleUser,
          size: 18,
          color: Color(0xFF1E3799),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Welcome, $userEmail',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: _logout,
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      color: const Color(0xFF0A3D62),
      child: Column(
        children: [
          const Text(
            'Job Portal / Online Recruitment System',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dynamicText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNav(BuildContext context) {
    return Container(
      color: const Color(0xFF1E3799),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        children: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Home',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/login');
              _loadStoredUser();
            },
            child: const Text(
              'Login',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text(
              'Register',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    final categories = [
      {
        'title': 'Internship',
        'subtitle': 'For students & learners',
        'key': 'internship',
        'icon': FontAwesomeIcons.graduationCap,
      },
      {
        'title': 'Fresher',
        'subtitle': 'Start your career',
        'key': 'fresher',
        'icon': FontAwesomeIcons.seedling,
      },
      {
        'title': 'Experienced',
        'subtitle': 'Professional jobs',
        'key': 'experienced',
        'icon': FontAwesomeIcons.briefcase,
      },
    ];

    return Row(
      children: categories.map((category) {
        final isActive = activeFilter == category['key'];

        return Expanded(
          child: GestureDetector(
            onTap: () => filterJobs(category['key'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: isActive
                    ? Border.all(color: const Color(0xFF1E3799), width: 2)
                    : null,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    category['icon'] as IconData,
                    size: 18,
                    color: const Color(0xFF1E3799),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['subtitle'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildJobCard(JobPost job, int index) {
    final expanded = expandedCards.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text('Location: ${job.location}'),
          Text('Category: ${_capitalize(job.category)}'),
          const SizedBox(height: 4),
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.calendarDays,
                size: 12,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                'Posted: ${postedDateFormat.format(job.postedDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3799),
              foregroundColor: Colors.white,
            ),
            onPressed: () => toggleDetails(index),
            child: Text(expanded ? 'Hide Details' : 'View Details'),
          ),
          if (expanded)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6F8),
                border: Border(
                  left: BorderSide(color: Color(0xFF1E3799), width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: job.details.entries
                    .map((entry) => Text('${entry.key}: ${entry.value}'))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A3D62),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _footerColumn('JobConnect', [
                'Your trusted online recruitment platform connecting talent with opportunity.',
              ]),
              _footerColumn('Quick Links', ['Home', 'Login', 'Register']),
              _footerColumn(
                'Categories',
                ['Internships', 'Freshers', 'Experienced Jobs'],
              ),
              _footerColumn(
                'Contact',
                ['support@jobconnect.com', '+91 98765 43210'],
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Text(
            '© ${DateFormat('yyyy').format(DateTime.now())} JobConnect. All Rights Reserved.',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.faceLaughBeam,
              color: Colors.white70,
            ),
            tooltip: 'Tell me a joke',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(getRandomUselessJoke())),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<String> lines) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          ...lines.map(
                (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}