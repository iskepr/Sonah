import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../../constant.dart";
import "../../features/get_start/views/permissions_view.dart";
import "../../features/home/views/home_view.dart";
import "../../features/routine/cubit/routine_cubit.dart";
import "../../features/routine/views/edit_routine_view.dart";

CustomTransitionPage pageTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: kAnimationSlowerDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1, 0), // بيبدأ من اليمين
                end: Offset.zero, // بيقف في النص
              ).animate(
                CurvedAnimation(parent: animation, curve: kCurveEaseOutBack),
              ),
          child: child,
        ),
      );
    },
  );
}

bool isFirstOpen = true;

final appRouter = GoRouter(
  initialLocation: isFirstOpen ? kRouteGetStarted : kRouteHome,

  navigatorKey: kNavigatorKey,

  redirect: (context, state) {
    final uri = state.uri;
    if (uri.scheme == "sonah") return "/${uri.host}${uri.path}";
    return null;
  },

  routes: [
    GoRoute(
      path: kRouteHome,
      pageBuilder: (context, state) {
        return pageTransition(
          context: context,
          state: state,
          child: const Scaffold(
            backgroundColor: Colors.transparent,
            body: HomeView(),
          ),
        );
      },
    ),
    GoRoute(
      path: kRouteGetStarted,
      pageBuilder: (context, state) => pageTransition(
        context: context,
        state: state,
        child: const PermissionsView(),
      ),
    ),
    GoRoute(
      path: kRouteRoutine,
      pageBuilder: (context, state) => pageTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (context) => RoutineCubit(),
          child: const EditRoutineView(),
        ),
      ),
    ),
  ],
);
