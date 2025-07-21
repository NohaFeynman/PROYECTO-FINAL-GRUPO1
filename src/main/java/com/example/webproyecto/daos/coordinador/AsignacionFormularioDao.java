package com.example.webproyecto.daos.coordinador;

import com.example.webproyecto.daos.BaseDao;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AsignacionFormularioDao extends BaseDao {

    public boolean yaEstaAsignado(int idEncuestador, int idFormulario) {
        String sql = "SELECT COUNT(*) FROM asignacionformulario WHERE idencuestador = ? AND idformulario = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idEncuestador);
            stmt.setInt(2, idFormulario);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return true;
        }
    }

    public void asignarFormulario(int idEncuestador, int idFormulario) {
        String sql = "INSERT INTO asignacionformulario (idencuestador, idformulario, fechaasignacion, estado) VALUES (?, ?, NOW(), 'Activo')";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idEncuestador);
            stmt.setInt(2, idFormulario);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Integer> obtenerFormulariosAsignados(int idEncuestador) {
        List<Integer> lista = new ArrayList<>();
        String sql = "SELECT idformulario FROM asignacionformulario WHERE idencuestador = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idEncuestador);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                lista.add(rs.getInt("idformulario"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
    public boolean existenAsignacionesActivas(int idFormulario, int idZona) {
        String sql = """
        SELECT 1
        FROM asignacionformulario af
        JOIN usuario u ON af.idEncuestador = u.idUsuario
        WHERE af.idFormulario = ? AND af.estado = 'Activo'
          AND u.idRol = 3 AND u.idZonaTrabajo = ?
        LIMIT 1
    """;
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idFormulario);
            stmt.setInt(2, idZona);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int obtenerIdAsignacion(int idFormulario, int idUsuario) throws SQLException {
        int idAsignacion = -1;

        String sql = "SELECT idAsignacionFormulario FROM asignacionformulario " +
                "WHERE idFormulario = ? AND idEncuestador = ? AND estado = 'Activo' LIMIT 1";

        try (Connection conn = this.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idFormulario);
            stmt.setInt(2, idUsuario);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                     rs.getInt("idAsignacionFormulario");
                }
            }
        }

        return idAsignacion;
    }


}
