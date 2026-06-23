import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../core/extensions/extensions.dart";
import "../cubit/routine_cubit.dart";
import "widgets/task_view.dart";

class EditRoutineView extends StatefulWidget {
  const EditRoutineView({super.key});

  @override
  State<EditRoutineView> createState() => _EditRoutineViewState();
}

class _EditRoutineViewState extends State<EditRoutineView> {
  late final RoutineCubit cubit;
  @override
  void initState() {
    super.initState();

    cubit = context.read<RoutineCubit>();
    cubit.getRoutin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.check),
          onPressed: () => context.close(),
        ),
      ),
      body: BlocBuilder<RoutineCubit, RoutineState>(
        builder: (context, state) {
          if (state is! RoutineLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = state.tasks;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => Transform.scale(
                    scale: state.currentTask == tasks[index] ? 1 : 0.95,
                    child: TaskView(task: tasks[index]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
