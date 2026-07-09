-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 15_notify_recipients.sql
-- Эскалация заявок в НЕСКОЛЬКО Telegram-аккаунтов (массив получателей)
-- =====================================================================

-- Раньше был один chat_id; теперь эскалация уходит во ВСЕ id из массива
-- (оба менеджера нажали Start у Bali_Rent_Manager_bot). Каждый получатель —
-- отдельная запись в notifications со своим статусом (одному ушло, другому
-- нет — видно по статусам; заявка в БД сохраняется в любом случае).
DELETE FROM system_config WHERE key = 'manager_telegram_chat_id';

INSERT INTO system_config (company_id, key, value, description)
SELECT id, 'manager_telegram_chat_ids', '[1593619177, 7257636963]'::jsonb,
       'Telegram chat_id менеджеров для эскалации заявок (массив, отправка во все). Бот: Bali_Rent_Manager_bot, токен — env TELEGRAM_BOT_TOKEN. WhatsApp-канал — на будущее (Notification Service мультиканальный, ТЗ п.15.3).'
FROM companies;
