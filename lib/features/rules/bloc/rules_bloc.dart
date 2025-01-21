import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'rules_event.dart';
part 'rules_state.dart';

class RulesBloc extends Bloc<RulesEvent, RulesState> {
  final FirebaseAuth _auth;

  RulesBloc(this._auth) : super(RulesInitial()) {
    on<LoadUserId>((event, emit) async {
      final user = _auth.currentUser;
      if (user != null) {
        emit(RulesLoaded(
          userId: user.uid,
          searchMode: false,
          searchQuery: "",
        ));
      }
    });

    on<ToggleSearchMode>((event, emit) {
      if (state is RulesLoaded) {
        final currentState = state as RulesLoaded;
        emit(currentState.copyWith(searchMode: true));
      }
    });

    on<ExitSearchMode>((event, emit) {
      if (state is RulesLoaded) {
        final currentState = state as RulesLoaded;
        emit(currentState.copyWith(searchMode: false, searchQuery: ""));
      }
    });

    on<UpdateSearchQuery>((event, emit) {
      if (state is RulesLoaded) {
        final currentState = state as RulesLoaded;
        emit(currentState.copyWith(searchQuery: event.query.toLowerCase()));
      }
    });
  }
}
