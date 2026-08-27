; === Rainmeter Layout Switcher ===
; Change these to your actual layout names

taskbarLayout := "!Jiggara!ntaskbar!"
liteLayout    := "!JiggatrOn_lite"
omegaLayout   := "!JiggatrOn_omega"
lambdaLayout   := "!JiggatrOn_lambda"

; Path to Rainmeter.exe
rain := "C:\Program Files\Rainmeter\Rainmeter.exe"

; --- Hotkeys ---
+#!1::
Run, %rain% !LoadLayout "%taskbarLayout%"
return

+#!2::
Run, %rain% !LoadLayout "%liteLayout%"
return

+#!3::
Run, %rain% !LoadLayout "%omegaLayout%"
return

+#!4::
Run, %rain% !LoadLayout "%lambdaLayout%"
return
