package com.example.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

private val DarkColorScheme =
  darkColorScheme(
    primary = GoldOld,
    secondary = GoldChampagne,
    tertiary = GoldDeep,
    background = GraphiteDark,
    surface = GraphiteSurface,
    onPrimary = GraphiteDark,
    onSecondary = GraphiteDark,
    onTertiary = TextLight,
    onBackground = TextLight,
    onSurface = TextLight,
    surfaceVariant = GraphiteLight,
    onSurfaceVariant = TextMuted,
    outline = GraphiteBorder
  )

private val LightColorScheme =
  lightColorScheme(
    primary = GoldOld,
    secondary = GoldDeep,
    tertiary = GoldChampagne,
    background = OffWhite,
    surface = WarmWhiteSurface,
    onPrimary = GraphiteDark,
    onSecondary = TextLight,
    onTertiary = TextDark,
    onBackground = TextDark,
    onSurface = TextDark,
    surfaceVariant = OffWhite,
    onSurfaceVariant = TextMuted,
    outline = WarmGrayBorder
  )

@Composable
fun UniEatsTheme(
  darkTheme: Boolean = isSystemInDarkTheme(),
  // Dynamic color is disabled by default for Uni eats to preserve the highly custom luxury branding
  dynamicColor: Boolean = false,
  content: @Composable () -> Unit,
) {
  val colorScheme =
    when {
      dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
        val context = LocalContext.current
        if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
      }

      darkTheme -> DarkColorScheme
      else -> LightColorScheme
    }

  MaterialTheme(colorScheme = colorScheme, typography = Typography, content = content)
}
