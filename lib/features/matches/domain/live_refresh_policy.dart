/// How often live scoreboards are refreshed.
///
/// A live match changes by the minute, but every refresh reads each
/// competition in the sweep. Forty-five seconds keeps goals close to real
/// time. When nothing is in play the sweep backs off to five minutes, and
/// the shell cancels the timer if the user leaves Home or Live, or sends
/// the app to the background.
class LiveRefreshPolicy {
  const LiveRefreshPolicy({
    this.liveInterval = const Duration(seconds: 45),
    this.idleInterval = const Duration(minutes: 5),
  });

  final Duration liveInterval;
  final Duration idleInterval;

  Duration delay({required bool hasLiveMatches}) =>
      hasLiveMatches ? liveInterval : idleInterval;
}
