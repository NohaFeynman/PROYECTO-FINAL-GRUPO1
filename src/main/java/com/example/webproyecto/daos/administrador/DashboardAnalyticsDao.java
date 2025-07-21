package com.example.webproyecto.daos.administrador;

import com.example.webproyecto.daos.BaseDao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO específico para obtener datos analíticos del dashboard de administrador
 * Contiene métodos para extraer estadísticas y métricas de respuestas de formularios
 */
public class DashboardAnalyticsDao extends BaseDao {

    /**
     * Obtiene la distribución de respuestas por opciones múltiples para gráficos de barras
     */
    public List<Map<String, Object>> obtenerDistribucionRespuestasPorPregunta(int idPregunta) {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
            SELECT 
                op.textoopcion as opcion,
                COUNT(r.idrespuesta) as cantidad_respuestas
            FROM opcionpregunta op
            LEFT JOIN respuesta r ON op.idopcionpregunta = r.idopcionpregunta
            LEFT JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            WHERE op.idpregunta = ? AND (sr.estadoterminado = 1 OR r.idrespuesta IS NULL)
            GROUP BY op.idopcionpregunta, op.textoopcion
            ORDER BY cantidad_respuestas DESC
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idPregunta);

            try (ResultSet rs = pstmt.executeQuery()) {
                int totalRespuestas = 0;
                List<Map<String, Object>> resultadosTemporales = new ArrayList<>();

                // Primero obtener todos los datos y calcular el total
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    int cantidad = rs.getInt("cantidad_respuestas");
                    fila.put("opcion", rs.getString("opcion"));
                    fila.put("cantidad", cantidad);
                    totalRespuestas += cantidad;
                    resultadosTemporales.add(fila);
                }

                // Ahora calcular porcentajes y agregar a la lista final
                for (Map<String, Object> fila : resultadosTemporales) {
                    int cantidad = (Integer) fila.get("cantidad");
                    double porcentaje = totalRespuestas > 0 ?
                            Math.round((cantidad * 100.0 / totalRespuestas) * 100.0) / 100.0 : 0.0;
                    fila.put("porcentaje", porcentaje);
                    datos.add(fila);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }

    /**
     * Obtiene análisis de satisfacción basado en preguntas que contengan palabras clave
     */
    public List<Map<String, Object>> obtenerAnalisisSatisfaccion() {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
            SELECT 
                op.textoopcion as nivel_satisfaccion,
                COUNT(r.idrespuesta) as cantidad,
                ROUND(COUNT(r.idrespuesta) * 100.0 / 
                    (SELECT COUNT(*) FROM respuesta r2 
                     JOIN sesionrespuesta sr2 ON r2.idsesion = sr2.idsesion 
                     JOIN pregunta p2 ON r2.idpregunta = p2.idpregunta
                     WHERE (LOWER(p2.textopregunta) LIKE '%satisf%' 
                         OR LOWER(p2.textopregunta) LIKE '%conform%'
                         OR LOWER(p2.textopregunta) LIKE '%calific%')
                         AND sr2.estadoterminado = 1), 2) as porcentaje
            FROM pregunta p
            JOIN opcionpregunta op ON p.idpregunta = op.idpregunta
            LEFT JOIN respuesta r ON op.idopcionpregunta = r.idopcionpregunta
            LEFT JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            WHERE (LOWER(p.textopregunta) LIKE '%satisf%' 
                OR LOWER(p.textopregunta) LIKE '%conform%'
                OR LOWER(p.textopregunta) LIKE '%calific%')
                AND sr.estadoterminado = 1
            GROUP BY op.textoopcion
            ORDER BY cantidad DESC
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("nivel", rs.getString("nivel_satisfaccion"));
                fila.put("cantidad", rs.getInt("cantidad"));
                fila.put("porcentaje", rs.getDouble("porcentaje"));
                datos.add(fila);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }

    /**
     * Obtiene distribución por rangos de edad
     */
    public List<Map<String, Object>> obtenerDistribucionPorEdad() {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
            SELECT 
                CASE 
                    WHEN CAST(r.textoRespuesta AS UNSIGNED) BETWEEN 18 AND 25 THEN '18-25'
                    WHEN CAST(r.textoRespuesta AS UNSIGNED) BETWEEN 26 AND 35 THEN '26-35'
                    WHEN CAST(r.textoRespuesta AS UNSIGNED) BETWEEN 36 AND 45 THEN '36-45'
                    WHEN CAST(r.textoRespuesta AS UNSIGNED) BETWEEN 46 AND 55 THEN '46-55'
                    WHEN CAST(r.textoRespuesta AS UNSIGNED) > 55 THEN '56+'
                    ELSE 'Sin especificar'
                END as rango_edad,
                COUNT(r.idrespuesta) as cantidad_respuestas
            FROM respuesta r
            JOIN pregunta p ON r.idpregunta = p.idpregunta
            JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            WHERE (LOWER(p.textopregunta) LIKE '%edad%' 
                OR LOWER(p.textopregunta) LIKE '%años%')
                AND r.textoRespuesta IS NOT NULL
                AND r.textoRespuesta REGEXP '^[0-9]+$'
                AND sr.estadoterminado = 1
            GROUP BY rango_edad
            ORDER BY cantidad_respuestas DESC
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("rango", rs.getString("rango_edad"));
                fila.put("cantidad", rs.getInt("cantidad_respuestas"));
                datos.add(fila);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }

    /**
     * Obtiene respuestas de texto libre más recientes
     */
    public List<Map<String, Object>> obtenerRespuestasAbiertasRecientes(int limite) {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
            SELECT 
                r.textoRespuesta as respuesta_texto,
                p.textopregunta as pregunta,
                sr.fechaenvio as fecha,
                z.nombrezona as zona,
                f.titulo as formulario
            FROM respuesta r
            JOIN pregunta p ON r.idpregunta = p.idpregunta
            JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            JOIN asignacionformulario af ON sr.idasignacionformulario = af.idasignacionformulario
            JOIN formulario f ON af.idformulario = f.idformulario
            JOIN usuario u ON af.idencuestador = u.idusuario
            JOIN distrito d ON u.iddistrito = d.iddistrito
            JOIN zona z ON d.idzona = z.idzona
            WHERE r.textoRespuesta IS NOT NULL 
                AND LENGTH(TRIM(r.textoRespuesta)) > 10
                AND sr.estadoterminado = 1
            ORDER BY sr.fechaenvio DESC
            LIMIT ?
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limite);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("texto", rs.getString("respuesta_texto"));
                    fila.put("pregunta", rs.getString("pregunta"));
                    fila.put("fecha", rs.getTimestamp("fecha"));
                    fila.put("zona", rs.getString("zona"));
                    fila.put("formulario", rs.getString("formulario"));
                    datos.add(fila);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }

    /**
     * Obtiene métricas generales para cards del dashboard
     */
    public Map<String, Object> obtenerMetricasGenerales() {
        Map<String, Object> metricas = new HashMap<>();

        String sql = """
            SELECT 
                'total_formularios_completados' as metrica,
                COUNT(DISTINCT sr.idsesion) as valor
            FROM sesionrespuesta sr
            WHERE sr.estadoterminado = 1
            UNION ALL
            SELECT 
                'total_respuestas_registradas' as metrica,
                COUNT(r.idrespuesta) as valor
            FROM respuesta r
            JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            WHERE sr.estadoterminado = 1
            UNION ALL
            SELECT 
                'zonas_con_actividad' as metrica,
                COUNT(DISTINCT z.idzona) as valor
            FROM zona z
            JOIN distrito d ON z.idzona = d.idzona
            JOIN usuario u ON d.iddistrito = u.iddistrito
            JOIN asignacionformulario af ON u.idusuario = af.idencuestador
            JOIN sesionrespuesta sr ON af.idasignacionformulario = sr.idasignacionformulario
            WHERE sr.estadoterminado = 1
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                String metrica = rs.getString("metrica");
                Object valor = rs.getObject("valor");
                metricas.put(metrica, valor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return metricas;
    }

    /**
     * Obtiene estadísticas por zona geográfica
     */
    public List<Map<String, Object>> obtenerEstadisticasPorZona() {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
            SELECT 
                z.nombrezona as zona,
                COUNT(DISTINCT sr.idsesion) as total_sesiones_completadas,
                COUNT(DISTINCT af.idencuestador) as encuestadores_activos,
                COUNT(DISTINCT sr.idencuestado) as personas_encuestadas,
                COALESCE(AVG(DATEDIFF(sr.fechaenvio, sr.fechainicio)), 0) as promedio_dias_completar
            FROM zona z
            LEFT JOIN distrito d ON z.idzona = d.idzona
            LEFT JOIN usuario u ON d.iddistrito = u.iddistrito
            LEFT JOIN asignacionformulario af ON u.idusuario = af.idencuestador
            LEFT JOIN sesionrespuesta sr ON af.idasignacionformulario = sr.idasignacionformulario
            WHERE sr.estadoterminado = 1 OR sr.idsesion IS NULL
            GROUP BY z.idzona, z.nombrezona
            ORDER BY total_sesiones_completadas DESC
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("zona", rs.getString("zona"));
                fila.put("sesiones_completadas", rs.getInt("total_sesiones_completadas"));
                fila.put("encuestadores_activos", rs.getInt("encuestadores_activos"));
                fila.put("personas_encuestadas", rs.getInt("personas_encuestadas"));
                fila.put("promedio_dias", rs.getDouble("promedio_dias_completar"));
                datos.add(fila);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }

    /**
     * Obtiene las preguntas disponibles con sus tipos para el dashboard
     */
    public List<Map<String, Object>> obtenerPreguntasParaAnalisis() {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
            SELECT DISTINCT
                p.idpregunta,
                p.textopregunta,
                f.titulo,
                COUNT(DISTINCT op.idopcionpregunta) as tiene_opciones,
                COUNT(DISTINCT r.idrespuesta) as total_respuestas
            FROM pregunta p
            JOIN formulario f ON p.idformulario = f.idformulario
            LEFT JOIN opcionpregunta op ON p.idpregunta = op.idpregunta
            LEFT JOIN respuesta r ON p.idpregunta = r.idpregunta
            LEFT JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            WHERE sr.estadoterminado = 1 OR r.idrespuesta IS NULL
            GROUP BY p.idpregunta, p.textopregunta, f.titulo
            HAVING total_respuestas > 0
            ORDER BY total_respuestas DESC
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("id", rs.getInt("idpregunta"));
                fila.put("texto", rs.getString("textopregunta"));
                fila.put("formulario", rs.getString("titulo"));
                fila.put("tieneOpciones", rs.getInt("tiene_opciones") > 0);
                fila.put("totalRespuestas", rs.getInt("total_respuestas"));
                datos.add(fila);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }

    /**
     * Obtiene análisis detallado de formularios con sus preguntas y respuestas agrupadas
     */
    public List<Map<String, Object>> obtenerAnalisisCompletoFormularios() {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
            SELECT 
                f.idformulario,
                f.titulo,
                f.descripcion as formulario_descripcion,
                COUNT(DISTINCT sr.idsesion) as total_respuestas_formulario,
                COUNT(DISTINCT af.idencuestador) as encuestadores_asignados
            FROM formulario f
            LEFT JOIN asignacionformulario af ON f.idformulario = af.idformulario
            LEFT JOIN sesionrespuesta sr ON af.idasignacionformulario = sr.idasignacionformulario 
                AND sr.estadoterminado = 1
            GROUP BY f.idformulario, f.titulo, f.descripcion
            ORDER BY f.idformulario
        """;

        System.out.println("[DEBUG] SQL para formularios: " + sql);

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            System.out.println("[DEBUG] Ejecutando consulta de formularios...");

            while (rs.next()) {
                Map<String, Object> formulario = new HashMap<>();
                int idFormulario = rs.getInt("idformulario");
                String nombreFormulario = rs.getString("titulo");
                int totalRespuestas = rs.getInt("total_respuestas_formulario");

                System.out.println("[DEBUG] Formulario encontrado: ID=" + idFormulario +
                        ", Nombre=" + nombreFormulario +
                        ", Respuestas=" + totalRespuestas);

                formulario.put("idFormulario", idFormulario);
                formulario.put("nombreFormulario", nombreFormulario);
                formulario.put("descripcion", rs.getString("formulario_descripcion"));
                formulario.put("totalRespuestas", totalRespuestas);
                formulario.put("encuestadoresAsignados", rs.getInt("encuestadores_asignados"));

                // Obtener preguntas del formulario
                List<Map<String, Object>> preguntas = obtenerPreguntasConAnalisis(idFormulario);
                System.out.println("[DEBUG] Preguntas encontradas para formulario " + idFormulario + ": " + preguntas.size());
                formulario.put("preguntas", preguntas);

                datos.add(formulario);
            }

            System.out.println("[DEBUG] Total formularios encontrados: " + datos.size());

        } catch (SQLException e) {
            System.err.println("[ERROR] Error en obtenerAnalisisCompletoFormularios: " + e.getMessage());
            e.printStackTrace();
        }

        return datos;
    }

    /**
     * Obtiene preguntas de un formulario específico con análisis de respuestas
     */
    public List<Map<String, Object>> obtenerPreguntasConAnalisis(int idFormulario) {
        List<Map<String, Object>> preguntas = new ArrayList<>();

        System.out.println("==============================================");
        System.out.println("[DEBUG-PREGUNTAS] Iniciando para formulario ID: " + idFormulario);

        // Verificación simple primero
        String sqlSimple = "SELECT COUNT(*) as total FROM pregunta WHERE idformulario = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlSimple)) {

            pstmt.setInt(1, idFormulario);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("total");
                    System.out.println("[DEBUG-PREGUNTAS] Contador simple de preguntas: " + count);
                    if (count == 0) {
                        System.out.println("[DEBUG-PREGUNTAS] ❌ NO HAY PREGUNTAS - Retornando lista vacía");
                        return preguntas;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[ERROR-PREGUNTAS] Error en consulta simple: " + e.getMessage());
            e.printStackTrace();
            return preguntas;
        }

        // Consulta principal MUY SIMPLE
        String sql = "SELECT idpregunta, textopregunta, obligatorio FROM pregunta WHERE idformulario = ? ORDER BY idpregunta";

        System.out.println("[DEBUG-PREGUNTAS] Ejecutando consulta principal...");
        System.out.println("[DEBUG-PREGUNTAS] SQL: " + sql);

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idFormulario);

            try (ResultSet rs = pstmt.executeQuery()) {
                int contadorProcesadas = 0;

                while (rs.next()) {
                    contadorProcesadas++;
                    int idPregunta = rs.getInt("idpregunta");
                    String textoPregunta = rs.getString("textopregunta");
                    boolean obligatorio = rs.getBoolean("obligatorio");

                    System.out.println("[DEBUG-PREGUNTAS] " + contadorProcesadas + ". ID: " + idPregunta +
                            " | Texto: '" + textoPregunta + "' | Obligatorio: " + obligatorio);

                    Map<String, Object> pregunta = new HashMap<>();
                    pregunta.put("idPregunta", idPregunta);
                    pregunta.put("textoPregunta", textoPregunta);
                    pregunta.put("obligatorio", obligatorio);

                    // Verificar el tipo de pregunta primero
                    String tipoPregunta = obtenerTipoPregunta(idPregunta);
                    System.out.println("    -> Tipo de pregunta: " + tipoPregunta);

                    boolean esOpcionMultiple = "opcion_multiple".equals(tipoPregunta) || "si_no".equals(tipoPregunta);
                    pregunta.put("tieneOpciones", esOpcionMultiple);

                    // Solo contar opciones si es de opción múltiple
                    int tieneOpciones = 0;
                    if (esOpcionMultiple) {
                        tieneOpciones = contarOpcionesPorPregunta(idPregunta);
                        System.out.println("    -> Opciones disponibles: " + tieneOpciones);
                    }

                    // Contar respuestas
                    int totalRespuestas = contarRespuestasPorPregunta(idPregunta);
                    pregunta.put("totalRespuestas", totalRespuestas);
                    System.out.println("    -> Total respuestas: " + totalRespuestas);

                    // DECISIÓN CLAVE: Determinar si es opción múltiple basado en número de opciones
                    if (tieneOpciones > 0) {
                        System.out.println("    -> 🚀 PREGUNTA CON OPCIONES - Procesando como opciones múltiples");
                        esOpcionMultiple = true;
                    } else {
                        System.out.println("    -> 📝 PREGUNTA SIN OPCIONES - Procesando como texto libre");
                        esOpcionMultiple = false;
                    }

                    if (esOpcionMultiple) {
                        // CRÍTICO: Debug antes de la llamada al método
                        System.err.println("    -> 🚨 CRÍTICO: A PUNTO DE LLAMAR obtenerDatosOpcionesMultiplesPorPregunta");
                        System.err.println("    -> 🚨 CRÍTICO: ID Pregunta: " + idPregunta);
                        System.err.println("    -> 🚨 CRÍTICO: esOpcionMultiple: " + esOpcionMultiple);
                        System.err.println("    -> 🚨 CRÍTICO: Tipo pregunta: " + tipoPregunta);

                        // Obtener datos para gráficos
                        System.out.println("    -> 🚀 INICIANDO obtenerDatosOpcionesMultiplesPorPregunta para ID: " + idPregunta);

                        List<Map<String, Object>> opcionesData = null;
                        try {
                            System.err.println("    -> 🚨 EJECUTANDO MÉTODO...");
                            opcionesData = obtenerDatosOpcionesMultiplesPorPregunta(idPregunta);
                            System.err.println("    -> 🚨 MÉTODO COMPLETADO - Resultado size: " + (opcionesData != null ? opcionesData.size() : "NULL"));
                        } catch (Exception e) {
                            System.err.println("    -> ❌ ERROR AL EJECUTAR obtenerDatosOpcionesMultiplesPorPregunta: " + e.getMessage());
                            e.printStackTrace();
                            opcionesData = new ArrayList<>();
                        }

                        if (opcionesData == null) {
                            System.err.println("    -> ❌ ERROR CRÍTICO: opcionesData es NULL");
                            opcionesData = new ArrayList<>();
                        }

                        System.out.println("    -> 🔄 RESULTADO obtenerDatosOpcionesMultiplesPorPregunta: " + opcionesData.size() + " elementos");

                        if (opcionesData.isEmpty()) {
                            System.err.println("    -> ❌ ERROR: obtenerDatosOpcionesMultiplesPorPregunta retornó lista vacía para pregunta " + idPregunta);
                        }

                        // Determinar el tipo de análisis basado en el tipo de pregunta y opciones
                        if ("si_no".equals(tipoPregunta)) {
                            System.out.println("    -> ✅ Tipo: SI_NO (por tipo de pregunta)");
                            pregunta.put("tipoAnalisis", "si_no");
                        } else if (opcionesData.size() == 2) {
                            // Verificar si las opciones son similares a Sí/No
                            String opcion1 = opcionesData.get(0).get("textoOpcion").toString().toLowerCase().trim();
                            String opcion2 = opcionesData.get(1).get("textoOpcion").toString().toLowerCase().trim();

                            if ((opcion1.contains("sí") || opcion1.contains("si") || opcion1.contains("yes")) &&
                                    (opcion2.contains("no") || opcion2.contains("no") || opcion2.contains("not"))) {
                                System.out.println("    -> ✅ Tipo: SI_NO (detectado por contenido)");
                                pregunta.put("tipoAnalisis", "si_no");
                            } else if ((opcion2.contains("sí") || opcion2.contains("si") || opcion2.contains("yes")) &&
                                    (opcion1.contains("no") || opcion1.contains("no") || opcion1.contains("not"))) {
                                System.out.println("    -> ✅ Tipo: SI_NO (detectado por contenido)");
                                pregunta.put("tipoAnalisis", "si_no");
                            } else {
                                System.out.println("    -> ✅ Tipo: OPCIONES_MULTIPLES");
                                pregunta.put("tipoAnalisis", "opciones_multiples");
                            }
                        } else {
                            System.out.println("    -> ✅ Tipo: OPCIONES_MULTIPLES");
                            pregunta.put("tipoAnalisis", "opciones_multiples");
                        }

                        pregunta.put("opcionesMultiples", opcionesData);
                        System.out.println("    -> Datos opciones generados: " + opcionesData.size() + " elementos");

                        // Debug detallado de opciones - MEJORADO
                        if (opcionesData.isEmpty()) {
                            System.out.println("    -> ❌ WARNING: No se generaron datos de opciones para pregunta " + idPregunta);
                        } else {
                            System.out.println("    -> ✅ Opciones detalladas:");
                            for (int i = 0; i < Math.min(opcionesData.size(), 5); i++) {
                                Map<String, Object> opt = opcionesData.get(i);
                                System.out.println("      [" + i + "] '" + opt.get("textoOpcion") + "' = " + opt.get("cantidadRespuestas") + " respuestas");
                            }
                        }

                    } else {
                        System.out.println("    -> ✅ Tipo: TEXTO_LIBRE");
                        pregunta.put("tipoAnalisis", "texto_libre");

                        List<Map<String, Object>> respuestasTexto = obtenerRespuestasTextoLibrePorPregunta(idPregunta, 10);
                        pregunta.put("respuestasTexto", respuestasTexto);
                        System.out.println("    -> Respuestas texto obtenidas: " + respuestasTexto.size());
                    }

                    preguntas.add(pregunta);
                    System.out.println("    -> ✅ Pregunta añadida exitosamente");
                }

                System.out.println("[DEBUG-PREGUNTAS] 🎯 TOTAL PROCESADAS: " + contadorProcesadas);
                System.out.println("[DEBUG-PREGUNTAS] 🎯 LISTA FINAL SIZE: " + preguntas.size());

            }
        } catch (SQLException e) {
            System.err.println("[ERROR-PREGUNTAS] Error en consulta principal: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("[DEBUG-PREGUNTAS] ✅ Retornando " + preguntas.size() + " preguntas para formulario " + idFormulario);
        System.out.println("==============================================");
        return preguntas;
    }

    /**
     * Método auxiliar para contar opciones por pregunta
     */
    private int contarOpcionesPorPregunta(int idPregunta) {
        String sql = "SELECT COUNT(*) as total FROM opcionpregunta WHERE idpregunta = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idPregunta);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt("total");
                    System.out.println("[DEBUG] >>> Contando opciones para pregunta " + idPregunta + ": " + count);
                    return count;
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR contando opciones para pregunta " + idPregunta + ": " + e.getMessage());
            // Intentar una consulta alternativa para verificar si la tabla existe
            try (Connection conn = getConnection();
                 PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM opcionpregunta WHERE idpregunta = ? LIMIT 1")) {
                pstmt.setInt(1, idPregunta);
                try (ResultSet rs = pstmt.executeQuery()) {
                    int count = 0;
                    while (rs.next()) {
                        count++;
                    }
                    System.out.println("[DEBUG] >>> Contando opciones (método alternativo) para pregunta " + idPregunta + ": " + count);
                    return count;
                }
            } catch (SQLException e2) {
                System.err.println("ERROR en método alternativo para pregunta " + idPregunta + ": " + e2.getMessage());
            }
        }
        return 0;
    }

    /**
     * Obtiene el tipo de pregunta desde la base de datos
     */
    private String obtenerTipoPregunta(int idPregunta) {
        String sql = "SELECT tipo FROM pregunta WHERE idpregunta = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idPregunta);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String tipo = rs.getString("tipo");
                    System.out.println("[DEBUG] >>> Tipo de pregunta " + idPregunta + ": " + tipo);
                    return tipo;
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR obteniendo tipo de pregunta " + idPregunta + ": " + e.getMessage());
            // Si no existe la columna tipo, intentar determinar por opciones
            int opciones = contarOpcionesPorPregunta(idPregunta);
            if (opciones > 0) {
                return "opcion_multiple";
            } else {
                return "texto_libre";
            }
        }
        return "texto_libre";
    }

    /**
     * Método auxiliar para contar respuestas por pregunta
     */
    private int contarRespuestasPorPregunta(int idPregunta) {
        String sql = """
            SELECT COUNT(DISTINCT r.idrespuesta) as total
            FROM respuesta r
            JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
            WHERE r.idpregunta = ? AND sr.estadoterminado = 1
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idPregunta);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR contando respuestas para pregunta " + idPregunta + ": " + e.getMessage());
        }
        return 0;
    }

    /**
     * Obtiene respuestas de texto libre para una pregunta específica
     */
    public List<Map<String, Object>> obtenerRespuestasTextoLibrePorPregunta(int idPregunta, int limite) {
        List<Map<String, Object>> respuestas = new ArrayList<>();
        String sql = """
            SELECT 
                r.textorespuesta,
                'N/A' as fechaenvio,
                'N/A' as nombrezona,
                'N/A' as encuestador
            FROM respuesta r
            INNER JOIN sesionrespuesta sr ON r.idSesion = sr.idSesion
            WHERE r.idpregunta = ? 
                AND r.textorespuesta IS NOT NULL 
                AND LENGTH(TRIM(r.textorespuesta)) > 0
                AND sr.estadoTerminado = 1
            ORDER BY r.idrespuesta DESC
            LIMIT ?
        """;

        System.out.println("[DEBUG] Ejecutando consulta respuestas texto libre SOLO TERMINADOS para pregunta: " + idPregunta);
        System.out.println("[DEBUG] SQL: " + sql);

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idPregunta);
            pstmt.setInt(2, limite);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> respuesta = new HashMap<>();
                    respuesta.put("texto", rs.getString("textorespuesta"));
                    respuesta.put("fecha", rs.getString("fechaenvio"));
                    respuesta.put("zona", rs.getString("nombrezona"));
                    respuesta.put("encuestador", rs.getString("encuestador"));
                    respuestas.add(respuesta);
                    
                    System.out.println("[DEBUG] Respuesta texto libre (TERMINADO) encontrada: " + rs.getString("textorespuesta"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error en obtenerRespuestasTextoLibrePorPregunta: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("[DEBUG] Total respuestas texto libre TERMINADAS encontradas para pregunta " + idPregunta + ": " + respuestas.size());
        return respuestas;
    }

    /**
     * Obtiene estadísticas de respuestas por zona para un formulario específico
     */
    public List<Map<String, Object>> obtenerEstadisticasRespuestasPorZona(int idFormulario) {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
            SELECT 
                z.nombrezona,
                COUNT(DISTINCT sr.idsesion) as formularios_completados,
                COUNT(DISTINCT af.idencuestador) as encuestadores_participantes,
                ROUND(AVG(DATEDIFF(sr.fechaenvio, sr.fechainicio)), 2) as promedio_dias_completar
            FROM zona z
            JOIN distrito d ON z.idzona = d.idzona
            JOIN usuario u ON d.iddistrito = u.iddistrito
            JOIN asignacionformulario af ON u.idusuario = af.idencuestador
            JOIN sesionrespuesta sr ON af.idasignacionformulario = sr.idasignacionformulario
            WHERE af.idformulario = ? AND sr.estadoterminado = 1
            GROUP BY z.idzona, z.nombrezona
            ORDER BY formularios_completados DESC
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idFormulario);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("zona", rs.getString("nombrezona"));
                    fila.put("formulariosCompletados", rs.getInt("formularios_completados"));
                    fila.put("encuestadoresParticipantes", rs.getInt("encuestadores_participantes"));
                    fila.put("promedioDias", rs.getDouble("promedio_dias_completar"));
                    datos.add(fila);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }

    /**
     * Obtiene el top de respuestas más frecuentes para análisis de palabras clave
     */
    public List<Map<String, Object>> obtenerPalabrasClaveRespuestas() {
        List<Map<String, Object>> datos = new ArrayList<>();
        String sql = """
            SELECT 
                LOWER(TRIM(palabra)) as palabra_clave,
                COUNT(*) as frecuencia
            FROM (
                SELECT 
                    SUBSTRING_INDEX(SUBSTRING_INDEX(LOWER(r.textoRespuesta), ' ', n.n), ' ', -1) as palabra
                FROM respuesta r
                JOIN sesionrespuesta sr ON r.idsesion = sr.idsesion
                CROSS JOIN (
                    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION 
                    SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
                ) n
                WHERE r.textoRespuesta IS NOT NULL 
                    AND LENGTH(TRIM(r.textoRespuesta)) > 10
                    AND sr.estadoterminado = 1
                    AND CHAR_LENGTH(r.textoRespuesta) - CHAR_LENGTH(REPLACE(r.textoRespuesta, ' ', '')) >= n.n - 1
            ) palabras
            WHERE LENGTH(palabra) > 3 
                AND palabra NOT IN ('para', 'pero', 'desde', 'hasta', 'como', 'cuando', 'donde', 'porque', 'aunque', 'mientras', 'durante', 'antes', 'después', 'entre', 'sobre', 'bajo', 'contra', 'hacia', 'según', 'sin', 'con', 'por', 'que', 'una', 'las', 'los', 'del', 'muy', 'más', 'hay', 'son', 'fue', 'ser', 'fue', 'está', 'han', 'sus', 'todo', 'dos', 'año', 'años', 'hace', 'bien', 'vez', 'día', 'días', 'otro', 'otros', 'tiene', 'puede', 'también', 'había', 'cada', 'otro')
            GROUP BY palabra_clave
            HAVING frecuencia >= 3
            ORDER BY frecuencia DESC
            LIMIT 20
        """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("palabra", rs.getString("palabra_clave"));
                fila.put("frecuencia", rs.getInt("frecuencia"));
                datos.add(fila);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return datos;
    }

    /**
     * Método de prueba para verificar datos básicos en la base de datos
     */
    public Map<String, Object> verificarDatosBasicos() {
        Map<String, Object> verificacion = new HashMap<>();

        try (Connection conn = getConnection()) {
            // Verificar formularios
            String sqlFormularios = "SELECT COUNT(*) as total FROM formulario";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlFormularios);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    verificacion.put("totalFormularios", rs.getInt("total"));
                }
            }

            // Verificar preguntas
            String sqlPreguntas = "SELECT COUNT(*) as total FROM pregunta";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlPreguntas);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    verificacion.put("totalPreguntas", rs.getInt("total"));
                }
            }

            // Verificar opciones de pregunta
            String sqlOpciones = "SELECT COUNT(*) as total FROM opcionpregunta";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlOpciones);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    verificacion.put("totalOpciones", rs.getInt("total"));
                }
            }

            // Verificar respuestas
            String sqlRespuestas = "SELECT COUNT(*) as total FROM respuesta";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlRespuestas);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    verificacion.put("totalRespuestas", rs.getInt("total"));
                }
            }

            // Verificar sesiones completadas
            String sqlSesiones = "SELECT COUNT(*) as total FROM sesionrespuesta WHERE estadoterminado = 1";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlSesiones);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    verificacion.put("sesionesCompletadas", rs.getInt("total"));
                }
            }

            // Verificar un formulario específico con sus preguntas
            String sqlFormularioDetalle = """
                SELECT 
                    f.idformulario,
                    f.titulo,
                    COUNT(DISTINCT p.idpregunta) as preguntas_count,
                    COUNT(DISTINCT op.idopcionpregunta) as opciones_count,
                    COUNT(DISTINCT r.idrespuesta) as respuestas_count
                FROM formulario f
                LEFT JOIN pregunta p ON f.idformulario = p.idformulario
                LEFT JOIN opcionpregunta op ON p.idpregunta = op.idpregunta
                LEFT JOIN respuesta r ON p.idpregunta = r.idpregunta
                GROUP BY f.idformulario, f.titulo
                LIMIT 1
            """;
            try (PreparedStatement pstmt = conn.prepareStatement(sqlFormularioDetalle);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> formularioEjemplo = new HashMap<>();
                    formularioEjemplo.put("id", rs.getInt("idformulario"));
                    formularioEjemplo.put("nombre", rs.getString("titulo"));
                    formularioEjemplo.put("preguntas", rs.getInt("preguntas_count"));
                    formularioEjemplo.put("opciones", rs.getInt("opciones_count"));
                    formularioEjemplo.put("respuestas", rs.getInt("respuestas_count"));
                    verificacion.put("formularioEjemplo", formularioEjemplo);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            verificacion.put("error", e.getMessage());
        }

        return verificacion;
    }

    /**
     * Método de debug simple para verificar datos básicos
     */
    public Map<String, Object> obtenerDatosDebug() {
        Map<String, Object> debug = new HashMap<>();

        try (Connection conn = getConnection()) {
            // Contar formularios
            try (PreparedStatement pstmt = conn.prepareStatement("SELECT COUNT(*) FROM formulario")) {
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    debug.put("totalFormularios", rs.getInt(1));
                }
            }

            // Contar preguntas
            try (PreparedStatement pstmt = conn.prepareStatement("SELECT COUNT(*) FROM pregunta")) {
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    debug.put("totalPreguntas", rs.getInt(1));
                }
            }

            // Contar opciones de preguntas
            try (PreparedStatement pstmt = conn.prepareStatement("SELECT COUNT(*) FROM opcionpregunta")) {
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    debug.put("totalOpciones", rs.getInt(1));
                }
            }

            // Contar respuestas
            try (PreparedStatement pstmt = conn.prepareStatement("SELECT COUNT(*) FROM respuesta")) {
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    debug.put("totalRespuestas", rs.getInt(1));
                }
            }

            // Contar sesiones completadas
            try (PreparedStatement pstmt = conn.prepareStatement("SELECT COUNT(*) FROM sesionrespuesta WHERE estadoterminado = 1")) {
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    debug.put("sesionesCompletadas", rs.getInt(1));
                }
            }

            // Primeros 3 formularios
            try (PreparedStatement pstmt = conn.prepareStatement("SELECT idformulario, titulo FROM formulario LIMIT 3")) {
                ResultSet rs = pstmt.executeQuery();
                StringBuilder formularios = new StringBuilder();
                while (rs.next()) {
                    formularios.append("ID:").append(rs.getInt(1))
                            .append(" Nombre:").append(rs.getString(2)).append("; ");
                }
                debug.put("ejemplosFormularios", formularios.toString());
            }

            // DIAGNÓSTICO: Verificar estructura de tabla opcionpregunta
            try {
                DatabaseMetaData metaData = conn.getMetaData();
                ResultSet columns = metaData.getColumns(null, null, "opcionpregunta", null);
                StringBuilder columnasOpcionPregunta = new StringBuilder("Columnas en opcionpregunta: ");
                while (columns.next()) {
                    columnasOpcionPregunta.append(columns.getString("COLUMN_NAME")).append(", ");
                }
                debug.put("columnasOpcionPregunta", columnasOpcionPregunta.toString());
            } catch (SQLException e) {
                debug.put("errorColumnasOpcionPregunta", e.getMessage());
            }

            // DIAGNÓSTICO: Verificar estructura de tabla respuesta
            try {
                DatabaseMetaData metaData = conn.getMetaData();
                ResultSet columns = metaData.getColumns(null, null, "respuesta", null);
                StringBuilder columnasRespuesta = new StringBuilder("Columnas en respuesta: ");
                while (columns.next()) {
                    columnasRespuesta.append(columns.getString("COLUMN_NAME")).append(", ");
                }
                debug.put("columnasRespuesta", columnasRespuesta.toString());
            } catch (SQLException e) {
                debug.put("errorColumnasRespuesta", e.getMessage());
            }

            // Verificar ejemplos de preguntas con opciones (usando solo columnas que sabemos que existen)
            try (PreparedStatement pstmt = conn.prepareStatement(
                    "SELECT p.idpregunta, p.textopregunta " +
                            "FROM pregunta p " +
                            "WHERE p.idpregunta IN (8, 10, 11, 12) " +
                            "ORDER BY p.idpregunta LIMIT 5")) {
                ResultSet rs = pstmt.executeQuery();
                StringBuilder ejemplosPregunta = new StringBuilder();
                while (rs.next()) {
                    ejemplosPregunta.append("ID:").append(rs.getInt(1))
                            .append(" Texto:").append(rs.getString(2).substring(0, Math.min(30, rs.getString(2).length()))).append("...; ");
                }
                debug.put("ejemplosPreguntas", ejemplosPregunta.toString());
            }

            // Verificar si hay datos en opcionpregunta para las preguntas que sabemos que tienen opciones
            try (PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM opcionpregunta WHERE idpregunta = 8 LIMIT 5")) {
                ResultSet rs = pstmt.executeQuery();
                StringBuilder opcionesEjemplo = new StringBuilder("Opciones para pregunta 8: ");
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();

                // Mostrar nombres de columnas primero
                for (int i = 1; i <= columnCount; i++) {
                    opcionesEjemplo.append(rsmd.getColumnName(i)).append(", ");
                }
                opcionesEjemplo.append(" | Datos: ");

                while (rs.next()) {
                    for (int i = 1; i <= columnCount; i++) {
                        opcionesEjemplo.append(rs.getString(i)).append(", ");
                    }
                    opcionesEjemplo.append(" | ");
                }
                debug.put("opcionesEjemplo", opcionesEjemplo.toString());
            } catch (SQLException e) {
                debug.put("errorOpcionesEjemplo", e.getMessage());
            }

        } catch (SQLException e) {
            debug.put("error", e.getMessage());
            e.printStackTrace();
        }

        return debug;
    }

    /**
     * Obtiene datos de opciones múltiples para una pregunta específica, para crear gráficos
     * VERSIÓN CORREGIDA: Usa el tipo de pregunta y la relación correcta con respuestas
     */
    public List<Map<String, Object>> obtenerDatosOpcionesMultiplesPorPregunta(int idPregunta) {
        List<Map<String, Object>> datos = new ArrayList<>();

        System.out.println("[DEBUG] >>> 🔍 INICIANDO obtenerDatosOpcionesMultiplesPorPregunta SOLO TERMINADOS para pregunta ID: " + idPregunta);

        try (Connection conn = getConnection()) {
            System.out.println("[DEBUG] >>> ✅ Conexión a BD obtenida exitosamente");

            // Consulta mejorada que asegura SOLO formularios terminados
            String sql = """
                SELECT 
                    op.idOpcion,
                    op.textoOpcion,
                    COUNT(r.idRespuesta) as cantidad_respuestas
                FROM opcionpregunta op
                LEFT JOIN respuesta r ON op.idOpcion = r.idOpcion
                LEFT JOIN sesionrespuesta sr ON r.idSesion = sr.idSesion
                WHERE op.idPregunta = ?
                    AND (r.idRespuesta IS NULL OR sr.estadoTerminado = 1)
                GROUP BY op.idOpcion, op.textoOpcion
                ORDER BY op.idOpcion
            """;

            System.out.println("[DEBUG] >>> 📝 SQL preparado SOLO TERMINADOS: " + sql.replaceAll("\\s+", " "));
            System.out.println("[DEBUG] >>> 🎯 Parámetro idPregunta: " + idPregunta);

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, idPregunta);
                System.out.println("[DEBUG] >>> ⚡ PreparedStatement configurado, ejecutando query...");

                try (ResultSet rs = pstmt.executeQuery()) {
                    System.out.println("[DEBUG] >>> 📊 Query ejecutado exitosamente, procesando ResultSet...");

                    int contador = 0;
                    while (rs.next()) {
                        contador++;
                        Map<String, Object> opcion = new HashMap<>();

                        int idOpcionPregunta = rs.getInt("idOpcion");
                        String textoOpcion = rs.getString("textoOpcion");
                        int cantidadRespuestas = rs.getInt("cantidad_respuestas");

                        opcion.put("idOpcionPregunta", idOpcionPregunta);
                        opcion.put("textoOpcion", textoOpcion);
                        opcion.put("cantidadRespuestas", cantidadRespuestas);
                        datos.add(opcion);

                        System.out.println("[DEBUG] >>> 📋 Opción " + contador + " (SOLO TERMINADOS): ID=" + idOpcionPregunta +
                                ", Texto='" + textoOpcion + "', Respuestas=" + cantidadRespuestas);
                    }

                    System.out.println("[DEBUG] >>> 🎯 TOTAL OPCIONES PROCESADAS (SOLO TERMINADOS): " + contador);
                    System.out.println("[DEBUG] >>> 📝 TAMAÑO LISTA RESULTADO: " + datos.size());

                    if (datos.isEmpty()) {
                        System.err.println("[ERROR] >>> ❌ NO SE ENCONTRARON OPCIONES para pregunta " + idPregunta);
                        System.err.println("[ERROR] >>> 🔍 Verifica la tabla 'opcionpregunta' para idPregunta=" + idPregunta);
                    } else {
                        System.out.println("[DEBUG] >>> ✅ Opciones encontradas exitosamente (SOLO FORMULARIOS TERMINADOS)");
                    }
                }
            }

            System.out.println("[DEBUG] >>> 🏁 Total opciones encontradas para pregunta " + idPregunta + " (SOLO TERMINADOS): " + datos.size());

        } catch (SQLException e) {
            System.err.println("❌ ERROR en obtenerDatosOpcionesMultiplesPorPregunta: " + e.getMessage());
            e.printStackTrace();
        }

        return datos;
    }
}
