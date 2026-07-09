import 'dotenv/config';

export const env = {
    port: Number(process.env.PORT ?? 3000),
    nodeEnv: process.env.NODE_ENV ?? 'development',
    databaseUrl: process.env.DATABASE_URL ?? 'postgres://localhost:5432/mdb_platform',
    // Токен Telegram-бота для эскалации заявок менеджеру. Секрет — только из env,
    // не хардкодится и не коммитится. Без него уведомление логируется как failed,
    // заявка всё равно сохраняется (БД — источник правды).
    telegramBotToken: process.env.TELEGRAM_BOT_TOKEN ?? null,
};
