part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

class OnboardingViewed extends OnboardingState {
  final List<OnboadingEntity> data;

  const OnboardingViewed({required this.data});

  @override
  List<Object> get props => [data];
}

class OnboardingNotViewed extends OnboardingState {
  final List<OnboadingEntity> data;

  const OnboardingNotViewed({required this.data});

  @override
  List<Object> get props => [data];
}

class FetchOnboading extends OnboardingState {}

class FailedToFetched extends OnboardingState {
  final ResponseFailure<List<OnboadingEntity>> failure;

  const FailedToFetched({required this.failure});

  @override
  List<Object> get props => [failure];
}
