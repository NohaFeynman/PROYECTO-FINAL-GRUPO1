package com.example.webproyecto.daos;

import com.example.webproyecto.beans.Credencial;
import com.example.webproyecto.beans.Usuario;
import com.example.webproyecto.utils.PasswordUtil;


import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;

/**
 * CredencialDao - Maneja las operaciones de credenciales de usuario
 * Extiende BaseDao para usar conexión centralizada
 */
public class CredencialDao extends BaseDao {

    // Ya no necesitamos estas variables ya que la conexión viene de BaseDao
    // private final String url = "jdbc:mysql://localhost:3306/proyecto";
    // private final String user = "root";
    // private final String pass = "root";

    // Utilidad para hashear con SHA-256
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


    public Usuario validarLogin(String correo, String contrasenha) {
        Usuario usuario = null;

        String sql = """
            SELECT u.idUsuario, u.nombre, u.apellidopaterno, u.apellidomaterno, u.dni, u.direccion,
                   u.idRol, u.idDistrito, u.idEstado, u.foto, c.contrasenha
            FROM usuario u
            INNER JOIN credencial c ON u.idUsuario = c.idUsuario
            WHERE c.correo = ? AND u.idEstado IN (1,2,3) AND c.verificado = TRUE
            """;

        // Ahora usamos getConnection() de BaseDao
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, correo);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String hashAlmacenado = rs.getString("contrasenha");
                String hashIngresado = sha256(contrasenha);
                if (hashIngresado.equals(hashAlmacenado)) {
                    usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("idUsuario"));
                    usuario.setNombre(rs.getString("nombre"));
                    usuario.setApellidopaterno(rs.getString("apellidopaterno"));
                    usuario.setApellidomaterno(rs.getString("apellidomaterno"));
                    usuario.setDni(rs.getString("dni"));
                    usuario.setDireccion(rs.getString("direccion"));
                    usuario.setIdDistrito(rs.getInt("idDistrito"));
                    usuario.setIdRol(rs.getInt("idRol"));
                    usuario.setIdEstado(rs.getInt("idEstado"));
                    usuario.setFoto(rs.getString("foto"));
                }
            }

        } catch (SQLException e) {
            System.err.println("❌ Error en validarLogin: " + e.getMessage());
            e.printStackTrace();
        }

        return usuario;
    }

    public boolean cambiarContrasenha(int idUsuario, String contrasenaActual, String nuevaContrasenha) {
        // Hashear ambas contraseñas antes de usarlas
        String hashActual = sha256(contrasenaActual);
        String hashNueva = sha256(nuevaContrasenha);

        String sqlVerificar = "SELECT 1 FROM credencial WHERE idUsuario = ? AND contrasenha = ?";
        String sqlActualizar = "UPDATE credencial SET contrasenha = ? WHERE idUsuario = ?";

        try (Connection conn = getConnection()) {
            // Verificar contraseña actual
            try (PreparedStatement stmtVerificar = conn.prepareStatement(sqlVerificar)) {
                stmtVerificar.setInt(1, idUsuario);
                stmtVerificar.setString(2, hashActual);

                ResultSet rs = stmtVerificar.executeQuery();
                if (!rs.next()) {
                    return false; // La contraseña actual no coincide
                }
            }

            // Actualizar a la nueva contraseña
            try (PreparedStatement stmtActualizar = conn.prepareStatement(sqlActualizar)) {
                stmtActualizar.setString(1, hashNueva);
                stmtActualizar.setInt(2, idUsuario);

                return stmtActualizar.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Métodos adicionales para CredencialDao.java

    // Métodos adicionales para CredencialDao
    public boolean insertarCredencial(Credencial credencial) {
        String sql = "INSERT INTO credencial (correo, contrasenha, idUsuario, verificado) VALUES (?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, credencial.getCorreo());
            // Solo hashear si la contraseña no es null
            if (credencial.getContrasenha() != null) {
                stmt.setString(2, sha256(credencial.getContrasenha()));
            } else {
                stmt.setString(2, null); // Permitir contraseña null para coordinadores pendientes
            }
            stmt.setInt(3, credencial.getIdUsuario());
            stmt.setBoolean(4, credencial.getContrasenha() != null); // Verificado solo si tiene contraseña

            int filasAfectadas = stmt.executeUpdate();
            return filasAfectadas > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean existeCorreo(String correo) {
        String sql = "SELECT 1 FROM credencial WHERE correo = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, correo);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean actualizarCorreo(int idUsuario, String nuevoCorreo) {
        String sql = "UPDATE credencial SET correo = ? WHERE idUsuario = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, nuevoCorreo);
            stmt.setInt(2, idUsuario);

            int filasAfectadas = stmt.executeUpdate();
            return filasAfectadas > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    public boolean insertarUsuario(Usuario usuario) {
        String sql = "INSERT INTO usuario (nombre, apellidopaterno, apellidomaterno, dni, direccion, idDistrito, idRol, idEstado, foto) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, usuario.getNombre());
            stmt.setString(2, usuario.getApellidopaterno());
            stmt.setString(3, usuario.getApellidomaterno());
            stmt.setString(4, usuario.getDni());
            stmt.setString(5, usuario.getDireccion());
            stmt.setInt(6, usuario.getIdDistrito());
            stmt.setInt(7, usuario.getIdRol());
            stmt.setInt(8, usuario.getIdEstado());
            stmt.setString(9, usuario.getFoto());
            int filas = stmt.executeUpdate();
            if (filas > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    usuario.setIdUsuario(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public void insertarCredencial(String correo, String contrasenha, int idUsuario) {
        // Crear hash de la contraseña
        String hashedPassword = null;
        if (contrasenha != null && !contrasenha.trim().isEmpty()) {
            hashedPassword = sha256(contrasenha);
        }
        
        // Guardar tanto el hash como la contraseña plain
        String sql = "INSERT INTO credencial (correo, contrasenha, contrasenha_plain, idusuario, verificado) VALUES (?, ?, ?, ?, 0)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, correo);
            pstmt.setString(2, hashedPassword);      // contrasenha (hash)
            pstmt.setString(3, contrasenha);         // contrasenha_plain (texto plano)
            pstmt.setInt(4, idUsuario);
            pstmt.executeUpdate();
            System.out.println("✅ Credencial insertada con hash y plain password para usuario: " + idUsuario);
        } catch (SQLException e) {
            System.err.println("❌ Error al insertar credencial: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }
    public int insertarUsuarioYObtenerId(Usuario usuario) {
        String sql = "INSERT INTO usuario (nombre, apellidopaterno, apellidomaterno, dni, direccion, idDistrito, idRol, idEstado, foto) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, usuario.getNombre());
            stmt.setString(2, usuario.getApellidopaterno());
            stmt.setString(3, usuario.getApellidomaterno());
            stmt.setString(4, usuario.getDni());
            stmt.setString(5, usuario.getDireccion());
            stmt.setInt(6, usuario.getIdDistrito());
            stmt.setInt(7, usuario.getIdRol());
            stmt.setInt(8, usuario.getIdEstado());
            stmt.setString(9, usuario.getFoto());
            int filas = stmt.executeUpdate();
            if (filas > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Método para actualizar la contraseña de un usuario
    public boolean actualizarContrasenha(String correo, String nuevaContrasenha) {
        String sql = "UPDATE credencial SET contrasenha = ? WHERE correo = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
        
            // Usar PasswordUtil para hashear la contraseña
            String hashedPassword = PasswordUtil.hashPassword(nuevaContrasenha);
            stmt.setString(1, hashedPassword);
            stmt.setString(2, correo);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Obtiene el estado del usuario por su correo electrónico
     * @param correo El correo del usuario
     * @return El idEstado del usuario, o null si no se encuentra
     */
    public Integer obtenerEstadoUsuarioPorCorreo(String correo) {
        String sql = """
            SELECT u.idEstado 
            FROM usuario u
            INNER JOIN credencial c ON u.idUsuario = c.idUsuario
            WHERE c.correo = ?
            """;
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, correo);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("idEstado");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener estado del usuario por correo: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
}
