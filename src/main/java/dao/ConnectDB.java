package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

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
