-- Upgrade Migration: Add ON UPDATE CASCADE to all user_id foreign keys
-- For PostgreSQL environments

BEGIN;

-- bookmarks
ALTER TABLE bookmarks DROP CONSTRAINT bookmarks_user_id_fkey;
ALTER TABLE bookmarks ADD CONSTRAINT bookmarks_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- search_history
ALTER TABLE search_history DROP CONSTRAINT search_history_user_id_fkey;
ALTER TABLE search_history ADD CONSTRAINT search_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- downloads
ALTER TABLE downloads DROP CONSTRAINT downloads_user_id_fkey;
ALTER TABLE downloads ADD CONSTRAINT downloads_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- collections
ALTER TABLE collections DROP CONSTRAINT collections_user_id_fkey;
ALTER TABLE collections ADD CONSTRAINT collections_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- ai_sessions
ALTER TABLE ai_sessions DROP CONSTRAINT ai_sessions_user_id_fkey;
ALTER TABLE ai_sessions ADD CONSTRAINT ai_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- notifications
ALTER TABLE notifications DROP CONSTRAINT notifications_user_id_fkey;
ALTER TABLE notifications ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- activity_logs
ALTER TABLE activity_logs DROP CONSTRAINT activity_logs_user_id_fkey;
ALTER TABLE activity_logs ADD CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- browser_sessions
ALTER TABLE browser_sessions DROP CONSTRAINT browser_sessions_user_id_fkey;
ALTER TABLE browser_sessions ADD CONSTRAINT browser_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- history
ALTER TABLE history DROP CONSTRAINT history_user_id_fkey;
ALTER TABLE history ADD CONSTRAINT history_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- sync_queue
ALTER TABLE sync_queue DROP CONSTRAINT sync_queue_user_id_fkey;
ALTER TABLE sync_queue ADD CONSTRAINT sync_queue_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

COMMIT;

/* 
-- Downgrade Migration: Revert ON UPDATE CASCADE to NO ACTION

BEGIN;

ALTER TABLE bookmarks DROP CONSTRAINT bookmarks_user_id_fkey;
ALTER TABLE bookmarks ADD CONSTRAINT bookmarks_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE search_history DROP CONSTRAINT search_history_user_id_fkey;
ALTER TABLE search_history ADD CONSTRAINT search_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE downloads DROP CONSTRAINT downloads_user_id_fkey;
ALTER TABLE downloads ADD CONSTRAINT downloads_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE collections DROP CONSTRAINT collections_user_id_fkey;
ALTER TABLE collections ADD CONSTRAINT collections_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ai_sessions DROP CONSTRAINT ai_sessions_user_id_fkey;
ALTER TABLE ai_sessions ADD CONSTRAINT ai_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE notifications DROP CONSTRAINT notifications_user_id_fkey;
ALTER TABLE notifications ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE activity_logs DROP CONSTRAINT activity_logs_user_id_fkey;
ALTER TABLE activity_logs ADD CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE browser_sessions DROP CONSTRAINT browser_sessions_user_id_fkey;
ALTER TABLE browser_sessions ADD CONSTRAINT browser_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE history DROP CONSTRAINT history_user_id_fkey;
ALTER TABLE history ADD CONSTRAINT history_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE sync_queue DROP CONSTRAINT sync_queue_user_id_fkey;
ALTER TABLE sync_queue ADD CONSTRAINT sync_queue_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

COMMIT;
*/
