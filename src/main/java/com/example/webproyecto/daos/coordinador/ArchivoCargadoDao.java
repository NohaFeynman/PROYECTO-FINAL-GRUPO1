package com.example.webproyecto.daos.coordinador;

import com.example.webproyecto.beans.ArchivoCargado;
import com.example.webproyecto.daos.BaseDao;
import java.sql.*;
import java.time.LocalDateTime;

public class ArchivoCargadoDao extends BaseDao {
    
    public int guardarArchivo(ArchivoCargado archivo) throws SQLException {
        String sql = "INSERT INTO archivocargado (nombreArchivoOriginal, contenido, fechaCarga, " +
                    "idUsuarioQueCargo, idFormularioAsociado, estadoProcesamiento) " +
                    "VALUES (?, ?, ?, ?, ?, 'PENDIENTE')";

        try (Connection conn = this.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, archivo.getNombreArchivoOriginal());
            stmt.setBytes(2, archivo.getContenido());
            stmt.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
            stmt.setInt(4, archivo.getIdUsuarioQueCargo());
            stmt.setInt(5, archivo.getIdFormularioAsociado());
            
            stmt.executeUpdate();
            
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public void actualizarEstado(int idArchivo, String estado, String mensaje) throws SQLException {
        String sql = "UPDATE archivocargado SET estadoProcesamiento = ?, mensajeProcesamiento = ? " +
                    "WHERE idArchivoCargado = ?";
                    
        try (Connection conn = this.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, estado);
            stmt.setString(2, mensaje);
            stmt.setInt(3, idArchivo);
            stmt.executeUpdate();
        }
    }
}