package com.example.webproyecto.daos;

import com.example.webproyecto.beans.Distrito;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DistritoDao extends BaseDao {

    public List<Distrito> listarDistritos() {
        List<Distrito> distritos = new ArrayList<>();
        String sql = "SELECT iddistrito, nombredistrito, idzona FROM distrito ORDER BY nombredistrito";
        
        System.out.println("🏘️ DistritoDao - Cargando lista de distritos");

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Distrito distrito = new Distrito();
                distrito.setIdDistrito(rs.getInt("iddistrito"));
                distrito.setNombreDistrito(rs.getString("nombredistrito"));
                distrito.setIdZona(rs.getInt("idzona"));
                distritos.add(distrito);
            }
            
            System.out.println("✅ " + distritos.size() + " distritos cargados correctamente");
            
        } catch (SQLException e) {
            System.err.println("❌ Error al cargar distritos: " + e.getMessage());
            e.printStackTrace();
        }

        return distritos;
    }
}
