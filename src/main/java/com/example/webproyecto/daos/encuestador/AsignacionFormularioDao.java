package com.example.webproyecto.daos.encuestador;
import com.example.webproyecto.daos.BaseDao;
import com.example.webproyecto.beans.AsignacionFormulario;
import com.example.webproyecto.beans.Formulario;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AsignacionFormularioDao extends BaseDao {

    public List<AsignacionFormulario> obtenerFormulariosAsignados(int idEncuestador) {
        List<AsignacionFormulario> lista = new ArrayList<>();

        String sql = """
            SELECT af.*, f.titulo, f.descripcion, f.fechaCreacion
            FROM asignacionformulario af
            INNER JOIN formulario f ON af.idFormulario = f.idFormulario
            WHERE af.idEncuestador = ? and af.estado = 'Activo'
            """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idEncuestador);

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                AsignacionFormulario asignacion = new AsignacionFormulario();
                asignacion.setIdAsignacionFormulario(rs.getInt("idAsignacionFormulario"));
                asignacion.setIdEncuestador(rs.getInt("idEncuestador"));
                asignacion.setIdFormulario(rs.getInt("idFormulario"));
                asignacion.setFechaAsignacion(rs.getTimestamp("fechaAsignacion"));
                asignacion.setEstado(rs.getString("estado"));

                // Datos del formulario relacionado
                Formulario formulario = new Formulario();
                formulario.setIdFormulario(rs.getInt("idFormulario"));
                formulario.setTitulo(rs.getString("titulo"));
                formulario.setDescripcion(rs.getString("descripcion"));
                formulario.setFechaCreacion(rs.getTimestamp("fechaCreacion"));

                asignacion.setFormulario(formulario);

                lista.add(asignacion);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }
    public void asignarFormulario(int idEncuestador, int idFormulario) {
        String sql = "INSERT INTO asignacionformulario (idencuestador, idformulario, estado) VALUES (?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idEncuestador);
            stmt.setInt(2, idFormulario);
            stmt.setString(3, "pendiente");
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
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

    public int obtenerIdAsignacionFormulario(int idFormulario, int idUsuario) throws SQLException {
        int idAsignacion = -1;

        String sql = "SELECT idAsignacionFormulario FROM asignacionformulario " +
                "WHERE idFormulario = ? AND idEncuestador = ? AND estado = 'Activo' LIMIT 1";

        try (Connection conn = this.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idFormulario);
            stmt.setInt(2, idUsuario);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    idAsignacion = rs.getInt("idAsignacionFormulario");
                }
            }
        }

        return idAsignacion;
    }


}
