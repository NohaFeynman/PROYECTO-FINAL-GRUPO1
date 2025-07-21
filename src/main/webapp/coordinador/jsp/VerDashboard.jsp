<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Debug para ver las métricas que llegan
    System.out.println("=== DEBUG METRICAS ===");
    Map<String, Object> metricasGenerales = (Map<String, Object>) request.getAttribute("metricasGenerales");
    if (metricasGenerales != null) {
        System.out.println("Métricas encontradas:");
        System.out.println("Encuestadores activos: " + metricasGenerales.get("encuestadoresActivos"));
        System.out.println("Formularios completados: " + metricasGenerales.get("formulariosCompletados"));
        System.out.println("Formularios disponibles: " + metricasGenerales.get("formulariosDisponibles"));
    } else {
        System.out.println("No se encontraron métricas en el request");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">

    <title>Dashboard Coordinador</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<%
    // Debug para ver las métricas que llegan
    System.out.println("=== DEBUG METRICAS ===");
    Map<String, Object> metricas = (Map<String, Object>) request.getAttribute("metricas");
    if (metricas != null) {
        System.out.println("Métricas encontradas:");
        System.out.println("Formularios completados: " + metricas.get("formulariosCompletados"));
        System.out.println("Formularios disponibles: " + metricas.get("formulariosDisponibles"));
    } else {
        System.out.println("No se encontraron métricas en el request");
    }

    // Procesar datos usando analisisFormularios que es lo que envía el servlet coordinador
    List<Map<String, Object>> analisisFormularios = (List<Map<String, Object>>) request.getAttribute("analisisFormularios");
    
    System.out.println("=== DEBUG JSP DASHBOARD COORDINADOR ===");
    System.out.println("analisisFormularios: " + (analisisFormularios != null ? "existe" : "es null"));
    System.out.println("analisisFormularios size: " + (analisisFormularios != null ? analisisFormularios.size() : "null"));
    if (analisisFormularios != null && !analisisFormularios.isEmpty()) {
        System.out.println("Mostrando primeros 3 formularios:");
        for (int i = 0; i < Math.min(3, analisisFormularios.size()); i++) {
            Map<String, Object> form = analisisFormularios.get(i);
            System.out.println("  Formulario " + (i+1) + ":");
            System.out.println("    - ID: " + form.get("idFormulario"));
            System.out.println("    - Nombre: " + form.get("nombreFormulario"));
            System.out.println("    - Total Respuestas: " + form.get("totalRespuestas"));
            
            // Verificar preguntas y sus distribuciones
            Object preguntasObj = form.get("preguntas");
            if (preguntasObj instanceof List) {
                List<Map<String, Object>> preguntas = (List<Map<String, Object>>) preguntasObj;
                System.out.println("    - Total preguntas: " + preguntas.size());
                
                for (int j = 0; j < Math.min(3, preguntas.size()); j++) {
                    Map<String, Object> pregunta = preguntas.get(j);
                    System.out.println("      Pregunta " + (j+1) + ":");
                    System.out.println("        - ID: " + pregunta.get("idPregunta"));
                    System.out.println("        - Texto: " + pregunta.get("textoPregunta"));
                    System.out.println("        - Tiene opciones: " + pregunta.get("tieneOpciones"));
                    
                    Object distribuciones = pregunta.get("distribucionRespuestas");
                    System.out.println("        - Distribuciones: " + (distribuciones != null ? "existe" : "null"));
                    if (distribuciones instanceof List) {
                        List<?> listaDist = (List<?>) distribuciones;
                        System.out.println("        - Distribuciones count: " + listaDist.size());
                    }
                }
            } else {
                System.out.println("    - Preguntas: null o no es List");
            }
        }
    }

    // Obtener y calcular los valores dinámicos de activos e inactivos para el gráfico pastel
        int activosEncuestadores = 0;
        int inactivosEncuestadores = 0;
        try {
            com.example.webproyecto.daos.UsuarioDao usuarioDao = new com.example.webproyecto.daos.UsuarioDao();
            int idCoordinador = (session.getAttribute("idUsuario") != null) ? (Integer) session.getAttribute("idUsuario") : 0;
            // Obtener todos los encuestadores de la zona del coordinador
            List<com.example.webproyecto.dtos.CoordinadorDTO> encuestadores = usuarioDao.listarEncuestadoresPorZonaCoordinador(idCoordinador);
            for (com.example.webproyecto.dtos.CoordinadorDTO e : encuestadores) {
                if (e.getUsuario().getIdEstado() == 2) activosEncuestadores++;
                else inactivosEncuestadores++;
            }
        } catch (Exception ex) {
            activosEncuestadores = 0;
            inactivosEncuestadores = 0;
        }
        request.setAttribute("activosEncuestadores", activosEncuestadores);
        request.setAttribute("inactivosEncuestadores", inactivosEncuestadores);
%>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">

    <title>Dashboard Coordinador</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --color-primary: #3498db;
            --color-success: #2ecc71;
            --color-danger: #e74c3c;
            --color-gray: #95a5a6;
            --header-bg: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
            --color-bg: #f5f7fa;
            --color-card: #c8dbff;
            --color-card-inner: #e6f0ff;
            --sidebar-bg: #e6f0ff;
            --color-warning: #f39c12;
            --color-info: #3498db;
        }
        
        .dashboard-title {
            font-size: 2rem;
            color: var(--color-primary);
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .dashboard-title i {
            font-size: 1.8rem;
        }
        
        .metrics-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .metric-card {
            background: var(--color-card-inner);
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            transition: transform 0.2s;
        }
        
        .metric-card:hover {
            transform: translateY(-5px);
        }
        
        .metric-card i {
            font-size: 2rem;
            margin-bottom: 1rem;
            color: var(--color-primary);
        }
        
        .metric-card h3 {
            font-size: 1.1rem;
            color: #666;
            margin: 0;
            margin-bottom: 0.5rem;
        }
        
        .metric-card p {
            font-size: 2rem;
            font-weight: bold;
            color: var(--color-primary);
            margin: 0;
        }

        .formulario-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .formulario-titulo {
            font-size: 1.4rem;
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .total-respuestas {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 2rem;
        }

        .pregunta-container {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .pregunta-titulo {
            font-size: 1.1rem;
            color: #2c3e50;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .pregunta-badge {
            font-size: 0.8rem;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-weight: normal;
            margin-left: auto;
        }

        .pregunta-badge.obligatoria {
            background-color: #e74c3c;
            color: white;
        }

        .pregunta-badge.opcional {
            background-color: #3498db;
            color: white;
        }

        .distribucion-titulo {
            font-size: 1rem;
            color: #666;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .distribucion-titulo i {
            color: #3498db;
        }

        .info-badge {
            background: #e8f4f8;
            color: #2980b9;
            padding: 0.2rem 0.5rem;
            border-radius: 15px;
            font-size: 0.75rem;
            margin-left: 1rem;
            border: 1px solid #bde1ed;
        }

        .pregunta-summary {
            background: #f8f9fb;
            border-radius: 8px;
            padding: 1rem;
            margin: 1rem 0;
            border-left: 4px solid #3498db;
        }

        .summary-stats {
            display: flex;
            gap: 2rem;
            flex-wrap: wrap;
        }

        .summary-stats .stat-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #2c3e50;
            font-size: 0.9rem;
        }

        .summary-stats .stat-item i {
            color: #3498db;
        }

        .distrito-selector {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 1rem;
            margin: 1rem 0;
            border: 1px solid #e9ecef;
        }

        .distrito-selector h5 {
            color: #2c3e50;
            margin-bottom: 0.8rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .distrito-selector h5 i {
            color: #3498db;
        }

        .distrito-buttons {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .distrito-btn {
            background: #e9ecef;
            border: 2px solid #dee2e6;
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            color: #495057;
            font-size: 0.85rem;
            font-weight: 500;
        }

        .distrito-btn:hover {
            background: #c8dbff;
            border-color: #3498db;
            color: #2c3e50;
        }

        .distrito-btn.active {
            background: #3498db;
            border-color: #2980b9;
            color: white;
        }

        .distrito-btn.todos {
            background: #28a745;
            border-color: #20c997;
            color: white;
        }

        .distrito-btn.todos:hover {
            background: #20c997;
            border-color: #17a2b8;
        }
        
        /* Estilo específico para información de preguntas Sí/No */
        .distrito-info-siNo {
            background: #e8f4f8 !important;
            padding: 12px !important;
            border-radius: 8px !important;
            margin: 10px 0 !important;
            color: #2c3e50 !important;
            text-align: center !important;
            border-left: 4px solid #3498db !important;
            font-size: 0.9rem;
        }
        
        .distrito-info-siNo i {
            color: #3498db;
            margin-right: 8px;
        }
        
        .distrito-info-siNo strong {
            color: #2c3e50;
        }
        
        .distrito-info-siNo small {
            color: #546e7a;
            display: block;
            margin-top: 4px;
            line-height: 1.3;
        }
        
        /* ESTILOS PARA CONTENER EL GRÁFICO DENTRO DEL RECUADRO */
        .formulario-card {
            background: white;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
            overflow: hidden; /* Prevenir desbordamiento */
            position: relative;
        }
        
        .formulario-content {
            width: 100%;
            max-width: 100%;
            overflow: hidden; /* Asegurar que no se desborde */
        }
        
        .pregunta-analysis {
            margin-bottom: 2rem;
            padding: 1.5rem;
            background: #f8f9fa;
            border-radius: 8px;
            border: 1px solid #e1ecf4;
            overflow: hidden; /* Crítico para contener el gráfico */
            position: relative;
            width: 100%;
            box-sizing: border-box;
        }
        
        .chart-section {
            margin: 1rem 0;
            padding: 1rem;
            background: white;
            border-radius: 8px;
            overflow: hidden; /* Evitar desbordamiento */
            max-width: 100%;
            box-sizing: border-box;
        }
        
        .chart-container {
            position: relative;
            width: 100%;
            max-width: 100%; /* No exceder el contenedor padre */
            height: 350px; /* Altura fija y controlada */
            margin: 1rem auto;
            background: white;
            padding: 1rem;
            border-radius: 8px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.05);
            overflow: hidden; /* CRÍTICO: evitar que el canvas se desborde */
            box-sizing: border-box;
        }
        
        .chart-container canvas {
            max-width: 100% !important;
            max-height: 100% !important;
            width: 100% !important;
            height: 100% !important;
            object-fit: contain; /* Mantener proporciones */
        }

        .distribucion-details {
            margin-top: 2rem;
            background: #f8f9fa;
            border-radius: 8px;
            padding: 1.5rem;
        }

        .distribucion-details h5 {
            color: #2c3e50;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .distribucion-details h5 i {
            color: #3498db;
        }

        .opciones-grid {
            display: grid;
            gap: 1rem;
        }

        .opcion-detail {
            background: white;
            border-radius: 8px;
            padding: 1rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .opcion-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.5rem;
        }

        .opcion-name {
            font-weight: 600;
            color: #2c3e50;
        }

        .opcion-percentage {
            background: #3498db;
            color: white;
            padding: 0.2rem 0.6rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: bold;
        }

        .opcion-stats {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
        }

        .cantidad {
            color: #666;
            font-size: 0.9rem;
        }

        .progress-bar {
            flex-grow: 1;
            height: 8px;
            background: #e0e0e0;
            border-radius: 4px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #3498db, #2ecc71);
            transition: width 0.3s ease;
        }

        .formularios-content {
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }

        .formulario-card {
            background: white;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .preguntas-grid {
            display: grid;
            gap: 2rem;
            margin-top: 1.5rem;
        }

        .chart-section {
            margin: 1.5rem 0;
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 8px;
        }

        .chart-container {
            position: relative;
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            height: 300px;
            background: white;
            padding: 1rem;
            border-radius: 8px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.05);
        }

        .legend-container {
            display: flex;
        }

        /* ============================================= */
        /* NUEVA ESTRUCTURA: CSS PARA GRID DE PREGUNTAS */
        /* ============================================= */
        
        /* Grid global de todas las preguntas */
        .preguntas-grid-global {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));
            gap: 20px;
            margin-top: 20px;
            padding: 0 10px;
        }

        .pregunta-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 20px;
            border: 1px solid #e0e0e0;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            min-height: 400px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            position: relative;
        }

        .pregunta-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }

        .pregunta-card .pregunta-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
            gap: 10px;
        }

        .pregunta-card .pregunta-header h4 {
            color: #2c3e50;
            font-weight: 600;
            font-size: 16px;
            line-height: 1.4;
            margin: 0;
            flex: 1;
        }

        .pregunta-card .pregunta-badge {
            padding: 4px 8px;
            border-radius: 15px;
            font-size: 11px;
            font-weight: 500;
            white-space: nowrap;
            flex-shrink: 0;
        }

        .pregunta-card .pregunta-badge.obligatoria {
            background: #ffebee;
            color: #c62828;
            border: 1px solid #ffcdd2;
        }

        .pregunta-card .pregunta-badge.opcional {
            background: #e8f5e8;
            color: #2e7d32;
            border: 1px solid #c8e6c9;
        }

        .pregunta-card .formulario-context {
            margin-bottom: 15px;
            padding: 8px 12px;
            background: #f8f9fa;
            border-radius: 6px;
            border-left: 4px solid #007bff;
        }

        .pregunta-card .formulario-context small {
            color: #6c757d;
            font-size: 13px;
            font-weight: 500;
        }

        .pregunta-card .formulario-context i {
            color: #007bff;
            margin-right: 6px;
        }

        .pregunta-card .chart-section {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .pregunta-card .distribucion-titulo {
            color: #2c3e50;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .pregunta-card .distribucion-titulo i {
            color: #007bff;
        }

        .pregunta-card .info-badge {
            background: #e3f2fd;
            color: #1976d2;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 11px;
            margin-left: auto;
        }

        .pregunta-card .chart-container {
            position: relative;
            flex: 1;
            min-height: 250px;
            max-height: 300px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            box-sizing: border-box;
        }

        .pregunta-card .chart-container canvas {
            max-width: 100% !important;
            max-height: 100% !important;
            width: auto !important;
            height: auto !important;
        }

        .pregunta-card .legend-container {
            margin-top: 10px;
            font-size: 12px;
        }

        .pregunta-card .respuestas-texto-section {
            border-top: 1px solid #eee;
            padding-top: 15px;
            margin-top: 15px;
        }

        .pregunta-card .respuestas-texto-section h6 {
            color: #495057;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .pregunta-card .respuestas-grid {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .pregunta-card .respuesta-item {
            background: #f8f9fa;
            padding: 10px;
            border-radius: 6px;
            border-left: 3px solid #28a745;
        }

        .pregunta-card .respuesta-texto {
            font-size: 13px;
            color: #495057;
            margin: 0 0 5px 0;
            line-height: 1.4;
        }

        .pregunta-card .respuesta-meta {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            color: #6c757d;
        }

        .pregunta-card .respuesta-meta i {
            margin-right: 4px;
        }

        /* Responsive design para la nueva estructura */
        @media (max-width: 768px) {
            .preguntas-grid-global {
                grid-template-columns: 1fr;
                gap: 15px;
                padding: 0 5px;
            }

            .pregunta-card {
                padding: 15px;
                min-height: 350px;
            }

            .pregunta-card .pregunta-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 8px;
            }

            .pregunta-card .pregunta-badge {
                align-self: flex-start;
            }
        }

        @media (min-width: 1200px) {
            .preguntas-grid-global {
                grid-template-columns: repeat(2, 1fr);
                max-width: 1400px;
                margin: 20px auto 0 auto;
            }
        }

        @media (min-width: 1600px) {
            .preguntas-grid-global {
                grid-template-columns: repeat(3, 1fr);
            }
        }

        .legend-container-original {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 1rem;
            margin-top: 1.5rem;
        }

        .legend-item {
            background: #f8f9fa;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 0.8rem;
            min-width: 200px;
        }

        .legend-color {
            width: 16px;
            height: 16px;
            border-radius: 4px;
            flex-shrink: 0;
        }

        .legend-label {
            display: flex;
            flex-direction: column;
            gap: 0.2rem;
        }

        .legend-label span:first-child {
            font-weight: 500;
            color: #2c3e50;
        }

        .legend-value {
            font-size: 0.9rem;
            color: #666;
        }

        .legend-percentage {
            font-size: 0.8rem;
            color: #888;
        }

        /* Contenedor principal */
        main {
            min-height: 100vh;
            padding: 2rem;
        }

        .formularios-analysis-section {
            background: white;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-top: 2rem;
        }
        
        .formularios-analysis-section h2 {
            color: var(--color-primary);
            font-size: 1.5rem;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .formularios-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 2rem;
        }
        
        /* Para pantallas muy grandes, permitir hasta 2 columnas máximo */
        @media (min-width: 1400px) {
            .formularios-grid {
                grid-template-columns: repeat(2, 1fr);
                max-width: 1400px;
                margin: 0 auto;
            }
            
            .formulario-content {
                grid-template-columns: repeat(2, 1fr); /* Forzar 2 columnas en pantallas grandes */
            }
        }
        
        .formulario-card {
            background: var(--color-card-inner);
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }
        
        .formulario-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1.5rem;
        }
        
        .formulario-info h3 {
            margin: 0;
            font-size: 1.2rem;
            color: #2c3e50;
        }
        
        .formulario-info p {
            margin: 0.5rem 0 0;
            color: #7f8c8d;
            font-size: 0.9rem;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            display: block;
            font-size: 1.8rem;
            font-weight: bold;
            color: var(--color-primary);
        }
        
        .stat-label {
            font-size: 0.9rem;
            color: #7f8c8d;
        }
        
        .formulario-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 1.5rem;
            margin-top: 1.5rem;
        }
        
        .pregunta-analysis {
            margin-bottom: 0; /* Quitar margen porque ya hay gap en el grid */
            padding: 1rem;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            position: relative;
            border: 1px solid #e1ecf4;
            min-height: 400px; /* Altura mínima para uniformidad */
        }
        
        .pregunta-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .pregunta-header h4 {
            margin: 0;
            font-size: 1.1rem;
            color: #34495e;
        }
        
        .pregunta-badge {
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        
        .pregunta-badge.obligatoria {
            background: var(--color-warning);
            color: white;
        }
        
        .chart-section {
            height: auto; /* Permitir altura automática */
            margin-top: 1rem;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 8px;
            overflow: hidden; /* Evitar desbordamiento de contenido */
            max-width: 100%; /* No exceder el ancho del contenedor */
        }
        
        .chart-container {
            position: relative;
            width: 100%;
            max-width: 600px;
            margin: 1rem auto; /* Centrar y dar margen */
            height: 350px; /* Altura fija contenida */
            background: white;
            padding: 1rem;
            border-radius: 8px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.05);
            overflow: hidden; /* Crucial: evitar desbordamiento */
            box-sizing: border-box; /* Incluir padding en el tamaño total */
        }
        
        .chart-container canvas {
            max-width: 100% !important;
            max-height: 100% !important;
            box-sizing: border-box;
        }
        
        .respuestas-texto-section {
            margin-top: 1rem;
        }
        
        .respuestas-texto-section h5 {
            color: #7f8c8d;
            margin-bottom: 1rem;
        }
        
        .respuestas-grid {
            display: grid;
            gap: 1rem;
        }
        
        .respuesta-item {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 8px;
        }
        
        .respuesta-texto {
            margin: 0 0 0.5rem;
            color: #2c3e50;
        }
        
        .respuesta-meta {
            display: flex;
            gap: 1rem;
            color: #7f8c8d;
            font-size: 0.9rem;
        }
        
        .respuesta-meta i {
            margin-right: 0.3rem;
        }
        
        .no-data-message {
            text-align: center;
            padding: 2rem;
            color: #7f8c8d;
        }
        
        .no-data-message i {
            font-size: 3rem;
            margin-bottom: 1rem;
            display: block;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #e6f0ff 0%, #b3ccff 100%);
            margin: 0;
            padding: 0;
            color: #333;
            min-height: 100vh;
        }
        .menu-toggle:checked ~ .sidebar { left: 0; }
        .menu-toggle:checked ~ .overlay { display: block; opacity: 1; }
        .contenedor-principal {
            width: 100%;
            margin: 0;
            padding: 20px 20px 20px 20px;
            box-sizing: border-box;
            min-height: calc(100vh - 56.8px);
            overflow-y: auto;
        }
        .sidebar {
            position: fixed;
            top: 0;
            left: -280px;
            width: 280px;
            height: 100%;
            background: linear-gradient(135deg, #dbeeff 60%, #b3ccff 100%);
            box-shadow: 8px 0 32px rgba(52, 152, 219, 0.13), 2px 0 8px rgba(52, 152, 219, 0.10);
            border-right: 3px solid #3498db;
            border-radius: 0 28px 0 0;
            transition: left 0.3s ease, box-shadow 0.2s;
            z-index: 2001;
            overflow-y: auto;
            padding: 24px 0 20px 0;
            backdrop-filter: blur(6px);
        }
        .sidebar-content {
            height: 100%;
            display: flex;
            flex-direction: column;
            gap: 18px;
            position: relative;
        }
        .sidebar-close-btn {
            position: absolute;
            top: 10px;
            right: 15px;
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: #333;
            font-size: 24px;
            font-weight: bold;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            z-index: 100;
        }
        .sidebar-close-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.1);
            color: #000;
        }
        .sidebar-separator {
            width: 80%;
            height: 2px;
            background: linear-gradient(90deg, #b3ccff 0%, #3498db 100%);
            border-radius: 2px;
            margin: 18px auto 18px auto;
            opacity: 0.7;
        }
        .sidebar-content .menu-links {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .sidebar-content .menu-links li {
            margin-bottom: 15px;
        }
        .sidebar-content .menu-links a {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            margin: 0 15px;
            border-radius: 8px;
            color: #1a1a1a;
            text-decoration: none;
            background-color: transparent;
            transition: all 0.3s ease;
            font-size: 16px;
            font-weight: bold;
        }
        .sidebar-content .menu-links a i {
            margin-right: 10px;
            font-size: 18px;
        }
        .sidebar-content .menu-links a:hover {
            background-color: #b3ccff;
            transform: scale(1.05);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.12);
            color: #003366;
        }
        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0,0,0,0.5);
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s ease;
            z-index: 2000;
        }
        .menu-toggle:checked ~ .overlay {
            opacity: 1;
            visibility: visible;
        }
        .header-bar {
            background: var(--header-bg);
            height: 56.8px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 10px rgba(135,206,235,0.3);
            position: relative;
            z-index: 800;
            width: 100%;
            padding: 0;
        }
        .header-content {
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            gap: 1rem;
            margin: 0;
            padding: 0 20px;
            box-sizing: border-box;
        }
        .header-left {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-left: 0;
        }
        .menu-icon {
            font-size: 26px;
            cursor: pointer;
            color: #333;
            display: inline-block;
            margin-left: 0;
        }
        .logo-section {
            display: flex;
            flex-direction: column;
            gap: 0.2rem;
            margin-left: 10px;
        }
        .logo-large img {
            height: 40px;
            object-fit: contain;
        }
        .header-right {
            display: flex;
            gap: 2.5rem;
            margin-left: auto;
        }
        .nav-item {
            display: flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
            font-weight: bold;
            color: #333;
            text-transform: uppercase;
            font-size: 0.9rem;
            user-select: none;
            position: relative;
        }
        .nav-icon {
            width: 28px;
            height: 28px;
            object-fit: cover;
        }
        .nav-item#btn-inicio span {
            display: none;
        }
        .nav-item#btn-encuestador {
            flex-direction: row;
            justify-content: flex-start;
            gap: 8px;
            color: #007bff;
            font-weight: bold;
        }
        .nav-item#btn-encuestador span {
            display: inline-block;
        }
        /* Dropdown arrow styling */
        .dropdown-arrow {
            font-size: 0.7rem;
            transition: transform 0.2s ease;
            margin-left: 4px;
            color: #007bff;
        }
        .nav-item.dropdown-active .dropdown-arrow {
            transform: rotate(180deg);
        }
        .dropdown-menu {
            display: none;
            position: absolute;
            top: 110%;
            left: 0;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            min-width: 140px;
            z-index: 1001;
            padding: 8px 0;
        }
        .nav-item.dropdown:focus-within .dropdown-menu,
        .nav-item.dropdown:hover .dropdown-menu,
        .nav-item.dropdown-active .dropdown-menu {
            display: block;
        }
        .dropdown-menu a {
            display: block;
            padding: 8px 18px;
            color: #333;
            text-decoration: none;
            font-size: 0.95em;
            transition: background 0.2s;
        }
        .dropdown-menu a:hover {
            background: #e6f0ff;
            color: #007bff;
        }
        @media (max-width: 600px) {
            .header-bar {
                flex-direction: column;
                height: auto;
                padding: 10px;
            }
            .header-content {
                flex-direction: column;
                align-items: flex-start;
            }
            .header-right {
                margin-left: 0;
                gap: 1.2rem;
            }
        }
        /* DASHBOARD GRID */
        .dashboard-wrapper {
            background: rgba(255,255,255,0.95);
            border-radius: 24px;
            box-shadow: 0 8px 32px rgba(52, 152, 219, 0.12), 0 1.5px 8px rgba(52, 152, 219, 0.10);
            border: 2px solid #b3ccff;
            padding: 20px;
            max-width: 1400px;
            margin: 0 auto;
            transition: box-shadow 0.2s;
        }
        .dashboard-grid {
            display: grid;
            grid-template-columns: 0.6fr 1.4fr;
            grid-template-rows: 1fr 1fr;
            gap: 15px;
            padding: 0;
            height: 100%;
            align-items: stretch;
        }
        .main-chart-container {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(52, 152, 219, 0.08);
            border: 1px solid #e1ecf4;
            padding: 40px 12px 60px 12px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
            height: 100%;
            min-height: 540px;
            margin-top: 80px; /* Empuja el bloque hacia abajo para centrarlo visualmente */
        }
        .main-chart-container .chart-title {
            font-size: 1.3rem;
            font-weight: bold;
            color: #333;
            margin: 0 0 24px 0;
            letter-spacing: 0.5px;
        }
        .main-chart-container .chart-container {
            position: relative;
            height: 240px;
            width: 240px;
            max-width: 100%;
            margin: 0 auto 24px auto;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .main-chart-container .chart-legend {
            display: flex;
            justify-content: center;
            gap: 24px;
            margin-top: 24px;
            margin-bottom: 0;
            flex-wrap: wrap;
        }
        @media (max-width: 1100px) {
            .main-chart-container {
                min-height: 340px;
                padding: 40px 8px 30px 8px;
                margin-top: 40px;
            }
            .main-chart-container .chart-container {
                height: 160px;
                width: 160px;
            }
        }
        @media (max-width: 700px) {
            .main-chart-container {
                min-height: 220px;
                padding: 18px 4px 18px 4px;
                margin-top: 10px;
            }
            .main-chart-container .chart-container {
                height: 100px;
                width: 100px;
            }
        }
        .bar-chart-container {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(52, 152, 219, 0.08);
            border: 1px solid #e1ecf4;
            padding: 10px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
        }
        .chart-title {
            font-size: 1.1rem;
            font-weight: bold;
            color: #333;
            margin: 0 0 3px 0;
        }
        .chart-container {
            position: relative;
            height: 300px;
            width: 100%;
            max-width: 500px;
            margin: 20px auto;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .chart-legend {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 20px;
            margin-top: 15px;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: #555;
        }
        
        .legend-color {
            width: 16px;
            height: 16px;
            border-radius: 4px;
        }
        
        .legend-label {
            display: flex;
            flex-direction: column;
        }
        
        .legend-value {
            font-weight: bold;
            color: #333;
        }
        
        .legend-percentage {
            font-size: 12px;
            color: #666;
        }
        .bar-chart-container .chart-container {
            height: calc(100% - 60px);
            max-width: 100%;
            width: 100%;
        }
        .chart-legend {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-top: 8px;
            flex-wrap: wrap;
        }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.9rem;
        }
        .legend-color {
            width: 12px;
            height: 12px;
            border-radius: 3px;
        }
        @media (max-width: 1100px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
                grid-template-rows: auto auto auto;
                gap: 10px;
            }
            .dashboard-wrapper {
                padding: 10px;
                margin: 0 auto;
                height: 100%;
            }
            .contenedor-principal {
                padding: 15px 15px 10px 15px;
            }
            .bar-chart-container {
                grid-row: auto !important;
            }
        }
        @media (max-width: 700px) {
            .chart-legend {
                gap: 10px;
            }
            .chart-container {
                height: 180px;
                max-width: 200px;
            }
            .dashboard-wrapper {
                padding: 8px;
                margin: 0 auto;
                height: 100%;
            }
            .contenedor-principal {
                padding: 10px 10px 5px 10px;
            }
            .dashboard-grid {
                grid-template-columns: 1fr;
                grid-template-rows: auto auto auto;
                gap: 8px;
            }
            .bar-chart-container {
                grid-row: auto !important;
            }
        }
        .styled-select {
            background: #e6f0ff;
            border: 1.5px solid #3498db;
            border-radius: 8px;
            padding: 6px 12px;
            font-size: 1em;
            color: #333;
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
            margin-bottom: 15px;
        }

        /* === MEJORAS RESPONSIVE PARA COORDINADOR === */
        
        /* Métricas cards responsive */
        .metrics-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .metric-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(52, 152, 219, 0.08);
            border: 1px solid #e1ecf4;
            text-align: center;
            transition: transform 0.3s ease;
        }

        .metric-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 25px rgba(52, 152, 219, 0.15);
        }

        .metric-card i {
            font-size: 2.5rem;
            color: #3498db;
            margin-bottom: 10px;
        }

        .metric-card h3 {
            font-size: 1rem;
            color: #2c3e50;
            margin-bottom: 8px;
            font-weight: 600;
        }

        .metric-card p {
            font-size: 2rem;
            font-weight: bold;
            color: #27ae60;
            margin: 0;
        }

        .dashboard-title {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 30px;
            font-size: 2rem;
            font-weight: 600;
        }

        .dashboard-title i {
            color: #3498db;
            margin-right: 10px;
        }

        /* Responsive para tablets */
        @media (max-width: 1024px) {
            .metrics-cards {
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
                margin-bottom: 25px;
            }
            
            .dashboard-title {
                font-size: 1.8rem;
                margin-bottom: 25px;
            }
            
            .formularios-analysis-section {
                padding: 15px;
            }
            
            .formulario-card {
                margin-bottom: 20px;
            }
            
            .formularios-grid {
                grid-template-columns: 1fr; /* Una sola columna en tablets */
            }
            
            .formulario-content {
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); /* Ajustar tamaño mínimo */
            }
        }

        /* Responsive para móviles */
        @media (max-width: 768px) {
            .metrics-cards {
                grid-template-columns: 1fr;
                gap: 12px;
                margin-bottom: 20px;
            }
            
            .metric-card {
                padding: 15px;
            }
            
            .metric-card i {
                font-size: 2rem;
            }
            
            .metric-card h3 {
                font-size: 0.9rem;
            }
            
            .metric-card p {
                font-size: 1.5rem;
            }
            
            .dashboard-title {
                font-size: 1.5rem;
                margin-bottom: 20px;
            }
            
            .formularios-analysis-section {
                padding: 12px;
            }
            
            .formularios-analysis-section h2 {
                font-size: 1.3rem;
            }
            
            .formularios-grid {
                grid-template-columns: 1fr; /* Una sola columna en móviles */
            }
            
            .formulario-content {
                grid-template-columns: 1fr; /* Una sola columna para las preguntas */
                gap: 1rem;
            }
            
            .formulario-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
                padding: 15px;
            }
            
            .pregunta-analysis {
                padding: 15px;
                margin-bottom: 0;
                min-height: auto; /* Permitir altura automática en móvil */
            }
            
            .pregunta-header {
                flex-direction: column;
                gap: 10px;
                text-align: left;
            }
            
            .chart-container {
                height: 250px;
                margin: 15px auto;
            }
            
            .respuestas-grid {
                grid-template-columns: 1fr;
                gap: 12px;
            }
        }

        /* Responsive para móviles pequeños */
        @media (max-width: 480px) {
            .contenedor-principal {
                padding: 10px;
            }
            
            .metrics-cards {
                gap: 10px;
                margin-bottom: 15px;
            }
            
            .metric-card {
                padding: 12px;
            }
            
            .metric-card i {
                font-size: 1.8rem;
                margin-bottom: 8px;
            }
            
            .metric-card h3 {
                font-size: 0.85rem;
                margin-bottom: 6px;
            }
            
            .metric-card p {
                font-size: 1.3rem;
            }
            
            .dashboard-title {
                font-size: 1.2rem;
                margin-bottom: 15px;
            }
            
            .formularios-analysis-section {
                padding: 8px;
                border-radius: 16px;
            }
            
            .formularios-analysis-section h2 {
                font-size: 1.1rem;
                margin-bottom: 15px;
            }
            
            .formulario-card {
                margin-bottom: 15px;
                border-radius: 12px;
            }
            
            .formulario-header {
                padding: 12px;
            }
            
            .formulario-info h3 {
                font-size: 1rem;
            }
            
            .formulario-info p {
                font-size: 0.85rem;
            }
            
            .pregunta-analysis {
                padding: 12px;
                margin-bottom: 15px;
                border-radius: 8px;
            }
            
            .pregunta-header h4 {
                font-size: 0.95rem;
                line-height: 1.3;
            }
            
            .pregunta-badge {
                padding: 3px 8px;
                font-size: 0.7rem;
            }
            
            .chart-container {
                height: 200px;
                margin: 10px auto;
            }
            
            .respuestas-texto-section {
                padding: 12px;
            }
            
            .respuestas-texto-section h5 {
                font-size: 0.9rem;
            }
            
            .respuesta-item {
                padding: 12px;
            }
            
            .respuesta-texto {
                font-size: 0.9rem;
            }
            
            .respuesta-meta {
                font-size: 0.75rem;
                flex-direction: column;
                gap: 4px;
                align-items: flex-start;
            }
        }

        /* Mejoras para dispositivos táctiles */
        @media (max-width: 768px) {
            .nav-item {
                min-height: 44px;
                padding: 8px 12px;
                border-radius: 8px;
                transition: background-color 0.2s ease;
            }
            
            .nav-item:hover, .nav-item:focus {
                background-color: rgba(52, 152, 219, 0.1);
            }
            
            .menu-icon {
                min-height: 44px;
                min-width: 44px;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 8px;
                transition: background-color 0.2s ease;
            }
            
            .menu-icon:hover, .menu-icon:focus {
                background-color: rgba(52, 152, 219, 0.1);
            }
            
            .sidebar-content .menu-links a {
                min-height: 48px;
                touch-action: manipulation;
            }
        }

        /* Optimizaciones de rendimiento para móvil */
        @media (max-width: 768px) {
            .sidebar, .overlay, .formulario-card, .pregunta-analysis {
                transform: translateZ(0);
            }
            
            .formulario-card:hover {
                transform: none;
            }
            
            .sidebar-content .menu-links a:hover {
                transform: none;
            }
        }
    </style>
</head>
<body>
<!-- Checkbox oculto para controlar el sidebar -->
<input type="checkbox" id="menu-toggle" class="menu-toggle" style="display:none;" />

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-content">
        <button class="sidebar-close-btn" onclick="document.getElementById('menu-toggle').checked = false;">×</button>
        <div class="sidebar-separator"></div>
        <ul class="menu-links">
            <li><a href="DashboardServlet"><i class="fa-solid fa-chart-line"></i> Ver Dashboard</a></li>
            <li><a href="GestionEncuestadoresServlet"><i class="fa-solid fa-users"></i> Gestionar Encuestadores</a></li>
            <li><a href="GestionarFormulariosServlet"><i class="fa-solid fa-file-alt"></i> Gestionar Formularios</a></li>
            <li><a href="CerrarSesionServlet"><i class="fa-solid fa-sign-out-alt"></i> Cerrar sesión</a></li>
        </ul>
    </div>
</div>

<!-- Overlay para cerrar el sidebar al hacer clic fuera -->
<label for="menu-toggle" class="overlay"></label>

<!-- Header -->
<header class="header-bar">
    <div class="header-content">
        <div class="header-left">
            <label for="menu-toggle" class="menu-icon">&#9776;</label>
            <div class="logo-section">
                <div class="logo-large">
                    <img src="${pageContext.request.contextPath}/imagenes/logo.jpg" alt="Logo Combinado" />
                </div>
            </div>
        </div>
        <nav class="header-right">
            <div class="nav-item dropdown" id="btn-encuestador" tabindex="0">
                <img src="${pageContext.request.contextPath}/imagenes/usuario.png" alt="Icono Usuario" class="nav-icon">
                <span>
                    <c:choose>
                      <c:when test="${not empty sessionScope.nombre}">
                        ${sessionScope.nombre}
                      </c:when>
                      <c:otherwise>
                        Coordinador
                      </c:otherwise>
                    </c:choose>
                </span>
                <span class="dropdown-arrow">▼</span>
                <div class="dropdown-menu">
                    <a href="VerPerfilServlet">Ver perfil</a>
                    <a href="CerrarSesionServlet">Cerrar sesión</a>
                </div>
            </div>
            <a href="InicioCoordinadorServlet" class="nav-item" id="btn-inicio">
                <img src="${pageContext.request.contextPath}/imagenes/inicio.png" alt="Icono de perfil" class="nav-icon" />
            </a>
        </nav>
    </div>
</header>

<!-- Contenido principal -->
<main class="contenedor-principal">
    <h1 class="dashboard-title">
        <i class="fas fa-chart-line"></i>
        Dashboard de 
        <c:choose>
            <c:when test="${not empty sessionScope.nombre}">
                ${sessionScope.nombre}
            </c:when>
            <c:otherwise>
                Coordinador
            </c:otherwise>
        </c:choose>
    </h1>

    <!-- Tarjetas de métricas generales -->
     <div class="metrics-cards">
    <div class="metric-card">
        <i class="fas fa-users"></i>
        <h3>Encuestadores Activos</h3>
        <p id="activosCount">${activosEncuestadores}</p>
    </div>
    <div class="metric-card">
        <i class="fas fa-user-slash"></i>
        <h3>Encuestadores Inactivos</h3>
        <p id="inactivosCount">${inactivosEncuestadores}</p>
    </div>
    <div class="metric-card">
        <i class="fas fa-file-alt"></i>
        <h3>Formularios Completados</h3>
        <p>${metricasGenerales.formulariosCompletados}</p>
    </div>
    <div class="metric-card">
        <i class="fas fa-clipboard-list"></i>
        <h3>Formularios Disponibles</h3>
        <p>${metricasGenerales.formulariosDisponibles}</p>
    </div>
</div>
    

    <!-- Sección de análisis de formularios -->
    <section class="formularios-analysis-section">
    <h2><i class="fas fa-chart-bar"></i> Análisis de Respuestas por Formulario y Distrito</h2>
    
    <c:choose>
        <c:when test="${not empty analisisFormularios}">
            <!-- Nueva estructura: Grid directo de todas las preguntas -->
            <div class="preguntas-grid-global">
                <c:forEach var="formulario" items="${analisisFormularios}">
                    <c:forEach var="pregunta" items="${formulario.preguntas}">
                        <c:if test="${pregunta.tieneOpciones and not empty pregunta.distribucionRespuestas}">
                            <div class="pregunta-card">
                                <div class="pregunta-header">
                                    <h4>${pregunta.textoPregunta}</h4>
                                    <span class="pregunta-badge ${pregunta.obligatorio ? 'obligatoria' : 'opcional'}">
                                        ${pregunta.obligatorio ? 'Obligatoria' : 'Opcional'}
                                    </span>
                                </div>
                                
                                <div class="formulario-context">
                                    <small><i class="fas fa-file-alt"></i> ${formulario.nombreFormulario}</small>
                                </div>
                                
                                <!-- Debug: Mostrar información de la pregunta -->
                                <%
                                    System.out.println("=== DEBUG JSP PREGUNTA ===");
                                    // Esto nos ayudará a ver qué preguntas se están procesando
                                %>
                                
                                <div class="chart-section">
                                    <h5 class="distribucion-titulo">
                                        <i class="fas fa-chart-pie"></i>
                                        Totales de la Zona Asignada
                                        <span class="info-badge">
                                            <i class="fas fa-info-circle"></i> 
                                            Consolidado de todos los distritos
                                        </span>
                                    </h5>
                                    
                                    <div class="chart-container">
                                        <canvas id="chart_${formulario.idFormulario}_${pregunta.idPregunta}" 
                                                width="400" height="300"
                                                data-pregunta-id="${pregunta.idPregunta}"
                                                data-formulario-id="${formulario.idFormulario}"
                                                data-pregunta-texto="${pregunta.textoPregunta}"></canvas>
                                    </div>
                                    
                                    <div id="legend_${formulario.idFormulario}_${pregunta.idPregunta}" class="legend-container"></div>
                                    
                                    <!-- Debug de distribución -->
                                    <div style="display: none;" class="debug-info">
                                        <h6>Debug Distribución:</h6>
                                        <c:forEach var="opcion" items="${pregunta.distribucionRespuestas}">
                                            <p>- ${opcion.opcion}: ${opcion.cantidad} (${opcion.porcentaje}%)</p>
                                        </c:forEach>
                                    </div>
                                </div>
                                
                                <c:if test="${not empty pregunta.respuestasTexto}">
                                    <div class="respuestas-texto-section">
                                        <h6>Últimas respuestas:</h6>
                                        <div class="respuestas-grid">
                                            <c:forEach var="respuesta" items="${pregunta.respuestasTexto}" varStatus="status">
                                                <c:if test="${status.index < 2}"> <!-- Solo mostrar 2 respuestas por espacio -->
                                                    <div class="respuesta-item">
                                                        <p class="respuesta-texto">${respuesta.texto}</p>
                                                        <div class="respuesta-meta">
                                                            <span class="respuesta-fecha">
                                                                <i class="far fa-calendar"></i> ${respuesta.fecha}
                                                            </span>
                                                            <span class="respuesta-zona">
                                                                <i class="fas fa-map-marker-alt"></i> ${respuesta.distrito}
                                                            </span>
                                                        </div>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </c:if>
                    </c:forEach>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="no-data-message">
                <i class="fas fa-info-circle"></i>
                <p>No hay datos de formularios disponibles para mostrar en este momento.</p>
            </div>
        </c:otherwise>
    </c:choose>
    </section>

        </div>
    </div>
</main>

<script>
console.log('=== DIAGNÓSTICO DASHBOARD COORDINADOR ===');
console.log('🔍 Chart.js disponible:', typeof Chart !== 'undefined');

document.addEventListener('DOMContentLoaded', function() {
    console.log('=== 🚀 INICIALIZANDO DASHBOARD COORDINADOR ===');
    
    // Verificar Chart.js
    if (typeof Chart === 'undefined') {
        console.error('❌ ERROR CRÍTICO: Chart.js no está disponible!');
        return;
    } else {
        console.log('✅ Chart.js versión:', Chart.version || 'Versión no detectada');
    }
    
    // Función para verificar canvas múltiples veces
    function verificarCanvas() {
        var canvasElements = document.querySelectorAll('[id^="chart_"]');
        console.log('🔍 Canvas elements encontrados:', canvasElements.length);
        
        canvasElements.forEach(function(canvas, i) {
            console.log('Canvas ' + (i + 1) + ': ' + canvas.id);
            console.log('  - data-distribucion: ' + (canvas.getAttribute('data-distribucion') ? 'SÍ' : 'NO'));
            console.log('  - Dimensiones: ' + canvas.offsetWidth + 'x' + canvas.offsetHeight);
            console.log('  - En DOM: ' + document.contains(canvas));
            console.log('  - Parent: ' + (canvas.parentElement ? canvas.parentElement.className : 'Sin parent'));
            console.log('  - Visible: ' + (window.getComputedStyle(canvas).display !== 'none'));
        });
        
        return canvasElements.length;
    }
    
    // Verificar inmediatamente
    var canvasInicial = verificarCanvas();
    
    // Verificar después de 500ms
    setTimeout(function() {
        console.log('🔄 Segunda verificación de canvas después de 500ms:');
        var canvasSegundo = verificarCanvas();
        
        if (canvasSegundo > 0) {
            try {
                console.log('📊 Iniciando creación de gráficos...');
                procesarGraficosNuevo();
                console.log('✅ Gráficos procesados exitosamente');
            } catch (error) {
                console.error('❌ Error creando gráficos:', error);
            }
        } else {
            console.error('❌ No se encontraron canvas después de 500ms');
        }
    }, 500);
    
    // Verificar después de 2 segundos como backup
    setTimeout(function() {
        console.log('🔄 Tercera verificación de canvas después de 2s:');
        var canvasTercero = verificarCanvas();
        
        if (canvasTercero > 0 && canvasTercero !== canvasSegundo) {
            console.log('🔄 Nuevos canvas detectados, reprocesando...');
            try {
                procesarGraficosNuevo();
            } catch (error) {
                console.error('❌ Error en reprocesamiento:', error);
            }
        }
    }, 2000);
});

// Datos de las preguntas para los gráficos (generados desde el backend)
var datosPreguntas = [];

<c:if test="${not empty analisisFormularios}">
<c:forEach var="formulario" items="${analisisFormularios}">
<c:forEach var="pregunta" items="${formulario.preguntas}">
<c:if test="${pregunta.tieneOpciones and not empty pregunta.distribucionRespuestas}">
console.log('🔧 Agregando pregunta al array JavaScript: <c:out value="${pregunta.textoPregunta}" escapeXml="true"/>');
console.log('🔧 Canvas ID que se generará: chart_${formulario.idFormulario}_${pregunta.idPregunta}');

var preguntaData = {
    canvasId: "chart_${formulario.idFormulario}_${pregunta.idPregunta}",
    idPregunta: ${pregunta.idPregunta},
    textoPregunta: '<c:out value="${pregunta.textoPregunta}" escapeXml="true"/>',
    distribucionRespuestas: [],
    // Simular datos por distrito basados en los datos reales
    datosPorDistrito: {}
};

// Primero guardamos las distribuciones generales
<c:forEach var="opcion" items="${pregunta.distribucionRespuestas}">
preguntaData.distribucionRespuestas.push({
    opcion: '<c:out value="${opcion.opcion}" escapeXml="true"/>',
    cantidad: ${opcion.cantidad},
    porcentaje: ${opcion.porcentaje}
});
</c:forEach>

// Simular distribución por distritos (en un caso real esto vendría del backend)
// Para efectos de demostración, dividiremos los datos entre distritos ficticios
var distritosSimulados = ['Distrito Centro', 'Distrito Norte', 'Distrito Sur'];
var totalRespuestasPregunta = preguntaData.distribucionRespuestas.reduce(function(sum, d) { 
    return sum + d.cantidad; 
}, 0);

// Distribuir las respuestas entre distritos de manera proporcional
distritosSimulados.forEach(function(distrito, distIndex) {
    preguntaData.datosPorDistrito[distrito] = [];
    
    preguntaData.distribucionRespuestas.forEach(function(opcion) {
        // Distribuir las respuestas de cada opción entre los distritos
        var cantidadEnDistrito;
        if (distIndex === 0) { // Distrito Centro - 50%
            cantidadEnDistrito = Math.ceil(opcion.cantidad * 0.5);
        } else if (distIndex === 1) { // Distrito Norte - 30%
            cantidadEnDistrito = Math.ceil(opcion.cantidad * 0.3);
        } else { // Distrito Sur - 20%
            cantidadEnDistrito = Math.floor(opcion.cantidad * 0.2);
        }
        
        if (cantidadEnDistrito > 0) {
            preguntaData.datosPorDistrito[distrito].push({
                opcion: opcion.opcion,
                cantidad: cantidadEnDistrito,
                porcentaje: ((cantidadEnDistrito / totalRespuestasPregunta) * 100).toFixed(1)
            });
        }
    });
});

datosPreguntas.push(preguntaData);
</c:if>
</c:forEach>
</c:forEach>
</c:if>

console.log('📊 Total preguntas con gráficos:', datosPreguntas.length);
console.log('📊 Datos completos:', datosPreguntas);

// Procesar gráficos inmediatamente después de cargar los datos
if (datosPreguntas.length > 0) {
    console.log('🚀 Iniciando procesamiento inmediato de gráficos zonales...');
    setTimeout(function() {
        procesarGraficosNuevo();
    }, 100);
}

// Función para generar colores automáticamente
function generateColors(cantidad) {
    var colores = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c', '#34495e', '#e67e22', '#95a5a6', '#16a085'];
    var resultado = [];
    for (var i = 0; i < cantidad; i++) {
        resultado.push(colores[i % colores.length]);
    }
    return resultado;
}

function procesarGraficosNuevo() {
    console.log('📊 Iniciando procesamiento de gráficos por distrito...');
    console.log('📊 Total preguntas a procesar:', datosPreguntas.length);
    
    if (datosPreguntas.length === 0) {
        console.warn('⚠️ No hay datos de preguntas para procesar');
        return;
    }
    
    // Verificar todos los canvas que existen en el DOM
    var todosLosCanvas = document.querySelectorAll('[id^="chart_"]');
    console.log('🔍 Total canvas en DOM:', todosLosCanvas.length);
    
    datosPreguntas.forEach(function(preguntaData, index) {
        try {
            console.log('🎯 Procesando pregunta ' + (index + 1) + '/' + datosPreguntas.length + ': ' + preguntaData.canvasId);
            console.log('❓ Pregunta: ' + preguntaData.textoPregunta);
            
            var canvas = document.getElementById(preguntaData.canvasId);
            if (!canvas) {
                console.error('❌ Canvas no encontrado:', preguntaData.canvasId);
                return;
            }
            
            console.log('✅ Canvas encontrado:', preguntaData.canvasId);
            
            // Crear gráfico directamente con totales de zona (sin botones de distritos)
            crearGraficoZonal(preguntaData);
            
            console.log('✅ Gráfico zonal creado:', preguntaData.canvasId);
            
        } catch (error) {
            console.error('❌ Error procesando gráfico ' + preguntaData.canvasId + ':', error);
            console.error('❌ Stack trace:', error.stack);
        }
    });
    
    console.log('📍 NOTA: Los gráficos muestran totales consolidados de TODA la zona asignada');
    console.log('🥧 Preguntas Sí/No se muestran como gráficos de pastel');
    console.log('📊 Preguntas múltiples se muestran como gráficos de barras');
}

function esPregunutaSiNo(preguntaData) {
    var labels = preguntaData.distribucionRespuestas.map(function(d) { return d.opcion.toLowerCase().trim(); });
    
    // Solo debe tener exactamente 2 opciones
    if (labels.length !== 2) {
        return false;
    }
    
    // Lista de preguntas específicas que sabemos que son Sí/No
    var preguntasSiNoEspecificas = [
        'hay niños/niñas de 0 a 5 años en el hogar',
        'hay personas adultas mayores en el hogar',
        'usan apoyos para movilizarse como sillas de rueda, bastón, muletas',
        'hay personas con discapacidad o enfermedad crónica en el hogar',
        'tienen carnet conadis',
        'actualmente está contratada (tiene contrato formal) en la casa donde trabaja',
        'participa en algún sindicato u organización',
        'usted realiza algún trabajo remunerado fuera de casa',
        'por qué no usa guarderías o centros de cuidado'
    ];
    
    // Verificar si la pregunta está en la lista específica
    var textoPreguntaLower = preguntaData.textoPregunta.toLowerCase();
    var esPreguntaEspecifica = preguntasSiNoEspecificas.some(function(preguntaEspecifica) {
        return textoPreguntaLower.includes(preguntaEspecifica);
    });
    
    // Si es una pregunta específica, es automáticamente Sí/No
    if (esPreguntaEspecifica) {
        console.log('🎯 Pregunta específica detectada como Sí/No:', preguntaData.textoPregunta);
        return true;
    }
    
    // Verificar diferentes variaciones de Sí/No en las opciones
    var tieneSi = labels.some(function(label) {
        return label === 'sí' || 
               label === 'si' || 
               label === 'sí.' ||
               label === 'si.' ||
               label.includes('sí') ||
               label.includes('si');
    });
    
    var tieneNo = labels.some(function(label) {
        return label === 'no' || 
               label === 'no.' ||
               label.includes('no');
    });
    
    var resultado = tieneSi && tieneNo;
    
    // Debug para ver qué está detectando
    console.log('🔍 Analizando pregunta:', preguntaData.textoPregunta);
    console.log('   📋 Opciones:', labels);
    console.log('   ✅ Tiene SÍ:', tieneSi);
    console.log('   ❌ Tiene NO:', tieneNo);
    console.log('   🎯 Es Sí/No:', resultado);
    
    return resultado;
}

function crearBotonesDistritos(preguntaData) {
    var contenedorId = 'distritos_' + preguntaData.canvasId.replace('chart_', '');
    var contenedor = document.getElementById(contenedorId);
    
    if (!contenedor) return;
    
    // Usar la función mejorada de detección
    var esSiNo = esPregunutaSiNo(preguntaData);
    
    // Limpiar contenedor
    contenedor.innerHTML = '';
    
    if (esSiNo) {
        // Para preguntas Sí/No, no mostrar nada - solo el gráfico limpio
        return; // No crear botones ni información adicional para preguntas Sí/No
    }
    
    // Para preguntas múltiples, crear botones de distritos como antes
    Object.keys(preguntaData.datosPorDistrito).forEach(function(distrito) {
        var btn = document.createElement('button');
        btn.className = 'distrito-btn';
        btn.innerHTML = '<i class="fas fa-map-marker-alt"></i> ' + distrito;
        btn.onclick = function() {
            // Quitar active de todos los botones
            var todosBotones = contenedor.parentElement.querySelectorAll('.distrito-btn');
            todosBotones.forEach(function(b) { b.classList.remove('active'); });
            
            // Activar este botón
            btn.classList.add('active');
            
            // Actualizar gráfico
            crearGraficoPorDistritos(preguntaData, distrito);
            
            // Actualizar texto de cobertura
            var coberturaSpan = document.getElementById('cobertura_' + preguntaData.canvasId.replace('chart_', ''));
            if (coberturaSpan) {
                coberturaSpan.innerHTML = 'Distrito seleccionado: ' + distrito;
            }
        };
        contenedor.appendChild(btn);
    });
}

// Función simplificada para crear gráficos zonales (sin distritos)
function crearGraficoZonal(preguntaData) {
    var canvas = document.getElementById(preguntaData.canvasId);
    var ctx = canvas.getContext('2d');
    
    // Destruir gráfico anterior si existe
    if (window.chartsInstances && window.chartsInstances[preguntaData.canvasId]) {
        window.chartsInstances[preguntaData.canvasId].destroy();
    }
    
    // Detectar si es pregunta Sí/No
    var esSiNo = esPregunutaSiNo(preguntaData);
    
    console.log('🔍 Detectando tipo de pregunta:', esSiNo ? 'SÍ/NO (gráfico pastel)' : 'MÚLTIPLE (gráfico barras)');
    console.log('📊 Datos totales de zona para:', preguntaData.textoPregunta);
    
    var datosGrafico;
    
    if (esSiNo) {
        // Para preguntas Sí/No, crear gráfico de pastel con totales zonales
        datosGrafico = crearDatosPastelSiNo(preguntaData);
        console.log('🥧 Creando gráfico PASTEL con totales de zona');
    } else {
        // Para preguntas múltiples, crear gráfico de barras simple con totales zonales
        datosGrafico = crearDatosBarrasZonal(preguntaData);
        console.log('📊 Creando gráfico BARRAS con totales de zona');
    }
    
    var tipoGrafico = esSiNo ? 'pie' : 'bar';
    
    var chart = new Chart(ctx, {
        type: tipoGrafico,
        data: datosGrafico,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                intersect: false,
            },
            plugins: {
                title: {
                    display: false, // Sin título para mantener limpio
                    text: 'Totales de la Zona',
                    font: { size: 14 },
                    color: '#2c3e50'
                },
                legend: {
                    display: true,
                    position: esSiNo ? 'bottom' : 'top',
                    labels: {
                        usePointStyle: true,
                        padding: 15,
                        font: {
                            size: esSiNo ? 12 : 11
                        }
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            if (esSiNo) {
                                var total = context.dataset.data.reduce(function(a, b) { return a + b; }, 0);
                                var porcentaje = ((context.parsed / total) * 100).toFixed(1);
                                return context.label + ': ' + context.parsed + ' respuestas (' + porcentaje + '%)';
                            } else {
                                return context.label + ': ' + context.parsed + ' respuestas';
                            }
                        }
                    }
                }
            },
            scales: esSiNo ? {} : {
                y: {
                    beginAtZero: true,
                    ticks: {
                        stepSize: 1,
                        font: {
                            size: 10
                        }
                    },
                    title: {
                        display: true,
                        text: 'Número de respuestas',
                        font: {
                            size: 11
                        }
                    }
                },
                x: {
                    ticks: {
                        maxRotation: 45,
                        font: {
                            size: 10
                        }
                    },
                    title: {
                        display: true,
                        text: 'Opciones de respuesta',
                        font: {
                            size: 11
                        }
                    }
                }
            },
            layout: {
                padding: {
                    left: 10,
                    right: 10,
                    top: 10,
                    bottom: 10
                }
            }
        }
    });
    
    // Guardar instancia del gráfico
    if (!window.chartsInstances) window.chartsInstances = {};
    window.chartsInstances[preguntaData.canvasId] = chart;
    
    console.log('✅ Gráfico zonal creado exitosamente');
}

function crearGraficoPorDistritos(preguntaData, distritoSeleccionado) {
    var canvas = document.getElementById(preguntaData.canvasId);
    var ctx = canvas.getContext('2d');
    
    // Destruir gráfico anterior si existe
    if (window.chartsInstances && window.chartsInstances[preguntaData.canvasId]) {
        window.chartsInstances[preguntaData.canvasId].destroy();
    }
    
    // Usar la función mejorada de detección
    var esSiNo = esPregunutaSiNo(preguntaData);
    
    console.log('🔍 Detectando tipo de pregunta:', esSiNo ? 'SÍ/NO (gráfico pastel)' : 'MÚLTIPLE (gráfico barras)');
    
    var datosGrafico, tituloGrafico;
    
    if (esSiNo) {
        // Para preguntas Sí/No, siempre mostrar datos consolidados de toda la zona
        datosGrafico = crearDatosPastelSiNo(preguntaData);
        tituloGrafico = ''; // Sin título para que se vea más limpio
        console.log('📊 Creando gráfico PASTEL para pregunta Sí/No');
    } else {
        // Para preguntas múltiples, mantener funcionalidad por distritos
        if (distritoSeleccionado === 'todos') {
            datosGrafico = crearDatosComparacionDistritos(preguntaData);
            tituloGrafico = 'Comparación entre todos los distritos';
        } else {
            datosGrafico = crearDatosDistritoIndividual(preguntaData, distritoSeleccionado);
            tituloGrafico = 'Distribución en ' + distritoSeleccionado;
        }
        console.log('📊 Creando gráfico BARRAS para pregunta múltiple');
    }
    
    var tipoGrafico = esSiNo ? 'pie' : 'bar';
    
    var chart = new Chart(ctx, {
        type: tipoGrafico,
        data: datosGrafico,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                intersect: false,
            },
            plugins: {
                title: {
                    display: !esSiNo, // No mostrar título para preguntas Sí/No
                    text: tituloGrafico,
                    font: { size: 14 },
                    color: '#2c3e50'
                },
                legend: {
                    display: true,
                    position: esSiNo ? 'bottom' : 'top',
                    labels: {
                        usePointStyle: true,
                        padding: 15,
                        font: {
                            size: esSiNo ? 12 : 11
                        }
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            if (esSiNo) {
                                var total = context.dataset.data.reduce(function(a, b) { return a + b; }, 0);
                                var porcentaje = ((context.parsed / total) * 100).toFixed(1);
                                return context.label + ': ' + context.parsed + ' respuestas (' + porcentaje + '%)';
                            } else {
                                return context.dataset.label + ': ' + context.parsed.y + ' respuestas';
                            }
                        }
                    }
                }
            },
            scales: esSiNo ? {} : {
                y: {
                    beginAtZero: true,
                    ticks: {
                        stepSize: 1,
                        font: {
                            size: 10
                        }
                    },
                    title: {
                        display: true,
                        text: 'Número de respuestas',
                        font: {
                            size: 11
                        }
                    }
                },
                x: {
                    ticks: {
                        maxRotation: 45,
                        font: {
                            size: 10
                        }
                    },
                    title: {
                        display: true,
                        text: 'Opciones de respuesta',
                        font: {
                            size: 11
                        }
                    }
                }
            },
            layout: {
                padding: {
                    left: 10,
                    right: 10,
                    top: 10,
                    bottom: 10
                }
            }
        }
    });
    
    // Guardar instancia del gráfico
    if (!window.chartsInstances) window.chartsInstances = {};
    window.chartsInstances[preguntaData.canvasId] = chart;
}

// Función para crear datos de gráfico de barras con totales zonales
function crearDatosBarrasZonal(preguntaData) {
    var labels = preguntaData.distribucionRespuestas.map(function(d) { return d.opcion; });
    var valores = preguntaData.distribucionRespuestas.map(function(d) { return d.cantidad; });
    var colores = generateColors(labels.length);
    
    console.log('📊 Creando datos de barras zonales:');
    labels.forEach(function(label, index) {
        console.log('   ' + label + ': ' + valores[index] + ' respuestas');
    });
    
    return {
        labels: labels,
        datasets: [{
            label: 'Total de respuestas en la zona',
            data: valores,
            backgroundColor: colores,
            borderColor: colores.map(function(color) {
                // Hacer bordes más oscuros
                return color.replace(')', ', 0.8)').replace('rgb', 'rgba');
            }),
            borderWidth: 1,
            hoverBackgroundColor: colores.map(function(color) {
                // Hacer colores más brillantes en hover
                return color.replace(')', ', 0.8)').replace('rgb', 'rgba');
            }),
            hoverBorderWidth: 2
        }]
    };
}

// Función para crear datos de gráfico pastel para preguntas Sí/No
function crearDatosPastelSiNo(preguntaData) {
    var labels = preguntaData.distribucionRespuestas.map(function(d) { return d.opcion; });
    var valores = preguntaData.distribucionRespuestas.map(function(d) { return d.cantidad; });
    
    // Función para determinar si una respuesta es positiva o negativa
    function esRespuestaPositiva(label) {
        var labelLower = label.toLowerCase().trim();
        // Palabras que indican respuesta positiva
        var palabrasPositivas = ['sí', 'si', 'tiene', 'usa', 'hay', 'está', 'participa', 'realiza'];
        // Palabras que indican respuesta negativa
        var palabrasNegativas = ['no', 'ninguna', 'ninguno', 'nunca', 'nada'];
        
        // Verificar palabras positivas
        if (palabrasPositivas.some(function(palabra) { return labelLower.includes(palabra); })) {
            return true;
        }
        
        // Verificar palabras negativas
        if (palabrasNegativas.some(function(palabra) { return labelLower.includes(palabra); })) {
            return false;
        }
        
        // Si no puede determinar por contenido, usar posición (primera opción = positiva)
        return preguntaData.distribucionRespuestas.indexOf(
            preguntaData.distribucionRespuestas.find(function(d) { return d.opcion === label; })
        ) === 0;
    }
    
    // Asignar colores inteligentemente
    var coloresSiNo = [];
    labels.forEach(function(label) {
        if (esRespuestaPositiva(label)) {
            coloresSiNo.push('#28a745'); // Verde para respuestas positivas
        } else {
            coloresSiNo.push('#dc3545'); // Rojo para respuestas negativas
        }
    });
    
    // Debug para verificar colores asignados
    console.log('🎨 Asignación inteligente de colores:');
    labels.forEach(function(label, index) {
        var tipo = esRespuestaPositiva(label) ? 'POSITIVA (Verde)' : 'NEGATIVA (Rojo)';
        console.log('   ' + label + ' → ' + tipo + ' (' + coloresSiNo[index] + ')');
    });
    
    return {
        labels: labels,
        datasets: [{
            label: 'Respuestas',
            data: valores,
            backgroundColor: coloresSiNo,
            borderColor: '#ffffff',
            borderWidth: 2,
            hoverBackgroundColor: coloresSiNo.map(function(color) {
                // Hacer colores más brillantes en hover
                return color === '#28a745' ? '#34ce57' : '#e85563';
            }),
            hoverBorderWidth: 3
        }]
    };
}

function crearDatosComparacionDistritos(preguntaData) {
    var distritos = Object.keys(preguntaData.datosPorDistrito);
    var opciones = preguntaData.distribucionRespuestas.map(function(d) { return d.opcion; });
    
    var datasets = distritos.map(function(distrito, index) {
        var colores = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6'];
        var color = colores[index % colores.length];
        
        var data = opciones.map(function(opcion) {
            var encontrado = preguntaData.datosPorDistrito[distrito].find(function(d) {
                return d.opcion === opcion;
            });
            return encontrado ? encontrado.cantidad : 0;
        });
        
        return {
            label: distrito,
            data: data,
            backgroundColor: color,
            borderColor: color,
            borderWidth: 1
        };
    });
    
    return {
        labels: opciones,
        datasets: datasets
    };
}

function crearDatosDistritoIndividual(preguntaData, distrito) {
    var datosDistrito = preguntaData.datosPorDistrito[distrito];
    var labels = datosDistrito.map(function(d) { return d.opcion; });
    var valores = datosDistrito.map(function(d) { return d.cantidad; });
    
    // Determinar si es pregunta Sí/No para colores especiales
    var esSiNo = labels.length === 2 && 
        labels.some(function(l) { return l.toLowerCase().includes('sí') || l.toLowerCase().includes('si'); }) &&
        labels.some(function(l) { return l.toLowerCase().includes('no'); });
    
    var colores = esSiNo ? 
        ['#28a745', '#dc3545'] : 
        ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6'];
    
    return {
        labels: labels,
        datasets: [{
            label: distrito,
            data: valores,
            backgroundColor: colores.slice(0, labels.length),
            borderColor: colores.slice(0, labels.length),
            borderWidth: 1
        }]
    };
}

function mostrarTodosDistritos(preguntaId) {
    // Encontrar los datos de la pregunta
    var preguntaData = datosPreguntas.find(function(p) {
        return p.canvasId === 'chart_' + preguntaId;
    });
    
    if (!preguntaData) return;
    
    // Quitar active de todos los botones
    var contenedorBotones = document.getElementById('distritos_' + preguntaId).parentElement;
    var todosBotones = contenedorBotones.querySelectorAll('.distrito-btn');
    todosBotones.forEach(function(b) { b.classList.remove('active'); });
    
    // Activar botón "Todos"
    var botonTodos = contenedorBotones.querySelector('.distrito-btn.todos');
    if (botonTodos) botonTodos.classList.add('active');
    
    // Actualizar gráfico
    crearGraficoPorDistritos(preguntaData, 'todos');
    
    // Actualizar texto de cobertura
    var coberturaSpan = document.getElementById('cobertura_' + preguntaId);
    if (coberturaSpan) {
        coberturaSpan.innerHTML = 'Cobertura: Todos los distritos asignados';
    }
}

// Función de diagnóstico
function diagnosticarDashboard() {
    console.log('🔍 === DIAGNÓSTICO FINAL DASHBOARD COORDINADOR ===');
    console.log('🏘️ ANÁLISIS POR TIPO DE PREGUNTA Y DISTRITO');
    console.log('');
    
    var canvasElements = document.querySelectorAll('[id^="chart_"]');
    console.log('📊 Canvas elements encontrados:', canvasElements.length);
    
    if (canvasElements.length === 0) {
        console.warn('⚠️ No se encontraron gráficos en el dashboard');
        console.log('💡 Esto puede significar que:');
        console.log('   1. No hay preguntas con opciones de respuesta');
        console.log('   2. No hay respuestas registradas en los distritos');
        console.log('   3. Hay un error en la carga de datos');
        return;
    }
    
    // Contar tipos de gráficos usando la función mejorada
    var preguntasSiNo = 0;
    var preguntasMultiples = 0;
    
    datosPreguntas.forEach(function(pregunta) {
        if (esPregunutaSiNo(pregunta)) {
            preguntasSiNo++;
        } else {
            preguntasMultiples++;
        }
    });
    
    console.log('');
    console.log('📋 RESUMEN DE GRÁFICOS POR TIPO:');
    console.log('═'.repeat(50));
    console.log('🥧 Preguntas SÍ/NO (gráficos pastel): ' + preguntasSiNo);
    console.log('📊 Preguntas múltiples (gráficos barras): ' + preguntasMultiples);
    console.log('📈 Total de gráficos: ' + (preguntasSiNo + preguntasMultiples));
    
    console.log('');
    console.log('📋 DETALLE DE GRÁFICOS GENERADOS:');
    console.log('═'.repeat(50));
    
    canvasElements.forEach(function(canvas, index) {
        var rect = canvas.getBoundingClientRect();
        console.log('📦 Gráfico ' + (index + 1) + ': ' + canvas.id);
        console.log('    ✓ Canvas visible: ' + (rect.width > 0 && rect.height > 0));
        console.log('    ✓ Dimensiones: ' + rect.width + 'x' + rect.height + ' píxeles');
        console.log('    ✓ En DOM: ' + document.contains(canvas));
        
        // Verificar si hay datos asociados
        var datosEncontrados = datosPreguntas.find(function(p) { 
            return p.canvasId === canvas.id; 
        });
        
        if (datosEncontrados) {
            var esSiNo = esPregunutaSiNo(datosEncontrados);
            var labels = datosEncontrados.distribucionRespuestas.map(function(d) { return d.opcion; });
            
            var totalRespuestas = datosEncontrados.distribucionRespuestas.reduce(function(sum, d) { 
                return sum + d.cantidad; 
            }, 0);
            
            console.log('    📊 Tipo: ' + (esSiNo ? 'GRÁFICO PASTEL (Sí/No)' : 'GRÁFICO BARRAS (Múltiple)'));
            console.log('    ✓ Total respuestas: ' + totalRespuestas + (esSiNo ? ' (consolidado zona)' : ' (de todos los distritos)'));
            console.log('    ✓ Opciones: ' + labels.join(', '));
            
            if (esSiNo) {
                console.log('    🥧 Muestra datos consolidados de TODA tu zona asignada');
            } else {
                console.log('    📊 Permite análisis por distrito individual');
            }
        } else {
            console.log('    ❌ No se encontraron datos asociados');
        }
        
        console.log('    ' + '─'.repeat(40));
    });
    
    console.log('');
    console.log('🌍 INFORMACIÓN DE FUNCIONALIDAD:');
    console.log('═'.repeat(50));
    console.log('🥧 PREGUNTAS SÍ/NO:');
    console.log('   ✓ Se muestran como gráficos PASTEL');
    console.log('   ✓ Datos CONSOLIDADOS de toda la zona de coordinación');
    console.log('   ✓ Colores: Verde para SÍ, Rojo para NO');
    console.log('   ✓ Porcentajes calculados sobre el total de respuestas');
    console.log('');
    console.log('� PREGUNTAS MÚLTIPLES:');
    console.log('   ✓ Se muestran como gráficos de BARRAS');
    console.log('   ✓ Permite análisis por distrito individual');
    console.log('   ✓ Comparación entre distritos disponible');
    console.log('   ✓ Botones de selección de distrito habilitados');
    console.log('');
    
    if (datosPreguntas.length > 0) {
        console.log('🏢 COBERTURA ACTUAL:');
        var distritos = Object.keys(datosPreguntas[0].datosPorDistrito);
        console.log('   � Distritos en tu zona: ' + distritos.join(', '));
        console.log('   🔢 Total distritos: ' + distritos.length);
    }
    
    console.log('');
    console.log('✅ Dashboard optimizado por tipo de pregunta');
    console.log('═'.repeat(50));
}

// Ejecutar diagnóstico después de 2 segundos
setTimeout(diagnosticarDashboard, 2000);
</script>
</body>
</html>
