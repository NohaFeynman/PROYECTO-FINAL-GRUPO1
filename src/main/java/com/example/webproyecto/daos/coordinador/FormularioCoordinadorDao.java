package com.example.webproyecto.daos.coordinador;

import com.example.webproyecto.beans.Formulario;
import com.example.webproyecto.daos.BaseDao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FormularioCoordinadorDao extends BaseDao {

    public int contarFormulariosNoAsignados(int idEncuestador) {
        int total = 0;
        String sql = """
            SELECT COUNT(*)
            FROM formulario f
            WHERE f.idformulario NOT IN (
                SELECT a.idFormulario
                FROM asignacionformulario a
                WHERE a.idEncuestador = ? AND a.estado = 'Activo'
            )
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idEncuestador);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return total;
    }

    public List<Formulario> obtenerFormulariosPaginados(int offset, int limit) {
        List<Formulario> lista = new ArrayList<>();

        String sql = """
        SELECT f.idFormulario, f.titulo, f.descripcion
        FROM formulario f
        ORDER BY f.fechacreacion DESC
        LIMIT ? OFFSET ?
    """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Formulario f = new Formulario();
                    f.setIdFormulario(rs.getInt("idFormulario"));
                    f.setTitulo(rs.getString("titulo"));
                    f.setDescripcion(rs.getString("descripcion"));
                    lista.add(f);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

}
