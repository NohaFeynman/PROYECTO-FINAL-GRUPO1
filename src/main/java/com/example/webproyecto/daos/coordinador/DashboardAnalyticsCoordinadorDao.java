package com.example.webproyecto.daos.coordinador;

import com.example.webproyecto.daos.BaseDao;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DashboardAnalyticsCoordinadorDao extends BaseDao {

    public List<Map<String, Object>> obtenerAnalisisCompletoFormulariosPorZona(int idCoordinador) {
        List<Map<String, Object>> formularios = new ArrayList<>();
        String sql = """
            SELECT DISTINCT 
                f.idformulario,
                f.titulo as nombreFormulario,
                COUNT(DISTINCT sr.idsesion) as totalRespuestas
            FROM formulario f
            JOIN asignacionformulario af_coord ON f.idformulario = af_coord.idformulario AND af_coord.idencuestador = ?
            LEFT JOIN asignacionformulario af ON f.idformulario = af.idformulario
            LEFT JOIN sesionrespuesta sr ON af.idasignacionformulario = sr.idasignacionformulario
            LEFT JOIN usuario u ON af.idencuestador = u.idusuario AND u.idrol = 3
            LEFT JOIN usuario coord ON u.idzonatrabajo = coord.idzonatrabajo AND coord.idusuario = ?
            WHERE sr.estadoterminado = 1
            GROUP BY f.idformulario, f.titulo
            ORDER BY f.idformulario
            """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idCoordinador);
            pstmt.setInt(2, idCoordinador);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> formulario = new HashMap<>();
                    int idFormulario = rs.getInt("idformulario");
                    formulario.put("idFormulario", idFormulario);
                    formulario.put("nombreFormulario", rs.getString("nombreFormulario"));
                    formulario.put("totalRespuestas", rs.getInt("totalRespuestas"));
                    formulario.put("preguntas", obtenerPreguntasConAnalisisPorZona(idFormulario, idCoordinador));
                    formularios.add(formulario);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener análisis de formularios: " + e.getMessage());
        }
        return formularios;
    }

    private List<Map<String, Object>> obtenerPreguntasConAnalisisPorZona(int idFormulario, int idCoordinador) {
        List<Map<String, Object>> preguntas = new ArrayList<>();
        String sql = """
            SELECT DISTINCT
                p.idpregunta,
                p.textopregunta,
                p.obligatorio,
                p.tipopregunta,
                COUNT(DISTINCT r.idrespuesta) as totalRespuestas
            FROM pregunta p
            INNER JOIN opcionpregunta op ON p.idpregunta = op.idpregunta
            LEFT JOIN respuesta r ON p.idpregunta = r.idpregunta
            LEFT JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            LEFT JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
            LEFT JOIN usuario u ON af.idencuestador = u.idusuario
            LEFT JOIN usuario coord ON u.idzonatrabajo = coord.idzonatrabajo
            WHERE p.idformulario = ? 
            AND coord.idusuario = ?
            AND u.idrol = 3 
            AND sr.estadoterminado = 1
            AND EXISTS (SELECT 1 FROM opcionpregunta WHERE idpregunta = p.idpregunta)
            GROUP BY p.idpregunta, p.textopregunta, p.obligatorio, p.tipopregunta
            """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idFormulario);
            pstmt.setInt(2, idCoordinador);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> pregunta = new HashMap<>();
                    int idPregunta = rs.getInt("idpregunta");
                    
                    pregunta.put("idPregunta", idPregunta);
                    pregunta.put("textoPregunta", rs.getString("textopregunta"));
                    pregunta.put("obligatorio", rs.getBoolean("obligatorio"));
                    pregunta.put("tipoAnalisis", rs.getString("tipopregunta"));
                    pregunta.put("totalRespuestas", rs.getInt("totalRespuestas"));
                    
                    boolean tieneOpciones = contarOpcionesPorPregunta(idPregunta) > 0;
                    pregunta.put("tieneOpciones", tieneOpciones);
                    
                    // DEBUG: Verificar si tiene opciones
                    System.out.println("    - Pregunta ID: " + idPregunta + " tiene opciones: " + tieneOpciones);
                    
                    if (tieneOpciones) {
                        List<Map<String, Object>> distribucionRespuestas = 
                            obtenerDistribucionRespuestasPorPreguntaYZona(idPregunta, idCoordinador);
                        
                        // DEBUG: Verificar qué se obtiene
                        System.out.println("    - Pregunta ID: " + idPregunta + " tiene " + 
                            (distribucionRespuestas != null ? distribucionRespuestas.size() : 0) + 
                            " distribuciones de respuestas");
                        
                        if (distribucionRespuestas != null && !distribucionRespuestas.isEmpty()) {
                            for (Map<String, Object> dist : distribucionRespuestas) {
                                System.out.println("      - Opción: " + dist.get("opcion") + 
                                    ", Cantidad: " + dist.get("cantidad") + 
                                    ", Porcentaje: " + dist.get("porcentaje"));
                            }
                        } else {
                            System.out.println("      - No se encontraron distribuciones para pregunta " + idPregunta);
                        }
                        
                        pregunta.put("distribucionRespuestas", distribucionRespuestas);
                    } else {
                        pregunta.put("respuestasTexto", 
                            obtenerRespuestasTextoLibrePorPreguntaYZona(idPregunta, idCoordinador, 5));
                    }
                    
                    preguntas.add(pregunta);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener preguntas con análisis: " + e.getMessage());
        }
        return preguntas;
    }

    private List<Map<String, Object>> obtenerDistribucionRespuestasPorPreguntaYZona(
            int idPregunta, int idCoordinador) {
        List<Map<String, Object>> distribucion = new ArrayList<>();
        String sql = """
            SELECT 
                op.textoopcion as opcion,
                COUNT(r.idrespuesta) as cantidad,
                ROUND(COUNT(r.idrespuesta) * 100.0 / NULLIF(SUM(COUNT(r.idrespuesta)) OVER(), 0), 2) as porcentaje
            FROM opcionpregunta op
            LEFT JOIN respuesta r ON op.idopcion = r.idopcion
            LEFT JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            LEFT JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
            LEFT JOIN usuario u ON af.idencuestador = u.idusuario
            LEFT JOIN usuario coord ON u.idzonatrabajo = coord.idzonatrabajo
            WHERE op.idpregunta = ?
            AND coord.idusuario = ?
            AND (sr.estadoterminado = 1 OR sr.estadoterminado IS NULL)
            AND (u.idrol = 3 OR u.idrol IS NULL)
            GROUP BY op.idopcion, op.textoopcion
            ORDER BY cantidad DESC
            """;

        System.out.println("      - Ejecutando consulta distribución para pregunta " + idPregunta + 
                          " y coordinador " + idCoordinador);

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idPregunta);
            pstmt.setInt(2, idCoordinador);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                int rowCount = 0;
                while (rs.next()) {
                    rowCount++;
                    Map<String, Object> opcion = new HashMap<>();
                    String textoOpcion = rs.getString("opcion");
                    int cantidad = rs.getInt("cantidad");
                    double porcentaje = rs.getDouble("porcentaje");
                    
                    opcion.put("opcion", textoOpcion);
                    opcion.put("cantidad", cantidad);
                    opcion.put("porcentaje", porcentaje);
                    distribucion.add(opcion);
                    
                    System.out.println("        - Fila " + rowCount + ": " + textoOpcion + 
                                     " = " + cantidad + " (" + porcentaje + "%)");
                }
                System.out.println("      - Total filas obtenidas: " + rowCount);
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener distribución de respuestas: " + e.getMessage());
            e.printStackTrace();
        }
        return distribucion;
    }

    private List<Map<String, Object>> obtenerRespuestasTextoLibrePorPreguntaYZona(
            int idPregunta, int idCoordinador, int limite) {
        List<Map<String, Object>> respuestas = new ArrayList<>();
        String sql = """
            SELECT 
                r.textounico,
                DATE_FORMAT(sr.fechacreacion, '%d/%m/%Y') as fecha,
                d.nombre as distrito
            FROM respuesta r
            JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
            JOIN usuario u ON af.idencuestador = u.idusuario
            JOIN usuario coord ON u.idzonatrabajo = coord.idzonatrabajo
            LEFT JOIN distrito d ON u.iddistrito = d.iddistrito
            WHERE r.idpregunta = ?
            AND coord.idusuario = ?
            AND u.idrol = 3
            AND sr.estadoterminado = 1
            AND r.textounico IS NOT NULL
            ORDER BY sr.fechacreacion DESC
            LIMIT ?
            """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idPregunta);
            pstmt.setInt(2, idCoordinador);
            pstmt.setInt(3, limite);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> respuesta = new HashMap<>();
                    respuesta.put("texto", rs.getString("textounico"));
                    respuesta.put("fecha", rs.getString("fecha"));
                    respuesta.put("distrito", rs.getString("distrito"));
                    respuestas.add(respuesta);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener respuestas de texto: " + e.getMessage());
        }
        return respuestas;
    }

    private int contarOpcionesPorPregunta(int idPregunta) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM opcionpregunta WHERE idpregunta = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idPregunta);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
            
            // DEBUG: Mostrar cuántas opciones tiene cada pregunta
            System.out.println("      - Pregunta " + idPregunta + " tiene " + count + " opciones");
            
        } catch (SQLException e) {
            System.err.println("Error al contar opciones: " + e.getMessage());
        }
        return count;
    }

    public Map<String, Object> obtenerMetricasGeneralesPorZona(int idCoordinador) {
        Map<String, Object> metricas = new HashMap<>();
        String sql = """
            SELECT 
                COUNT(DISTINCT CASE WHEN u.idestado = 2 THEN u.idusuario END) as encuestadores_activos,
                COUNT(DISTINCT CASE WHEN u.idestado = 1 THEN u.idusuario END) as encuestadores_inactivos,
                (SELECT COUNT(DISTINCT sr2.idsesion) 
                 FROM sesionrespuesta sr2 
                 JOIN asignacionformulario af2 ON sr2.idasignacionformulario = af2.idasignacionformulario
                 JOIN usuario u2 ON af2.idencuestador = u2.idusuario 
                 WHERE u2.idzonatrabajo = coord.idzonatrabajo 
                 AND sr2.estadoterminado = 1) as formularios_completados,
                (SELECT COUNT(DISTINCT f2.idformulario) 
                 FROM formulario f2
                 JOIN asignacionformulario af2 ON f2.idformulario = af2.idformulario
                 WHERE af2.idencuestador = coord.idusuario) as formularios_disponibles
            FROM usuario u
            JOIN usuario coord ON u.idzonatrabajo = coord.idzonatrabajo
            WHERE coord.idusuario = ? 
            AND u.idrol = 3
            """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idCoordinador);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    metricas.put("encuestadoresActivos", rs.getInt("encuestadores_activos"));
                    metricas.put("encuestadoresInactivos", rs.getInt("encuestadores_inactivos"));
                    metricas.put("formulariosCompletados", rs.getInt("formularios_completados"));
                    metricas.put("formulariosDisponibles", rs.getInt("formularios_disponibles"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener métricas generales: " + e.getMessage());
        }
        return metricas;
    }
}
