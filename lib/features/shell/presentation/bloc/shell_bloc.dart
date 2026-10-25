import 'package:domain_extention/features/shell/presentation/bloc/shell_event.dart';
import 'package:domain_extention/features/shell/presentation/bloc/shell_state.dart';

abstract class ShellBloc {
  const ShellBloc();

  void add(ShellEvent event);

  Stream<ShellState> get stream;
}
