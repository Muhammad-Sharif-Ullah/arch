// lib/theme/schemes.dart
// ------ 10 scheme classes (3 old + 7 new) ------
import 'package:flutter/material.dart';
import 'package:{{project_name}}/app/theme/schemes/amber.dart';
import 'package:{{project_name}}/app/theme/schemes/arch.dart';
import 'package:{{project_name}}/app/theme/schemes/crimson.dart';
import 'package:{{project_name}}/app/theme/schemes/forest.dart';
import 'package:{{project_name}}/app/theme/schemes/lavender.dart';
import 'package:{{project_name}}/app/theme/schemes/midnight.dart';
import 'package:{{project_name}}/app/theme/schemes/mint.dart';
import 'package:{{project_name}}/app/theme/schemes/neon.dart';
import 'package:{{project_name}}/app/theme/schemes/ocean.dart';
import 'package:{{project_name}}/app/theme/schemes/sakura.dart';
import 'package:{{project_name}}/app/theme/schemes/sunset.dart';

/* ---------- helper ---------- */
ThemeData _build(ColorScheme scheme) =>
    ThemeData.from(colorScheme: scheme, useMaterial3: true);

/* ---------- Ocean ---------- */
final oceanLightTheme = _build(OceanScheme.light);
final oceanDarkTheme = _build(OceanScheme.dark);

/* ---------- Sunset ---------- */
final sunsetLightTheme = _build(SunsetScheme.light);
final sunsetDarkTheme = _build(SunsetScheme.dark);

/* ---------- Forest ---------- */
final forestLightTheme = _build(ForestScheme.light);
final forestDarkTheme = _build(ForestScheme.dark);

/* ---------- Lavender ---------- */
final lavenderLightTheme = _build(LavenderScheme.light);
final lavenderDarkTheme = _build(LavenderScheme.dark);

/* ---------- Sakura ---------- */
final sakuraLightTheme = _build(SakuraScheme.light);
final sakuraDarkTheme = _build(SakuraScheme.dark);

/* ---------- Midnight ---------- */
final midnightLightTheme = _build(MidnightScheme.light);
final midnightDarkTheme = _build(MidnightScheme.dark);

/* ---------- Amber ---------- */
final amberLightTheme = _build(AmberScheme.light);
final amberDarkTheme = _build(AmberScheme.dark);

/* ---------- Mint ---------- */
final mintLightTheme = _build(MintScheme.light);
final mintDarkTheme = _build(MintScheme.dark);

/* ---------- Crimson ---------- */
final crimsonLightTheme = _build(CrimsonScheme.light);
final crimsonDarkTheme = _build(CrimsonScheme.dark);

/* ---------- Neon ---------- */
final neonLightTheme = _build(NeonScheme.light);
final neonDarkTheme = _build(NeonScheme.dark);

/* ---------- Arch ---------- */
final archLightTheme = _build(ArchScheme.light);
final archDarkTheme = _build(ArchScheme.dark);
