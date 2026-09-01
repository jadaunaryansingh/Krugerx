class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? avatarUrl;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.userId,
    this.email,
    this.displayName,
    this.avatarUrl,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? userId,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: clearError ? null : (error ?? this.error),
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
