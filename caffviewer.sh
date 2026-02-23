#!/bin/bash

echo "Проверка наличия Java..."
# Функция проверки java
check_java() {
    if command -v java >/dev/null 2>&1; then
        echo "Java установлена: $(java -version 2>&1 | head -n1)"
        return 0
    else
        echo "Java не найдена"
        return 1
    fi
}

# Определяем пакетный менеджер

for PM in apt dnf yum pacman zypper apk emerge; do command -v $PM && echo "Пакетный менеджер=> $PM"; done

# Если java не установлена — ставим
if ! check_java; then
    echo "Установка Java через $PM..."

    if [ "$PM" = "apt" ]; then
        sudo apt update
        sudo apt install -y default-jre
    elif [ "$PM" = "dnf" ]; then
        sudo dnf install -y java
    elif [ "$PM" = "yum" ]; then
        sudo yum install -y java
    else
    echo "Пакетный менеджер=> $PM , не применяется в нашей системе"
    fi

    echo "Проверяем Java после установки..."
    check_java
fi

echo "Установка Caffviewer..."

mkdir -p /opt/caffviewer/ 

wget https://caff.de/projects/caffviewer/caffviewer.jar 

mv -fv ./caffviewer.jar  /opt/caffviewer/ 

chmod 644 /opt/caffviewer/caffviewer.jar

tee /usr/share/applications/Caffviewer.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=CaffViewer
Exec=java -mx3g -jar /opt/caffviewer/caffviewer.jar
Comment=
Terminal=false
Icon=cinnamon-panel-launcher
Type=Application
Name[ru_RU]=CaffViewer
EOF

chmod 644 /usr/share/applications/Caffviewer.desktop

if [[ `hostnamectl | grep -i 'alteros'` ]];then

echo "Копирование ярлыков пользователям..."

cp -frv /usr/share/applications/Caffviewer.desktop /etc/skel/Рабочий\ стол/
chmod +x /etc/skel/Рабочий\ стол/Caffviewer.desktop 

for i in /home/* ; do [ -d "$i" ] && cp -frv "/usr/share/applications/Caffviewer.desktop" "$i/Рабочий стол/"; done

elif [[ `hostnamectl | grep -i 'astra'` ]];then

cp -frv /usr/share/applications/Caffviewer.desktop /usr/share/applications/flydesktop

fi

echo "Обновление базы приложений..."
update-desktop-database

echo "Готово."

echo "Если была заявка на просмотр DWG напишите в заявке следующее сообщение: 'Добрый день! Программа для просмотра DWG файлов установлена, для её запуска запустите на рабочем столе файл Caffviewer.'."
