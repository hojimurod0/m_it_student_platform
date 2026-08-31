import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/utils/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.debug('${bloc.runtimeType} -> Event: $event', tag: 'BLOC_EVENT');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    AppLogger.info(
      '${bloc.runtimeType} | State: ${transition.currentState.runtimeType} ➔ ${transition.nextState.runtimeType}',
      tag: 'BLOC_TRANSITION',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.error(
      '${bloc.runtimeType} Error: $error',
      error: error,
      stackTrace: stackTrace,
      tag: 'BLOC_ERROR',
    );
  }
}
