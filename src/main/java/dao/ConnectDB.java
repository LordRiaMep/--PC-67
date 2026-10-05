package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * @author luand
 */
public class ConnectDB {
    public static Connection con = null;

    public static Connection getConnect() {
        String strDbUrl = "jdbc:sqlserver://localhost:1433;"
                + "databaseName=SD2001_DATN_DEMO3;"
                + "user=sa;"
                + "password=Keowyt12@_@;"
                + "encrypt=true;"
                + "trustServerCertificate=true;";
        try {
            if (con == null || con.isClosed()) {
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                con = DriverManager.getConnection(strDbUrl);
                System.out.println("=== KẾT NỐI DATABASE SD2001_DATN_DEMO THÀNH CÔNG! ===");
            }
        } catch (ClassNotFoundException e) {
            System.out.println("Lỗi: Không tìm thấy Driver JDBC! Bạn đã add file .jar vào thư mục lib chưa?");
        } catch (SQLException e) {
            System.out.println("Lỗi kết nối SQL Server: " + e.getMessage());
        }
        return con;
    }
    public static void main(String[] args) {
        ConnectDB.getConnect();
    }
}