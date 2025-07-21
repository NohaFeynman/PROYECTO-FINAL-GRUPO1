package com.example.webproyecto.daos.coordinador;

import com.example.webproyecto.beans.ArchivoCargado;
import com.example.webproyecto.daos.BaseDao;
import com.example.webproyecto.beans.*;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class SubidaMasivaDao extends BaseDao {

    public int contarArchivosPorUsuarioYFormulario(int idUsuario, int idFormulario) {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM archivocargado WHERE idUsuarioQueCargo = ? AND idFormularioAsociado = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);
            pstmt.setInt(2, idFormulario);

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return total;
    }

    public List<ArchivoCargado> obtenerArchivosPorUsuarioYFormulario(int idUsuario, int idFormulario, int offset, int limit) {
        List<ArchivoCargado> lista = new ArrayList<>();

        String sql = "SELECT idArchivoCargado, nombreArchivoOriginal, fechaCarga, estadoProcesamiento, mensajeProcesamiento " +
                "FROM archivocargado WHERE idUsuarioQueCargo = ? AND idFormularioAsociado = ? " +
                "ORDER BY fechaCarga DESC LIMIT ? OFFSET ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);
            pstmt.setInt(2, idFormulario);
            pstmt.setInt(3, limit);
            pstmt.setInt(4, offset);

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                ArchivoCargado archivo = new ArchivoCargado();
                archivo.setIdArchivoCargado(rs.getInt("idArchivoCargado"));
                archivo.setNombreArchivoOriginal(rs.getString("nombreArchivoOriginal"));

                Timestamp ts = rs.getTimestamp("fechaCarga");
                if (ts != null) {
                    archivo.setFechaCarga(ts.toLocalDateTime());
                }

                archivo.setEstadoProcesamiento(rs.getString("estadoProcesamiento"));
                archivo.setMensajeProcesamiento(rs.getString("mensajeProcesamiento"));

                lista.add(archivo);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    public List<Pregunta> obtenerPreguntasOrdenadasPorFormulario(int idFormulario) {
        List<Pregunta> preguntas = new ArrayList<>();
        String sql = "SELECT idpregunta, textopregunta, tipopregunta FROM pregunta " +
                "WHERE idformulario = ? ORDER BY orden ASC";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idFormulario);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Pregunta p = new Pregunta();
                p.setIdPregunta(rs.getInt("idpregunta"));
                p.setTextoPregunta(rs.getString("textopregunta"));
                p.setTipoPregunta(rs.getInt("tipopregunta"));
                preguntas.add(p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return preguntas;
    }

    public int obtenerUltimoNumeroSesion(int idUsuario, int idFormulario) {
        String sql = "SELECT MAX(sr.numeroSesion) FROM sesionrespuesta sr " +
                "JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario " +
                "WHERE af.idEncuestador = ? AND af.idFormulario = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idFormulario);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int insertarSesionRespuesta(int idFormulario, int numeroSesion) {
        int idSesion = -1;
        String sql = "INSERT INTO sesionrespuesta (fechainicio, fechaenvio, estadoterminado, idasignacionformulario, numeroSesion) " +
                "SELECT NOW(), NOW(), 1, af.idasignacionformulario, ? " +
                "FROM asignacionformulario af " +
                "WHERE af.idFormulario = ? AND af.idEncuestador IS NULL LIMIT 1";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, numeroSesion);
            stmt.setInt(2, idFormulario);

            stmt.executeUpdate();

            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                idSesion = rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return idSesion;
    }

    public void insertarRespuestaAbierta(int idSesion, int idPregunta, String texto) {
        String sql = "INSERT INTO respuesta (idsesion, idpregunta, textoRespuesta) VALUES (?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idSesion);
            stmt.setInt(2, idPregunta);
            stmt.setString(3, texto);

            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void insertarRespuestaOpcion(int idSesion, int idPregunta, int idOpcion) {
        String sql = "INSERT INTO respuesta (idsesion, idpregunta, idopcion) VALUES (?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idSesion);
            stmt.setInt(2, idPregunta);
            stmt.setInt(3, idOpcion);

            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public Integer obtenerIdOpcionPorTexto(int idPregunta, String texto) {
        String sql = "SELECT idopcion FROM opcionpregunta WHERE idpregunta = ? AND textoopcion = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPregunta);
            stmt.setString(2, texto);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("idopcion");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public String generarNombreArchivo(String original, int idUsuario) {
        LocalDateTime ahora = LocalDateTime.now();
        int total = contarArchivosPorUsuarioEnFecha(idUsuario, ahora.toLocalDate().toString());

        String correlativo = String.format("%05d", total + 1);
        return ahora.toLocalDate() + "_" + correlativo + "_" + original;
    }

    public int contarArchivosPorUsuarioEnFecha(int idUsuario, String fecha) {
        String sql = "SELECT COUNT(*) FROM archivocargado " +
                "WHERE idUsuarioQueCargo = ? AND DATE(fechaCarga) = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setString(2, fecha);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void insertarArchivo(String nombre, byte[] contenido, int idUsuario, String estado, String mensaje, int idFormulario) {
        String sql = "INSERT INTO archivocargado (nombreArchivoOriginal, contenido, fechaCarga, idUsuarioQueCargo, estadoProcesamiento, mensajeProcesamiento, idFormularioAsociado) " +
                "VALUES (?, ?, NOW(), ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, nombre);
            stmt.setBytes(2, contenido);
            stmt.setInt(3, idUsuario);
            stmt.setString(4, estado);
            stmt.setString(5, mensaje);
            stmt.setInt(6, idFormulario);

            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public ArchivoCargado obtenerArchivoPorId(int idArchivo) {
        String sql = "SELECT nombreArchivoOriginal, contenido FROM archivocargado WHERE idArchivoCargado = ?";
        ArchivoCargado archivo = null;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idArchivo);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                archivo = new ArchivoCargado();
                archivo.setNombreArchivoOriginal(rs.getString("nombreArchivoOriginal"));
                archivo.setContenido(rs.getBytes("contenido"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return archivo;
    }

}
