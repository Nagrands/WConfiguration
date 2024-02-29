@echo off
cls

:: Изменение кодовой страницы консоли на UTF-8
chcp 65001 > nul

:Menu
cls
echo Текущее время: %TIME%
echo.
echo             Информация о системе
echo ------------------------------------------
systeminfo | findstr /C:"System Boot Time" /C:"OS Name" /C:"OS Version" /C:"Original Install Date" /C:"System Locale" /C:"Total Physical Memory" /C:"Virtual Memory: In Use"
echo. 

for /f %%i in ('tasklist /FO CSV /NH ^| find /c /v ""') do set "processes=%%i"
echo Количество запущенных процессов: %processes%

echo.
echo.
echo             Выберите действие
echo ------------------------------------------
echo [1] Перезагрузить компьютер
echo [2] Выключить компьютер
echo.
echo [3] Информация о файле подкачки
echo [0] Выйти
echo.

choice /C 1230 /N /M "Введите номер действия: "

if errorlevel 4 goto Exit
if errorlevel 3 goto Pagefile
if errorlevel 2 goto Shutdown
if errorlevel 1 goto Reboot

timeout /t 3 > nul
goto :eof

:Reboot
echo Перезагрузка компьютера через 3 секунды...
timeout /t 3 > nul
shutdown /r /t 0 /c "Перезагрузка компьютера"
goto :eof

:Shutdown
echo Выключение компьютера через 3 секунды...
timeout /t 3 > nul
shutdown /s /t 0 /c "Выключение компьютера"
goto :eof

:Pagefile
cls
for /f %%i in ('tasklist /FO CSV /NH ^| find /c /v ""') do set "processes=%%i"
echo Количество запущенных процессов: %processes%
echo.
echo Информация о файле подкачки
echo ------------------------------------------
wmic pagefile list /format:list
echo.
echo Нажмите любую клавишу ...
pause > nul
goto Menu

:Exit
exit /b
