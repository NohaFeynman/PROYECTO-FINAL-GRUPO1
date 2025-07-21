package com.example.webproyecto.daos.encuestador;

import com.example.webproyecto.beans.SesionRespuesta;
import com.example.webproyecto.daos.BaseDao;

import java.sql.*;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SesionRespuestaDao extends BaseDao {

    private LocalDate obtenerFechaActualPeru() {
        ZoneId zonaHoraPeru = ZoneId.of("America/Lima");
        return ZonedDateTime.now(zonaHoraPeru).toLocalDate();
    }

    public int crearSesionRespuesta(SesionRespuesta sesion) {
        int idGenerado = -1;

        String sql = """
            INSERT INTO sesionrespuesta (fechainicio, fechaenvio, estadoterminado, idasignacionformulario, idencuestado)
            VALUES (?, ?, ?, ?, ?)
        """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setTimestamp(1, Timestamp.valueOf(sesion.getFechaInicio()));

            if (sesion.getFechaEnvio() != null) {
                stmt.setTimestamp(2, Timestamp.valueOf(sesion.getFechaEnvio()));
            } else {
                stmt.setNull(2, Types.TIMESTAMP);
            }

            stmt.setInt(3, sesion.getEstadoTerminado());

            if (sesion.getIdAsignacionFormulario() != null) {
                stmt.setInt(4, sesion.getIdAsignacionFormulario());
            } else {
                stmt.setNull(4, Types.INTEGER);
            }

            if (sesion.getIdEncuestado() != null) {
                stmt.setString(5, sesion.getIdEncuestado());
            } else {
                stmt.setNull(5, Types.VARCHAR);
            }

            int filasAfectadas = stmt.executeUpdate();

            if (filasAfectadas > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        idGenerado = rs.getInt(1);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return idGenerado;
    }

    public void actualizarNumeroSesion(int idSesion, int numeroSesion) {
        String sql = "UPDATE sesionrespuesta SET numerosesion = ? WHERE idsesion = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, numeroSesion);
            stmt.setInt(2, idSesion);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int contarSesionesPorEncuestadorYAnhio(int idEncuestador, int anio) {
        int contador = 0;

        String sql = """
            SELECT COUNT(*) AS total
            FROM sesionrespuesta sr
            INNER JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
            WHERE af.idencuestador = ? AND YEAR(sr.fechainicio) = ?
        """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idEncuestador);
            stmt.setInt(2, anio);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    contador = rs.getInt("total");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return contador;
    }

    public int obtenerIdEncuestadorPorSesion(int idSesion) {
        int idEncuestador = -1;

        String sql = """
            SELECT af.idEncuestador
            FROM sesionrespuesta sr
            INNER JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
            WHERE sr.idsesion = ?
        """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idSesion);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    idEncuestador = rs.getInt("idEncuestador");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return idEncuestador;
    }

    public List<Map<String, Object>> obtenerSesionesPorEncuestador(int idEncuestador) {
        List<Map<String, Object>> sesiones = new ArrayList<>();

        String sql = """
            SELECT sr.idsesion, sr.fechainicio, sr.fechaenvio, sr.estadoterminado,
                   f.idformulario, f.titulo, sr.numerosesion
            FROM sesionrespuesta sr
            INNER JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
            INNER JOIN formulario f ON af.idformulario = f.idformulario
            WHERE af.idencuestador = ?
            ORDER BY sr.fechainicio DESC
        """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idEncuestador);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("idsesion", rs.getInt("idsesion"));
                    fila.put("fechainicio", rs.getTimestamp("fechainicio"));
                    fila.put("fechaenvio", rs.getTimestamp("fechaenvio"));
                    fila.put("estadoTerminado", rs.getInt("estadoterminado"));
                    fila.put("idformulario", rs.getInt("idformulario"));
                    fila.put("titulo", rs.getString("titulo"));
                    fila.put("numeroSesion", rs.getInt("numerosesion"));
                    sesiones.add(fila);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return sesiones;
    }

    public Map<String, Object> obtenerInfoSesion(int idSesion) {
        Map<String, Object> datos = null;

        String sql = """
            SELECT sr.idasignacionformulario, af.idformulario
            FROM sesionrespuesta sr
            INNER JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
            WHERE sr.idsesion = ?
        """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idSesion);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    datos = new HashMap<>();
                    datos.put("idasignacionformulario", rs.getInt("idasignacionformulario"));
                    datos.put("idformulario", rs.getInt("idformulario"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }

    public void actualizarEstadoYFechaEnvio(int idSesion, int estadoTerminado, Timestamp fechaEnvio) {
        String sql = """
            UPDATE sesionrespuesta
            SET estadoterminado = ?, fechaenvio = ?
            WHERE idsesion = ?
        """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, estadoTerminado);

            if (fechaEnvio != null) {
                stmt.setTimestamp(2, fechaEnvio);
            } else {
                stmt.setNull(2, Types.TIMESTAMP);
            }

            stmt.setInt(3, idSesion);
            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    public List<Map<String, Object>> obtenerResumenSesionesPorEncuestador(int idEncuestador) {
        List<Map<String, Object>> resumen = new ArrayList<>();

        // Obtener la fecha actual de Perú para los cálculos
        LocalDate fechaActualPeru = obtenerFechaActualPeru();
        LocalDate fechaHace7Dias = fechaActualPeru.minusDays(7);

        System.out.println("DEBUG DAO: Fecha actual Perú: " + fechaActualPeru);
        System.out.println("DEBUG DAO: Fecha hace 7 días: " + fechaHace7Dias);

        String sql = """
        SELECT CASE 
               WHEN sr.estadoterminado = 1 AND sr.fechaenvio IS NOT NULL 
               THEN DATE(sr.fechaenvio) 
               ELSE DATE(sr.fechainicio) 
               END AS fecha, 
               CASE WHEN sr.estadoterminado = 1 AND sr.fechaenvio IS NOT NULL THEN 'registrada' ELSE 'borrador' END AS estado
        FROM sesionrespuesta sr
        INNER JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
        WHERE af.idencuestador = ?
        AND (
            (sr.estadoterminado = 1 AND sr.fechaenvio IS NOT NULL AND DATE(sr.fechaenvio) >= ?)
            OR
            (sr.estadoterminado = 0 AND DATE(sr.fechainicio) >= ?)
        )
        ORDER BY fecha DESC
    """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idEncuestador);
            stmt.setDate(2, java.sql.Date.valueOf(fechaHace7Dias));
            stmt.setDate(3, java.sql.Date.valueOf(fechaHace7Dias));

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();

                    // Manejar fecha de manera más segura
                    java.sql.Date fecha = rs.getDate("fecha");
                    if (fecha != null) {
                        fila.put("fecha", fecha.toString()); // Formato YYYY-MM-DD
                    } else {
                        fila.put("fecha", "");
                    }

                    // Manejar estado de manera más segura
                    String estado = rs.getString("estado");
                    fila.put("estado", estado != null ? estado : "");

                    resumen.add(fila);
                    System.out.println("DEBUG DAO: fecha=" + fila.get("fecha") + ", estado=" + fila.get("estado"));
                }
            }

        } catch (SQLException e) {
            System.err.println("Error en obtenerResumenSesionesPorEncuestador: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("DEBUG DAO: Total registros encontrados: " + resumen.size());
        return resumen;
    }
    public List<Map<String, Object>> obtenerFormulariosCompletadosPorZonaYMes() {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
        SELECT 
            z.nombrezona as zona,
            MONTH(sr.fechaenvio) as mes,
            COUNT(*) as formularios_completados
        FROM sesionrespuesta sr
        INNER JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
        INNER JOIN usuario u ON af.idencuestador = u.idusuario
        INNER JOIN distrito d ON u.iddistrito = d.iddistrito
        INNER JOIN zona z ON d.idzona = z.idzona
        WHERE sr.estadoterminado = 1 
            AND sr.fechaenvio IS NOT NULL
            AND YEAR(sr.fechaenvio) = YEAR(CURDATE())
        GROUP BY z.nombrezona, MONTH(sr.fechaenvio)
        ORDER BY z.nombrezona, mes
    """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("zona", rs.getString("zona"));
                fila.put("mes", rs.getInt("mes"));
                fila.put("formularios_completados", rs.getInt("formularios_completados"));
                datos.add(fila);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }
    public List<Map<String, Object>> obtenerFormulariosCompletadosPorEncuestadorYMes(int idCoordinador) {
        List<Map<String, Object>> resultados = new ArrayList<>();

        String sql = """
        SELECT 
            CONCAT(u.nombre, ' ', u.apellidopaterno) as encuestador,
            MONTH(sr.fechaenvio) as mes,
            COUNT(*) as formularios_completados
        FROM sesionrespuesta sr
        JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
        JOIN usuario u ON af.idencuestador = u.idusuario
        JOIN distrito d ON u.iddistrito = d.iddistrito
        WHERE sr.fechaenvio IS NOT NULL
            AND sr.estadoterminado = 1
            AND d.idzona = (
                SELECT dz.idzona
                FROM usuario uc
                JOIN distrito dz ON uc.idDistritoTrabajo = dz.iddistrito
                WHERE uc.idUsuario = ?
            )
            AND sr.fechaenvio >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
        GROUP BY u.idusuario, MONTH(sr.fechaenvio)
        ORDER BY encuestador, mes
    """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCoordinador);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("encuestador", rs.getString("encuestador"));
                fila.put("mes", rs.getInt("mes"));
                fila.put("formularios_completados", rs.getInt("formularios_completados"));
                resultados.add(fila);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return resultados;
    }
    public int contarSesionesPorFormulario(int idFormulario) {
        int cantidad = 0;
        String sql = """
        SELECT COUNT(*) AS total
        FROM sesionrespuesta sr
        INNER JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
        WHERE af.idformulario = ?
    """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idFormulario);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    cantidad = rs.getInt("total");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return cantidad;
    }
    public int crearSesionManual(int idFormulario, SesionRespuesta sesion) {
        int idSesionGenerado = -1;
        String sql = """
        INSERT INTO sesionrespuesta (fechainicio, fechaenvio, estadoterminado, numerosesion, idasignacionformulario)
        VALUES (?, ?, ?, ?, (
            SELECT af.idasignacionformulario
            FROM asignacionformulario af
            WHERE af.idformulario = ?
            LIMIT 1
        ))
    """;

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setTimestamp(1, Timestamp.valueOf(sesion.getFechaInicio()));
            stmt.setTimestamp(2, Timestamp.valueOf(sesion.getFechaEnvio()));
            stmt.setInt(3, sesion.getEstadoTerminado());
            stmt.setInt(4, sesion.getNumeroSesion());
            stmt.setInt(5, idFormulario);

            int filasAfectadas = stmt.executeUpdate();
            if (filasAfectadas > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        idSesionGenerado = rs.getInt(1);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return idSesionGenerado;
    }

    public List<Map<String, Object>> obtenerFormulariosCompletadosPorDistritoYMes(int idCoordinador) {
        List<Map<String, Object>> resultados = new ArrayList<>();
        String sql = """
        SELECT 
            d.nombredistrito AS distrito,
            MONTH(sr.fechaenvio) AS mes,
            COUNT(*) AS formularios_completados
        FROM sesionrespuesta sr
        JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
        JOIN usuario u_enc ON af.idencuestador = u_enc.idusuario
        JOIN distrito d ON u_enc.idDistritoTrabajo = d.iddistrito
        WHERE sr.fechaenvio IS NOT NULL
            AND sr.estadoterminado = 1
            AND d.idzona = (
                SELECT u_coor.idZonaTrabajo
                FROM usuario u_coor
                WHERE u_coor.idusuario = ?
            )
            AND YEAR(sr.fechaenvio) = YEAR(CURDATE())
        GROUP BY d.nombredistrito, MONTH(sr.fechaenvio)
        ORDER BY d.nombredistrito, mes
        """;
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idCoordinador);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("distrito", rs.getString("distrito"));
                fila.put("mes", rs.getInt("mes"));
                fila.put("formularios_completados", rs.getInt("formularios_completados"));
                resultados.add(fila);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return resultados;
    }

    public int obtenerMaximoNumeroSesion(int idUsuario) {
        int maxNumero = 0;
        String sql = "SELECT MAX(numeroSesion) FROM sesionrespuesta sr " +
                "JOIN asignacionformulario af ON sr.idAsignacionFormulario = af.idAsignacionFormulario " +
                "WHERE af.idEncuestador = ?";

        try (Connection conn = this.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    maxNumero = rs.getInt(1); // Si es NULL, getInt devuelve 0 automáticamente
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return maxNumero;
    }


    public int insertarSesion(SesionRespuesta sesion) {
        int idGenerado = -1;
        String sql = "INSERT INTO sesionrespuesta (fechaInicio, fechaEnvio, estadoTerminado, idAsignacionFormulario, idEncuestado, numeroSesion) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = this.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setTimestamp(1, Timestamp.valueOf(sesion.getFechaInicio()));
            stmt.setTimestamp(2, Timestamp.valueOf(sesion.getFechaEnvio()));
            stmt.setInt(3, sesion.getEstadoTerminado());
            stmt.setInt(4, sesion.getIdAsignacionFormulario());

            // idEncuestado puede ser null
            if (sesion.getIdEncuestado() != null) {
                stmt.setString(5, sesion.getIdEncuestado());
            } else {
                stmt.setNull(5, Types.VARCHAR);
            }

            stmt.setInt(6, sesion.getNumeroSesion());

            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    idGenerado = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return idGenerado;
    }
}

