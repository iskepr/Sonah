import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:permission_handler/permission_handler.dart";
import "package:usage_stats/usage_stats.dart";

import "../../../constant.dart";
import "../../../core/theme/colors.dart";
import "../../../core/utils/get_location.dart";

class PermissionsView extends StatefulWidget {
  const PermissionsView({super.key});

  @override
  State<PermissionsView> createState() => _PermissionsViewState();
}

const _launcherChannel = MethodChannel("sonah.launcher/default");

class _PermissionsViewState extends State<PermissionsView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<PermissionItemData> _filteredPermissions = [];
  bool _isCheckingPermissions = true;

  List<PermissionItemData> _getAllPermissions() {
    return [
      PermissionItemData(
        title: "تعيين كمشغل افتراضي",
        description:
            "عشان سُنة يشتغل كلانشر أساسي للجهاز وتستفيد من كل المميزات والإيماءات وسرعة الوصول.",
        icon: LucideIcons.home,
        checkStatus: () async =>
            await _launcherChannel.invokeMethod("isDefaultLauncher"),
        onRequest: () async {
          await _launcherChannel.invokeMethod("openLauncherChooser");
          await Future.delayed(const Duration(milliseconds: 1500));
          return await _launcherChannel.invokeMethod("isDefaultLauncher");
        },
      ),
      PermissionItemData(
        title: "الموقع الجغرافي",
        description:
            "عشان نجيب مواعيد الصلاة المظبوطة ونعرض حالة الطقس في اللانشر.",
        icon: LucideIcons.mapPin,
        checkStatus: () async => await Permission.location.status.isGranted,
        onRequest: () async {
          var status = await Permission.location.status;
          if (!status.isGranted) status = await Permission.location.request();
          getLocalLocation();
          return status.isGranted;
        },
      ),
      PermissionItemData(
        title: "استخدام التطبيقات",
        description:
            "عشان نقدر نحدد مدة استخدامك لكل تطبيق ونساعدك تقلل تضييع الوقت وتنجز مهامك.",
        icon: LucideIcons.chartLine,
        checkStatus: () async =>
            await UsageStats.checkUsagePermission() == true,
        onRequest: () async {
          bool? granted = await UsageStats.checkUsagePermission();
          if (granted == null || !granted) {
            await UsageStats.grantUsagePermission();
            granted = await UsageStats.checkUsagePermission();
          }
          return granted == true;
        },
      ),
      PermissionItemData(
        title: "جهات الاتصال",
        description:
            "عشان تقدر تبحث عن أي حد وتتصل بيه بسرعة من شريط البحث بتاع اللانشر.",
        icon: LucideIcons.contact,
        checkStatus: () async => await Permission.contacts.status.isGranted,
        onRequest: () async {
          var status = await Permission.contacts.status;
          if (!status.isGranted) status = await Permission.contacts.request();
          return status.isGranted;
        },
      ),
      PermissionItemData(
        title: "إجراء المكالمات",
        description:
            "عشان لما تبحث عن جهة اتصال تقدر ترن عليه مباشرة بضغطة واحدة.",
        icon: LucideIcons.phoneCall,
        checkStatus: () async => await Permission.phone.status.isGranted,
        onRequest: () async {
          var status = await Permission.phone.status;
          if (!status.isGranted) status = await Permission.phone.request();
          return status.isGranted;
        },
      ),
      PermissionItemData(
        title: "الإشعارات",
        description:
            "عشان نبعتلك الأذكار في وقتها وننبهك وقت الصلاة ومنبه الفجر.",
        icon: LucideIcons.bellRing,
        checkStatus: () async => await Permission.notification.status.isGranted,
        onRequest: () async {
          var status = await Permission.notification.status;
          if (!status.isGranted) {
            status = await Permission.notification.request();
          }
          return status.isGranted;
        },
      ),
      PermissionItemData(
        title: "التقويم",
        description:
            "عشان نعمل مزامنة مع تقويم جوجل ونعرض مهامك ومواعيدك في شاشة اللانشر.",
        icon: LucideIcons.calendar,
        checkStatus: () async => await Permission.calendar.status.isGranted,
        onRequest: () async {
          var status = await Permission.calendar.status;
          if (!status.isGranted) status = await Permission.calendar.request();
          return status.isGranted;
        },
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _checkAndFilterPermissions();
  }

  Future<void> _checkAndFilterPermissions() async {
    final List<PermissionItemData> missingPermissions = [];
    final allPermissions = _getAllPermissions();

    for (var permission in allPermissions) {
      final isGranted = await permission.checkStatus();
      if (!isGranted) {
        missingPermissions.add(permission);
      }
    }

    if (mounted) {
      setState(() {
        _filteredPermissions = missingPermissions;
        _isCheckingPermissions = false;
      });

      if (_filteredPermissions.isEmpty) {
        _navigateToHome();
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _filteredPermissions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    context.go(kRouteHome);
    debugPrint("كل الصلاحيات تمام.. اقلب على الهوم!");
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _filteredPermissions.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentPage == index ? 24.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? context.colorScheme.primary
                          : context.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _filteredPermissions.length,
                itemBuilder: (context, index) {
                  return PermissionWidget(
                    data: _filteredPermissions[index],
                    onGranted: _nextPage,
                    onSkip: _nextPage,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionItemData {
  final String title;
  final String description;
  final IconData icon;
  final Future<bool> Function() checkStatus;
  final Future<bool> Function() onRequest;

  PermissionItemData({
    required this.title,
    required this.description,
    required this.icon,
    required this.checkStatus,
    required this.onRequest,
  });
}

class PermissionWidget extends StatefulWidget {
  final PermissionItemData data;
  final VoidCallback onGranted;
  final VoidCallback onSkip;

  const PermissionWidget({
    super.key,
    required this.data,
    required this.onGranted,
    required this.onSkip,
  });

  @override
  State<PermissionWidget> createState() => _PermissionWidgetState();
}

class _PermissionWidgetState extends State<PermissionWidget> {
  bool _isLoading = false;

  void _request() async {
    setState(() => _isLoading = true);
    final granted = await widget.data.onRequest();
    setState(() => _isLoading = false);

    if (granted) {
      widget.onGranted();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("الصلاحية دي مهمة عشان الميزة تشتغل صح!"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.data.icon,
              size: 80,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 40),

          Text(
            widget.data.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Text(
            widget.data.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: context.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isLoading ? null : _request,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "السماح بالصلاحية",
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onSkip,
            child: const Text(
              "تخطي في الوقت الحالي",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
