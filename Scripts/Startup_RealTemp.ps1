Clear-Host

try {
	# Проверка наличия административных прав
	$admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
	if (-not $admin) {
		Write-Host "Не удалось получить административные привилегии."
		Write-Host "Запустите скрипт от имени администратора."
		pause
		exit 1
	}
	
	# Определение пути к файлу
	$appFolder = Join-Path $PSScriptRoot "..\Setup\Software\System Monitoring\RealTemp\RealTempGT.exe"
	
	# Проверка существования файла перед выполнением задачи
	if (-not (Test-Path $appFolder)) {
		Write-Host ""
		Write-Host "Ошибка: Файл не найден. Проверьте путь к приложению."
		exit 1
	}
	
	# Создание задачи
	$action = New-ScheduledTaskAction -Execute $appFolder
	$trigger = New-ScheduledTaskTrigger -AtLogon
	Register-ScheduledTask -TaskName "RealTemp_Startup" -Action $action -Trigger $trigger -RunLevel Highest
	
	Write-Host ""
	Write-Host "Задача создана успешно."

	# Открытие планировщика задач
    Start-Process "mmc" -ArgumentList "taskschd.msc"
	
} catch {
	Write-Host ""
	Write-Host "Ошибка: $_"
	exit 1
}

Start-Sleep -Seconds 7
exit 0
