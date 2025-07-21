package com.example.webproyecto.daos.encuestador;

import com.example.webproyecto.daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class OpcionPreguntaDao extends BaseDao {

    public Integer obtenerIdOpcionPorTexto(int idPregunta, String textoOpcion) {
        String sql = "SELECT idopcion FROM opcionpregunta WHERE idpregunta = ? AND textoopcion = ?";
        try (Connection conn = this.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPregunta);
            stmt.setString(2, textoOpcion.trim()); // Se recomienda aplicar trim por seguridad

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("idopcion");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // Si no se encontró la opción
    }
}
