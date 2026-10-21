package service;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Bảo mật: Giới hạn số lần đăng nhập sai, chống tấn công Brute-force.
 * ============================================================================
 */

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Quản lý bảo mật đăng nhập:
 * Giới hạn nhập sai mật khẩu tối đa 5 lần liên tiếp.
 * Nếu vượt quá 5 lần sẽ tạm thời khóa đăng nhập trong vòng 15 phút vì lý do an toàn bảo mật.
 */
public class LoginSecurityService {

    public static final int MAX_FAILED_ATTEMPTS = 5;
    public static final long LOCK_DURATION_MS = 15 * 60 * 1000; // Khóa 15 phút

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

    /**
     * Kiểm tra xem tài khoản email này có đang bị tạm khóa đăng nhập không.
     */
    public static boolean isLocked(String email) {
        String key = normalizeEmail(email);
        if (key.isEmpty()) return false;

        AttemptRecord record = attemptsMap.get(key);
        if (record == null) return false;

        if (record.isLocked()) {
            return true;
        } else if (record.getLockUntilMillis() > 0 && System.currentTimeMillis() >= record.getLockUntilMillis()) {
            // Hết hạn khóa -> xóa bản ghi để người dùng thử lại
            attemptsMap.remove(key);
            return false;
        }
        return false;
    }

    /**
     * Trả về số phút còn lại bị khóa
     */
    public static long getRemainingLockMinutes(String email) {
        String key = normalizeEmail(email);
        AttemptRecord record = attemptsMap.get(key);
        if (record == null || !record.isLocked()) return 0;

        long diff = record.getLockUntilMillis() - System.currentTimeMillis();
        return Math.max(1, (diff + 59999) / 60000);
    }

    /**
     * Ghi nhận một lần nhập sai mật khẩu.
     * Trả về số lần đã sai hiện tại.
     */
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

    /**
     * Đăng nhập thành công -> xóa bỏ mọi lịch sử sai mật khẩu
     */
    public static void resetAttempts(String email) {
        String key = normalizeEmail(email);
        if (!key.isEmpty()) {
            attemptsMap.remove(key);
        }
    }
}
