package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Order;
import model.ProfitStats;

public class DashboardDAO {

    public double getTotalRevenue() {
        String sql = "SELECT SUM(total_amount) FROM hoa_don WHERE order_status NOT IN ('CANCELLED', 'CLIENT_CANCELLED', 'RETURNED', 'REFUNDED')";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return Math.round(rs.getDouble(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

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

    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM san_pham WHERE status = 'ACTIVE'";
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

    public List<Order> getRecentOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT TOP 5 h.id, ISNULL(h.receiver_name, u.full_name) as receiver_name, h.total_amount, h.order_status " +
                "FROM hoa_don h " +
                "LEFT JOIN users u ON h.user_id = u.id " +
                "ORDER BY h.id DESC";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setReceiverName(rs.getString("receiver_name"));
                o.setTotalMoney(Math.round(rs.getDouble("total_amount")));
                o.setStatus(rs.getString("order_status"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ProfitStats getProfitStats() {
        ProfitStats stats = new ProfitStats();

        String sqlActive = "SELECT h.id, h.total_amount, ISNULL(h.shipping_fee, 0) as shipping_fee, ISNULL(h.discount_amount, 0) as discount_amount " +
                "FROM hoa_don h " +
                "WHERE h.order_status NOT IN ('CANCELLED', 'CLIENT_CANCELLED', 'RETURNED', 'REFUNDED')";

        String sqlCancelled = "SELECT COUNT(*) as cnt, ISNULL(SUM(total_amount), 0) as total_cancelled " +
                "FROM hoa_don " +
                "WHERE order_status IN ('CANCELLED', 'CLIENT_CANCELLED', 'RETURNED', 'REFUNDED')";

        String sqlDetails = "SELECT d.invoice_id, d.price_at_purchase, d.quantity, d.line_total, d.upgrade_info, " +
                "ISNULL(p.price, d.price_at_purchase) AS original_price " +
                "FROM hoa_don_chi_tiet d " +
                "JOIN hoa_don h ON d.invoice_id = h.id " +
                "LEFT JOIN san_pham p ON d.product_id = p.id " +
                "WHERE h.order_status NOT IN ('CANCELLED', 'CLIENT_CANCELLED', 'RETURNED', 'REFUNDED')";

        double totalRev = 0;
        double totalShipping = 0;
        double totalDiscount = 0;
        int activeCount = 0;

        try (Connection conn = ConnectDB.getConnect()) {
            if (conn == null) return getDefaultProfitStats();

            try (PreparedStatement ps = conn.prepareStatement(sqlActive);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    activeCount++;
                    totalRev += rs.getDouble("total_amount");
                    totalShipping += rs.getDouble("shipping_fee");
                    totalDiscount += rs.getDouble("discount_amount");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlCancelled);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setCancelledOrdersCount(rs.getInt("cnt"));
                    stats.setCancelledAmount(Math.round(rs.getDouble("total_cancelled")));
                }
            }

            double productAmount = 0;
            double upgradeAmount = 0;

            try (PreparedStatement ps = conn.prepareStatement(sqlDetails);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    double lineTotal = rs.getDouble("line_total");
                    int qty = rs.getInt("quantity");
                    double origPrice = rs.getDouble("original_price");
                    String upInfo = rs.getString("upgrade_info");

                    if (upInfo != null && !upInfo.trim().isEmpty() && origPrice > 0 && origPrice < rs.getDouble("price_at_purchase")) {
                        double origLine = origPrice * qty;
                        double upLine = lineTotal - origLine;
                        if (upLine < 0) upLine = 0;
                        productAmount += origLine;
                        upgradeAmount += upLine;
                    } else {
                        productAmount += lineTotal;
                    }
                }
            }

            double serviceAmount = upgradeAmount + totalShipping;

            if (productAmount <= 0 && totalRev > 0) {
                productAmount = totalRev * 0.85;
                serviceAmount = totalRev * 0.15;
            }

            productAmount = Math.round(productAmount);
            serviceAmount = Math.round(serviceAmount);
            totalRev = Math.round(totalRev);

            double productProfit = Math.round(productAmount * 0.18);
            double serviceProfit = Math.round(serviceAmount * 0.65);
            double voucherDiscount = Math.round(totalDiscount);
            double totalProfit = Math.round((productProfit + serviceProfit) - voucherDiscount);
            if (totalProfit <= 0) {
                totalProfit = Math.round(totalRev * 0.20);
                productProfit = Math.round(totalProfit * 0.70);
                serviceProfit = Math.round(totalProfit * 0.30);
            }

            double sumProfit = productProfit + serviceProfit;
            double prodPct = sumProfit > 0 ? (productProfit / sumProfit) * 100.0 : 83.0;
            double servPct = sumProfit > 0 ? (serviceProfit / sumProfit) * 100.0 : 17.0;

            prodPct = Math.round(prodPct * 10.0) / 10.0;
            servPct = Math.round((100.0 - prodPct) * 10.0) / 10.0;

            double sumRev = productAmount + serviceAmount;
            double prodRevPct = sumRev > 0 ? Math.round((productAmount / sumRev) * 1000.0) / 10.0 : 85.0;
            double servRevPct = Math.round((100.0 - prodRevPct) * 10.0) / 10.0;

            stats.setTotalRevenue(totalRev);
            stats.setActiveOrdersCount(activeCount);
            stats.setProductRevenue(productAmount);
            stats.setServiceRevenue(serviceAmount);
            stats.setProductProfit(productProfit);
            stats.setServiceProfit(serviceProfit);
            stats.setVoucherDiscount(voucherDiscount);
            stats.setTotalProfit(totalProfit);
            stats.setProductPercent(prodPct);
            stats.setServicePercent(servPct);
            stats.setProductRevPercent(prodRevPct);
            stats.setServiceRevPercent(servRevPct);
            stats.setProfitMargin(totalRev > 0 ? Math.round((totalProfit / totalRev) * 1000.0) / 10.0 : 20.5);

            return stats;
        } catch (Exception e) {
            e.printStackTrace();
            return getDefaultProfitStats();
        }
    }

    private ProfitStats getDefaultProfitStats() {
        ProfitStats s = new ProfitStats();
        s.setTotalRevenue(0);
        s.setTotalProfit(0);
        s.setProductPercent(70.0);
        s.setServicePercent(30.0);
        s.setProductRevPercent(85.0);
        s.setServiceRevPercent(15.0);
        s.setProfitMargin(20.0);
        return s;
    }
}
