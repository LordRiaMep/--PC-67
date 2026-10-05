package dao; // Đã thêm dòng này để hết lỗi package

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Order; // Đảm bảo bạn đã import model Order

public class DashboardDAO {

    // 1. Lấy tổng doanh thu
    public double getTotalRevenue() {
        String sql = "SELECT SUM(total_amount) FROM hoa_don";
        // Đã sửa thành getConnect() theo đúng class ConnectDB của bạn
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 2. Lấy tổng số đơn hàng
    public int getTotalOrders() {
        String sql = "SELECT COUNT(*) FROM hoa_don";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 3. Lấy tổng số sản phẩm
    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM san_pham";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 4. Lấy tổng số khách hàng
    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'CUSTOMER'";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 5. Lấy danh sách 5 đơn hàng gần đây cho bảng
    public List<Order> getRecentOrders() {
        List<Order> list = new ArrayList<>();
        // Query lấy dữ liệu từ bảng hoa_don và nối với users để lấy tên
        String sql = "SELECT TOP 5 h.id, u.full_name as receiver_name, h.total_amount, h.order_status " +
                "FROM hoa_don h " +
                "JOIN users u ON h.user_id = u.id " +
                "ORDER BY h.created_at DESC";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setReceiverName(rs.getString("receiver_name"));
                o.setTotalMoney(rs.getDouble("total_amount"));
                o.setStatus(rs.getString("order_status"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}