import 'package:domain_extention/features/smart_home/presentation/bloc/smart_home_event.dart';
import 'package:domain_extention/features/smart_home/presentation/bloc/smart_home_state.dart';

abstract class SmartHomeBloc {
  const SmartHomeBloc();

  void add(SmartHomeEvent event);

  Stream<SmartHomeState> get stream;
}
