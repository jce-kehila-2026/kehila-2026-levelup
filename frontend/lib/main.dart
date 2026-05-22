import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'di/service_locator.dart';
import 'l10n/app_localizations.dart';
import 'logic/controllers/locale_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/widgets/branded_scaffold.dart';

import 'presentation/screens/layouts/admin_layout.dart';
import 'presentation/screens/layouts/instructor_layout.dart';
import 'presentation/screens/layouts/student_layout.dart';

import 'presentation/screens/details/assignment_detail_screen.dart';
import 'presentation/screens/details/group_detail_screen.dart';
import 'presentation/screens/details/lesson_detail_screen.dart';
import 'presentation/screens/details/student_detail_screen.dart';
import 'presentation/screens/details/student_assignment_detail_screen.dart';
import 'data/models/assignment_model.dart';
import 'data/repositories/assignment_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupServiceLocator();

  final localeProvider = LocaleProvider();
  await localeProvider.load();
  
  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: const LevelApp(),
    ),
  );
}

class LevelApp extends StatelessWidget {
  const LevelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      title: 'Level',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: localeProvider.locale,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      builder: (context, child) {
        Widget app = child!;

        // Arabic text +10% scale for visual balance with Cairo font
        if (localeProvider.isArabic) {
          app = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.1),
            ),
            child: app,
          );
        }

        final isDesktopWeb = kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
             defaultTargetPlatform == TargetPlatform.windows ||
             defaultTargetPlatform == TargetPlatform.linux);

        if (!isDesktopWeb) {
          return BrandedBackground(child: app);
        }

        const double screenWidth = 390.0;
        const double screenHeight = 844.0;

        return ColoredBox(
          color: const Color(0xFFE5E7EB),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 24,
                        spreadRadius: 4,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BrandedBackground(child: app),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminLayout(),
    ),
    GoRoute(
      path: '/instructor',
      builder: (context, state) => const InstructorLayout(),
    ),
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentLayout(),
    ),
    GoRoute(
      path: '/assignment/:id',
      builder: (context, state) => AssignmentDetailScreen(id: state.pathParameters['id']!, isAdminView: state.extra == 'admin'),
    ),
    GoRoute(
      path: '/group/:id',
      builder: (context, state) => GroupDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/lesson/:id',
      builder: (context, state) => LessonDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/student/:id',
      builder: (context, state) => StudentDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/student-assignment/:id',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is AssignmentModel) {
          return StudentAssignmentDetailScreen(assignment: extra);
        }
        return _AssignmentLoaderScreen(assignmentId: state.pathParameters['id']!);
      },
    ),
  ],
);

class _AssignmentLoaderScreen extends StatefulWidget {
  final String assignmentId;
  const _AssignmentLoaderScreen({required this.assignmentId});

  @override
  State<_AssignmentLoaderScreen> createState() => _AssignmentLoaderScreenState();
}

class _AssignmentLoaderScreenState extends State<_AssignmentLoaderScreen> {
  late final AssignmentRepository _repo = getIt<AssignmentRepository>();
  bool _isLoading = true;
  AssignmentModel? _assignment;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _repo.getAssignmentById(widget.assignmentId);
    if (mounted) {
      setState(() {
        _assignment = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_assignment == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.notFound)),
        body: Center(child: Text(l10n.assignmentNotFound)),
      );
    }
    return StudentAssignmentDetailScreen(assignment: _assignment!);
  }
}
