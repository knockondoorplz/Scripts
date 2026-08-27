; === RainWallpaper Theme Loader (Correct Version) ===

helper := "C:\Program Files (x86)\RainWallpaper\Res\Lib\lwphelper.exe"

wpRain       := "C:\Users\brigi\Documents\RainWallpaper\Themes\Rain"
wpClouds     := "C:\Users\brigi\Documents\RainWallpaper\Themes\clouds"
wpRainClouds := "C:\Users\brigi\Documents\RainWallpaper\Themes\rainclouds"

; --- Load wallpapers ---
^#!Numpad1::
Run, %helper% "%wpRain%"
return

^#!Numpad2::
Run, %helper% "%wpClouds%"
return

^#!Numpad3::
Run, %helper% "%wpRainClouds%"
return

; --- Remove wallpaper (kill RainWallpaper) ---
^#!Numpad0::
Run, taskkill /IM RainWallpaper.exe /F
return
