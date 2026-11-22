# SC Client (Flutter: Android + Windows)

## Установка
1. Поставь Flutter SDK (https://docs.flutter.dev/get-started/install). Для Windows включи Developer Mode.
2. В папке проекта:
   flutter create . --platforms=android,windows --project-name sc_client
   (перезапишет только платформенные папки, lib/ и pubspec.yaml останутся)
3. Android: в android/app/src/main/AndroidManifest.xml добавь перед <application>:
   <uses-permission android:name="android.permission.INTERNET"/>
   И в android/app/build.gradle(.kts) поставь minSdk = 21 (или выше).
4. Получи client_id и client_secret: https://soundcloud.com/you/apps
5. Запуск:
   flutter pub get
   flutter run -d windows --dart-define=SC_CLIENT_ID=xxx --dart-define=SC_CLIENT_SECRET=yyy
   flutter run -d <android-device> --dart-define=SC_CLIENT_ID=xxx --dart-define=SC_CLIENT_SECRET=yyy

## Сборка
   flutter build windows --dart-define=SC_CLIENT_ID=xxx --dart-define=SC_CLIENT_SECRET=yyy
   flutter build apk --dart-define=SC_CLIENT_ID=xxx --dart-define=SC_CLIENT_SECRET=yyy

## Что есть
Поиск треков, список с обложками, плеер (пауза, перемотка).

## Дальше
Вход пользователя (OAuth + PKCE), лайки и плейлисты, очередь, фоновое воспроизведение (audio_service), кэш.

## Сборка в облаке (без установки Flutter)
1. Создай репозиторий на GitHub и залей туда содержимое этой папки (включая .github).
2. Settings -> Secrets and variables -> Actions -> New repository secret:
   SC_CLIENT_ID и SC_CLIENT_SECRET.
3. Вкладка Actions -> Build -> Run workflow.
4. Через ~10 минут в результатах запуска (Artifacts) скачай:
   sc-client-android (app-release.apk) и sc-client-windows (папка с sc_client.exe, запускай целиком).
"# soc" 
