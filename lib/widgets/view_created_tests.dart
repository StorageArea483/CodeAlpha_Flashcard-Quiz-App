import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_card_quiz/pages/role_select_page.dart';
import 'package:flash_card_quiz/pages/test_info_page.dart';
import 'package:flash_card_quiz/providers/role_select_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../styles/styles.dart';

class ViewCreatedTests extends ConsumerStatefulWidget {
  const ViewCreatedTests({super.key});

  @override
  ConsumerState<ViewCreatedTests> createState() => _ViewCreatedTestsState();
}

class _ViewCreatedTestsState extends ConsumerState<ViewCreatedTests> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTestNames();
    });
  }

  Future<void> _fetchTestNames() async {
    try {
      if (!mounted) return;
      ref.read(isLoading.notifier).state = true;

      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection('quizinfo').get();

      if (querySnapshot.docs.isNotEmpty) {
        // Extract unique test names
        final names = querySnapshot.docs
            .map((doc) => doc.data()['testName'] as String)
            .toSet()
            .toList();

        if (mounted) {
          ref.read(testNames.notifier).state = names;
          ref.read(isNotEmpty.notifier).state = true;
        }
      } else {
        if (mounted) {
          ref.read(isNotEmpty.notifier).state = false;
        }
      }

      if (mounted) {
        ref.read(isLoading.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        ref.read(isLoading.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error fetching tests, please try again'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: const Text('Created Tests', style: AppText.appHeader),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RoleSelectPage()),
          ),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // App Logo
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/images/app-logo.png',
                    width: 100,
                    height: 100,
                  ),
                  // App Name
                  const SizedBox(height: 10),
                  Text(
                    'FlashCard Quiz',
                    style: AppText.welcomeTitle.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tests List
                  Consumer(
                    builder: (context, ref, child) {
                      if (!mounted) return const SizedBox.shrink();
                      final names = ref.watch(testNames);
                      return names.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: names.length,
                              itemBuilder: (context, index) {
                                final testName = names[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: SimpleDecoration.card(),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    title: Text(
                                      testName,
                                      style: AppText.base.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.primaryDark,
                                      size: 20,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TestInfoPage(testName: testName),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 100,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.quiz_outlined,
                                      size: 64,
                                      color: AppColors.textLight,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'No tests created yet',
                                      style: AppText.base.copyWith(
                                        color: AppColors.textLight,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
            // Loading indicator at the center
            Consumer(
              builder: (context, ref, child) {
                if (!mounted) return const SizedBox.shrink();
                final loading = ref.watch(isLoading);
                if (!loading) return const SizedBox.shrink();
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.buttonBackground,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
