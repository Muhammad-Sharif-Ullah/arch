import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/core/extensions/onboading_ext.dart';
import 'package:{{project_name}}/features/onboarding/data/models/onbading.dart';
import 'package:{{project_name}}/features/onboarding/domain/entities/onboading.dart';
import 'package:{{project_name}}/features/onboarding/domain/usecases/get_onboard.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends HydratedBloc<OnboardingEvent, OnboardingState> {
  final GetOnboardUseCase useCase;
  OnboardingBloc({required this.useCase})
      : super(OnboardingNotViewed(data: [])) {
    on<ToggleOnboardingViewed>((event, emit) {
      if (state is OnboardingNotViewed) {
        emit(OnboardingViewed(data: (state as OnboardingNotViewed).data));
      } else {
        emit(OnboardingNotViewed(data: (state as OnboardingNotViewed).data));
      }
    });

    on<FetchBoadingDateFromAPI>((evnet, emit) async {
      emit(FetchOnboading());
      final response = await useCase.call();
      response.fold(
        (error) {
          emit(FailedToFetched(failure: error));
        },
        (success) {
          emit(OnboardingNotViewed(data: success));
        },
      );
    });
  }

  @override
  OnboardingState? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OnboardingNotViewed(data: []);
    } else {
      List<OnboadingEntity> data = (json['data'] as List<dynamic>)
          .map((e) => OnboadingModel.fromJson(e).toEntity())
          .toList();

      if (json['isViewd']) {
        return OnboardingViewed(data: data);
      } else {
        return OnboardingNotViewed(data: data);
      }
    }
  }

  @override
  Map<String, dynamic>? toJson(OnboardingState state) {
    if (state is OnboardingViewed) {
      List<Map<String, dynamic>> data =
          state.data.map((e) => e.toModel().toJson()).toList();
      return {'data': data, 'isViewd': true};
    } else if (state is OnboardingNotViewed) {
      List<Map<String, dynamic>> data =
          state.data.map((e) => e.toModel().toJson()).toList();
      return {'data': data, 'isViewd': false};
    }
    return null;
  }
}
