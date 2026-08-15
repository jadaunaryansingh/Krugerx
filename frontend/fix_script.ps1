function Replace-In-File {
    param ($file, $old, $new)
    $content = Get-Content $file -Raw
    $content = $content -replace $old, $new
    Set-Content $file $content
}

Replace-In-File 'lib\features\auth\signup_screen.dart' 'AppTheme\.radiusSmall' '4.0'
Replace-In-File 'lib\features\auth\signup_screen.dart' 'AppTheme\.radiusMedium' '8.0'
Replace-In-File 'lib\features\auth\signup_screen.dart' 'AppTheme\.radiusLarge' '16.0'
Replace-In-File 'lib\features\auth\signup_screen.dart' 'AppTheme\.glassGradient' 'LinearGradient(colors: [DesignSystem.surface.withValues(alpha: 0.8), DesignSystem.surface.withValues(alpha: 0.9)])'
Replace-In-File 'lib\features\auth\signup_screen.dart' 'AppTheme\.glowShadow\(.*?\)' 'BoxShadow(color: DesignSystem.primary.withValues(alpha: 0.5), blurRadius: 10)'

Replace-In-File 'lib\features\bookmarks\bookmarks_screen.dart' 'AppTheme\.surfaceContainer' 'DesignSystem.surfaceContainer'
Replace-In-File 'lib\features\bookmarks\bookmarks_screen.dart' 'AppTheme\.radiusSmall' '4.0'
Replace-In-File 'lib\features\bookmarks\bookmarks_screen.dart' 'AppTheme\.eldritchGold' 'DesignSystem.primary'

Replace-In-File 'lib\features\browser\new_tab_page.dart' 'DesignSystem\.headline' 'DesignSystem.fontFamilyHanken'
Replace-In-File 'lib\features\browser\new_tab_page.dart' 'inset:\s*true,?' ''
Replace-In-File 'lib\features\browser\new_tab_page.dart' 'EdgeInsets\.top' 'EdgeInsets.only'
Replace-In-File 'lib\features\browser\new_tab_page.dart' 'DesignSystem\.primaryDark' 'DesignSystem.primaryDim'

Replace-In-File 'lib\features\browser\widgets\address_bar_widget.dart' 'inset:\s*true,?' ''

Replace-In-File 'lib\features\browser\widgets\browser_engine_widget.dart' 'AppTheme\.surface' 'DesignSystem.surface'
$be_content = Get-Content 'lib\features\browser\widgets\browser_engine_widget.dart' -Raw
if ($be_content -notmatch 'import.*?design_system\.dart') {
    $be_content = $be_content -replace "import 'package:flutter/material\.dart';", "import 'package:flutter/material.dart';`nimport '../../../core/theme/design_system.dart';"
    Set-Content 'lib\features\browser\widgets\browser_engine_widget.dart' $be_content
}

Replace-In-File 'lib\features\browser\widgets\search_overlay.dart' 'AppTheme\.voidBlack' 'DesignSystem.background'
Replace-In-File 'lib\features\browser\widgets\search_overlay.dart' 'AppTheme\.radiusSmall' '4.0'
