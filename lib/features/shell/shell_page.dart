import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/features/matches/presentation/live/live_matches_bloc.dart";
import "package:soccer/features/matches/presentation/pages/home_page.dart";
import "package:soccer/features/matches/presentation/pages/live_page.dart";
import "package:soccer/features/matches/presentation/pages/matches_page.dart";
import "package:soccer/features/more/more_page.dart";
import "package:soccer/features/teams/presentation/teams_page.dart";

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> with WidgetsBindingObserver {
  int _index = 0;
  bool? _watching;
  final List<Widget?> _pages = List<Widget?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncWatch();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<LiveMatchesBloc>();
    switch (state) {
      case AppLifecycleState.resumed:
        bloc.add(const LiveAppResumed());
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        bloc.add(const LiveAppPaused());
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _syncWatch() {
    final watch = _index == 0 || _index == 1;
    if (_watching == watch) return;
    _watching = watch;
    context.read<LiveMatchesBloc>().add(
      watch ? const LiveWatchStarted() : const LiveWatchStopped(),
    );
  }

  Widget _page(int index) {
    final existing = _pages[index];
    if (existing != null) return existing;
    if (index != _index) return const SizedBox.shrink();
    final page = switch (index) {
      0 => const HomePage(),
      1 => const LivePage(),
      2 => const MatchesPage(),
      3 => const TeamsPage(),
      _ => const MorePage(),
    };
    _pages[index] = page;
    return page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (var i = 0; i < 5; i++) _page(i)],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
          _syncWatch();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors),
            label: "Live",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: "Matches",
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: "Teams",
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu),
            label: "More",
          ),
        ],
      ),
    );
  }
}
