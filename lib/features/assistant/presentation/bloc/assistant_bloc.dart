import 'package:domain_extention/features/assistant/presentation/bloc/assistant_event.dart';
import 'package:domain_extention/features/assistant/presentation/bloc/assistant_state.dart';

abstract class AssistantBloc {
  const AssistantBloc();

  void add(AssistantEvent event);

  Stream<AssistantState> get stream;
}
