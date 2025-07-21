package com.example.webproyecto.daos.administrador;

import com.example.webproyecto.beans.AsignacionFormulario;
import com.example.webproyecto.daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class AsignacionFormularioDao extends BaseDao {

    public void insertarAsignacionFormulario(int idUsuario, int idFormulario, String estado) {
        String sql = "INSERT INTO asignacionformulario (idEncuestador, idFormulario, fechaAsignacion, estado) " +
                "VALUES (?, ?, NOW(), ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario); // en tu modelo, idEncuestador incluye coordinadores
            pstmt.setInt(2, idFormulario);
            pstmt.setString(3, estado);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            System.err.println("Error al insertar asignación de formulario: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
