import 'package:flutter_bloc/flutter_bloc.dart';


class CreatePostCubit extends Cubit<String> {
  CreatePostCubit() : super(' ');

  void inputs(string) => emit(string);
}