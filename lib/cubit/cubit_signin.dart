import 'package:flutter_bloc/flutter_bloc.dart';


class SignInCubit extends Cubit<String> {
  SignInCubit() : super(' ');

  void inputs(string) => emit(string);
}