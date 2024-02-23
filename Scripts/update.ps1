# Установка кодировки UTF-8 для консоли
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Функция для проверки прав администратора
function CheckAdminRights {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "Не удалось получить административные привилегии." -ForegroundColor Red
        Write-Host "Запустите скрипт от имени администратора."
        Pause
        exit 1
    }
}

# Функция для клонирования или обновления репозитория
function CloneOrUpdateRepository {
    param (
        [string]$repo_url,
        [string]$repo_dir,
        [string]$git_path
    )

    if (-not (Test-Path (Join-Path $repo_dir $git_dir))) {
        Write-Host $message_check_repo
        Write-Host $message_clone_repo
        & $git_path clone $repo_url $repo_dir
        if (-not $?) {
            throw "$error_clone"
        }
    } else {
        Write-Host $message_update_repo
        Write-Host "Текущий каталог после смены: $repo_dir"
  
        # Выполнение git pull
        & $git_path -C $repo_dir pull
        if (-not $?) {
            throw "$error_pull"
        }
    }
}

# Конфигурация
$repo_url = "https://github.com/Nagrands/windows_config.git"
$repo_dir = (Join-Path $PSScriptRoot "windows_config")
$git_path = "git"  # Используем переменную окружения PATH для поиска Git
$git_dir = ".git"  # Поддиректория Git

# Сообщения
$message_check_repo = "Проверка наличия репозитория..."
$message_clone_repo = "Репозиторий не найден. Клонирование..."
$message_update_repo = "Репозиторий найден. Обновление..."
$success_message = "Операция успешно выполнена."
$error_change_dir = "Ошибка при переходе в директорию $PSScriptRoot."
$error_clone = "Ошибка при клонировании репозитория."
$error_pull = "Ошибка при выполнении git pull."

# Проверка наличия административных прав
CheckAdminRights

# Переходим в директорию, где находится скрипт
try {
    Set-Location $PSScriptRoot -ErrorAction Stop
    Write-Output "Текущий каталог: $PWD"
} catch {
    Write-Host $error_change_dir -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

# Клонируем или обновляем репозиторий
try {
    CloneOrUpdateRepository -repo_url $repo_url -repo_dir $repo_dir -git_path $git_path
    Write-Output $success_message
    # Открыть текущую папку в проводнике
    Invoke-Item $repo_dir
} catch {
    Write-Host $_ -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

Write-Output ""

exit 0
