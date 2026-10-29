package service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class LoginSecurityService {

    public static final int MAX_FAILED_ATTEMPTS = 5;
    public static final long LOCK_DURATION_MS = 15 * 60 * 1000;

    public static class AttemptRecord {
        private int failedCount;
        private long lockUntilMillis;

        public AttemptRecord(int failedCount, long lockUntilMillis) {
            this.failedCount = failedCount;
            this.lockUntilMillis = lockUntilMillis;
        }

        public int getFailedCount() { return failedCount; }
        public void setFailedCount(int failedCount) { this.failedCount = failedCount; }
        public long getLockUntilMillis() { return lockUntilMillis; }
        public void setLockUntilMillis(long lockUntilMillis) { this.lockUntilMillis = lockUntilMillis; }

        public boolean isLocked() {
            return System.currentTimeMillis() < lockUntilMillis;
        }
    }

    private static final Map<String, AttemptRecord> attemptsMap = new ConcurrentHashMap<>();

    private static String normalizeEmail(String email) {
        return email != null ? email.trim().toLowerCase() : "";
    }

    public static boolean isLocked(String email) {
        String key = normalizeEmail(email);
        if (key.isEmpty()) return false;

        AttemptRecord record = attemptsMap.get(key);
        if (record == null) return false;

        if (record.isLocked()) {
            return true;
        } else if (record.getLockUntilMillis() > 0 && System.currentTimeMillis() >= record.getLockUntilMillis()) {

            attemptsMap.remove(key);
            return false;
        }
        return false;
    }

    public static long getRemainingLockMinutes(String email) {
        String key = normalizeEmail(email);
        AttemptRecord record = attemptsMap.get(key);
        if (record == null || !record.isLocked()) return 0;

        long diff = record.getLockUntilMillis() - System.currentTimeMillis();
        return Math.max(1, (diff + 59999) / 60000);
    }

    public static int recordFailedAttempt(String email) {
        String key = normalizeEmail(email);
        if (key.isEmpty()) return 1;

        AttemptRecord record = attemptsMap.compute(key, (k, existing) -> {
            long now = System.currentTimeMillis();
            if (existing == null || (!existing.isLocked() && existing.getLockUntilMillis() > 0)) {
                return new AttemptRecord(1, 0);
            }
            int newCount = existing.getFailedCount() + 1;
            long lockUntil = 0;
            if (newCount >= MAX_FAILED_ATTEMPTS) {
                lockUntil = now + LOCK_DURATION_MS;
            }
            return new AttemptRecord(newCount, lockUntil);
        });

        return record.getFailedCount();
    }

    public static void resetAttempts(String email) {
        String key = normalizeEmail(email);
        if (!key.isEmpty()) {
            attemptsMap.remove(key);
        }
    }
}
