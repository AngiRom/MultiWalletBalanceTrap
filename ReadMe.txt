MultiWalletBalanceTrap — це смарт-контракт-ловушка для Drosera
, яка відстежує баланс кількох гаманців (наприклад, “китів”) і сигналізує, якщо зміна перевищує заданий поріг (0.01%).

⚡ Основні можливості

✅ Відстеження кількох гаманців одночасно

✅ Поріг зміни балансу в базисних пунктах (bp)
— 10 bp = 0.01% (налаштовується)

✅ Повертає повідомлення з адресою та величиною зміни

✅ Сумісний із Drosera:

collect() → збирає дані (баланси)

shouldRespond() → порівнює й вирішує, чи сигналізувати

📂 Структура проекту
my-drosera-trap/
├── foundry.toml
├── src/
    ├── MultiWalletBalanceTrap.sol      # Основна ловушка
    └── LogAlertReceiver.sol            # Контракт-приймач (логування подій)


🛠 Як встановити
# 1. Створюємо новий проєкт Foundry
forge init my-drosera-trap
cd my-drosera-trap

# 2. Замінюємо вміст папок src/ і test/ на файли з цього репозиторію

# 3. Будуємо і тестуємо
forge build


🔗 Інтеграція в Drosera

При налаштуванні Drosera node, вкажи ці параметри:

{
  "path": "src/MultiWalletBalanceTrap.sol",
  "response_contract": "<АДРЕСА_DEPLOYED_LogAlertReceiver>",
  "response_function": "logAnomaly(address,string,uint256)"
}


ВАЖЛИВО: перед деплоєм заміни масив targets у MultiWalletBalanceTrap.sol на ті гаманці, які хочеш відстежувати.

🧪 Приклад роботи

collect() → повертає масив поточних балансів усіх гаманців

shouldRespond() → порівнює з попередніми даними

Якщо зміна ≥ 0.01%, повертає true і текст повідомлення

Drosera викликає logAnomaly() на LogAlertReceiver