part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class ToggleOnboardingViewed extends OnboardingEvent {}

class FetchBoadingDateFromAPI extends OnboardingEvent {}
