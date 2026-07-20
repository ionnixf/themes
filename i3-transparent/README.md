# i3 Transparent

Минималистичная прозрачная тема для i3/X11 с нейтральной серой палитрой. Она
не навязывает голубой или другой акцент и рассчитана на сочетание с любыми
обоями. Скругления отключены, внешние и внутренние gaps сохраняются даже при
одном окне.

## Что входит

- i3 с i3bar и быстрыми блоками i3blocks;
- Alacritty;
- Rofi и отдельный выбор обоев с превью;
- Picom;
- Dunst;
- коллекция обоев;
- необязательный Polybar, который не запускается автоматически.

Скомпилированный `i3/xkb-layout` и локальное состояние `i3/wallpaper` намеренно
не хранятся в Git.

## Зависимости

Основные: `i3`, `i3blocks`, `alacritty`, `rofi`, `picom`, `dunst`, `i3lock`,
`feh`, `wpctl` (WirePlumber), `brightnessctl`, ImageMagick `import`, `xprop`,
`notify-send`, C-компилятор и заголовки Xlib. Для альтернативной панели нужен
`polybar`.

Интерфейс использует **JetBrainsMono Nerd Font**, а Rofi — иконки
**Papirus-Dark**. В Polybar также предусмотрен fallback на DejaVu Sans.

## Git-установка через ссылки

Рекомендуемый вариант — держать репозиторий в `~/.config/themes`. Тогда
изменения обычных файлов `~/.config/i3/config`, `~/.config/rofi/neutral.rasi`
и остальных сразу отображаются в Git:

```sh
git clone git@github.com:ionnixf/themes.git "$HOME/.config/themes"
"$HOME/.config/themes/i3-transparent/install.sh"
i3 -C -c "$HOME/.config/i3/config"
i3-msg reload
```

Установщик связывает каталоги конфигурации и `~/Pictures/Wallpapers` с
репозиторием, автоматически собирает `i3/xkb-layout`, а существующие пути
переносит в `~/.config/backups`. Локальные файлы `i3/wallpaper` и
`i3/xkb-layout` сохраняются, но остаются вне Git. Для установки только ссылок
на конфиги без обоев и компиляции можно запустить `link-configs.sh`.

Для обновления темы после редактирования активных конфигов:

```sh
cd "$HOME/.config/themes"
git status --short
git diff -- i3-transparent
git add i3-transparent
git commit -m "Update i3 transparent theme"
git push origin main
```

Перед началом новой серии изменений получите внешние обновления командой
`git pull --ff-only`.

## Установка копированием

Сначала сохраните резервную копию собственных конфигов. Затем из этой папки:

```sh
cp -a alacritty dunst i3 i3blocks picom polybar rofi "$HOME/.config/"
cc -O2 -Wall -Wextra -pedantic \
  -o "$HOME/.config/i3/xkb-layout" \
  "$HOME/.config/i3/xkb-layout.c" -lX11
i3 -C -c "$HOME/.config/i3/config"
i3-msg reload
```

Picom и Dunst запускаются конфигом i3 при старте новой сессии. Polybar оставлен
как ручная альтернатива: `~/.config/polybar/launch.sh`. Чтобы использовать его
вместо i3bar, отключите блок `bar { ... }` в конфиге i3.

## Обои

Коллекция из репозитория устанавливается в `~/Pictures/Wallpapers`. После
Git-установки этот путь является ссылкой на `i3-transparent/wallpapers`, поэтому
добавленные туда PNG, JPG и WebP сразу видны в `git status`. Нажмите
`Super+Shift+W`, чтобы открыть выбор обоев. Другой путь установки можно передать
через переменную `WALLPAPER_DIR`. Выбранное изображение сохраняется локально в
`~/.config/i3/wallpaper`.

## Клавиши

Буквенные и цифровые команды используют физические X11 keycodes, поэтому
работают одинаково в английской и русской раскладках.

| Комбинация | Действие |
| --- | --- |
| `Super+Enter` | Alacritty |
| `Super+D` | Rofi |
| `Super+Space` | EN/RU |
| `Super+Q` | Закрыть окно |
| `Super+Alt+L` | Заблокировать экран |
| `Super+Shift+R` | Перезагрузить конфиг i3 |
| `Super+Shift+E` | Выйти из i3 с подтверждением |
| `Super+Shift+W` | Выбрать обои в Rofi |
| `Super+Arrow` | Переместить фокус |
| `Super+Shift+Arrow` | Переместить окно |
| `Super+1…0` | Открыть workspace 1…10 |
| `Super+Shift+1…0` | Переместить окно на workspace 1…10 |
| `Super+U` / `Super+I` | Предыдущий / следующий workspace |
| `Super+Ctrl+U` / `Super+Ctrl+I` | Переместить окно на соседний workspace |
| `Super+V` | Floating toggle |
| `Super+F` | Fullscreen toggle |
| `Super+B` / `Super+N` | Горизонтальный / вертикальный split |
| `Super+A` | Фокус на родителя |
| `Super+-` / `Super+=` | Уменьшить / увеличить ширину |
| `Super+Shift+-` / `Super+Shift+=` | Уменьшить / увеличить высоту |
| `Print` | Скриншот всего экрана |
| `Shift+Print` | Скриншот области |
| `Ctrl+Print` | Скриншот активного окна |
| Клавиши громкости | Громкость ±10% / mute |
| Клавиши яркости | Яркость ±10% |
