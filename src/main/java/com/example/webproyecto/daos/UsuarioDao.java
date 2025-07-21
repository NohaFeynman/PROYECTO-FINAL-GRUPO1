package com.example.webproyecto.daos;

import com.example.webproyecto.dtos.CoordinadorDTO;
import com.example.webproyecto.dtos.EncuestadorDTO;
import com.example.webproyecto.dtos.UsuarioDTO;
import com.example.webproyecto.dtos.CredencialDTO;
import com.example.webproyecto.beans.Credencial;
import com.example.webproyecto.beans.Usuario;

import java.util.ArrayList;
import java.util.List;
import java.util.Base64;
import java.util.Map;
import java.util.HashMap;

import java.io.InputStream;
import java.sql.*; // Importa java.sql.* para PreparedStatement, ResultSet, SQLException, Types

public class UsuarioDao extends BaseDao {

    /**
     * Guarda un nuevo registro de archivo cargado en la base de datos.
     * Importante: Este método asume que la 'foto' en el bean Usuario es un String (ruta/URL).
     * Si 'foto' es un BLOB (InputStream), el manejo en actualizarPerfilCoordinador deberá ser ajustado.
     *
     * @param archivoCargado El objeto ArchivoCargado a guardar.
     * @return true si la operación fue exitosa, false en caso contrario.
     */



    public int contarEncuestadoresActivos() {
        String sql = "SELECT COUNT(*) FROM usuario WHERE idRol = 3 AND idEstado = 2";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int contarEncuestadoresDesactivos() {
        String sql = "SELECT COUNT(*) FROM usuario WHERE idRol = 3 AND idEstado != 2";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }


    /**
     * Obtiene una lista de todos los archivos cargados.
     *
     * @return Una lista de objetos ArchivoCargado.
     */


    public Usuario obtenerUsuarioPorId(int idUsuario) {
        String sql = "SELECT * FROM usuario WHERE idUsuario = ?";
        Usuario usuario = null; // Inicializar a null

        try (Connection conn = getConnection(); // Usar el método getConnection
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("idUsuario"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setApellidopaterno(rs.getString("apellidopaterno"));
                usuario.setApellidomaterno(rs.getString("apellidomaterno"));
                usuario.setDni(rs.getString("dni"));
                usuario.setDireccion(rs.getString("direccion"));
                usuario.setIdDistrito(rs.getInt("idDistrito"));
                // Leer el nuevo atributo idDistritoTrabajo
                usuario.setIdDistritoTrabajo((Integer) rs.getObject("idDistritoTrabajo"));
                usuario.setIdRol(rs.getInt("idrol"));
                usuario.setIdEstado(rs.getInt("idEstado"));

                java.sql.Blob fotoBlob = rs.getBlob("foto");
                if (fotoBlob != null && fotoBlob.length() > 0) {
                    byte[] fotoBytes = fotoBlob.getBytes(1, (int) fotoBlob.length());
                    String fotoBase64 = java.util.Base64.getEncoder().encodeToString(fotoBytes);
                    usuario.setFoto(fotoBase64);
                } else {
                    usuario.setFoto(null);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuario;
    }

    public List<CoordinadorDTO> listarEncuestadoresPorZonaCoordinador(int idUsuarioCoordinador) {
        List<CoordinadorDTO> lista = new ArrayList<>();

        String sql = """
        SELECT u_enc.*, c.correo, d.nombreDistrito AS distritoNombre
        FROM usuario u_enc
        JOIN distrito d ON u_enc.idDistritoTrabajo = d.iddistrito
        LEFT JOIN credencial c ON u_enc.idUsuario = c.idUsuario
        WHERE u_enc.idrol = 3
          AND u_enc.idZonaTrabajo = (
              SELECT idZonaTrabajo FROM usuario WHERE idUsuario = ?
          )
    """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuarioCoordinador);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Usuario usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("idUsuario"));
                    usuario.setNombre(rs.getString("nombre"));
                    usuario.setApellidopaterno(rs.getString("apellidopaterno"));
                    usuario.setApellidomaterno(rs.getString("apellidomaterno"));
                    usuario.setDni(rs.getString("dni"));
                    usuario.setDireccion(rs.getString("direccion"));
                    usuario.setIdDistrito(rs.getInt("idDistrito"));
                    usuario.setIdDistritoTrabajo(rs.getInt("idDistritoTrabajo"));
                    usuario.setIdEstado(rs.getInt("idEstado"));
                    usuario.setIdZonaTrabajo(rs.getObject("idZonaTrabajo") != null ? rs.getInt("idZonaTrabajo") : null);

                    Credencial credencial = new Credencial();
                    credencial.setCorreo(rs.getString("correo"));

                    CoordinadorDTO dto = new CoordinadorDTO(usuario, credencial);
                    dto.setDistritoNombre(rs.getString("distritoNombre"));
                    lista.add(dto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public List<EncuestadorDTO> listarEncuestadoresConCorreo() {
        List<EncuestadorDTO> lista = new ArrayList<>();
        String sql = "SELECT u.*, c.correo, z.nombreZona AS zonaTrabajoNombre " +
                "FROM usuario u " +
                "LEFT JOIN credencial c ON u.idUsuario = c.idUsuario " +
                "LEFT JOIN zona z ON u.idZonaTrabajo = z.idZona " +
                "WHERE u.idRol = 3 " +
                "ORDER BY u.idUsuario DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                UsuarioDTO usuario = new UsuarioDTO();
                usuario.setIdUsuario(rs.getInt("idUsuario"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setApellidopaterno(rs.getString("apellidopaterno"));
                usuario.setApellidomaterno(rs.getString("apellidomaterno"));
                usuario.setDni(rs.getString("dni"));
                usuario.setIdEstado(rs.getInt("idEstado"));
                usuario.setIdDistrito(rs.getInt("idDistrito"));
                usuario.setIdZonaTrabajo(rs.getObject("idZonaTrabajo") != null ? rs.getInt("idZonaTrabajo") : null);
                usuario.setFechaRegistro(rs.getTimestamp("fecha_registro"));

                CredencialDTO credencial = new CredencialDTO();
                credencial.setCorreo(rs.getString("correo"));

                EncuestadorDTO dto = new EncuestadorDTO();
                dto.setUsuario(usuario);
                dto.setCredencial(credencial);
                dto.setZonaTrabajoNombre(rs.getString("zonaTrabajoNombre"));
                lista.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    public boolean actualizarPerfilCompleto(Usuario usuario) {
        // Construcción dinámica de la consulta SQL
        StringBuilder sql = new StringBuilder("UPDATE usuario SET direccion = ?, idDistrito = ?, idDistritoTrabajo = ?");
        ArrayList<Object> params = new ArrayList<>();

        params.add(usuario.getDireccion());
        params.add(usuario.getIdDistrito());
        // Manejar idDistritoTrabajo (usar setObject para Integer que puede ser null)
        params.add(usuario.getIdDistritoTrabajo()); // Esto se establecerá a NULL si el bean tiene null

        // Agregar foto solo si viene en el objeto
        if (usuario.getFoto() != null && !usuario.getFoto().isEmpty()) {
            sql.append(", foto = ?");
            // Convierte el Base64 a bytes si tu columna foto es BLOB
            // Si la columna foto es String (ruta/URL), simplemente params.add(usuario.getFoto());
            try {
                byte[] fotoBytes = java.util.Base64.getDecoder().decode(usuario.getFoto());
                params.add(new java.io.ByteArrayInputStream(fotoBytes)); // Asume que la DB espera BLOB
            } catch (IllegalArgumentException e) {
                System.err.println("Error al decodificar la imagen Base64: " + e.getMessage());
                // Si la foto es una ruta string, no decodifiques y simplemente añádelo
                params.add(usuario.getFoto()); // Si la foto es solo una cadena (URL/ruta)
            }
        }

        sql.append(" WHERE idUsuario = ?");
        params.add(usuario.getIdUsuario());

        System.out.println("SQL a ejecutar: " + sql.toString());
        System.out.println("Parámetros: " + params);

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            // Establecer parámetros dinámicamente
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    stmt.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    stmt.setInt(i + 1, (Integer) param);
                } else if (param instanceof InputStream) {
                    stmt.setBlob(i + 1, (InputStream) param);
                } else if (param == null) { // Para manejar el caso de idDistritoTrabajo como NULL
                    stmt.setNull(i + 1, Types.INTEGER);
                }
            }

            int filasAfectadas = stmt.executeUpdate();
            System.out.println("Filas afectadas: " + filasAfectadas);

            if (filasAfectadas == 0) {
                System.err.println("ADVERTENCIA: Ninguna fila actualizada. Verifica que el usuario con ID " +
                        usuario.getIdUsuario() + " existe");
            }

            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("Error SQL al actualizar perfil:");
            System.err.println("- Código de error: " + e.getErrorCode());
            System.err.println("- Estado SQL: " + e.getSQLState());
            System.err.println("- Mensaje: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean cambiarEstadoUsuario(int idusuario, int estadoNuevo) {
        boolean actualizado = false;
        String sql = "UPDATE usuario SET idestado = ? WHERE idusuario = ?";
        System.out.println(">>> Ejecutando cambio estado:");
        System.out.println(">>> idUsuario = " + idusuario);
        System.out.println(">>> nuevoEstado = " + estadoNuevo);

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            System.out.println(">>> Conexión establecida: " + (conn != null));
            System.out.println(">>> SQL = " + sql);

            pstmt.setInt(1, estadoNuevo);
            pstmt.setInt(2, idusuario);

            int filas = pstmt.executeUpdate();
            System.out.println(">>> Filas afectadas: " + filas);

            actualizado = filas > 0;

        } catch (SQLException e) {
            System.out.println(">>> Error SQL:");
            e.printStackTrace();
        }

        return actualizado;
    }



    public boolean actualizarDireccionYDistrito(int idUsuario, String direccion, int idDistrito) {
        // Este método NO incluye idDistritoTrabajo, si necesitas actualizarlo junto con estos,
        // considera usar actualizarPerfilCompleto o crear un método específico.
        String sql = "UPDATE usuario SET direccion = ?, idDistrito = ? WHERE idUsuario = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, direccion);
            stmt.setInt(2, idDistrito);
            stmt.setInt(3, idUsuario);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al actualizar dirección y distrito:");
            e.printStackTrace();
            return false;
        }
    }

    public boolean insertarUsuario(Usuario usuario) throws SQLException {
        // Columnas en DB: nombre, apellidopaterno, apellidomaterno, dni, direccion, idrol, iddistrito, idDistritoTrabajo, idestado, foto, idZonaTrabajo
        String sql = "INSERT INTO usuario (" +
                "nombre, apellidopaterno, apellidomaterno, dni, direccion, " +
                "idrol, iddistrito, idDistritoTrabajo, idestado, foto, idZonaTrabajo" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"; // 11 PLACEHOLDERS

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, usuario.getNombre());
            pstmt.setString(2, usuario.getApellidopaterno());
            pstmt.setString(3, usuario.getApellidomaterno());
            pstmt.setString(4, usuario.getDni());
            pstmt.setString(5, usuario.getDireccion());
            pstmt.setInt(6, usuario.getIdRol());
            pstmt.setInt(7, usuario.getIdDistrito());

            if (usuario.getIdDistritoTrabajo() != null) {
                pstmt.setInt(8, usuario.getIdDistritoTrabajo());
            } else {
                pstmt.setNull(8, java.sql.Types.INTEGER);
            }

            pstmt.setInt(9, usuario.getIdEstado());

            if (usuario.getFoto() != null && !usuario.getFoto().isEmpty()) {
                try {
                    byte[] fotoBytes = Base64.getDecoder().decode(usuario.getFoto());
                    pstmt.setBlob(10, new java.io.ByteArrayInputStream(fotoBytes));
                } catch (IllegalArgumentException e) {
                    System.err.println("Advertencia: La cadena de foto no es un Base64 válido. Se insertará NULL para la foto binaria.");
                    pstmt.setNull(10, java.sql.Types.BLOB);
                }
            } else {
                pstmt.setNull(10, java.sql.Types.BLOB);
            }

            if (usuario.getIdZonaTrabajo() != null) {
                pstmt.setInt(11, usuario.getIdZonaTrabajo());
            } else {
                pstmt.setNull(11, java.sql.Types.INTEGER);
            }

            int filasAfectadas = pstmt.executeUpdate();
            if (filasAfectadas > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        usuario.setIdUsuario(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
            return false;
        }
    }


    public boolean existeDni(String dni) {
        String sql = "SELECT 1 FROM usuario WHERE dni = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, dni);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Usuario obtenerUsuarioPorDni(String dni) {
        Usuario usuario = null;
        String sql = "SELECT * FROM usuario WHERE dni = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, dni);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("idUsuario"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setApellidopaterno(rs.getString("apellidopaterno"));
                usuario.setApellidomaterno(rs.getString("apellidomaterno"));
                usuario.setDni(rs.getString("dni"));
                usuario.setDireccion(rs.getString("direccion"));
                usuario.setIdDistrito(rs.getInt("idDistrito"));
                usuario.setIdDistritoTrabajo((Integer) rs.getObject("idDistritoTrabajo")); // Leer aquí también
                usuario.setIdRol(rs.getInt("idRol"));
                usuario.setIdEstado(rs.getInt("idEstado"));
                // Asumiendo que la foto se guarda como BLOB en la DB y se convierte a Base64 en el bean.
                // Si la foto es String (ruta), usa rs.getString("foto")
                java.sql.Blob fotoBlob = rs.getBlob("foto");
                if (fotoBlob != null && fotoBlob.length() > 0) {
                    byte[] fotoBytes = fotoBlob.getBytes(1, (int) fotoBlob.length());
                    String fotoBase64 = java.util.Base64.getEncoder().encodeToString(fotoBytes);
                    usuario.setFoto(fotoBase64);
                } else {
                    usuario.setFoto(null);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return usuario;
    }

    public boolean actualizarPerfilConFoto(int idUsuario, String direccion, int idDistrito, Integer idDistritoTrabajo, InputStream fotoStream) {
        StringBuilder sql = new StringBuilder("UPDATE usuario SET direccion = ?, idDistrito = ?, idDistritoTrabajo = ?");
        List<Object> params = new ArrayList<>();

        params.add(direccion);
        params.add(idDistrito);
        params.add(idDistritoTrabajo); // Agrega el idDistritoTrabajo

        if (fotoStream != null) {
            sql.append(", foto = ?");
            params.add(fotoStream);
        }

        sql.append(" WHERE idUsuario = ?");
        params.add(idUsuario);

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object param : params) {
                if (param instanceof String) {
                    stmt.setString(idx++, (String) param);
                } else if (param instanceof Integer) {
                    stmt.setInt(idx++, (Integer) param);
                } else if (param instanceof InputStream) {
                    stmt.setBlob(idx++, (InputStream) param);
                } else if (param == null) { // Para manejar idDistritoTrabajo nulo
                    stmt.setNull(idx++, Types.INTEGER);
                }
            }

            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }


    public List<CoordinadorDTO> listarCoordinadoresConCorreo() {
        List<CoordinadorDTO> lista = new ArrayList<>();
        String sql = "SELECT u.*, c.correo, z.nombreZona AS zonaTrabajoNombre " +
                "FROM usuario u " +
                "LEFT JOIN credencial c ON u.idUsuario = c.idUsuario " +
                "LEFT JOIN zona z ON u.idZonaTrabajo = z.idZona " +
                "WHERE u.idRol = 2 " +
                "ORDER BY u.idUsuario DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Usuario usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("idUsuario"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setApellidopaterno(rs.getString("apellidopaterno"));
                usuario.setApellidomaterno(rs.getString("apellidomaterno"));
                usuario.setDni(rs.getString("dni"));
                usuario.setIdEstado(rs.getInt("idEstado"));
                usuario.setIdDistrito(rs.getInt("idDistrito"));
                usuario.setIdZonaTrabajo(rs.getObject("idZonaTrabajo") != null ? rs.getInt("idZonaTrabajo") : null);
                usuario.setFechaRegistro(rs.getTimestamp("fecha_registro"));

                Credencial c = new Credencial();
                c.setCorreo(rs.getString("correo"));

                CoordinadorDTO dto = new CoordinadorDTO(usuario, c);
                String zonaNombre = rs.getString("zonaTrabajoNombre");
                if (zonaNombre != null && zonaNombre.toLowerCase().startsWith("zona ")) {
                    zonaNombre = zonaNombre.substring(5).trim();
                }
                dto.setZonaTrabajoNombre(zonaNombre);
                lista.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public boolean actualizarPorPartes(int idUsuario, String direccion, Integer idDistrito, InputStream fotoStream) {
        StringBuilder sql = new StringBuilder("UPDATE usuario SET ");
        List<Object> params = new ArrayList<>();
        boolean needsComma = false;

        if (direccion != null) {
            sql.append("direccion = ?");
            params.add(direccion);
            needsComma = true;
        }
        if (idDistrito != null) {
            if (needsComma) sql.append(", ");
            sql.append("idDistrito = ?");
            params.add(idDistrito);
            needsComma = true;
        }

        if (fotoStream != null) {
            if (needsComma) sql.append(", ");
            sql.append("foto = ?");
            params.add(fotoStream);
        }
        sql.append(" WHERE idUsuario = ?");
        params.add(idUsuario);

        // Si no hay campos para actualizar, no hacer nada
        if (params.size() <= 1) return false; // Solo está el idUsuario, no hay campos a actualizar

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                if (param instanceof String) {
                    stmt.setString(idx++, (String) param);
                } else if (param instanceof Integer) {
                    stmt.setInt(idx++, (Integer) param);
                } else if (param instanceof InputStream) {
                    stmt.setBlob(idx++, (InputStream) param);
                } else if (param == null) { // Manejar parámetros nulos (especialmente para idDistritoTrabajo)
                    stmt.setNull(idx++, Types.INTEGER); // Asume que el null es para un INTEGER
                }
            }
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int contarCoordinadoresActivos() {
        String sql = "SELECT COUNT(*) FROM usuario WHERE idRol = 2 AND idEstado = 2";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int contarCoordinadoresDesactivos() {
        String sql = "SELECT COUNT(*) FROM usuario WHERE idRol = 2 AND idEstado != 2";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public List<CoordinadorDTO> obtenerCoordinadores() {
        return listarCoordinadoresConCorreo();
    }

    public List<EncuestadorDTO> obtenerEncuestadores() {
        return listarEncuestadoresConCorreo();
    }

    public List<CoordinadorDTO> obtenerCoordinadoresFiltrado(String nombre, String apellidopaterno, String dni, String zonaTrabajo, String rangoFechas) {
        List<CoordinadorDTO> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT u.*, c.correo, z.nombreZona AS zonaTrabajoNombre FROM usuario u " +
                "LEFT JOIN credencial c ON u.idUsuario = c.idUsuario " +
                "LEFT JOIN zona z ON u.idZonaTrabajo = z.idZona WHERE u.idRol = 2");
        List<Object> params = new ArrayList<>();
        if (nombre != null && !nombre.isEmpty()) {
            sql.append(" AND u.nombre LIKE ?");
            params.add("%" + nombre + "%");
        }
        if (apellidopaterno != null && !apellidopaterno.isEmpty()) {
            sql.append(" AND u.apellidopaterno LIKE ?");
            params.add("%" + apellidopaterno + "%");
        }
        if (dni != null && !dni.isEmpty()) {
            sql.append(" AND u.dni LIKE ?");
            params.add("%" + dni + "%");
        }
        if (zonaTrabajo != null && !zonaTrabajo.isEmpty()) {
            sql.append(" AND u.idZonaTrabajo = ?");
            params.add(Integer.parseInt(zonaTrabajo));
        }
        if (rangoFechas != null && !rangoFechas.isEmpty()) {
            sql.append(" AND u.fecha_registro >= ?");
            java.util.Date now = new java.util.Date();
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(now);
            switch (rangoFechas) {
                case "semana": cal.add(java.util.Calendar.DAY_OF_YEAR, -7); break;
                case "mes": cal.add(java.util.Calendar.MONTH, -1); break;
                case "tresmeses": cal.add(java.util.Calendar.MONTH, -3); break;
            }
            params.add(new java.sql.Timestamp(cal.getTimeInMillis()));
        }
        sql.append(" ORDER BY u.idUsuario DESC");
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Usuario u = new Usuario();
                u.setIdUsuario(rs.getInt("idUsuario"));
                u.setNombre(rs.getString("nombre"));
                u.setApellidopaterno(rs.getString("apellidopaterno"));
                u.setApellidomaterno(rs.getString("apellidomaterno"));
                u.setDni(rs.getString("dni"));
                u.setDireccion(rs.getString("direccion"));
                u.setIdDistrito(rs.getInt("idDistrito"));
                u.setIdDistritoTrabajo((Integer) rs.getObject("idDistritoTrabajo"));
                u.setIdRol(rs.getInt("idRol"));
                u.setIdEstado(rs.getInt("idEstado"));
                u.setFoto(rs.getString("foto"));
                u.setFechaRegistro(rs.getTimestamp("fecha_registro"));
                Credencial c = new Credencial();
                c.setCorreo(rs.getString("correo"));
                CoordinadorDTO dto = new CoordinadorDTO(u, c);
                String zonaNombre = rs.getString("zonaTrabajoNombre");
                if (zonaNombre != null && zonaNombre.toLowerCase().startsWith("zona ")) {
                    zonaNombre = zonaNombre.substring(5).trim();
                }
                dto.setZonaTrabajoNombre(zonaNombre);
                lista.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public List<EncuestadorDTO> obtenerEncuestadoresFiltrado(String nombre, String apellidopaterno, String dni, String zonaTrabajo, String rangoFechas) {
        List<EncuestadorDTO> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT u.*, c.correo, z.nombreZona AS zonaTrabajoNombre FROM usuario u " +
                "LEFT JOIN credencial c ON u.idUsuario = c.idUsuario " +
                "LEFT JOIN zona z ON u.idZonaTrabajo = z.idZona WHERE u.idRol = 3");
        List<Object> params = new ArrayList<>();
        if (nombre != null && !nombre.isEmpty()) {
            sql.append(" AND u.nombre LIKE ?");
            params.add("%" + nombre + "%");
        }
        if (apellidopaterno != null && !apellidopaterno.isEmpty()) {
            sql.append(" AND u.apellidopaterno LIKE ?");
            params.add("%" + apellidopaterno + "%");
        }
        if (dni != null && !dni.isEmpty()) {
            sql.append(" AND u.dni LIKE ?");
            params.add("%" + dni + "%");
        }
        if (zonaTrabajo != null && !zonaTrabajo.isEmpty()) {
            sql.append(" AND u.idZonaTrabajo = ?");
            params.add(Integer.parseInt(zonaTrabajo));
        }
        if (rangoFechas != null && !rangoFechas.isEmpty()) {
            sql.append(" AND u.fecha_registro >= ?");
            java.util.Date now = new java.util.Date();
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(now);
            switch (rangoFechas) {
                case "semana": cal.add(java.util.Calendar.DAY_OF_YEAR, -7); break;
                case "mes": cal.add(java.util.Calendar.MONTH, -1); break;
                case "tresmeses": cal.add(java.util.Calendar.MONTH, -3); break;
            }
            params.add(new java.sql.Timestamp(cal.getTimeInMillis()));
        }
        sql.append(" ORDER BY u.idUsuario DESC");
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                UsuarioDTO usuario = new UsuarioDTO();
                usuario.setIdUsuario(rs.getInt("idUsuario"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setApellidopaterno(rs.getString("apellidopaterno"));
                usuario.setApellidomaterno(rs.getString("apellidomaterno"));
                usuario.setDni(rs.getString("dni"));
                usuario.setIdEstado(rs.getInt("idEstado"));
                usuario.setIdDistrito(rs.getInt("idDistrito"));
                usuario.setIdZonaTrabajo(rs.getObject("idZonaTrabajo") != null ? rs.getInt("idZonaTrabajo") : null);
                usuario.setFechaRegistro(rs.getTimestamp("fecha_registro"));

                CredencialDTO credencial = new CredencialDTO();
                credencial.setCorreo(rs.getString("correo"));

                EncuestadorDTO dto = new EncuestadorDTO();
                dto.setUsuario(usuario);
                dto.setCredencial(credencial);
                dto.setZonaTrabajoNombre(rs.getString("zonaTrabajoNombre"));
                lista.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    /**
     * Cuenta encuestadores por zona, filtrando por activos si se indica.
     * @param idZona ID de la zona a consultar
     * @param soloActivos true para contar solo activos (idEstado=2), false para todos
     * @return cantidad de encuestadores en la zona
     */
    public int contarEncuestadoresPorZona(int idZona, boolean soloActivos) {
        String sql = "SELECT COUNT(*) FROM usuario WHERE idRol = 3 AND idZona = ?"
                + (soloActivos ? " AND idEstado = 2" : "");
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idZona);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Devuelve un mapa con el nombre del distrito y la cantidad de encuestadores en cada uno para una zona dada.
     * @param idZona ID de la zona
     * @return Mapa distrito -> cantidad de encuestadores
     */
    public Map<String, Integer> contarEncuestadoresPorDistritoEnZona(int idZona) {
        Map<String, Integer> resultado = new HashMap<>();
        String sql = "SELECT d.nombre AS distrito, COUNT(u.idUsuario) AS cantidad " +
                "FROM usuario u " +
                "JOIN distrito d ON u.idDistritoTrabajo = d.iddistrito " +
                "WHERE u.idRol = 3 AND d.idzona = ? " +
                "GROUP BY d.nombre";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idZona);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    resultado.put(rs.getString("distrito"), rs.getInt("cantidad"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return resultado;
    }

    /**
     * Devuelve un mapa con el nombre del distrito y un arreglo de conteos de encuestadores activos/inactivos en cada uno para una zona dada.
     * int[0] = activos (idEstado=2), int[1] = inactivos (idEstado!=2)
     * @param idZona ID de la zona
     * @return Mapa distrito -> [activos, inactivos]
     */
    public Map<String, int[]> contarEncuestadoresPorDistritoEnZonaConEstados(int idZona) {
        Map<String, int[]> resultado = new HashMap<>();
        String sql = "SELECT d.nombre AS distrito, " +
                "SUM(CASE WHEN u.idEstado = 2 THEN 1 ELSE 0 END) AS activos, " +
                "SUM(CASE WHEN u.idEstado != 2 THEN 1 ELSE 0 END) AS inactivos " +
                "FROM usuario u " +
                "JOIN distrito d ON u.idDistritoTrabajo = d.iddistrito " +
                "WHERE u.idRol = 3 AND d.idzona = ? " +
                "GROUP BY d.nombre";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idZona);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int[] estados = new int[2];
                    estados[0] = rs.getInt("activos");
                    estados[1] = rs.getInt("inactivos");
                    resultado.put(rs.getString("distrito"), estados);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return resultado;
    }
    public String obtenerNombrePorCorreo(String correo) {
        String sql = "SELECT u.nombre FROM usuario u " +
                "INNER JOIN credencial c ON u.id_usuario = c.id_usuario " +
                "WHERE c.correo = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, correo);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getString("nombre");
            }
            return null;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public int obtenerZonaPorId(int idUsuario) {
        int idZona = -1;
        String sql = "SELECT idZonaTrabajo FROM usuario WHERE idUsuario = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                idZona = rs.getInt("idZonaTrabajo");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return idZona;
    }

}
