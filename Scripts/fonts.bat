@echo off
setlocal EnableDelayedExpansion

:: Изменение кодовой страницы консоли на UTF-8
chcp 65001 > nul

:: Проверка наличия административных прав
net session >nul 2>&1
if not %errorLevel% == 0 (
    echo Не удалось получить административные привилегии. 
    echo Запустите скрипт от имени администратора.
    pause
    exit /B 1
)

set "script_path=%~dp0"
set "font_folder=!script_path!..\Setup\Fonts"
set "font_registry=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
set "log_folder=!script_path!logs"
set "log_file=!log_folder!\fonts.log"

:: Проверка существования папок
if not exist "!log_folder!" mkdir "!log_folder!"
if not exist "!font_folder!" mkdir "!font_folder!"

:selectAction
cls
echo.
echo Выберите действие:
echo.
echo  1. Установить шрифты из "!script_path!Setup\Fonts"
echo  2. Удалить установленные шрифты
echo  3. Проверить установленные шрифты
echo.
echo  4. Открыть log-файл
echo  5. Выход
echo.

choice /C 12345 /M "Цифра действия: "
set "action=%errorlevel%"

if /i !action! == 1 (
    cls
    echo Установка всех шрифтов...
    echo.
    for %%i in ("!font_folder!\*.ttf" "!font_folder!\*.otf") do (
        set "fontPath=%%~fi"
        echo Установка "%%~nxi"...
        if exist "!SystemRoot!\Fonts\%%~nxi" (
            echo "%%~nxi" уже установлен. Пропуск...
            echo !date! !time!: [Был установлен] "%%~nxi" - Путь: !fontPath! >> "!log_file!"
        ) else (
            copy "!fontPath!" "!SystemRoot!\Fonts\"
            reg add "!font_registry!" /v "%%~nxi (TrueType)" /t REG_SZ /d "!fontPath!" /f > nul || (
                echo Не удалось добавить запись в реестр для "%%~nxi".
                exit /b 1
            )
            echo !date! !time!: [Установка] "%%~nxi" - Путь: !fontPath! >> "!log_file!"
        )
    )
    echo.
    echo Нажмите любую клавишу для продолжения...
    pause > nul
    goto :selectAction
) else if /i !action! == 2 (
    cls
    echo Удаление всех шрифтов...
    echo.
    for %%i in ("!font_folder!\*.ttf" "!font_folder!\*.otf") do (
        set "fontPath=%%~fi"
        echo Удаление "%%~nxi"...
        if exist "!SystemRoot!\Fonts\%%~nxi" (
            del "!SystemRoot!\Fonts\%%~nxi"
            reg delete "!font_registry!" /v "%%~nxi (TrueType)" /f > nul || (
                echo Не удалось удалить запись из реестра для "%%~nxi".
                exit /b 1
            )
            echo !date! !time!: [Удаление] "%%~nxi" - Путь: !fontPath! >> "!log_file!"
        ) else (
            echo "%%~nxi" не установлен. Пропуск...
            echo !date! !time!: [Не установлен] "%%~nxi" - Путь: !fontPath! >> "!log_file!"
        )
    )
    echo.
    echo Нажмите любую клавишу для продолжения...
    pause > nul
    goto :selectAction
) else if /i !action! == 3 (
    cls
    echo Проверка установленных шрифтов из "!script_path!Setup\Fonts"...
    echo.
    set "installedFonts="
    for %%i in ("!font_folder!\*.ttf" "!font_folder!\*.otf") do (
        set "fontName=%%~nxi"
        if exist "!SystemRoot!\Fonts\!fontName!" (
            set "status=[+]"
            set "installedFonts=!installedFonts! - [+] "!fontName!""
        ) else (
            set "status=[-]"
            set "installedFonts=!installedFonts! - [-] "!fontName!""
        )
        echo !status! "!fontName!"
    )

    echo.
    echo Нажмите любую клавишу для продолжения...
    pause > nul
    goto :selectAction
) else if /i !action! == 4 (
    cls
    start notepad.exe "!log_file!"
    echo.
    echo Файл лога открыт! 
    timeout /t 5 > nul
    goto :selectAction
) else if /i !action! == 5 (
    cls
    echo. 
    echo Закрытие консоли...
    timeout /t 3 > nul
    exit /B
)

:: Задержка перед закрытием batch-файла
timeout /t 3 > nul
exit /B
