package com.example.webproyecto.daos.encuestador;

import com.example.webproyecto.beans.Zona;
import com.example.webproyecto.daos.BaseDao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ZonaDao extends BaseDao {

    public List<Zona> listarZonas() {
        List<Zona> zonas = new ArrayList<>();
        String sql = "SELECT idZona, nombreZona FROM zona ORDER BY nombreZona";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Zona zona = new Zona(rs.getInt("idZona"), rs.getString("nombreZona"));
                zonas.add(zona);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return zonas;
    }
    
    public Zona obtenerZonaPorId(int idZona) {
        String sql = "SELECT idZona, nombreZona FROM zona WHERE idZona = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idZona);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Zona(rs.getInt("idZona"), rs.getString("nombreZona"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
