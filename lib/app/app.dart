import 'package:defyx_vpn/app/router/app_router.dart';
import 'package:defyx_vpn/core/data/local/remote/api/flowline_service.dart';
import 'package:defyx_vpn/modules/core/vpn.dart';
import 'package:defyx_vpn/modules/core/vpn_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final Future<void> _initialization = _initializeServices();

  Future<void> _initializeServices() async {
    await dotenv.load();

    try {
      final vpnBridge = VpnBridge();
      await vpnBridge.getVpnStatus();
      if (!mounted) return;

      final container = ProviderScope.containerOf(context);
      final vpn = VPN(container);
      await vpn.getVPNStatus();
      await vpnBridge.setAsnName();
      await ref.read(flowlineServiceProvider).saveFlowline();
    } on PlatformException catch (error, stack) {
      debugPrint('PlatformException: ${error.message}, details: ${error.details}');
      debugPrintStack(stackTrace: stack);
    } catch (error, stack) {
      debugPrint('Unexpected VPN initialization error: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) => _buildApp(context),
    );
  }

  Widget _buildApp(BuildContext context) {
    final router = ref.watch(routerProvider);
    final designSize = _getDesignSize(context);

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          title: 'Defyx',
          theme: _buildAppTheme(),
          routerConfig: router,
          builder: _appBuilder,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Size _getDesignSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLargeTablet = size.width > 900;
    final isDesktop = size.width > 1200;

    if (isDesktop) return const Size(1440, 900);
    if (isLargeTablet) return const Size(1024, 768);
    if (isTablet) return const Size(768, 1024);
    return const Size(393, 852);
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Lato',
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _appBuilder(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
