package com.example.webproyecto.daos;

import com.example.webproyecto.utils.CodeGenerator;
import com.example.webproyecto.beans.Usuario;
import java.sql.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class CodigoDao extends BaseDao {
    
    // Método para hashear contraseñas con SHA-256
    private String sha256(String input) {
        if (input == null) {
            throw new IllegalArgumentException("El input no puede ser null");
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(input.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }
    
    public String generateCodigo(String correo) {
        Usuario usuario = getUsuarioByCorreo(correo);
        String codigo = CodeGenerator.generator();
        
        // Usar las nuevas columnas de fecha para manejar la expiración
        String sql = "INSERT INTO codigo_verificacion (idusuario, codigo, fecha_creacion, fecha_expiracion) VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 5 MINUTE))";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, usuario.getIdUsuario());
            pstmt.setString(2, codigo);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return codigo;
    }

    public Usuario getUsuarioByCorreo(String correo) {
        Usuario usuario = null;
        String sql = "SELECT u.* FROM usuario u JOIN credencial c ON u.idusuario = c.idusuario WHERE c.correo = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, correo);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("idusuario"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return usuario;
    }

    public boolean findCodigo(String codigoIngresado) {
        // Verificar que el código existe y no ha expirado
        String sql = "SELECT codigo FROM codigo_verificacion WHERE codigo = ? AND fecha_expiracion > NOW()";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, codigoIngresado);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void deleteCodigo(String codigo) {
        String sql = "DELETE FROM codigo_verificacion WHERE codigo = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, codigo);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public boolean marcarUsuarioComoVerificado(int usuarioId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Iniciar transacción
            
            // 1. Actualizar la credencial como verificada
            String sqlCredencial = "UPDATE credencial SET verificado = 1 WHERE idusuario = ?";
            try (PreparedStatement stmtCredencial = conn.prepareStatement(sqlCredencial)) {
                stmtCredencial.setInt(1, usuarioId);
                int filasCredencial = stmtCredencial.executeUpdate();
                System.out.println("✅ Credencial marcada como verificada: " + usuarioId + " (filas: " + filasCredencial + ")");
            }
            
            // 2. Actualizar el estado del usuario a activo (idEstado = 2)
            String sqlUsuario = "UPDATE usuario SET idEstado = 2 WHERE idusuario = ?";
            try (PreparedStatement stmtUsuario = conn.prepareStatement(sqlUsuario)) {
                stmtUsuario.setInt(1, usuarioId);
                int filasUsuario = stmtUsuario.executeUpdate();
                System.out.println("✅ Usuario activado (estado = 2): " + usuarioId + " (filas: " + filasUsuario + ")");
            }
            
            conn.commit(); // Confirmar transacción
            return true;

        } catch (SQLException e) {
            System.err.println("❌ Error al marcar usuario como verificado: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Revertir cambios en caso de error
                } catch (SQLException rollbackEx) {
                    System.err.println("❌ Error en rollback: " + rollbackEx.getMessage());
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Restaurar auto commit
                    conn.close();
                } catch (SQLException closeEx) {
                    System.err.println("❌ Error al cerrar conexión: " + closeEx.getMessage());
                }
            }
        }
    }

    // CORREGIDO: Método para obtener el ID de usuario a partir del código
    public int getUsuarioIdByCodigo(String codigo) {
        // Solo obtener usuario si el código no ha expirado
        String sql = "SELECT u.idusuario FROM usuario u " +
                    "JOIN credencial c ON u.idusuario = c.idusuario " +
                    "JOIN codigo_verificacion cv ON u.idusuario = cv.idusuario " +
                    "WHERE cv.codigo = ? AND cv.fecha_expiracion > NOW()";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, codigo);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("idusuario");
                }
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener usuario ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }

    public void actualizarContrasena(int usuarioId, String contrasena) {
        System.out.println("🔐 CodigoDao.actualizarContrasena - Iniciando para usuario ID: " + usuarioId);
        
        if (contrasena == null || contrasena.trim().isEmpty()) {
            System.err.println("❌ Contraseña vacía o null");
            throw new IllegalArgumentException("La contraseña no puede ser vacía o null");
        }
        
        // Actualizar tanto la contraseña hasheada como la plain
        String sql = "UPDATE credencial SET contrasenha = ?, contrasenha_plain = ? WHERE idusuario = ?";
        String hashedPassword = sha256(contrasena);
        
        System.out.println("🔑 Hash generado para contraseña (primeros 10 caracteres): " + hashedPassword.substring(0, 10) + "...");
        System.out.println("🔓 Guardando contraseña plain en contrasenha_plain");
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, hashedPassword);      // contrasenha (hash)
            pstmt.setString(2, contrasena);          // contrasenha_plain (texto plano)
            pstmt.setInt(3, usuarioId);
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("✅ Filas afectadas en actualización de contraseña: " + rowsAffected);
            
            if (rowsAffected == 0) {
                System.err.println("⚠️ No se actualizó ninguna fila. Usuario ID: " + usuarioId + " podría no existir");
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error SQL al actualizar contraseña: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }

    // MÉTODO guardarCodigo corregido:
    public boolean guardarCodigo(String correo, String codigo) {
        System.out.println("💾 Guardando código para: " + correo);
        
        // Primero obtener el usuario
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            System.err.println("❌ Usuario no encontrado para el correo: " + correo);
            return false;
        }
        
        System.out.println("✅ Usuario encontrado - ID: " + usuario.getIdUsuario() + " para correo: " + correo);
        
        // Usar las nuevas columnas de fecha con expiración de 5 minutos
        String sql = "INSERT INTO codigo_verificacion (idusuario, codigo, fecha_creacion, fecha_expiracion) " +
                    "VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 5 MINUTE)) " +
                    "ON DUPLICATE KEY UPDATE codigo = VALUES(codigo), fecha_creacion = NOW(), fecha_expiracion = DATE_ADD(NOW(), INTERVAL 5 MINUTE)";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuario.getIdUsuario());
            stmt.setString(2, codigo);
            
            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Código guardado: " + codigo + " para: " + correo + " (filas afectadas: " + filasAfectadas + ")");
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al guardar código: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean actualizarCodigo(String correo, String nuevoCodigo) {
        System.out.println("🔄 Actualizando código para: " + correo + " con nuevo código: " + nuevoCodigo);
        
        // Primero necesitamos obtener el usuario por su correo
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            System.err.println("❌ Usuario no encontrado para correo: " + correo);
            return false;
        }
        
        String sql = "UPDATE codigo_verificacion " +
                    "SET codigo = ?, fecha_creacion = CURRENT_TIMESTAMP, " +
                    "fecha_expiracion = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 5 MINUTE) " +
                    "WHERE idusuario = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, nuevoCodigo);
            stmt.setInt(2, usuario.getIdUsuario());
            
            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Código actualizado para usuario ID: " + usuario.getIdUsuario() + 
                             ", nuevo código: " + nuevoCodigo + ", filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar código: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // MÉTODO para verificar código considerando expiración
    public boolean verificarCodigo(String correo, String codigo) {
        String sql = "SELECT cv.codigo FROM codigo_verificacion cv " +
                    "JOIN usuario u ON cv.idusuario = u.idusuario " +
                    "JOIN credencial c ON u.idusuario = c.idusuario " +
                    "WHERE c.correo = ? AND cv.codigo = ? AND cv.fecha_expiracion > NOW()";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, correo);
            stmt.setString(2, codigo);
            
            try (ResultSet rs = stmt.executeQuery()) {
                boolean esValido = rs.next();
                if (esValido) {
                    System.out.println("✅ Código válido para: " + correo);
                } else {
                    System.out.println("❌ Código inválido o expirado para: " + correo);
                }
                return esValido;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al verificar código: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // MÉTODO para verificar si el código está expirado
    public boolean codigoExpirado(String correo) {
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            return true; // Si no existe el usuario, consideramos que está expirado
        }
        
        String sql = "SELECT fecha_expiracion FROM codigo_verificacion " +
                    "WHERE idusuario = ? AND fecha_expiracion <= CURRENT_TIMESTAMP";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuario.getIdUsuario());
            
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next(); // true si existe un código expirado
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al verificar expiración: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // MÉTODO para obtener tiempo restante en segundos
    public int obtenerTiempoRestante(String correo) {
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            return 0; // Si no existe el usuario, no hay tiempo restante
        }
        
        String sql = "SELECT TIMESTAMPDIFF(SECOND, CURRENT_TIMESTAMP, fecha_expiracion) as segundos_restantes " +
                    "FROM codigo_verificacion WHERE idusuario = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuario.getIdUsuario());
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int segundos = rs.getInt("segundos_restantes");
                    return Math.max(0, segundos); // No devolver números negativos
                }
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener tiempo restante: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }

    // MÉTODO para limpiar códigos expirados (ejecutar periódicamente)
    public void limpiarCodigosExpirados() {
        String sql = "DELETE FROM codigo_verificacion WHERE fecha_expiracion <= NOW()";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            int filasEliminadas = stmt.executeUpdate();
            System.out.println("🧹 Códigos expirados eliminados: " + filasEliminadas);
            
        } catch (SQLException e) {
            System.err.println("❌ Error al limpiar códigos expirados: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // AGREGAR este método a tu CodigoDao.java

    public boolean eliminarCodigo(String correo) {
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            return false;
        }
        
        String sql = "DELETE FROM codigo_verificacion WHERE idusuario = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuario.getIdUsuario());
            
            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Código eliminado para: " + correo);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar código: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // CORREGIDO: Método para activar usuario por correo
    public boolean activarUsuarioPorCorreo(String correo) {
        String sql = "UPDATE usuario u " +
                    "JOIN credencial c ON u.idusuario = c.idusuario " +
                    "SET u.id_estado = 2 " +
                    "WHERE c.correo = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, correo);
            
            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Usuario activado por correo: " + correo);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al activar usuario: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Método para obtener el tiempo restante del código en segundos
    public int getTiempoRestanteCodigo(String correo) {
        System.out.println("🔍 getTiempoRestanteCodigo - Correo: " + correo);
        
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            System.out.println("❌ Usuario no encontrado para correo: " + correo);
            return 0;
        }
        
        System.out.println("✅ Usuario encontrado - ID: " + usuario.getIdUsuario());
        
        String sql = "SELECT TIMESTAMPDIFF(SECOND, NOW(), fecha_expiracion) AS segundos_restantes " +
                    "FROM codigo_verificacion " +
                    "WHERE idusuario = ? AND fecha_expiracion > NOW() " +
                    "ORDER BY fecha_creacion DESC LIMIT 1";
        
        System.out.println("🔍 SQL: " + sql);
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            System.out.println("🔗 Conexión obtenida, preparando statement...");
            stmt.setInt(1, usuario.getIdUsuario());
            
            try (ResultSet rs = stmt.executeQuery()) {
                System.out.println("📊 Query ejecutada, procesando resultados...");
                if (rs.next()) {
                    int segundosRestantes = rs.getInt("segundos_restantes");
                    System.out.println("⏰ Segundos restantes encontrados: " + segundosRestantes);
                    return Math.max(0, segundosRestantes); // No devolver negativos
                } else {
                    System.out.println("📝 No se encontraron códigos activos para el usuario");
                }
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error SQL en getTiempoRestanteCodigo:");
            System.err.println("   Mensaje: " + e.getMessage());
            System.err.println("   Código: " + e.getErrorCode());
            System.err.println("   SQLState: " + e.getSQLState());
            e.printStackTrace();
        }
        
        System.out.println("⏰ Retornando 0 (código expirado o no existe)");
        return 0; // Código expirado o no existe
    }
    
    // =================================================================
    // MÉTODOS ESPECÍFICOS PARA RECUPERACIÓN DE CONTRASEÑA
    // =================================================================
    
    /**
     * Genera y guarda un código específico para recuperación de contraseña
     */
    public boolean generarCodigoRecuperacion(String correo, String codigo) {
        System.out.println("🔐 Generando código de recuperación para: " + correo);
        
        // Primero obtener el usuario
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            System.err.println("❌ Usuario no encontrado para el correo: " + correo);
            return false;
        }
        
        System.out.println("✅ Usuario encontrado - ID: " + usuario.getIdUsuario() + " para correo: " + correo);
        
        // Crear tabla separada para códigos de recuperación (si no existe)
        // O usar una columna tipo para diferenciar en la misma tabla
        String sql = "INSERT INTO codigo_verificacion (idusuario, codigo, fecha_creacion, fecha_expiracion, tipo) " +
                    "VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 5 MINUTE), 'recuperacion') " +
                    "ON DUPLICATE KEY UPDATE codigo = VALUES(codigo), fecha_creacion = NOW(), " +
                    "fecha_expiracion = DATE_ADD(NOW(), INTERVAL 5 MINUTE), tipo = 'recuperacion'";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuario.getIdUsuario());
            stmt.setString(2, codigo);
            
            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Código de recuperación guardado: " + codigo + " para: " + correo + " (filas afectadas: " + filasAfectadas + ")");
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            // Si no existe la columna 'tipo', usar método alternativo
            System.err.println("⚠️ Error al guardar con tipo, intentando método alternativo: " + e.getMessage());
            return guardarCodigoRecuperacionAlternativo(usuario.getIdUsuario(), codigo);
        }
    }
    
    /**
     * Método alternativo sin columna tipo (por si la BD no tiene esa columna)
     */
    private boolean guardarCodigoRecuperacionAlternativo(int usuarioId, String codigo) {
        // Eliminar cualquier código existente para este usuario
        String deleteSql = "DELETE FROM codigo_verificacion WHERE idusuario = ?";
        String insertSql = "INSERT INTO codigo_verificacion (idusuario, codigo, fecha_creacion, fecha_expiracion) " +
                          "VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 5 MINUTE))";
        
        try (Connection conn = getConnection()) {
            // Eliminar códigos anteriores
            try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                deleteStmt.setInt(1, usuarioId);
                deleteStmt.executeUpdate();
            }
            
            // Insertar nuevo código
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setInt(1, usuarioId);
                insertStmt.setString(2, codigo);
                int filasAfectadas = insertStmt.executeUpdate();
                System.out.println("✅ Código de recuperación guardado (método alternativo): " + codigo);
                return filasAfectadas > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error en método alternativo: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Actualiza un código específico para recuperación de contraseña
     */
    public boolean actualizarCodigoRecuperacion(String correo, String nuevoCodigo) {
        System.out.println("🔄 Actualizando código de recuperación para: " + correo + " con nuevo código: " + nuevoCodigo);
        
        // Primero necesitamos obtener el usuario por su correo
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            System.err.println("❌ Usuario no encontrado para correo: " + correo);
            return false;
        }
        
        System.out.println("✅ Usuario encontrado - ID: " + usuario.getIdUsuario());
        
        // Primero verificar si ya existe un código para este usuario
        String checkSql = "SELECT COUNT(*) FROM codigo_verificacion WHERE idusuario = ?";
        try (Connection conn = getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            
            checkStmt.setInt(1, usuario.getIdUsuario());
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("📊 Códigos existentes para usuario " + usuario.getIdUsuario() + ": " + count);
                    
                    if (count > 0) {
                        // Actualizar código existente
                        String updateSql = "UPDATE codigo_verificacion " +
                                         "SET codigo = ?, fecha_creacion = CURRENT_TIMESTAMP, " +
                                         "fecha_expiracion = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 5 MINUTE) " +
                                         "WHERE idusuario = ?";
                        
                        try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                            updateStmt.setString(1, nuevoCodigo);
                            updateStmt.setInt(2, usuario.getIdUsuario());
                            
                            int filasAfectadas = updateStmt.executeUpdate();
                            System.out.println("🔄 Filas afectadas en UPDATE: " + filasAfectadas);
                            
                            if (filasAfectadas > 0) {
                                System.out.println("✅ Código actualizado exitosamente para usuario ID: " + usuario.getIdUsuario());
                                return true;
                            } else {
                                System.err.println("❌ No se pudo actualizar el código");
                                return false;
                            }
                        }
                    } else {
                        // No existe código, crear uno nuevo
                        System.out.println("📝 No existe código previo, creando nuevo código para usuario ID: " + usuario.getIdUsuario());
                        return crearNuevoCodigo(usuario.getIdUsuario(), nuevoCodigo);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al verificar/actualizar código de recuperación: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
        
        return false;
    }
    
    /**
     * Crea un nuevo código de verificación para un usuario
     */
    private boolean crearNuevoCodigo(int usuarioId, String codigo) {
        String insertSql = "INSERT INTO codigo_verificacion (idusuario, codigo, fecha_creacion, fecha_expiracion) " +
                          "VALUES (?, ?, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 5 MINUTE))";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(insertSql)) {
            
            stmt.setInt(1, usuarioId);
            stmt.setString(2, codigo);
            
            int filasAfectadas = stmt.executeUpdate();
            System.out.println("➕ Filas afectadas en INSERT: " + filasAfectadas);
            
            if (filasAfectadas > 0) {
                System.out.println("✅ Nuevo código creado exitosamente para usuario ID: " + usuarioId);
                return true;
            } else {
                System.err.println("❌ No se pudo crear el nuevo código");
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al crear nuevo código: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Verifica un código específico para recuperación de contraseña
     */
    public boolean verificarCodigoRecuperacion(String correo, String codigo) {
        System.out.println("🔍 Verificando código de recuperación: " + codigo + " para: " + correo);
        
        String sql = "SELECT cv.codigo FROM codigo_verificacion cv " +
                    "JOIN usuario u ON cv.idusuario = u.idusuario " +
                    "JOIN credencial c ON u.idusuario = c.idusuario " +
                    "WHERE c.correo = ? AND cv.codigo = ? AND cv.fecha_expiracion > NOW()";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, correo);
            stmt.setString(2, codigo);
            
            try (ResultSet rs = stmt.executeQuery()) {
                boolean esValido = rs.next();
                if (esValido) {
                    System.out.println("✅ Código de recuperación válido para: " + correo);
                } else {
                    System.out.println("❌ Código de recuperación inválido o expirado para: " + correo);
                }
                return esValido;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al verificar código de recuperación: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Elimina un código de recuperación específico por correo
     */
    public boolean eliminarCodigoRecuperacion(String correo) {
        System.out.println("🗑️ Eliminando código de recuperación para: " + correo);
        
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            System.err.println("❌ Usuario no encontrado para eliminar código: " + correo);
            return false;
        }
        
        String sql = "DELETE FROM codigo_verificacion WHERE idusuario = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuario.getIdUsuario());
            
            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Código de recuperación eliminado para: " + correo + " (filas afectadas: " + filasAfectadas + ")");
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar código de recuperación: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Obtiene el tiempo restante de un código de recuperación en segundos
     */
    public int getTiempoRestanteRecuperacion(String correo) {
        System.out.println("⏰ getTiempoRestanteRecuperacion - Correo: " + correo);
        
        Usuario usuario = getUsuarioByCorreo(correo);
        if (usuario == null) {
            System.out.println("❌ Usuario no encontrado para correo: " + correo);
            return 0;
        }
        
        System.out.println("✅ Usuario encontrado - ID: " + usuario.getIdUsuario());
        
        String sql = "SELECT TIMESTAMPDIFF(SECOND, NOW(), fecha_expiracion) AS segundos_restantes " +
                    "FROM codigo_verificacion " +
                    "WHERE idusuario = ? AND fecha_expiracion > NOW() " +
                    "ORDER BY fecha_creacion DESC LIMIT 1";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuario.getIdUsuario());
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int segundosRestantes = rs.getInt("segundos_restantes");
                    System.out.println("⏰ Segundos restantes para recuperación: " + segundosRestantes);
                    return Math.max(0, segundosRestantes);
                } else {
                    System.out.println("📝 No se encontraron códigos activos de recuperación para el usuario");
                }
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error SQL en getTiempoRestanteRecuperacion:");
            System.err.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }

    /**
     * Obtiene el correo electrónico asociado a un código de verificación
     * @param codigo El código de verificación
     * @return El correo electrónico o null si no se encuentra
     */
    public String getCorreoByCode(String codigo) {
        String correo = null;
        String sql = "SELECT c.correo FROM credencial c " +
                    "JOIN usuario u ON c.idusuario = u.idusuario " +
                    "JOIN codigo_verificacion cv ON u.idusuario = cv.idusuario " +
                    "WHERE cv.codigo = ? AND cv.fecha_expiracion > NOW()";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, codigo);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    correo = rs.getString("correo");
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener correo por código: " + e.getMessage());
            e.printStackTrace();
        }
        
        return correo;
    }

    /**
     * Obtiene el correo del último código de verificación generado
     * @return El correo electrónico o null si no se encuentra
     */
    public String obtenerUltimoCorreoConCodigo() {
        String correo = null;
        String sql = "SELECT c.correo FROM credencial c " +
                    "JOIN usuario u ON c.idusuario = u.idusuario " +
                    "JOIN codigo_verificacion cv ON u.idusuario = cv.idusuario " +
                    "WHERE cv.fecha_expiracion > NOW() " +
                    "ORDER BY cv.fecha_creacion DESC LIMIT 1";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    correo = rs.getString("correo");
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener último correo con código: " + e.getMessage());
            e.printStackTrace();
        }
        
        return correo;
    }

    /**
     * Elimina todos los códigos de verificación para un correo específico
     * @param correo El correo del usuario
     * @return true si se eliminaron códigos, false en caso contrario
     */
    public boolean eliminarCodigosPorCorreo(String correo) {
        String sql = """
            DELETE cv FROM codigo_verificacion cv
            INNER JOIN usuario u ON cv.idusuario = u.idusuario
            INNER JOIN credencial c ON u.idusuario = c.idusuario
            WHERE c.correo = ?
            """;
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, correo);
            int rowsAffected = pstmt.executeUpdate();
            
            System.out.println("🧹 Códigos eliminados para " + correo + ": " + rowsAffected);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar códigos por correo: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
