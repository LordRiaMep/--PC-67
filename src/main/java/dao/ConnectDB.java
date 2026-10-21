package dao;

/**
 * ============================================================================
 * [HỆ THỐNG DÙNG CHUNG (CORE DATABASE)]
 * Phụ trách: Cả nhóm
 * Chức năng: Quản lý kết nối SQL Server đa luồng (Multi-threaded Safe) cho toàn bộ Servlet.
 * ============================================================================
 */

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Quản lý kết nối Database an toàn đa luồng (Multi-threaded Safe)
 */
public class ConnectDB {
    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;"
            + "databaseName=SD2001_DATN_DEMO3;"
            + "user=sa;"
            + "password=Keowyt12@_@;"
            + "encrypt=true;"
            + "trustServerCertificate=true;";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            System.err.println("Lỗi: Không tìm thấy Driver JDBC SQL Server: " + e.getMessage());
        }
    }

    /**
     * Trả về kết nối mới mỗi lần gọi, an toàn cho môi trường đa luồng Servlet
     */
    public static Connection getConnect() {
        try {
            return DriverManager.getConnection(DB_URL);
        } catch (SQLException e) {
            System.err.println("Lỗi kết nối SQL Server: " + e.getMessage());
            return null;
        }
    }

    public static void main(String[] args) {
        Connection conn = ConnectDB.getConnect();
        if (conn != null) {
            System.out.println("Kết nối test thành công!");
            try { conn.close(); } catch (Exception ignored) {}
        }
    }
}