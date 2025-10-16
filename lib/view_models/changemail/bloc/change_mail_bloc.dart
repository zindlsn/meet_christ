import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meta/meta.dart';

part 'change_mail_event.dart';
part 'change_mail_state.dart';

class ChangeMailBloc extends Bloc<ChangeMailEvent, ChangeMailState> {
  ChangeMailBloc() : super(ChangeMailInitial()) {
    on<ChangeMailEvent>((event, emit) {});
    on<ChangeMailRequested>((event, emit) async{
      await GetIt.I.get<AuthRepository>().changeEmail(event.oldEmail,event.newEmail,event.password);
    });
  }
}
