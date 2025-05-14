@echo off
echo 📦 Building APK with Gradle...
cd android
call gradlew assembleDebug
if %errorlevel% neq 0 (
    echo ❌ Gradle build failed.
    pause
    exit /b %errorlevel%
)
cd ..

echo 📱 Installing APK to device/emulator...
adb install -r android\app\build\outputs\flutter-apk\app-debug.apk
if %errorlevel% neq 0 (
    echo ❌ ADB install failed.
) else (
    echo ✅ APK installed successfully!
)

echo 📁 Copying APK to Flutter expected path...
mkdir "build\app\outputs\flutter-apk" >nul 2>&1
xcopy /Y /I "android\app\build\outputs\flutter-apk\app-debug.apk" "build\app\outputs\flutter-apk\"

pause
