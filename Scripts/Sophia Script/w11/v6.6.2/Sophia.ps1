<#
	.SYNOPSIS
	Default preset file for "Sophia Script for Windows 11"

	Version: v6.6.2
	Date: 06.03.2024

	Copyright (c) 2014—2024 farag
	Copyright (c) 2019—2024 farag & Inestic

	Thanks to all https://forum.ru-board.com members involved

	.DESCRIPTION
	Place the "#" char before function if you don't want to run it
	Remove the "#" char before function if you want to run it
	Every tweak in the preset file has its' corresponding function to restore the default settings

	.EXAMPLE Run the whole script
	.\Sophia.ps1

	.EXAMPLE Run the script by specifying the module functions as an argument
	.\Sophia.ps1 -Functions "DiagTrackService -Disable", "DiagnosticDataLevel -Minimal", UninstallUWPApps

	.EXAMPLE Download and expand the latest Sophia Script version archive (without running) according which Windows and PowerShell versions it is run on
	irm script.sophi.app -useb | iex

	.NOTES
	Supported Windows 11 versions
	Version: 23H2+
	Builds: 22631.3235+
	Editions: Home/Pro/Enterprise

	.NOTES
	To use the TAB completion for functions and their arguments dot source the Functions.ps1 script first:
		. .\Function.ps1 (with a dot at the beginning)
	Read more in the Functions.ps1 file

	.LINK GitHub
	https://github.com/farag2/Sophia-Script-for-Windows

	.LINK Telegram
	https://t.me/sophianews
	https://t.me/sophia_chat

	.LINK Discord
	https://discord.gg/sSryhaEv79

	.NOTES
	https://forum.ru-board.com/topic.cgi?forum=62&topic=30617#15
	https://habr.com/company/skillfactory/blog/553800/
	https://forums.mydigitallife.net/threads/powershell-windows-10-sophia-script.81675/
	https://www.reddit.com/r/PowerShell/comments/go2n5v/powershell_script_setup_windows_10/

	.LINK Authors
	https://github.com/farag2
	https://github.com/Inestic
#>

#Requires -RunAsAdministrator
#Requires -Version 5.1

[CmdletBinding()]
param
(
	[Parameter(Mandatory = $false)]
	[string[]]
	$Functions
)

Clear-Host

$Host.UI.RawUI.WindowTitle = "Sophia Script for Windows 11 v6.6.2 | Made with $([System.Char]::ConvertFromUtf32(0x1F497)) of Windows | $([System.Char]0x00A9) farag & Inestic, 2014$([System.Char]0x2013)2024"

Remove-Module -Name Sophia -Force -ErrorAction Ignore
Import-LocalizedData -BindingVariable Global:Localization -BaseDirectory $PSScriptRoot\Localizations -FileName Sophia

# Check whether script is not running via PowerShell (x86)
try
{
	Import-Module -Name $PSScriptRoot\Manifest\Sophia.psd1 -PassThru -Force -ErrorAction Stop
}
catch [System.InvalidOperationException]
{
	Write-Warning -Message $Localization.PowerShellx86Warning

	Start-Process -FilePath "https://t.me/sophia_chat"
	Start-Process -FilePath "https://discord.gg/sSryhaEv79"

	exit
}

<#
	.SYNOPSIS
	Run the script by specifying functions as an argument
	Запустить скрипт, указав в качестве аргумента функции

	.EXAMPLE
	.\Sophia.ps1 -Functions "DiagTrackService -Disable", "DiagnosticDataLevel -Minimal", UninstallUWPApps

	.NOTES
	Use commas to separate funtions
	Разделяйте функции запятыми
#>
if ($Functions)
{
	Invoke-Command -ScriptBlock {InitialActions}

	foreach ($Function in $Functions)
	{
		Invoke-Expression -Command $Function
	}

	# The "PostActions" and "Errors" functions will be executed at the end
	Invoke-Command -ScriptBlock {PostActions; Errors}

	exit
}

#region Protection
# The mandatory checks. If you want to disable a warning message about whether the preset file was customized, remove the "-Warning" argument
# Обязательные проверки. Чтобы выключить предупреждение о необходимости настройки пресет-файла, удалите аргумент "-Warning"
InitialActions -Warning

# Enable script logging. Log will be recorded into the script folder. To stop logging just close console or type "Stop-Transcript"
# Включить логирование работы скрипта. Лог будет записываться в папку скрипта. Чтобы остановить логгирование, закройте консоль или наберите "Stop-Transcript"
# Logging

# Create a restore point
# Создать точку восстановления
CreateRestorePoint
#endregion Protection

#region Privacy & Telemetry
<#
	Disable the "Connected User Experiences and Telemetry" service (DiagTrack), and block the connection for the Unified Telemetry Client Outbound Traffic
	Disabling the "Connected User Experiences and Telemetry" service (DiagTrack) can cause you not being able to get Xbox achievements anymore and affects Feedback Hub

	Отключить службу "Функциональные возможности для подключенных пользователей и телеметрия" (DiagTrack) и блокировать соединение для исходящего трафик клиента единой телеметрии
	Отключение службы "Функциональные возможности для подключенных пользователей и телеметрия" (DiagTrack) может привести к тому, что вы больше не сможете получать достижения Xbox, а также влияет на работу Feedback Hub
#>
DiagTrackService -Disable

# Enable the "Connected User Experiences and Telemetry" service (DiagTrack), and allow the connection for the Unified Telemetry Client Outbound Traffic (default value)
# Включить службу "Функциональные возможности для подключенных пользователей и телеметрия" (DiagTrack) и разрешить подключение для исходящего трафик клиента единой телеметрии (значение по умолчанию)
# DiagTrackService -Enable

# Set the diagnostic data collection to minimum
# Установить уровень сбора диагностических данных ОС на минимальный
DiagnosticDataLevel -Minimal

# Set the diagnostic data collection to default (default value)
# Установить уровень сбора диагностических данных ОС по умолчанию (значение по умолчанию)
# DiagnosticDataLevel -Default

# Turn off the Windows Error Reporting
# Отключить запись отчетов об ошибках Windows
ErrorReporting -Disable

# Turn on the Windows Error Reporting (default value)
# Включить отчеты об ошибках Windows (значение по умолчанию)
# ErrorReporting -Enable

# Change the feedback frequency to "Never"
# Изменить частоту формирования отзывов на "Никогда"
FeedbackFrequency -Never

# Change the feedback frequency to "Automatically" (default value)
# Изменить частоту формирования отзывов на "Автоматически" (значение по умолчанию)
# FeedbackFrequency -Automatically

# Turn off the diagnostics tracking scheduled tasks
# Отключить задания диагностического отслеживания
ScheduledTasks -Disable

# Turn on the diagnostics tracking scheduled tasks (default value)
# Включить задания диагностического отслеживания (значение по умолчанию)
# ScheduledTasks -Enable

# Do not use sign-in info to automatically finish setting up device after an update
# Не использовать данные для входа для автоматического завершения настройки устройства после перезапуска
SigninInfo -Disable

# Use sign-in info to automatically finish setting up device after an update (default value)
# Использовать данные для входа, чтобы автоматически завершить настройку после обновления (значение по умолчанию)
# SigninInfo -Enable

# Do not let websites provide locally relevant content by accessing language list
# Не позволять веб-сайтам предоставлять местную информацию за счет доступа к списку языков
LanguageListAccess -Disable

# Let websites provide locally relevant content by accessing language list (default value)
# Позволить веб-сайтам предоставлять местную информацию за счет доступа к списку языков (значение по умолчанию)
# LanguageListAccess -Enable

# Do not let apps show me personalized ads by using my advertising ID
# Не разрешать приложениям показывать персонализированную рекламу с помощью моего идентификатора рекламы
AdvertisingID -Disable

# Let apps show me personalized ads by using my advertising ID (default value)
# Разрешить приложениям показывать персонализированную рекламу с помощью моего идентификатора рекламы (значение по умолчанию)
# AdvertisingID -Enable

# Hide the Windows welcome experiences after updates and occasionally when I sign in to highlight what's new and suggested
# Скрывать экран приветствия Windows после обновлений и иногда при входе, чтобы сообщить о новых функциях и предложениях
WindowsWelcomeExperience -Hide

# Show the Windows welcome experiences after updates and occasionally when I sign in to highlight what's new and suggested (default value)
# Показывать экран приветствия Windows после обновлений и иногда при входе, чтобы сообщить о новых функциях и предложениях (значение по умолчанию)
# WindowsWelcomeExperience -Show

# Get tips and suggestions when I use Windows (default value)
# Получать советы и предложения при использованию Windows (значение по умолчанию)
#WindowsTips -Enable

# Do not get tips and suggestions when I use Windows
# Не получать советы и предложения при использованию Windows
# WindowsTips -Disable

# Hide from me suggested content in the Settings app
# Скрывать рекомендуемое содержимое в приложении "Параметры"
SettingsSuggestedContent -Hide

# Show me suggested content in the Settings app (default value)
# Показывать рекомендуемое содержимое в приложении "Параметры" (значение по умолчанию)
# SettingsSuggestedContent -Show

# Turn off automatic installing suggested apps
# Отключить автоматическую установку рекомендованных приложений
AppsSilentInstalling -Disable

# Turn on automatic installing suggested apps (default value)
# Включить автоматическую установку рекомендованных приложений (значение по умолчанию)
# AppsSilentInstalling -Enable

# Do not suggest ways to get the most out of Windows and finish setting up this device
# Не предлагать способы завершения настройки этого устройства для наиболее эффективного использования Windows
WhatsNewInWindows -Disable

# Suggest ways to get the most out of Windows and finish setting up this device (default value)
# Предложить способы завершения настройки этого устройства для наиболее эффективного использования Windows (значение по умолчанию)
# WhatsNewInWindows -Enable

# Don't let Microsoft use your diagnostic data for personalized tips, ads, and recommendations
# Не разрешать корпорации Майкрософт использовать диагностические данные персонализированных советов, рекламы и рекомендаций
TailoredExperiences -Disable

# Let Microsoft use your diagnostic data for personalized tips, ads, and recommendations (default value)
# Разрешить корпорации Майкрософт использовать диагностические данные для персонализированных советов, рекламы и рекомендаций (значение по умолчанию)
# TailoredExperiences -Enable

# Disable Bing search in the Start Menu
# Отключить в меню "Пуск" поиск через Bing
BingSearch -Disable

# Enable Bing search in the Start Menu (default value)
# Включить поиск через Bing в меню "Пуск" (значение по умолчанию)
# BingSearch -Enable

# Do not show websites from your browsing history in the Start menu. Windows 11 build 23451 (Dev) required
# Не показать веб-сайты из журнала браузера в меню "Пуск". Требуется Windows 11 build 23451 (Dev)
BrowsingHistory -Hide

# Show websites from your browsing history in the Start menu (default value)
# Показать веб-сайты из журнала браузера в меню "Пуск" (значение по умолчанию)
# BrowsingHistory -Show
#endregion Privacy & Telemetry

#region UI & Personalization
# Show the "This PC" icon on Desktop
# Отобразить значок "Этот компьютер" на рабочем столе
#ThisPC -Show

# Hide the "This PC" icon on Desktop (default value)
# Скрыть "Этот компьютер" на рабочем столе (значение по умолчанию)
# ThisPC -Hide

# Do not use item check boxes
# Не использовать флажки для выбора элементов
CheckBoxes -Disable

# Use check item check boxes (default value)
# Использовать флажки для выбора элементов (значение по умолчанию)
# CheckBoxes -Enable

# Show hidden files, folders, and drives
# Отобразить скрытые файлы, папки и диски
HiddenItems -Enable

# Do not show hidden files, folders, and drives (default value)
# Не показывать скрытые файлы, папки и диски (значение по умолчанию)
# HiddenItems -Disable

# Show file name extensions
# Отобразить расширения имён файлов
FileExtensions -Show

# Hide file name extensions (default value)
# Скрывать расширения имён файлов файлов (значение по умолчанию)
# FileExtensions -Hide

# Show folder merge conflicts
# Не скрывать конфликт слияния папок
MergeConflicts -Show

# Hide folder merge conflicts (default value)
# Скрывать конфликт слияния папок (значение по умолчанию)
# MergeConflicts -Hide

# Open File Explorer to "This PC"
# Открывать проводник для "Этот компьютер"
OpenFileExplorerTo -ThisPC

# Open File Explorer to Quick access (default value)
# Открывать проводник для "Быстрый доступ" (значение по умолчанию)
# OpenFileExplorerTo -QuickAccess

# Disable the File Explorer compact mode (default value)
# Отключить компактный вид проводника (значение по умолчанию)
#FileExplorerCompactMode -Disable

# Enable the File Explorer compact mode
# Включить компактный вид проводника
# FileExplorerCompactMode -Enable

# Do not show sync provider notification within File Explorer
# Не показывать уведомления поставщика синхронизации в проводнике
OneDriveFileExplorerAd -Hide

# Show sync provider notification within File Explorer (default value)
# Показывать уведомления поставщика синхронизации в проводнике (значение по умолчанию)
# OneDriveFileExplorerAd -Show

# When I snap a window, do not show what I can snap next to it
# При прикреплении окна не показывать, что можно прикрепить рядом с ним
SnapAssist -Disable

# When I snap a window, show what I can snap next to it (default value)
# При прикреплении окна показывать, что можно прикрепить рядом с ним (значение по умолчанию)
# SnapAssist -Enable

# Show the file transfer dialog box in the detailed mode
# Отображать диалоговое окно передачи файлов в развернутом виде
FileTransferDialog -Detailed

# Show the file transfer dialog box in the compact mode (default value)
# Отображать диалоговое окно передачи файлов в свернутом виде (значение по умолчанию)
# FileTransferDialog -Compact

# Display the recycle bin files delete confirmation dialog
# Запрашивать подтверждение на удаление файлов в корзину
RecycleBinDeleteConfirmation -Enable

# Do not display the recycle bin files delete confirmation dialog (default value)
# Не запрашивать подтверждение на удаление файлов в корзину (значение по умолчанию)
# RecycleBinDeleteConfirmation -Disable

# Hide recently used files in Quick access
# Скрыть недавно использовавшиеся файлы на панели быстрого доступа
QuickAccessRecentFiles -Hide

# Show recently used files in Quick access (default value)
# Показать недавно использовавшиеся файлы на панели быстрого доступа (значение по умолчанию)
# QuickAccessRecentFiles -Show

# Hide frequently used folders in Quick access
# Скрыть недавно используемые папки на панели быстрого доступа
QuickAccessFrequentFolders -Hide

# Show frequently used folders in Quick access (default value)
# Показать часто используемые папки на панели быстрого доступа (значение по умолчанию)
# QuickAccessFrequentFolders -Show

# Set the taskbar alignment to the center (default value)
# Установить выравнивание панели задач по центру (значение по умолчанию)
#TaskbarAlignment -Center

# Set the taskbar alignment to the left
# Установить выравнивание панели задач по левому краю
# TaskbarAlignment -Left

# Hide the widgets icon on the taskbar
# Скрыть кнопку "Мини-приложения" с панели задач
TaskbarWidgets -Hide

# Show the widgets icon on the taskbar (default value)
# Отобразить кнопку "Мини-приложения" на панели задач (значение по умолчанию)
# TaskbarWidgets -Show

# Hide the search on the taskbar
# Скрыть поле или значок поиска на панели задач
TaskbarSearch -Hide

# Show the search icon on the taskbar
# Показать значок поиска на панели задач
# TaskbarSearch -SearchIcon

# Show the search icon and label on the taskbar
# Показать значок и метку поиска на панели задач
# TaskbarSearch -SearchIconLabel

# Show the search box on the taskbar (default value)
# Показать поле поиска на панели задач (значение по умолчанию)
# TaskbarSearch -SearchBox

# Hide search highlights
# Скрыть главное в поиске
SearchHighlights -Hide

# Show search highlights (default value)
# Показать главное в поиске (значение по умолчанию)
# SearchHighlights -Show

# Hide Copilot button on the taskbar
# Скрыть кнопку Copilot с панели задач
CopilotButton -Hide

# Show Copilot button on the taskbar (default value)
# Отобразить кнопку Copilot на панели задач (значение по умолчанию)
# CopilotButton -Show

# Hide the Task view button from the taskbar
# Скрыть кнопку "Представление задач" с панели задач
TaskViewButton -Hide

# Show the Task view button on the taskbar (default value)
# Отобразить кнопку "Представление задач" на панели задач (значение по умолчанию)
# TaskViewButton -Show

# Hide the Chat icon (Microsoft Teams) on the taskbar and prevent Microsoft Teams from installing for new users
# Скрыть кнопку чата (Microsoft Teams) с панели задач и запретить установку Microsoft Teams для новых пользователей
PreventTeamsInstallation -Enable

# Show the Chat icon (Microsoft Teams) on the taskbar and remove block from installing Microsoft Teams for new users (default value)
# Отобразить кнопку чата (Microsoft Teams) на панели задач и убрать блокировку на устанвоку Microsoft Teams для новых пользователей (значение по умолчанию)
# PreventTeamsInstallation -Disable

# Show seconds on the taskbar clock
# Показывать секунды на часах на панели задач
#SecondsInSystemClock -Show

# Hide seconds on the taskbar clock (default value)
# Скрыть секунды на часах на панели задач (значение по умолчанию)
# SecondsInSystemClock -Hide

# Combine taskbar buttons and always hide labels (default value)
# Объединить кнопки панели задач и всегда скрывать метки (значение по умолчанию)
#TaskbarCombine -Always

# Combine taskbar buttons and hide labels when taskbar is full
# Объединить кнопки панели задач и скрывать метки при переполнении панели задач
# TaskbarCombine -Full

# Combine taskbar buttons and never hide labels
# Объединить кнопки панели задач и никогда не скрывать метки
# TaskbarCombine -Never

# Unpin the "Microsoft Edge", "Microsoft Store" shortcuts from the taskbar
# Открепить ярлыки "Microsoft Edge", "Microsoft Store" от панели задач
UnpinTaskbarShortcuts -Shortcuts Edge, Store

# View the Control Panel icons by large icons
# Просмотр иконок Панели управления как: крупные значки
#ControlPanelView -LargeIcons

# View the Control Panel icons by small icons
# Просмотр иконок Панели управления как: маленькие значки
ControlPanelView -SmallIcons

# View the Control Panel icons by category (default value)
# Просмотр иконок Панели управления как: категория (значение по умолчанию)
# ControlPanelView -Category

# Set the default Windows mode to dark
# Установить режим Windows по умолчанию на темный
#WindowsColorMode -Dark

# Set the default Windows mode to light (default value)
# Установить режим Windows по умолчанию на светлый (значение по умолчанию)
# WindowsColorMode -Light

# Set the default app mode to dark
# Установить цвет режима приложения на темный
#AppColorMode -Dark

# Set the default app mode to light (default value)
# Установить цвет режима приложения на светлый (значение по умолчанию)
# AppColorMode -Light

# Hide first sign-in animation after the upgrade
# Скрывать анимацию при первом входе в систему после обновления
FirstLogonAnimation -Disable

# Show first sign-in animation after the upgrade (default value)
# Показывать анимацию при первом входе в систему после обновления (значение по умолчанию)
# FirstLogonAnimation -Enable

# Set the quality factor of the JPEG desktop wallpapers to maximum
# Установить коэффициент качества обоев рабочего стола в формате JPEG на максимальный
JPEGWallpapersQuality -Max

# Set the quality factor of the JPEG desktop wallpapers to default
# Установить коэффициент качества обоев рабочего стола в формате JPEG по умолчанию
# JPEGWallpapersQuality -Default

# Do not add the "- Shortcut" suffix to the file name of created shortcuts
# Нe дoбaвлять "- яpлык" к имени coздaвaeмых яpлыков
ShortcutsSuffix -Disable

# Add the "- Shortcut" suffix to the file name of created shortcuts (default value)
# Дoбaвлять "- яpлык" к имени coздaвaeмых яpлыков (значение по умолчанию)
# ShortcutsSuffix -Enable

# Use the Print screen button to open screen snipping
# Использовать кнопку PRINT SCREEN, чтобы запустить функцию создания фрагмента экрана
PrtScnSnippingTool -Enable

# Do not use the Print screen button to open screen snipping (default value)
# Не использовать кнопку PRINT SCREEN, чтобы запустить функцию создания фрагмента экрана (значение по умолчанию)
# PrtScnSnippingTool -Disable

# Let me use a different input method for each app window
# Позволить выбирать метод ввода для каждого окна
AppsLanguageSwitch -Enable

# Do not use a different input method for each app window (default value)
# Не использовать метод ввода для каждого окна (значение по умолчанию)
# AppsLanguageSwitch -Disable

# When I grab a windows's title bar and shake it, minimize all other windows
# При захвате заголовка окна и встряхивании сворачиваются все остальные окна
#AeroShaking -Enable

# When I grab a windows's title bar and shake it, don't minimize all other windows (default value)
# При захвате заголовка окна и встряхивании не сворачиваются все остальные окна (значение по умолчанию)
# AeroShaking -Disable

# Download and install free dark "Windows 11 Cursors Concept v2" cursors from Jepri Creations
# Скачать и установить бесплатные темные курсоры "Windows 11 Cursors Concept v2" от Jepri Creations
#Cursors -Dark

# Download and install free light "Windows 11 Cursors Concept v2" cursors from Jepri Creations
# Скачать и установить бесплатные светлые курсоры "Windows 11 Cursors Concept v2" от Jepri Creations
# Cursors -Light

# Set default cursors
# Установить курсоры по умолчанию
# Cursors -Default

# Do not group files and folder in the Downloads folder
# Не группировать файлы и папки в папке Загрузки
#FolderGroupBy -None

# Group files and folder by date modified in the Downloads folder (default value)
# Группировать файлы и папки по дате изменения (значение по умолчанию)
# FolderGroupBy -Default

# Do not expand to open folder on navigation pane (default value)
# Не разворачивать до открытой папки область навигации (значение по умолчанию)
#NavigationPaneExpand -Disable

# Expand to open folder on navigation pane
# Развернуть до открытой папки область навигации
# NavigationPaneExpand -Enable
#endregion UI & Personalization

#region OneDrive
# Uninstall OneDrive. The OneDrive user folder won't be removed
# Удалить OneDrive. Папка пользователя OneDrive не будет удалена
OneDrive -Uninstall

# Install OneDrive 64-bit (default value)
# Установить OneDrive 64-бит (значение по умолчанию)
# OneDrive -Install

# Install OneDrive 64-bit all users to %ProgramFiles% depending which installer is triggered
# Установить OneDrive 64-бит для всех пользователей в %ProgramFiles% в зависимости от от того, как запускается инсталлятор
# OneDrive -Install -AllUsers
#endregion OneDrive

#region System
#region StorageSense
# Turn on Storage Sense
# Включить Контроль памяти
StorageSense -Enable

# Turn off Storage Sense (default value)
# Выключить Контроль памяти (значение по умолчанию)
# StorageSense -Disable

# Run Storage Sense every month
# Запускать Контроль памяти каждый месяц
StorageSenseFrequency -Month

# Run Storage Sense during low free disk space (default value)
# Запускать Контроль памяти, когда остается мало место на диске (значение по умолчанию)
# StorageSenseFrequency -Default

# Turn on automatic cleaning up temporary system and app files (default value)
# Автоматически очищать временные файлы системы и приложений (значение по умолчанию)
StorageSenseTempFiles -Enable

# Turn off automatic cleaning up temporary system and app files
# Не очищать временные файлы системы и приложений
# StorageSenseTempFiles -Disable
#endregion StorageSense

# Disable hibernation. It isn't recommended to turn off for laptops
# Отключить режим гибернации. Не рекомендуется выключать на ноутбуках
Hibernation -Disable

# Enable hibernate (default value)
# Включить режим гибернации (значение по умолчанию)
# Hibernation -Enable

# Change the %TEMP% environment variable path to %SystemDrive%\Temp
# Изменить путь переменной среды для %TEMP% на %SystemDrive%\Temp
# TempFolder -SystemDrive

# Change %TEMP% environment variable path to %LOCALAPPDATA%\Temp (default value)
# Изменить путь переменной среды для %TEMP% на %LOCALAPPDATA%\Temp (значение по умолчанию)
# TempFolder -Default

# Disable the Windows 260 characters path limit
# Отключить ограничение Windows на 260 символов в пути
Win32LongPathLimit -Disable

# Enable the Windows 260 character path limit (default value)
# Включить ограничение Windows на 260 символов в пути (значение по умолчанию)
# Win32LongPathLimit -Enable

# Display Stop error code when BSoD occurs
# Отображать код Stop-ошибки при появлении BSoD
BSoDStopError -Enable

# Do not Stop error code when BSoD occurs (default value)
# Не отображать код Stop-ошибки при появлении BSoD (значение по умолчанию)
# BSoDStopError -Disable

# Choose when to be notified about changes to your computer: never notify
# Настройка уведомления об изменении параметров компьютера: никогда не уведомлять
AdminApprovalMode -Never

# Choose when to be notified about changes to your computer: notify me only when apps try to make changes to my computer (default value)
# Настройка уведомления об изменении параметров компьютера: уведомлять меня только при попытках приложений внести изменения в компьютер (значение по умолчанию)
# AdminApprovalMode -Default

# Turn on access to mapped drives from app running with elevated permissions with Admin Approval Mode enabled
# Включить доступ к сетевым дискам при включенном режиме одобрения администратором при доступе из программ, запущенных с повышенными правами
#MappedDrivesAppElevatedAccess -Enable

# Turn off access to mapped drives from app running with elevated permissions with Admin Approval Mode enabled (default value)
# Выключить доступ к сетевым дискам при включенном режиме одобрения администратором при доступе из программ, запущенных с повышенными правами (значение по умолчанию)
# MappedDrivesAppElevatedAccess -Disable

# Turn off Delivery Optimization
# Выключить оптимизацию доставки
DeliveryOptimization -Disable

# Turn on Delivery Optimization (default value)
# Включить оптимизацию доставки (значение по умолчанию)
# DeliveryOptimization -Enable

# Do not let Windows manage my default printer
# Не разрешать Windows управлять принтером, используемым по умолчанию
WindowsManageDefaultPrinter -Disable

# Let Windows manage my default printer (default value)
# Разрешать Windows управлять принтером, используемым по умолчанию (значение по умолчанию)
# WindowsManageDefaultPrinter -Enable

<#
	Disable the Windows features using the pop-up dialog box
	If you want to leave "Multimedia settings" element in the advanced settings of Power Options do not disable the "Media Features" feature

	Если вы хотите оставить параметр "Параметры мультимедиа" в дополнительных параметрах схемы управления питанием, не отключайте "Компоненты для работы с медиа"
	Отключить компоненты Windows, используя всплывающее диалоговое окно
#>
WindowsFeatures -Disable

# Enable the Windows features using the pop-up dialog box
# Включить компоненты Windows, используя всплывающее диалоговое окно
# WindowsFeatures -Enable

<#
	Uninstall optional features using the pop-up dialog box
	If you want to leave "Multimedia settings" element in the advanced settings of Power Options do not uninstall the "Media Features" feature

	Удалить дополнительные компоненты, используя всплывающее диалоговое окно
	Если вы хотите оставить параметр "Параметры мультимедиа" в дополнительных параметрах схемы управления питанием, не удаляйте компонент "Компоненты для работы с медиа"
#>
WindowsCapabilities -Uninstall

# Install optional features using the pop-up dialog box
# Установить дополнительные компоненты, используя всплывающее диалоговое окно
# WindowsCapabilities -Install

# Receive updates for other Microsoft products
# Получать обновления для других продуктов Майкрософт
#UpdateMicrosoftProducts -Enable

# Do not receive updates for other Microsoft products (default value)
# Не получать обновления для других продуктов Майкрософт (значение по умолчанию)
# UpdateMicrosoftProducts -Disable

# Set power plan on "High performance". It isn't recommended to turn on for laptops
# Установить схему управления питанием на "Высокая производительность". Не рекомендуется включать на ноутбуках
PowerPlan -High

# Set power plan on "Balanced" (default value)
# Установить схему управления питанием на "Сбалансированная" (значение по умолчанию)
# PowerPlan -Balanced

# Do not allow the computer to turn off the network adapters to save power. It isn't recommended to turn off for laptops
# Запретить отключение всех сетевых адаптеров для экономии энергии. Не рекомендуется выключать на ноутбуках
NetworkAdaptersSavePower -Disable

# Allow the computer to turn off the network adapters to save power (default value)
# Разрешить отключение всех сетевых адаптеров для экономии энергии (значение по умолчанию)
# NetworkAdaptersSavePower -Enable

<#
	Disable the Internet Protocol Version 6 (TCP/IPv6) component for all network connections
	Before invoking the function, a check will be run whether your ISP supports the IPv6 protocol using https://ipify.org

	Выключить IP версии 6 (TCP/IPv6)
	Перед выполнением функции будет проведена проверка: поддерживает ли ваш провайдер IPv6, используя ресурс https://ipify.org
#>
IPv6Component -Disable

<#
	Enable the Internet Protocol Version 6 (TCP/IPv6) component for all network connections (default value)
	Before invoking the function, a check will be run whether your ISP supports the IPv6 protocol using https://ipify.org

	Включить IP версии 6 (TCP/IPv6) (значение по умолчанию)
	Перед выполнением функции будет проведена проверка: поддерживает ли ваш провайдер IPv6, используя ресурс https://ipify.org
#>
# IPv6Component -Enable

<#
	Enable the Internet Protocol Version 6 (TCP/IPv6) component for all network connections. Prefer IPv4 over IPv6
	Before invoking the function, a check will be run whether your ISP supports the IPv6 protocol using https://ipify.org

	Включить IP версии 6 (TCP/IPv6) и предпочитать. Предпочтение IPv4 перед IPv6
	Перед выполнением функции будет проведена проверка: поддерживает ли ваш провайдер IPv6, используя ресурс https://ipify.org
#>
# IPv6Component -PreferIPv4overIPv6

# Override for default input method: English
# Переопределить метод ввода по умолчанию: английский
InputMethod -English

# Override for default input method: use language list (default value)
# Переопределить метод ввода по умолчанию: использовать список языков (значение по умолчанию)
# InputMethod -Default

<#
	Change user folders location to the root of any drive using the interactive menu
	User files or folders won't me moved to a new location. Move them manually
	They're located in the %USERPROFILE% folder by default

	Переместить пользовательские папки в корень любого диска на выбор с помощью интерактивного меню
	Пользовательские файлы и папки не будут перемещены в новое расположение. Переместите их вручную
	По умолчанию они располагаются в папке %USERPROFILE%
#>
#Set-UserShellFolderLocation -Root

<#
	Select folders for user folders location manually using a folder browser dialog
	User files or folders won't me moved to a new location. Move them manually
	They're located in the %USERPROFILE% folder by default

	Выбрать папки для расположения пользовательских папок вручную, используя диалог "Обзор папок"
	Пользовательские файлы и папки не будут перемещены в новое расположение. Переместите их вручную
	По умолчанию они располагаются в папке %USERPROFILE%
#>
# Set-UserShellFolderLocation -Custom

<#
	Change user folders location to the default values
	User files or folders won't me moved to the new location. Move them manually
	They're located in the %USERPROFILE% folder by default

	Изменить расположение пользовательских папок на значения по умолчанию
	Пользовательские файлы и папки не будут перемещены в новое расположение. Переместите их вручную
	По умолчанию они располагаются в папке %USERPROFILE%
#>
# Set-UserShellFolderLocation -Default

# Use the latest installed .NET runtime for all apps
# Использовать последнюю установленную среду выполнения .NET для всех приложений
LatestInstalled.NET -Enable

# Do not use the latest installed .NET runtime for all apps (default value)
# Не использовать последнюю установленную версию .NET для всех приложений (значение по умолчанию)
# LatestInstalled.NET -Disable

<#
	Save screenshots by pressing Win+PrtScr on the Desktop
	The function will be applied only if the preset is configured to remove the OneDrive application, or the app was already uninstalled
	Otherwise the backup functionality for the "Desktop" and "Pictures" folders in OneDrive breaks

	Сохранять скриншоты по нажатию Win+PrtScr на рабочий столе
	Функция будет применена только в случае, если в пресете настроено удаление приложения OneDrive или приложение уже удалено,
	иначе в OneDrive ломается функционал резервного копирования для папок "Рабочий стол" и "Изображения"
#>
WinPrtScrFolder -Desktop

# Save screenshots by pressing Win+PrtScr in the Pictures folder (default value)
# Cохранять скриншоты по нажатию Win+PrtScr в папку "Изображения" (значение по умолчанию)
# WinPrtScrFolder -Default

<#
	Run troubleshooter automatically, then notify me
	In order this feature to work Windows level of diagnostic data gathering will be set to "Optional diagnostic data", and the error reporting feature will be turned on

	Автоматически запускать средства устранения неполадок, а затем уведомлять
	Чтобы заработала данная функция, уровень сбора диагностических данных ОС будет установлен на "Необязательные диагностические данные" и включится создание отчетов об ошибках Windows
#>
#RecommendedTroubleshooting -Automatically

<#
	Ask me before running troubleshooter (default value)
	In order this feature to work Windows level of diagnostic data gathering will be set to "Optional diagnostic data"

	Спрашивать перед запуском средств устранения неполадок (значение по умолчанию)
	Чтобы заработала данная функция, уровень сбора диагностических данных ОС будет установлен на "Необязательные диагностические данные" и включится создание отчетов об ошибках Windows
#>
# RecommendedTroubleshooting -Default

# Launch folder windows in a separate process
# Запускать окна с папками в отдельном процессе
#FoldersLaunchSeparateProcess -Enable

# Do not launch folder windows in a separate process (default value)
# Не запускать окна с папками в отдельном процессе (значение по умолчанию)
# FoldersLaunchSeparateProcess -Disable

# Disable and delete reserved storage after the next update installation
# Отключить и удалить зарезервированное хранилище после следующей установки обновлений
ReservedStorage -Disable

# Enable reserved storage (default value)
# Включить зарезервированное хранилище (значение по умолчанию)
# ReservedStorage -Enable

# Disable help lookup via F1
# Отключить открытие справки по нажатию F1
F1HelpPage -Disable

# Enable help lookup via F1 (default value)
# Включить открытие справки по нажатию F1 (значение по умолчанию)
# F1HelpPage -Enable

# Enable Num Lock at startup
# Включить Num Lock при загрузке
#NumLock -Enable

# Disable Num Lock at startup (default value)
# Выключить Num Lock при загрузке (значение по умолчанию)
# NumLock -Disable

# Disable Caps Lock
# Выключить Caps Lock
# CapsLock -Disable

# Enable Caps Lock (default value)
# Включить Caps Lock (значение по умолчанию)
# CapsLock -Enable

# Turn off pressing the Shift key 5 times to turn Sticky keys
# Выключить залипание клавиши Shift после 5 нажатий
StickyShift -Disable

# Turn on pressing the Shift key 5 times to turn Sticky keys (default value)
# Включить залипание клавиши Shift после 5 нажатий (значение по умолчанию)
# StickyShift -Enable

# Don't use AutoPlay for all media and devices
# Не использовать автозапуск для всех носителей и устройств
#Autoplay -Disable

# Use AutoPlay for all media and devices (default value)
# Использовать автозапуск для всех носителей и устройств (значение по умолчанию)
# Autoplay -Enable

# Disable thumbnail cache removal
# Отключить удаление кэша миниатюр
ThumbnailCacheRemoval -Disable

# Enable thumbnail cache removal (default value)
# Включить удаление кэша миниатюр (значение по умолчанию)
# ThumbnailCacheRemoval -Enable

# Automatically saving my restartable apps and restart them when I sign back in
# Автоматически сохранять мои перезапускаемые приложения из системы и перезапускать их при повторном входе
#SaveRestartableApps -Enable

# Turn off automatically saving my restartable apps and restart them when I sign back in (default value)
# Выключить автоматическое сохранение моих перезапускаемых приложений из системы и перезапускать их при повторном входе (значение по умолчанию)
# SaveRestartableApps -Disable

# Enable "Network Discovery" and "File and Printers Sharing" for workgroup networks
# Включить сетевое обнаружение и общий доступ к файлам и принтерам для рабочих групп
#NetworkDiscovery -Enable

# Disable "Network Discovery" and "File and Printers Sharing" for workgroup networks (default value)
# Выключить сетевое обнаружение и общий доступ к файлам и принтерам для рабочих групп (значение по умолчанию)
# NetworkDiscovery -Disable

# Notify me when a restart is required to finish updating
# Уведомлять меня о необходимости перезагрузки для завершения обновления
RestartNotification -Show

# Do not notify me when a restart is required to finish updating (default value)
# Не yведомлять меня о необходимости перезагрузки для завершения обновления (значение по умолчанию)
# RestartNotification -Hide

# Restart as soon as possible to finish updating
# Перезапустить устройство как можно быстрее, чтобы завершить обновление
#RestartDeviceAfterUpdate -Enable

# Don't restart as soon as possible to finish updating (default value)
# Не перезапускать устройство как можно быстрее, чтобы завершить обновление (значение по умолчанию)
# RestartDeviceAfterUpdate -Disable

# Automatically adjust active hours for me based on daily usage
# Автоматически изменять период активности для этого устройства на основе действий
#ActiveHours -Automatically

# Manually adjust active hours for me based on daily usage (default value)
# Вручную изменять период активности для этого устройства на основе действий (значение по умолчанию)
# ActiveHours -Manually

# Do not get the latest updates as soon as they're available (default value)
# Не получать последние обновления, как только они будут доступны (значение по умолчанию)
#WindowsLatestUpdate -Disable

# Get the latest updates as soon as they're available
# Получайте последние обновления, как только они будут доступны
# WindowsLatestUpdate -Enable

<#
	Register app, calculate hash, and associate with an extension with the "How do you want to open this" pop-up hidden
	Зарегистрировать приложение, вычислить хэш и ассоциировать его с расширением без всплывающего окна "Каким образом вы хотите открыть этот файл?"

	Set-Association -ProgramPath "C:\SumatraPDF.exe" -Extension .pdf -Icon "shell32.dll,100"
	Set-Association -ProgramPath "%ProgramFiles%\Notepad++\notepad++.exe" -Extension .txt -Icon "%ProgramFiles%\Notepad++\notepad++.exe,0"
	Set-Association -ProgramPath MSEdgeMHT -Extension .html
#>
# Set-Association -ProgramPath "%ProgramFiles%\Notepad++\notepad++.exe" -Extension .txt -Icon "%ProgramFiles%\Notepad++\notepad++.exe,0"

# Экспортировать все ассоциации в Windows в корень папки в виде файла Application_Associations.json
# Export all Windows associations into Application_Associations.json file to script root folder
# Export-Associations

<#
	Импортировать все ассоциации в Windows из файла Application_Associations.json
	Вам необходимо установить все приложения согласно экспортированному файлу Application_Associations.json, чтобы восстановить все ассоциации

	Import all Windows associations from an Application_Associations.json file
	You need to install all apps according to an exported Application_Associations.json file to restore all associations
#>
# Import-Associations

# Set Windows Terminal as default terminal app to host the user interface for command-line applications
# Установить Windows Terminal как приложение терминала по умолчанию для размещения пользовательского интерфейса для приложений командной строки
DefaultTerminalApp -WindowsTerminal

# Set Windows Console Host as default terminal app to host the user interface for command-line applications (default value)
# Установить Windows Console Host как приложение терминала по умолчанию для размещения пользовательского интерфейса для приложений командной строки (значение по умолчанию)
# DefaultTerminalApp -ConsoleHost

<#
	Install the latest Microsoft Visual C++ Redistributable Packages 2015–2022 (x86/x64)
	Установить последнюю версию распространяемых пакетов Microsoft Visual C++ 2015–2022 (x86/x64)

	https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist
#>
InstallVCRedist

<#
	Install the latest .NET Desktop Runtime 6, 7, 8 x64
	Установить последнюю версию .NET Desktop Runtime 6, 7, 8 x64

	https://dotnet.microsoft.com/en-us/download/dotnet
#>
InstallDotNetRuntimes -Runtimes NET6x64, NET7x64, NET8x64

# Enable proxying only blocked sites from the unified registry of Roskomnadzor. The function is applicable for Russia only
# Включить проксирование только заблокированных сайтов из единого реестра Роскомнадзора. Функция применима только для России
# https://antizapret.prostovpn.org
#RKNBypass -Enable

# Disable proxying only blocked sites from the unified registry of Roskomnadzor (default value)
# Выключить проксирование только заблокированных сайтов из единого реестра Роскомнадзора (значение по умолчанию)
# https://antizapret.prostovpn.org
# RKNBypass -Disable

# Enable all necessary dependencies (reboot may require) and open Microsoft Store WSA page to install Windows Subsystem for Android™ with Amazon Appstore manually
# Включить все необходимые зависимости (может потребоваться перезагрузка) и открыть страницу WSA в Microsoft Store, чтобы вручную установить Windows Subsystem for Android™ with Amazon Appstore
# Install-WSA

# List Microsoft Edge channels to prevent desktop shortcut creation upon its' update
# Перечислите каналы Microsoft Edge для предотвращения создания ярлыков на рабочем столе после его обновления
PreventEdgeShortcutCreation -Channels Stable, Beta, Dev, Canary

# Do not prevent desktop shortcut creation upon Microsoft Edge update (default value)
# Не предотвращать создание ярлыков на рабочем столе при обновлении Microsoft Edge (значение по умолчанию)
# PreventEdgeShortcutCreation -Disable

# Prevent all internal SATA drives from showing up as removable media in the taskbar notification area
# Запретить отображать все внутренние SATA-диски как съемные носители в области уведомлений на панели задач
SATADrivesRemovableMedia -Disable

# Show up all internal SATA drives as removeable media in the taskbar notification area (default value)
# Отображать все внутренние SATA-диски как съемные носители в области уведомлений на панели задач (значение по умолчанию)
# SATADrivesRemovableMedia -Default

# Back up the system registry to %SystemRoot%\System32\config\RegBack folder when PC restarts and create a RegIdleBackup in the Task Scheduler task to manage subsequent backups
# Создавать копии реестра при перезагрузки ПК и создавать задание RegIdleBackup в Планировщике задания для управления последующими резервными копиями
# RegistryBackup -Enable

# Do not back up the system registry to %SystemRoot%\System32\config\RegBack folder (default value)
# Не создавать копии реестра при перезагрузки ПК (значение по умолчанию)
# RegistryBackup -Disable
#endregion System

#region WSL
<#
	Enable Windows Subsystem for Linux (WSL), install the latest WSL Linux kernel version, and a Linux distribution using a pop-up form
	The "Receive updates for other Microsoft products" setting will enabled automatically to receive kernel updates

	Установить подсистему Windows для Linux (WSL), последний пакет обновления ядра Linux и дистрибутив Linux, используя всплывающую форму
	Параметр "При обновлении Windows получать обновления для других продуктов Майкрософт" будет включен автоматически в Центре обновлении Windows, чтобы получать обновления ядра
#>
# Install-WSL
#endregion WSL

#region Start menu
# Unpin all Start apps
# Открепить все приложения от начального экрана
# UnpinAllStartApps

# Show default Start layout (default value)
# Отображать стандартный макет начального экрана (значение по умолчанию)
# StartLayout -Default

# Show more pins on Start
# Отображать больше закреплений на начальном экране
StartLayout -ShowMorePins

# Show more recommendations on Start
# Отображать больше рекомендаций на начальном экране
# StartLayout -ShowMoreRecommendations
#endregion Start menu

#region UWP apps
<#
	Uninstall UWP apps using the pop-up dialog box
	If the "For All Users" is checked apps packages will not be installed for new users
	The "ForAllUsers" argument sets a checkbox to unistall packages for all users

	Удалить UWP-приложения, используя всплывающее диалоговое окно
	Пакеты приложений не будут установлены для новых пользователей, если отмечена галочка "Для всех пользователей"
	Аргумент "ForAllUsers" устанавливает галочку для удаления пакетов для всех пользователей
#>
UninstallUWPApps

<#
	Restore the default UWP apps using the pop-up dialog box
	UWP apps can be restored only if they were uninstalled only for the current user

	Восстановить стандартные UWP-приложения, используя всплывающее диалоговое окно
	UWP-приложения могут быть восстановлены, только если они были удалены для текущего пользователя
#>
# RestoreUWPApps

# Disable Cortana autostarting
# Выключить автозагрузку Кортана
CortanaAutostart -Disable

# Enable Cortana autostarting (default value)
# Включить автозагрузку Кортана (значение по умолчанию)
# CortanaAutostart -Enable

# Disable Microsoft Teams autostarting
# Выключить автозагрузку Microsoft Teams
TeamsAutostart -Disable

# Enable Microsoft Teams autostarting (default value)
# Включить автозагрузку Microsoft Teams (значение по умолчанию)
# TeamsAutostart -Enable
#endregion UWP apps

#region Gaming
<#
	Disable Xbox Game Bar
	To prevent popping up the "You'll need a new app to open this ms-gamingoverlay" warning, you need to disable the Xbox Game Bar app, even if you uninstalled it before

	Отключить Xbox Game Bar
	Чтобы предотвратить появление предупреждения "Вам понадобится новое приложение, чтобы открыть этот ms-gamingoverlay", вам необходимо отключить приложение Xbox Game Bar, даже если вы удалили его раньше
#>
XboxGameBar -Disable

# Enable Xbox Game Bar (default value)
# Включить Xbox Game Bar (значение по умолчанию)
# XboxGameBar -Enable

# Disable Xbox Game Bar tips
# Отключить советы Xbox Game Bar
XboxGameTips -Disable

# Enable Xbox Game Bar tips (default value)
# Включить советы Xbox Game Bar (значение по умолчанию)
# XboxGameTips -Enable

# Choose an app and set the "High performance" graphics performance for it. Only if you have a dedicated GPU
# Выбрать приложение и установить для него параметры производительности графики на "Высокая производительность". Только при наличии внешней видеокарты
#Set-AppGraphicsPerformance

<#
	Turn on hardware-accelerated GPU scheduling. Restart needed
	Only if you have a dedicated GPU and WDDM verion is 2.7 or higher

	Включить планирование графического процессора с аппаратным ускорением. Необходима перезагрузка
	Только при наличии внешней видеокарты и WDDM версии 2.7 и выше
#>
GPUScheduling -Enable

# Turn off hardware-accelerated GPU scheduling (default value). Restart needed
# Выключить планирование графического процессора с аппаратным ускорением (значение по умолчанию). Необходима перезагрузка
# GPUScheduling -Disable
#endregion Gaming

#region Scheduled tasks
<#
	Create the "Windows Cleanup" scheduled task for cleaning up Windows unused files and updates.
	A native interactive toast notification pops up every 30 days. You have to enable Windows Script Host in order to make the function work

	Создать задание "Windows Cleanup" по очистке неиспользуемых файлов и обновлений Windows в Планировщике заданий.
	Задание выполняется каждые 30 дней. Необходимо включить Windows Script Host для того, чтобы работала функция
#>
#CleanupTask -Register

# Delete the "Windows Cleanup" and "Windows Cleanup Notification" scheduled tasks for cleaning up Windows unused files and updates
# Удалить задания "Windows Cleanup" и "Windows Cleanup Notification" по очистке неиспользуемых файлов и обновлений Windows из Планировщика заданий
# CleanupTask -Delete

<#
	Create the "SoftwareDistribution" scheduled task for cleaning up the %SystemRoot%\SoftwareDistribution\Download folder
	The task will wait until the Windows Updates service finishes running. The task runs every 90 days. You have to enable Windows Script Host in order to make the function work

	Создать задание "SoftwareDistribution" по очистке папки %SystemRoot%\SoftwareDistribution\Download в Планировщике заданий
	Задание будет ждать, пока служба обновлений Windows не закончит работу. Задание выполняется каждые 90 дней. Необходимо включить Windows Script Host для того, чтобы работала функция
#>
#SoftwareDistributionTask -Register

# Delete the "SoftwareDistribution" scheduled task for cleaning up the %SystemRoot%\SoftwareDistribution\Download folder
# Удалить задание "SoftwareDistribution" по очистке папки %SystemRoot%\SoftwareDistribution\Download из Планировщика заданий
# SoftwareDistributionTask -Delete

<#
	Create the "Temp" scheduled task for cleaning up the %TEMP% folder
	Only files older than one day will be deleted. The task runs every 60 days. You have to enable Windows Script Host in order to make the function work

	Создать задание "Temp" в Планировщике заданий по очистке папки %TEMP%
	Удаляться будут только файлы старше одного дня. Задание выполняется каждые 60 дней. Необходимо включить Windows Script Host для того, чтобы работала функция
#>
#TempTask -Register

# Delete the "Temp" scheduled task for cleaning up the %TEMP% folder
# Удалить задание "Temp" по очистке папки %TEMP% из Планировщика заданий
# TempTask -Delete
#endregion Scheduled tasks

#region Microsoft Defender & Security
# Enable Microsoft Defender Exploit Guard network protection
# Включить защиту сети в Microsoft Defender Exploit Guard
#NetworkProtection -Enable

# Disable Microsoft Defender Exploit Guard network protection (default value)
# Выключить защиту сети в Microsoft Defender Exploit Guard (значение по умолчанию)
# NetworkProtection -Disable

# Enable detection for potentially unwanted applications and block them
# Включить обнаружение потенциально нежелательных приложений и блокировать их
#PUAppsDetection -Enable

# Disable detection for potentially unwanted applications and block them (default value)
# Выключить обнаружение потенциально нежелательных приложений и блокировать их (значение по умолчанию)
# PUAppsDetection -Disable

# Dismiss Microsoft Defender offer in the Windows Security about signing in Microsoft account
# Отклонить предложение Microsoft Defender в "Безопасность Windows" о входе в аккаунт Microsoft
DismissMSAccount

# Dismiss Microsoft Defender offer in the Windows Security about turning on the SmartScreen filter for Microsoft Edge
# Отклонить предложение Microsoft Defender в "Безопасность Windows" включить фильтр SmartScreen для Microsoft Edge
DismissSmartScreenFilter

# Enable events auditing generated when a process is created (starts)
# Включить аудит событий, возникающих при создании или запуске процесса
#AuditProcess -Enable

# Disable events auditing generated when a process is created (starts) (default value)
# Выключить аудит событий, возникающих при создании или запуске процесса (значение по умолчанию)
# AuditProcess -Disable

<#
	Include command line in process creation events
	In order this feature to work events auditing (ProcessAudit -Enable) will be enabled

	Включать командную строку в событиях создания процесса
	Для того, чтобы работал данный функционал, будет включен аудит событий (AuditProcess -Enable)
#>
#CommandLineProcessAudit -Enable

# Do not include command line in process creation events (default value)
# Не включать командную строку в событиях создания процесса (значение по умолчанию)
# CommandLineProcessAudit -Disable

<#
	Create the "Process Creation" сustom view in the Event Viewer to log executed processes and their arguments
	In order this feature to work events auditing (AuditProcess -Enable) and command line (CommandLineProcessAudit -Enable) in process creation events will be enabled

	Создать настраиваемое представление "Создание процесса" в Просмотре событий для журналирования запускаемых процессов и их аргументов
	Для того, чтобы работал данный функционал, буден включен аудит событий (AuditProcess -Enable) и командной строки (CommandLineProcessAudit -Enable) в событиях создания процесса
#>
#EventViewerCustomView -Enable

# Remove the "Process Creation" custom view in the Event Viewer to log executed processes and their arguments (default value)
# Удалить настраиваемое представление "Создание процесса" в Просмотре событий для журналирования запускаемых процессов и их аргументов (значение по умолчанию)
# EventViewerCustomView -Disable

# Enable logging for all Windows PowerShell modules
# Включить ведение журнала для всех модулей Windows PowerShell
#PowerShellModulesLogging -Enable

# Disable logging for all Windows PowerShell modules (default value)
# Выключить ведение журнала для всех модулей Windows PowerShell (значение по умолчанию)
# PowerShellModulesLogging -Disable

# Enable logging for all PowerShell scripts input to the Windows PowerShell event log
# Включить ведение журнала для всех вводимых сценариев PowerShell в журнале событий Windows PowerShell
#PowerShellScriptsLogging -Enable

# Disable logging for all PowerShell scripts input to the Windows PowerShell event log (default value)
# Выключить ведение журнала для всех вводимых сценариев PowerShell в журнале событий Windows PowerShell (значение по умолчанию)
# PowerShellScriptsLogging -Disable

# Microsoft Defender SmartScreen doesn't marks downloaded files from the Internet as unsafe
# Microsoft Defender SmartScreen не помечает скачанные файлы из интернета как небезопасные
AppsSmartScreen -Disable

# Microsoft Defender SmartScreen marks downloaded files from the Internet as unsafe (default value)
# Microsoft Defender SmartScreen помечает скачанные файлы из интернета как небезопасные (значение по умолчанию)
# AppsSmartScreen -Enable

# Disable the Attachment Manager marking files that have been downloaded from the Internet as unsafe
# Выключить проверку Диспетчером вложений файлов, скачанных из интернета, как небезопасные
SaveZoneInformation -Disable

# Enable the Attachment Manager marking files that have been downloaded from the Internet as unsafe (default value)
# Включить проверку Диспетчера вложений файлов, скачанных из интернета как небезопасные (значение по умолчанию)
# SaveZoneInformation -Enable

# Disable Windows Script Host. Blocks WSH from executing .js and .vbs files
# Отключить Windows Script Host. Блокирует запуск файлов .js и .vbs
# WindowsScriptHost -Disable

# Enable Windows Script Host (default value)
# Включить Windows Script Host (значение по умолчанию)
# WindowsScriptHost -Enable

# Enable Windows Sandbox
# Включить Windows Sandbox
# WindowsSandbox -Enable

# Disable Windows Sandbox (default value)
# Выключить Windows Sandbox (значение по умолчанию)
# WindowsSandbox -Disable

<#
	Enable DNS-over-HTTPS for IPv4
	The valid IPv4 addresses: 1.0.0.1, 1.1.1.1, 149.112.112.112, 8.8.4.4, 8.8.8.8, 9.9.9.9

	Включить DNS-over-HTTPS для IPv4
	Действительные IPv4-адреса: 1.0.0.1, 1.1.1.1, 149.112.112.112, 8.8.4.4, 8.8.8.8, 9.9.9.9
#>
#DNSoverHTTPS -Enable -PrimaryDNS 1.0.0.1 -SecondaryDNS 1.1.1.1

# Disable DNS-over-HTTPS for IPv4 (default value)
# Выключить DNS-over-HTTPS для IPv4 (значение по умолчанию)
# DNSoverHTTPS -Disable

# Enable DNS-over-HTTPS via Comss.one DNS server. Applicable for Russia only
# Включить DNS-over-HTTPS для IPv4 через DNS-сервер Comss.one. Применимо только для России
# DNSoverHTTPS -ComssOneDNS

# Enable Local Security Authority protection to prevent code injection
# Включить защиту локальной системы безопасности, чтобы предотвратить внедрение кода
# LocalSecurityAuthority -Enable

# Disable Local Security Authority protection (default value)
# Выключить защиту локальной системы безопасности (значение по умолчанию)
# LocalSecurityAuthority -Disable
#endregion Microsoft Defender & Security

#region Context menu
# Show the "Extract all" item in the Windows Installer (.msi) context menu
# Отобразить пункт "Извлечь все" в контекстное меню Windows Installer (.msi)
MSIExtractContext -Show

# Hide the "Extract all" item from the Windows Installer (.msi) context menu (default value)
# Скрыть пункт "Извлечь все" из контекстного меню Windows Installer (.msi) (значение по умолчанию)
# MSIExtractContext -Hide

# Show the "Install" item in the Cabinet (.cab) filenames extensions context menu
# Отобразить пункт "Установить" в контекстное меню .cab архивов
CABInstallContext -Show

# Hide the "Install" item from the Cabinet (.cab) filenames extensions context menu (default value)
# Скрыть пункт "Установить" из контекстного меню .cab архивов (значение по умолчанию)
# CABInstallContext -Hide

# Show the "Run as different user" item to the .exe filename extensions context menu
# Отобразить пункт "Запуск от имени другого пользователя" в контекстное меню .exe файлов
RunAsDifferentUserContext -Show

# Hide the "Run as different user" item from the .exe filename extensions context menu (default value)
# Скрыть пункт "Запуск от имени другого пользователя" из контекстное меню .exe файлов (значение по умолчанию)
# RunAsDifferentUserContext -Hide

# Hide the "Cast to Device" item from the media files and folders context menu
# Скрыть пункт "Передать на устройство" из контекстного меню медиа-файлов и папок
CastToDeviceContext -Hide

# Show the "Cast to Device" item in the media files and folders context menu (default value)
# Отобразить пункт "Передать на устройство" в контекстном меню медиа-файлов и папок (значение по умолчанию)
# CastToDeviceContext -Show

# Hide the "Share" item from the context menu
# Скрыть пункт "Отправить" (поделиться) из контекстного меню
ShareContext -Hide

# Show the "Share" item in the context menu (default value)
# Отобразить пункт "Отправить" (поделиться) в контекстном меню (значение по умолчанию)
# ShareContext -Show

# Hide the "Edit with Clipchamp" item from the media files context menu
# Скрыть пункт "Редактировать в Climpchamp" из контекстного меню
EditWithClipchampContext -Hide

# Show the "Edit with Clipchamp" item in the media files context menu (default value)
# Отобразить пункт "Редактировать в Climpchamp" в контекстном меню (значение по умолчанию)
# EditWithClipchampContext -Show

# Hide the "Print" item from the .bat and .cmd context menu
# Скрыть пункт "Печать" из контекстного меню .bat и .cmd файлов
PrintCMDContext -Hide

# Show the "Print" item in the .bat and .cmd context menu (default value)
# Отобразить пункт "Печать" в контекстном меню .bat и .cmd файлов (значение по умолчанию)
# PrintCMDContext -Show

# Hide the "Include in Library" item from the folders and drives context menu
# Скрыть пункт "Добавить в библиотеку" из контекстного меню папок и дисков
IncludeInLibraryContext -Hide

# Show the "Include in Library" item in the folders and drives context menu (default value)
# Отобразить пункт "Добавить в библиотеку" в контекстном меню папок и дисков (значение по умолчанию)
# IncludeInLibraryContext -Show

# Hide the "Send to" item from the folders context menu
# Скрыть пункт "Отправить" из контекстного меню папок
#SendToContext -Hide

# Show the "Send to" item in the folders context menu (default value)
# Отобразить пункт "Отправить" в контекстном меню папок (значение по умолчанию)
# SendToContext -Show

# Hide the "Compressed (zipped) Folder" item from the "New" context menu
# Скрыть пункт "Сжатая ZIP-папка" из контекстного меню "Создать"
CompressedFolderNewContext -Hide

# Show the "Compressed (zipped) Folder" item to the "New" context menu (default value)
# Отобразить пункт "Сжатая ZIP-папка" в контекстном меню "Создать" (значение по умолчанию)
# CompressedFolderNewContext -Show

# Enable the "Open", "Print", and "Edit" context menu items for more than 15 items selected
# Включить элементы контекстного меню "Открыть", "Изменить" и "Печать" при выделении более 15 элементов
MultipleInvokeContext -Enable

# Disable the "Open", "Print", and "Edit" context menu items for more than 15 items selected (default value)
# Отключить элементы контекстного меню "Открыть", "Изменить" и "Печать" при выделении более 15 элементов (значение по умолчанию)
# MultipleInvokeContext -Disable

# Hide the "Look for an app in the Microsoft Store" item in the "Open with" dialog
# Скрыть пункт "Поиск приложения в Microsoft Store" в диалоге "Открыть с помощью"
UseStoreOpenWith -Hide

# Show the "Look for an app in the Microsoft Store" item in the "Open with" dialog (default value)
# Отобразить пункт "Поиск приложения в Microsoft Store" в диалоге "Открыть с помощью" (значение по умолчанию)
# UseStoreOpenWith -Show

# Show the "Open in Windows Terminal" item in the folders context menu (default value)
# Отобразить пункт "Открыть в Терминале Windows" в контекстном меню папок (значение по умолчанию)
OpenWindowsTerminalContext -Show

# Hide the "Open in Windows Terminal" item in the folders context menu
# Скрыть пункт "Открыть в Терминале Windows" в контекстном меню папок
# OpenWindowsTerminalContext -Hide

# Open Windows Terminal in context menu as administrator by default
# Открывать Windows Terminal из контекстного меню от имени администратора по умолчанию
OpenWindowsTerminalAdminContext -Enable

# Do not open Windows Terminal in context menu as administrator by default (default value)
# Не открывать Windows Terminal из контекстного меню от имени администратора по умолчанию (значение по умолчанию)
# OpenWindowsTerminalAdminContext -Disable

# Disable the Windows 10 context menu style (default value)
# Отключить стиль контекстного меню из Windows 10 (значение по умолчанию)
#Windows10ContextMenu -Disable

# Enable the Windows 10 context menu style
# Включить стиль контекстного меню из Windows 10
# Windows10ContextMenu -Enable
#endregion Context menu

#region Update Policies
<#
	Display all policy registry keys (even manually created ones) in the Local Group Policy Editor snap-in (gpedit.msc)
	This can take up to 30 minutes, depending on on the number of policies created in the registry and your system resources

	Отобразить все политики реестра (даже созданные вручную) в оснастке Редактора локальной групповой политики (gpedit.msc)
	Это может занять до 30 минут в зависимости от количества политик, созданных в реестре, и мощности вашей системы
#>
# UpdateLGPEPolicies
#endregion Update Policies

# Environment refresh and other neccessary post actions
# Обновление окружения и прочие необходимые действия после выполнения основных функций
PostActions

# Errors output
# Вывод ошибок
Errors

# SIG # Begin signature block
# MIIbswYJKoZIhvcNAQcCoIIbpDCCG6ACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAlHhNE2RtxzWn3
# zk2d8SpL+w+PyAjmHLHqvBDvGXJfQaCCFgkwggL8MIIB5KADAgECAhBK+VzjbbRY
# tUuudcRyNd4PMA0GCSqGSIb3DQEBCwUAMBYxFDASBgNVBAMMC1RlYW0gU29waGlh
# MB4XDTI0MDMwNjIxMDcxOVoXDTI2MDMwNjIxMTcxNlowFjEUMBIGA1UEAwwLVGVh
# bSBTb3BoaWEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC7PNJLmjAq
# spvW0yqObHHVfiLcTdkASJXMnAMLj1musPi6qViEIm/5Wu/i1P/4SotvsRmYzMg/
# zp8WxHMbKsGardSLhBhCsms7F5QWb2GavqLtxekColUAzzwOEUCJq5iKr95QJILs
# QwcP7pjSEat4ozTGKeP9BDUr4KEZiSDU1lV4uozFb0e8kX2EstHK/ZgL+4+kbyMu
# bQPj4Sszm7m8ExdiF2/3ciVDc0YSkttHjZ170SeipLgDip1+5L5wLxBpxuvLCiJK
# 03ihfVXG87zogSMrSy2gCWDdDAz++IvIfl3zIuf6ZYBe4ZfaBupNfd4/8hKOcXCZ
# GHtSy73RCzqRAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAdBgNVHQ4EFgQU/L87UzRey/MqTSAP6+HdwHDfyMIwDQYJKoZIhvcN
# AQELBQADggEBAI4oH5sVDHCNPMAjG7sxN//wANgPqN1LAuXhl6FBO6dW9tr5zo9I
# zVnxowjxUxBJBw49GbHVE2svMMZ+5jgQNPpypBgrUnoU3vIo8C4faL8Bc21xM05k
# 6sDiIMWnUUqL/kOpkKlGmjH/YBxgvVLp+3nZ+4CWnej80XW5zl2yg8Opiz3MqHwT
# ItqdQ+swiFRSgz/LxC/WdVT8JPtbnOrNoK0oEP7/L32OgiuU5xmFNv9dzmJQ8af+
# UGve2Po3ULTdpxTIcwCSUclngpXVNSmM2/uBdypVCApg8cPFZX5QcID/KxfPIH7w
# wXBzITdsujYbSDO2OdiISldeBjPbjU5EUTwwggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMy
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcg
# Q0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
# JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMf
# UBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w
# 1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRk
# tFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYb
# qMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUm
# cJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP6
# 5x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzK
# QtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo
# 80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjB
# Jgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXche
# MBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd
# 4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiC
# qBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl
# /Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
# RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYT
# gAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/
# a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37
# xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmL
# NriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0
# YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJ
# RyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIG
# wjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkqhkiG9w0BAQsFADBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVowSDELMAkGA1UEBhMCVVMx
# FzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2VydCBUaW1l
# c3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAKNTRYcd
# g45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVYwamTEafNqrJq3RApih5i
# Y2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isgHMGXlLSlUIHyz8sHpjBo
# yoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFexAaaPPDFLnkPG2ZS48jW
# Pl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gpOWvgeFmX40QrStWVzu8I
# F+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28mxyyt1/f8O52fTGZZUdV
# nUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkHNwGRDxy1Uc2qTGaDiGhi
# u7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58ZE2dD9/O0V6MqqtQFcmz
# yrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXHg2TWdc2PEnZWpST618Rr
# IbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W1eEQE/5hRwqM/vC2x9XH
# 3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK8REuZODLIivK8SgTIUlR
# fgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGjggGLMIIBhzAOBgNVHQ8B
# Af8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAg
# BgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZ
# bU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn783QZKHVVqllMaPe1eNJ
# MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAG
# CCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQw
# DQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+KPGic2CX/yyzkzepdIpLs
# jCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1IjrhrunxdvcJhN2hJd6Pr
# kKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP2yZWK7Dzp703DNiYdk9W
# uVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ5EQSviANnqlE0PjlSXcI
# WiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON1I13fXVFoaVYJmoDRd7Z
# ULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S88lgIcRWR+3aEUuMMsOI
# 5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbUuXKWfpd5OEhfysLcPTLf
# ddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145WPR8czFVoIARyxQMfq68
# /qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6F/3Ed2wVbK6rr3M66ElG
# t9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso/zjlUlrWrBciI0707NMX
# +1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG70Ee8PBf4NvZrZCARK+A
# EEGKMYIFADCCBPwCAQEwKjAWMRQwEgYDVQQDDAtUZWFtIFNvcGhpYQIQSvlc4220
# WLVLrnXEcjXeDzANBglghkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKAC
# gAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsx
# DjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCBrHWP+Sff8IDQwk5pDc/5R
# AxNN7XUqi27YPmedvfKJKjANBgkqhkiG9w0BAQEFAASCAQB6sLpayqsfI+J1zAA0
# klj8G34/T40BAI6Ro6tUEH/AgrAlslRMBpatHUkCT8LxCZdWN/bshFbkVSpPXN5U
# uEwUsjn+5f8bliJ6LChLi9c9f19qMfDhynmFyJMWyCe3hSo/3+q7BaR37Pvfn35w
# aYuBaFtgzSaIRvzGMmy5nOfAVT1hOp0lEI80xCNy+4j8KBAnt9qg7xc2DALFhHf5
# rD98obEnsV72uzBOCOJ98kKgG7OOXFCFnEBP6a/1/BgFk2Ll/IudfmwYYTDDcduB
# oy0W5G/sPVIswd7hgY2hKGgNzu66JEFOzrPOAUCGJBYuMKo3Wvt4jb1NByKqicS5
# yRBdoYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJAgEBMHcwYzELMAkGA1UEBhMC
# VVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBU
# cnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQBUSv85Sd
# CDmmv9s/X+VhFjANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG
# 9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI0MDMwNjIxMTcyNVowLwYJKoZIhvcNAQkE
# MSIEIHt6XOYllWU2043vPaj4ubTaVf20aTSay+rykz0Gg5nOMA0GCSqGSIb3DQEB
# AQUABIICAAUFtpUmt2uVLyisLRnFLwwK4v8Veevq+D22Xbf3zI0UZWt4KAEnG2mg
# jwj3MKUitaneBtHlFgfkv6rl1CBte8TCfjRWjmNGu+YIlaj+78vzhGcePzLMxTE6
# nM/s746NB/lcYL1neFYwlPY8v4MVc3bcu9HeRlH560TAZB8wpDQ5/eDhyNDqYHjD
# ZEqr1iLxwz4ZBjOtOtAI1jgxPHh173rqqiI+RL/Xq9acXuNQ+WZkr8/zQAz96BOR
# hcLpjlhY9LbfnjnVushtFzeaIvdZwKxi7W/bGbaoGHHn0vP+b9YLlYIFjhRv19wt
# FfaoYZ7Z6RVx1tsIBU+bPPFlbVholzV4EMInCgbncKMLREQNmqxmpCCTE53buQQN
# EOcNkDQLiLbSldENPDWjCHG8/Gj6kWzph4d2I/tyJE7y8L5Iu6lCZ1FZuMVS03HY
# sY/XEaTWX5aVbTFKdEdSwY7VE391RGtkbLK1qMcprRGNQDwwmWIn9JesM8sUnqaT
# LxUOTWdVzokDIyQThCDraE0X8H5NzsXCmYYcT+TBsNpcHD4yCgtrQ/hjSpsyqBpd
# Hewlfixp1mBoCZPC3e4hBaP5hLhZzH2xQIpCKiKO5XJnwoX3W6tnF0gNH/ghRklC
# BeCdFHKoJngLiPxa6NV21hLFdavdMiW52/gYOCJqXhtXfxozvh3V
# SIG # End signature block
