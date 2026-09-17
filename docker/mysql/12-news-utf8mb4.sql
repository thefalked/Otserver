-- News (z_forum section 1) and tickers: store Unicode emoji.
-- latin1 cannot hold 4-byte UTF-8; utf8mb4 can.
-- Safe to re-run (CONVERT is idempotent when already utf8mb4).

ALTER TABLE `z_forum`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `z_news_tickers`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
