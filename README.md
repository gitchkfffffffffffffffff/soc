# Music Client (Flutter: Android + Windows), источник музыки: Audius

Ключи не нужны. Поиск, трендовые треки, плеер (пауза, перемотка).

## Сборка в облаке (без установки Flutter)
1. Создай репозиторий на GitHub, залей туда содержимое папки (включая скрытую .github).
2. Вкладка Actions -> Build -> Run workflow.
3. Через ~10 минут открой завершённый запуск, внизу в Artifacts скачай:
   - sc-client-android -> app-release.apk
   - sc-client-windows -> папка с sc_client.exe (запускать вместе со всеми файлами)

## Локально (если поставлен Flutter)
   flutter create . --platforms=android,windows --project-name sc_client
   (Android: добавь INTERNET в AndroidManifest.xml)
   flutter pub get && flutter run -d windows
