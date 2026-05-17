import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/repos/auth_repo.dart';
import '../../../domain/use_cases/signup_params.dart';

part 'sign_up_state.dart';

final class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepo _authRepo;

  SignUpCubit({required AuthRepo authRepo})
    : _authRepo = authRepo,
      super(const SignUpInitial());

  Future<void> signUp({required SignUpParams params}) async {
    emit(const SignUpLoading());

    final result = await _authRepo.signUp(params: params);

    result.fold(
      (failure) => emit(SignUpFailure(_mapFailureMessage(failure))),
      (_) => emit(const SignUpSuccess()),
    );
  }

  String _mapFailureMessage(Failure failure) {
    return switch (failure) {
      NoInternetFailure() => 'لا يوجد اتصال بالإنترنت',
      ValidationFailure() => failure.message,
      ServerFailure() => failure.message,
      UnauthorizedFailure() => 'غير مصرح بالتسجيل',
      RateLimitedFailure() => 'محاولات كثيرة، انتظر قليلاً',
      TimeoutFailure() => 'انتهت مهلة الاتصال، حاول مرة أخرى',
      _ => 'حدث خطأ غير متوقع',
    };
  }
}
