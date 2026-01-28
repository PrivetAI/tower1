# Tower Climber 🏗️

Idle clicker game для iOS. Строй башню, покупай апгрейды, достигай целей!

## Особенности

- **Кликер механика** — тапай кнопку, поднимайся выше
- **14 апгрейдов** — увеличивай силу тапа, авто-подъём, множители
- **20 целей** — от 10 до 100,000 этажей
- **Адаптивный UI** — оптимизирован для iPhone и iPad
- **Сохранение прогресса** — автосохранение в UserDefaults

## Требования

- iOS 15.0+
- Xcode 15+
- Swift 5

## Структура

```
TowerClimber/
├── Models/
│   ├── GameState.swift    # Логика игры, сохранение
│   ├── Upgrade.swift      # 14 апгрейдов
│   ├── Milestone.swift    # 20 целей
│   └── SoundManager.swift # Звуки и хаптика
├── Views/
│   ├── GameView.swift     # Главный экран с башней
│   ├── UpgradesView.swift # Магазин апгрейдов
│   ├── MilestonesView.swift # Цели
│   └── SettingsView.swift # Статистика и настройки
├── Components/
│   ├── Shapes.swift       # Triangle, Star
│   └── UpgradeIcons.swift # Кастомные иконки
└── Utilities/
    └── Constants.swift    # Цвета, шрифты
```

## Запуск

1. Открыть `TowerClimber.xcodeproj` в Xcode
2. Выбрать симулятор или устройство
3. Cmd+R

## Лицензия

MIT
