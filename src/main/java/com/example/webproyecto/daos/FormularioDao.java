package com.example.webproyecto.daos;

import com.example.webproyecto.beans.Formulario;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FormularioDao extends BaseDao {

    public List<Formulario> obtenerFormulariosAsignadosAlCoordinador(int idCoordinador) {
        List<Formulario> lista = new ArrayList<>();
        String sql = """
        SELECT f.*
        FROM formulario f
        INNER JOIN asignacionformulario af ON f.idformulario = af.idformulario
        WHERE af.idencuestador = ?
    """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCoordinador);

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Formulario formulario = new Formulario();
                formulario.setIdFormulario(rs.getInt("idFormulario"));
                formulario.setTitulo(rs.getString("titulo"));
                formulario.setDescripcion(rs.getString("descripcion"));
                formulario.setFechaCreacion(rs.getTimestamp("fechaCreacion"));
                formulario.setIdCoordinador(rs.getInt("idCoordinador"));
                formulario.setIdCarpeta(rs.getInt("idCarpeta"));
                lista.add(formulario);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }
    public boolean existenAsignacionesActivas(int idFormulario, int idCoordinador) {
        String sql = """
        SELECT COUNT(*) 
        FROM asignacionformulario af
        INNER JOIN usuario u ON af.idEncuestador = u.idUsuario
        WHERE af.idFormulario = ?
          AND af.estado = 'Activo'
          AND u.idRol = 3
          AND u.idZonaTrabajo = (
              SELECT idZonaTrabajo FROM usuario WHERE idUsuario = ?
          )
    """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idFormulario);
            stmt.setInt(2, idCoordinador);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public void desactivarFormularioParaZona(int idFormulario, int idCoordinador) {
        String sql = """
        UPDATE asignacionformulario
        SET estado = 'Inactivo'
        WHERE idFormulario = ?
          AND idEncuestador IN (
              SELECT idUsuario FROM usuario
              WHERE idRol = 3
                AND idZonaTrabajo = (
                    SELECT idZonaTrabajo FROM usuario WHERE idUsuario = ?
                )
          )
    """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idFormulario);
            stmt.setInt(2, idCoordinador);

            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void activarFormularioParaZona(int idFormulario, int idCoordinador) {
        String sql = """
        UPDATE asignacionformulario
        SET estado = 'Activo'
        WHERE idFormulario = ?
          AND idEncuestador IN (
              SELECT idUsuario FROM usuario
              WHERE idRol = 3
                AND idZonaTrabajo = (
                    SELECT idZonaTrabajo FROM usuario WHERE idUsuario = ?
                )
          )
    """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idFormulario);
            stmt.setInt(2, idCoordinador);

            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


}
