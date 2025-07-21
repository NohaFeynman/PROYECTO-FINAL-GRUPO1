<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<%
    // Configurar cabeceras de control de caché
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies

    // Procesar datos del gráfico de líneas para JavaScript
    List<Map<String, Object>> datosGraficoLineas = (List<Map<String, Object>>) request.getAttribute("datosGraficoLineas");
    Map<String, Map<Integer, Integer>> datosPorZona = new HashMap<>();

    if (datosGraficoLineas != null && !datosGraficoLineas.isEmpty()) {
        for (Map<String, Object> dato : datosGraficoLineas) {
            String zona = (String) dato.get("zona");
            Integer mes = (Integer) dato.get("mes");
            Integer cantidad = (Integer) dato.get("formularios_completados");

            if (!datosPorZona.containsKey(zona)) {
                datosPorZona.put(zona, new HashMap<>());
            }
            datosPorZona.get(zona).put(mes, cantidad);
        }
    }

    // Crear JSON para JavaScript
    StringBuilder jsonDatos = new StringBuilder("{");
    boolean primera = true;
    for (Map.Entry<String, Map<Integer, Integer>> entry : datosPorZona.entrySet()) {
        if (!primera) jsonDatos.append(",");
        jsonDatos.append("'").append(entry.getKey()).append("':[");

        for (int mes = 1; mes <= 12; mes++) {
            if (mes > 1) jsonDatos.append(",");
            Integer valor = entry.getValue().get(mes);
            jsonDatos.append(valor != null ? valor : 0);
        }
        jsonDatos.append("]");
        primera = false;
    }
    jsonDatos.append("}");

    // DEBUG: Agregar logs para ver qué se está generando
    System.out.println("=== DEBUG JSP DASHBOARD ===");
    System.out.println("datosGraficoLineas size: " + (datosGraficoLineas != null ? datosGraficoLineas.size() : "null"));
    System.out.println("datosPorZona size: " + datosPorZona.size());
    System.out.println("JSON generado: " + jsonDatos.toString());

    // DEBUG: Verificar datos de análisis de formularios
    List<Map<String, Object>> analisisFormularios = (List<Map<String, Object>>) request.getAttribute("analisisFormularios");
    System.out.println("=== DEBUG ANÁLISIS FORMULARIOS ===");
    System.out.println("analisisFormularios: " + (analisisFormularios != null ? "existe" : "es null"));
    System.out.println("analisisFormularios size: " + (analisisFormularios != null ? analisisFormularios.size() : "null"));
    if (analisisFormularios != null && !analisisFormularios.isEmpty()) {
        for (int i = 0; i < Math.min(3, analisisFormularios.size()); i++) {
            Map<String, Object> form = analisisFormularios.get(i);
            System.out.println("Formulario " + i + ": " + form);
        }
    }

    for (Map.Entry<String, Map<Integer, Integer>> entry : datosPorZona.entrySet()) {
        System.out.println("Zona: '" + entry.getKey() + "' -> " + entry.getValue());
    }

    request.setAttribute("jsonDatosGrafico", jsonDatos.toString());
%>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">

    <title>Dashboard Administrador</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>    <style>
    :root {
        --color-primary: #3498db;
        --color-bg: #f5f7fa;
        --color-card: #c8dbff;
        --color-card-inner: #e6f0ff;
        --sidebar-bg: #e6f0ff;
        --header-bg: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
    }
    body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        background: linear-gradient(135deg, #e6f0ff 0%, #b3ccff 100%);
        margin: 0;
        padding: 0;
        color: #333;
        overflow-x: hidden; /* Solo ocultar scroll horizontal */
        min-height: 100vh;
    }

    .menu-toggle:checked ~ .sidebar { left: 0; }
    .menu-toggle:checked ~ .overlay { display: block; opacity: 1; }
    .contenedor-principal {
        width: 100%;
        margin: 0;
        padding: 15px 20px 15px 20px;
        box-sizing: border-box;
        min-height: calc(100vh - 56.8px);
        overflow-y: visible; /* Permitir scroll vertical */
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

    /* Responsive para sidebar */
    @media (max-width: 768px) {
        .sidebar {
            width: 260px;
            left: -260px;
            border-radius: 0 20px 0 0;
            padding: 20px 0 15px 0;
        }
    }

    @media (max-width: 480px) {
        .sidebar {
            width: 240px;
            left: -240px;
            border-radius: 0 15px 0 0;
            padding: 15px 0 10px 0;
        }
        .sidebar-content .menu-links a {
            padding: 10px 15px;
            margin: 0 10px;
            font-size: 15px;
        }
        .sidebar-content .menu-links a i {
            font-size: 16px;
        }
    }

    .sidebar-content {
        height: 100%;
        display: flex;
        flex-direction: column;
        gap: 18px;
        position: relative;
    }

    .sidebar-separator {
        width: 80%;
        height: 2px;
        background: linear-gradient(90deg, #b3ccff 0%, #3498db 100%);
        border-radius: 2px;
        margin: 18px auto 18px auto;
        opacity: 0.7;
    }

    .menu-links {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    .menu-links li {
        margin-bottom: 15px;
    }
    .menu-links li a {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        display: flex;
        align-items: center;
        padding: 12px 20px;
        margin: 0 15px;
        border-radius: 8px;
        color: #1a1a1a;
        text-decoration: none;
        background-color: transparent;
        font-size: 16px;
        font-weight: bold;
        min-height: 48px;
        transition: background-color 0.25s cubic-bezier(0.77,0.2,0.05,1.0),
                    color 0.2s,
                    box-shadow 0.25s cubic-bezier(0.77,0.2,0.05,1.0),
                    transform 0.25s cubic-bezier(0.77,0.2,0.05,1.0);
    }
    .menu-links li a i {
        margin-right: 10px;
        font-size: 18px;
    }
    .menu-links li a:hover {
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
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15), 0 2px 4px rgba(0, 0, 0, 0.1);
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
        font-size: 22px; /* Más pequeño como solicitaste */
        cursor: pointer;
        color: #333;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0;
        padding: 0;
        border: none;
        background: none;
        text-decoration: none;
        transition: color 0.2s ease;
    }

    .menu-icon:hover {
        color: #007bff;
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
    /* Dropdown menu for user */
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
    .nav-item.dropdown:focus-within .dropdown-menu,
    .nav-item.dropdown:hover .dropdown-menu,
    .nav-item.dropdown-active .dropdown-menu {
        display: block;
    }
    /* Dropdown arrow styling */
    .dropdown-arrow {
        font-size: 0.7rem;
        margin-left: 4px;
        transition: transform 0.2s ease;
        color: #007bff;
    }
    .nav-item.dropdown-active .dropdown-arrow {
        transform: rotate(180deg);
    }
    .dropdown:hover .dropdown-arrow,
    .dropdown:focus-within .dropdown-arrow {
        transform: rotate(180deg);
    }
    /* === MEDIA QUERIES PARA RESPONSIVE === */
    
    /* Tablet - Landscape (1024px - 1200px) */
    @media (max-width: 1200px) and (min-width: 1025px) {
        .dashboard-grid {
            grid-template-columns: 0.7fr 1.3fr;
            gap: 18px;
        }
        .contenedor-principal {
            padding: 18px 25px;
        }
        .dashboard-wrapper {
            padding: 15px 18px;
        }
    }

    /* Tablet - Portrait (768px - 1024px) */
    @media (max-width: 1024px) and (min-width: 769px) {
        .dashboard-grid {
            grid-template-columns: 1fr;
            grid-template-rows: auto auto auto;
            gap: 20px;
            height: auto;
        }
        .contenedor-principal {
            padding: 15px 20px;
        }
        .dashboard-wrapper {
            padding: 15px 20px;
            height: auto;
        }
        .bar-chart-container {
            grid-row: auto !important;
            min-height: 400px;
        }
        .main-chart-container {
            min-height: 250px;
        }
        .chart-container {
            height: 180px;
            max-width: 200px;
        }
        /* Header ajustes para tablet */
        .header-content {
            padding: 0 15px;
        }
        .header-right {
            gap: 2rem;
        }
    }

    /* Mobile - Large (481px - 768px) */
    @media (max-width: 768px) and (min-width: 481px) {
        .dashboard-grid {
            grid-template-columns: 1fr;
            grid-template-rows: auto auto auto;
            gap: 15px;
            height: auto;
        }
        .contenedor-principal {
            padding: 12px 15px;
        }
        .dashboard-wrapper {
            padding: 12px 15px;
            height: auto;
        }
        .bar-chart-container {
            grid-row: auto !important;
            min-height: 350px;
            padding: 15px 12px;
        }
        .main-chart-container {
            min-height: 220px;
            padding: 12px 10px;
        }
        .chart-container {
            height: 160px;
            max-width: 180px;
            margin-bottom: 8px;
        }
        .chart-title {
            font-size: 1rem;
            margin-bottom: 8px;
        }
        .chart-legend {
            gap: 8px;
            margin-top: 8px;
        }
        .legend-item {
            font-size: 0.85rem;
        }
        /* Header para mobile large */
        .header-bar {
            height: auto;
            padding: 8px 0;
        }
        .header-content {
            flex-direction: column;
            gap: 10px;
            padding: 0 12px;
        }
        .header-left {
            width: 100%;
            justify-content: space-between;
        }
        .header-right {
            margin-left: 0;
            gap: 1.5rem;
            width: 100%;
            justify-content: center;
        }
        .nav-item span {
            font-size: 0.85rem;
        }
    }

    /* Mobile - Small (320px - 480px) */
    @media (max-width: 480px) {
        .dashboard-grid {
            grid-template-columns: 1fr;
            grid-template-rows: auto auto auto;
            gap: 12px;
            height: auto;
        }
        .contenedor-principal {
            padding: 8px 10px;
        }
        .dashboard-wrapper {
            padding: 10px 12px;
            height: auto;
        }
        .bar-chart-container {
            grid-row: auto !important;
            min-height: 300px;
            padding: 12px 8px;
        }
        .main-chart-container {
            min-height: 200px;
            padding: 10px 8px;
        }
        .chart-container {
            height: 140px;
            max-width: 160px;
            margin-bottom: 6px;
        }
        .chart-title {
            font-size: 0.9rem;
            margin-bottom: 6px;
        }
        .chart-legend {
            gap: 6px;
            margin-top: 6px;
            flex-direction: column;
            align-items: center;
        }
        .legend-item {
            font-size: 0.8rem;
            gap: 4px;
        }
        .legend-color {
            width: 8px;
            height: 8px;
        }
        /* Header para mobile small */
        .header-bar {
            height: auto;
            padding: 6px 0;
        }
        .header-content {
            flex-direction: column;
            gap: 8px;
            padding: 0 8px;
        }
        .header-left {
            width: 100%;
            justify-content: space-between;
        }
        .header-right {
            margin-left: 0;
            gap: 1.2rem;
            width: 100%;
            justify-content: center;
            flex-wrap: wrap;
        }
        .nav-item {
            font-size: 0.8rem;
        }
        .nav-item span {
            font-size: 0.75rem;
        }
        .nav-icon {
            width: 24px;
            height: 24px;
        }
        .logo-large img {
            height: 35px;
        }
        .menu-icon {
            font-size: 24px;
        }
        /* Export button responsive */
        .export-btn {
            padding: 8px 12px;
            font-size: 11px;
            gap: 4px;
        }
        .export-section {
            flex-direction: column;
            gap: 10px;
            align-items: stretch;
        }
        #indicadorEstado {
            text-align: center;
            font-size: 0.8rem;
            padding: 6px 8px;
        }
    }        /* DASHBOARD GRID */        .dashboard-wrapper {
                                             background: rgba(255,255,255,0.95);
                                             border-radius: 24px;
                                             box-shadow: 0 8px 32px rgba(52, 152, 219, 0.12), 0 1.5px 8px rgba(52, 152, 219, 0.10);
                                             border: 2px solid #b3ccff;
                                             padding: 12px 20px 15px 20px;
                                             max-width: 1400px;
                                             margin: 0 auto 20px auto; /* Agregar margen inferior */
                                             transition: box-shadow 0.2s;
                                         }.dashboard-grid {
                                              display: grid;
                                              grid-template-columns: 0.6fr 1.4fr;
                                              grid-template-rows: 1fr 1fr;
                                              gap: 15px; /* Reducir gap */
                                              padding: 0;
                                              height: calc(100vh - 200px); /* Reducir altura */
                                              align-items: stretch;
                                          }        .main-chart-container {
                                                       background: #ffffff;
                                                       border-radius: 16px;
                                                       box-shadow: 0 4px 20px rgba(52, 152, 219, 0.08);
                                                       border: 1px solid #e1ecf4;
                                                       padding: 10px 12px 12px 12px; /* Reducir padding */
                                                       text-align: center;
                                                       display: flex;
                                                       flex-direction: column;
                                                       align-items: center;
                                                       justify-content: center;
                                                       height: 100%;
                                                       min-height: 220px; /* Reducir altura mínima */
                                                   }.future-chart-container {
                                                        background: #ffffff;
                                                        border-radius: 16px;
                                                        box-shadow: 0 4px 20px rgba(52, 152, 219, 0.08);
                                                        border: 1px solid #e1ecf4;
                                                        padding: 20px;
                                                        text-align: center;
                                                        display: flex;
                                                        align-items: center;
                                                        justify-content: center;
                                                        color: #ccc;
                                                        font-size: 1.1rem;
                                                        min-height: 300px;
                                                    }        .bar-chart-container {
                                                                 background: #ffffff;
                                                                 border-radius: 16px;
                                                                 box-shadow: 0 4px 20px rgba(52, 152, 219, 0.08);
                                                                 border: 1px solid #e1ecf4;
                                                                 padding: 10px 15px 15px 15px; /* Reducir padding */
                                                                 text-align: center;
                                                                 display: flex;
                                                                 flex-direction: column;
                                                                 align-items: center;
                                                                 justify-content: center;
                                                                 height: 100%;
                                                                 min-height: 460px; /* Reducir altura mínima considerablemente */
                                                             }        .chart-title {
                                                                          font-size: 1rem; /* Reducir tamaño de título */
                                                                          font-weight: bold;
                                                                          color: #333;
                                                                          margin: 0 0 2px 0; /* Reducir margen */
                                                                      }        .chart-container {
                                                                                   position: relative;
                                                                                   height: 150px; /* Reducir altura */
                                                                                   width: 100%;
                                                                                   max-width: 180px; /* Reducir ancho máximo */
                                                                                   margin: 0 auto 8px auto; /* Reducir margen */
                                                                                   display: flex;
                                                                                   align-items: center;
                                                                                   justify-content: center;
                                                                               }
    .bar-chart-container .chart-container {
        height: calc(100% - 60px); /* Reducir altura considerando menos espacio */
        max-width: 100%;
        width: 100%;
        margin: 0 auto 10px auto; /* Reducir margen */
    }        .chart-legend {
                 display: flex;
                 justify-content: center;
                 gap: 10px; /* Reducir gap */
                 margin-top: 8px; /* Reducir margen */
                 margin-bottom: 5px; /* Reducir margen */
                 flex-wrap: wrap;
                 padding: 0 8px; /* Reducir padding */
             }        .legend-item {
                          display: flex;
                          align-items: center;
                          gap: 5px; /* Reducir gap */
                          font-size: 0.85rem; /* Reducir tamaño de fuente */
                      }.legend-color {
                           width: 10px; /* Reducir tamaño */
                           height: 10px; /* Reducir tamaño */
                           border-radius: 2px;
                       }@media (max-width: 1100px) {
        .dashboard-grid {
            grid-template-columns: 1fr;
            grid-template-rows: auto auto auto;
            gap: 12px;
            height: auto;
        }
        .dashboard-wrapper {
            padding: 12px 15px 15px 15px;
            height: auto;
        }
        .contenedor-principal {
            padding: 12px 15px 15px 15px;
            overflow-y: auto;
        }
        .bar-chart-container {
            grid-row: auto !important;
            min-height: 320px; /* Reducir altura para móvil */
        }
        .main-chart-container {
            min-height: 200px; /* Reducir altura para móvil */
        }
    }        @media (max-width: 700px) {
        .chart-legend {
            gap: 8px;
            margin-top: 6px;
            margin-bottom: 4px;
        }
        .chart-container {
            height: 140px; /* Reducir más para móvil */
            max-width: 160px;
            margin-bottom: 6px;
        }
        .dashboard-wrapper {
            padding: 10px 12px 15px 12px;
            height: auto;
        }
        .contenedor-principal {
            padding: 8px 10px 12px 10px;
            overflow-y: auto;
        }
        .dashboard-grid {
            grid-template-columns: 1fr;
            grid-template-rows: auto auto auto;
            gap: 10px;
        }
        .bar-chart-container {
            grid-row: auto !important;
            min-height: 280px;
            padding: 10px 8px 15px 8px;
        }
        .main-chart-container {
            min-height: 180px;
            padding: 8px 6px 10px 6px;
        }
        .chart-title {
            font-size: 0.9rem;
        }
        .legend-item {
            font-size: 0.8rem;
            gap: 4px;
        }
        .export-btn {
            padding: 8px 16px;
            font-size: 12px;
        }
    }    /* Estilos para el botón de exportar */

    .export-section {
        padding: 8px 0 10px 0;
        border-bottom: 2px solid #e1ecf4;
        margin-bottom: 15px;
        display: flex;
        justify-content: flex-end; /* Volver a flex-end para centrar a la derecha */
        align-items: center;
    }

    .export-btn {
        background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 8px;
        font-size: 13px;
        font-weight: bold;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    .export-btn:hover {
        background: linear-gradient(135deg, #229954 0%, #27ae60 100%);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(39, 174, 96, 0.4);
    }

    .export-btn:active {
        transform: translateY(0);
        box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
    }

    .export-btn:disabled {
        opacity: 0.7;
        cursor: not-allowed;
        transform: none;
    }

    /* Estilos para las nuevas secciones de análisis de formularios */
    .formularios-analysis-section {
        background: rgba(255,255,255,0.95);
        border-radius: 24px;
        box-shadow: 0 8px 32px rgba(52, 152, 219, 0.12), 0 1.5px 8px rgba(52, 152, 219, 0.10);
        border: 2px solid #b3ccff;
        padding: 20px;
        max-width: 1400px;
        margin: 20px auto 0 auto;
    }

    .formularios-analysis-section h2 {
        font-size: 1.5rem;
        color: #333;
        margin-bottom: 25px;
        text-align: center;
        position: relative;
    }

    .formularios-analysis-section h2:after {
        content: '';
        position: absolute;
        width: 100px;
        height: 3px;
        bottom: -5px;
        left: 50%;
        transform: translateX(-50%);
        background: linear-gradient(90deg, #3498db, #27ae60);
    }

    .formulario-card {
        background: #ffffff;
        border: 1px solid #e1ecf4;
        border-radius: 16px;
        margin-bottom: 30px;
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(52, 152, 219, 0.08);
        transition: all 0.3s ease;
    }

    .formulario-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(52, 152, 219, 0.15);
    }

    .formulario-header {
        background: linear-gradient(135deg, #3498db, #2980b9);
        color: white;
        padding: 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .formulario-info h3 {
        margin: 0;
        font-size: 1.3rem;
        font-weight: 600;
    }

    .formulario-info p {
        margin: 5px 0 0 0;
        opacity: 0.9;
        font-size: 0.95rem;
    }

    .formulario-stats {
        display: flex;
        gap: 20px;
        text-align: center;
    }

    .stat-item {
        display: flex;
        flex-direction: column;
    }

    .stat-number {
        font-size: 1.8rem;
        font-weight: bold;
        line-height: 1;
    }

    .stat-label {
        font-size: 0.8rem;
        opacity: 0.9;
        margin-top: 2px;
    }

    .formulario-content {
        padding: 25px;
    }

    .pregunta-analysis {
        margin-bottom: 35px;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 12px;
        border-left: 4px solid #3498db;
    }

    .pregunta-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 15px;
    }

    .pregunta-header h4 {
        color: #2c3e50;
        margin: 0;
        font-size: 1.1rem;
        line-height: 1.4;
        flex: 1;
        margin-right: 15px;
    }

    .pregunta-badge {
        background: #3498db;
        color: white;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.8rem;
        font-weight: bold;
        white-space: nowrap;
    }

    .pregunta-badge.obligatoria {
        background: #e74c3c;
    }

    .chart-section {
        margin-top: 20px;
    }

    .pregunta-chart {
        background: white;
        border-radius: 8px;
        padding: 15px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        min-height: 300px;
        position: relative;
    }

    .pregunta-chart canvas {
        max-height: 250px;
    }

    .respuestas-texto-section {
        background: white;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        margin-top: 15px;
    }

    .respuestas-texto-section h5 {
        color: #2c3e50;
        margin: 0 0 15px 0;
        font-size: 1rem;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .respuestas-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 15px;
        margin-top: 15px;
    }

    .respuesta-item {
        background: #f1f3f4;
        border: 1px solid #e9ecef;
        border-radius: 8px;
        padding: 15px;
        transition: all 0.2s ease;
    }

    .respuesta-item:hover {
        background: #e8f4fd;
        border-color: #3498db;
    }

    .respuesta-texto {
        color: #2c3e50;
        font-size: 0.95rem;
        line-height: 1.5;
        margin-bottom: 10px;
    }

    .respuesta-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 0.8rem;
        color: #666;
        border-top: 1px solid #dee2e6;
        padding-top: 8px;
    }

    .respuesta-fecha {
        font-weight: 500;
    }

    .respuesta-zona {
        background: #e9ecef;
        padding: 2px 8px;
        border-radius: 12px;
        font-size: 0.75rem;
    }

    /* Responsive design para secciones de análisis */
    @media (max-width: 1024px) {
        .formularios-analysis-section {
            padding: 15px;
            margin: 15px auto 0 auto;
        }
        .formulario-header {
            flex-direction: column;
            gap: 15px;
            text-align: center;
        }
        .formulario-stats {
            justify-content: center;
            width: 100%;
        }
        .pregunta-header {
            flex-direction: column;
            gap: 10px;
            text-align: left;
        }
        .pregunta-badge {
            align-self: flex-start;
        }
    }

    @media (max-width: 768px) {
        .formularios-analysis-section {
            padding: 12px;
            margin: 12px auto 0 auto;
        }
        .formularios-analysis-section h2 {
            font-size: 1.3rem;
            margin-bottom: 20px;
        }
        .formulario-card {
            margin-bottom: 25px;
        }
        .formulario-header {
            padding: 15px;
        }
        .formulario-info h3 {
            font-size: 1.1rem;
        }
        .formulario-info p {
            font-size: 0.9rem;
        }
        .formulario-content {
            padding: 20px;
        }
        .pregunta-analysis {
            margin-bottom: 25px;
            padding: 15px;
        }
        .pregunta-header h4 {
            font-size: 1rem;
        }
        .respuestas-grid {
            grid-template-columns: 1fr;
            gap: 12px;
        }
        .pregunta-chart {
            min-height: 250px;
            padding: 12px;
        }
        .respuestas-texto-section {
            padding: 15px;
        }
    }

    @media (max-width: 480px) {
        .formularios-analysis-section {
            padding: 8px;
            margin: 8px auto 0 auto;
            border-radius: 16px;
        }
        .formularios-analysis-section h2 {
            font-size: 1.1rem;
            margin-bottom: 15px;
        }
        .formulario-card {
            margin-bottom: 20px;
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
        .stat-item {
            margin: 0 8px;
        }
        .stat-number {
            font-size: 1.5rem;
        }
        .stat-label {
            font-size: 0.75rem;
        }
        .formulario-content {
            padding: 15px;
        }
        .pregunta-analysis {
            margin-bottom: 20px;
            padding: 12px;
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
        .pregunta-chart {
            min-height: 200px;
            padding: 10px;
        }
        .pregunta-chart canvas {
            max-height: 180px;
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
        .respuesta-zona {
            font-size: 0.7rem;
            padding: 1px 6px;
        }
    }

    /* === MEJORAS PARA DISPOSITIVOS TÁCTILES === */
    
    /* Aumentar áreas táctiles en móviles */
    @media (max-width: 768px) {
        .nav-item {
            min-height: 44px; /* Área táctil mínima recomendada */
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
            display: flex;
            align-items: center;
            touch-action: manipulation; /* Optimizar para touch */
        }
        
        .export-btn {
            min-height: 44px;
            touch-action: manipulation;
        }
    }
    
    /* === OPTIMIZACIONES ADICIONALES === */
    
    /* Evitar zoom en inputs en iOS */
    @media screen and (max-width: 768px) {
        input, select, textarea {
            font-size: 16px !important;
        }
    }
    
    /* Mejorar rendimiento en animaciones móviles */
    @media (max-width: 768px) {
        .sidebar, .overlay, .formulario-card, .pregunta-analysis {
            transform: translateZ(0); /* Activar aceleración por hardware */
        }
        
        /* Reducir animaciones complejas en móviles */
        .formulario-card:hover {
            transform: none;
        }
        
        .sidebar-content .menu-links a:hover {
            transform: none;
        }
    }
    
    /* === AJUSTES FINALES PARA PANTALLAS PEQUEÑAS === */
    
    @media (max-width: 360px) {
        .contenedor-principal {
            padding: 5px 8px;
        }
        
        .dashboard-wrapper {
            padding: 8px 10px;
            border-radius: 16px;
        }
        
        .formularios-analysis-section {
            padding: 6px;
            border-radius: 12px;
        }
        
        .chart-title {
            font-size: 0.85rem;
        }
        
        .export-btn {
            padding: 6px 10px;
            font-size: 10px;
        }
        
        .nav-item span {
            display: none !important; /* Ocultar texto en pantallas muy pequeñas */
        }
        
        .header-right {
            gap: 1rem;
        }
        
        .sidebar {
            width: 220px;
            left: -220px;
        }
    }

    /* === MEJORAS DE ACCESIBILIDAD Y UX === */
    
    /* Mejor contraste en elementos pequeños */
    @media (max-width: 480px) {
        .chart-legend {
            background: rgba(255, 255, 255, 0.9);
            padding: 8px;
            border-radius: 6px;
            border: 1px solid #e1ecf4;
        }
        
        .legend-item {
            background: white;
            padding: 4px 6px;
            border-radius: 4px;
            border: 1px solid #e9ecef;
            margin: 2px;
        }
    }
    
    /* Evitar problemas de overflow en contenido largo */
    @media (max-width: 768px) {
        .formulario-info h3,
        .pregunta-header h4 {
            word-wrap: break-word;
            hyphens: auto;
            line-height: 1.4;
        }
        
        .respuesta-texto {
            word-wrap: break-word;
            hyphens: auto;
        }
    }
    
    /* Mejorar espacio entre elementos en pantallas pequeñas */
    @media (max-width: 480px) {
        .dashboard-grid {
            gap: 10px;
        }
        
        .formulario-card + .formulario-card {
            margin-top: 15px;
        }
        
        /* Responsive Design */
        @media (max-width: 1024px) {
            .header h1 {
                font-size: 2rem;
            }
            .main-content {
                padding: 15px;
            }
            .cards-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
            }
            .charts-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            .chart-container canvas {
                max-width: 100% !important;
                height: auto !important;
            }
            .table-wrapper {
                overflow-x: auto;
            }
            .table {
                min-width: 600px;
            }
        }

        @media (max-width: 768px) {
            .header {
                padding: 12px 20px;
            }
            .header h1 {
                font-size: 1.8rem;
                text-align: center;
            }
            .close-btn {
                width: 32px;
                height: 32px;
                font-size: 18px;
            }
            .main-content {
                padding: 12px;
            }
            .cards-grid {
                grid-template-columns: 1fr;
                gap: 12px;
            }
            .card {
                padding: 16px;
            }
            .card h3 {
                font-size: 1.1rem;
                margin-bottom: 8px;
            }
            .card .number {
                font-size: 2rem;
            }
            .charts-grid {
                gap: 15px;
            }
            .chart-container {
                padding: 15px;
            }
            .chart-container h3 {
                font-size: 1.2rem;
                margin-bottom: 12px;
            }
            .table-wrapper {
                margin-top: 15px;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }
            .table {
                min-width: 500px;
                font-size: 0.9rem;
            }
            .table th,
            .table td {
                padding: 8px 6px;
            }
            .chart-container canvas {
                max-width: 100% !important;
                height: auto !important;
            }
            .sidebar {
                width: 250px;
            }
            .sidebar-close {
                display: block;
                position: absolute;
                top: 15px;
                right: 15px;
                color: white;
                font-size: 24px;
                cursor: pointer;
                z-index: 1001;
            }
        }

        @media (max-width: 480px) {
            .header {
                padding: 10px 15px;
            }
            .header h1 {
                font-size: 1.5rem;
            }
            .close-btn {
                width: 28px;
                height: 28px;
                font-size: 16px;
            }
            .main-content {
                padding: 10px 8px;
            }
            .card {
                padding: 14px;
            }
            .card h3 {
                font-size: 1rem;
            }
            .card .number {
                font-size: 1.8rem;
            }
            .chart-container {
                padding: 12px;
            }
            .chart-container h3 {
                font-size: 1.1rem;
            }
            .table {
                min-width: 400px;
                font-size: 0.85rem;
            }
            .table th,
            .table td {
                padding: 6px 4px;
            }
            .sidebar {
                width: 220px;
            }
            .sidebar-close {
                font-size: 20px;
                top: 12px;
                right: 12px;
            }
        }

        @media (max-width: 320px) {
            .header {
                padding: 8px 12px;
            }
            .header h1 {
                font-size: 1.3rem;
            }
            .close-btn {
                width: 26px;
                height: 26px;
                font-size: 14px;
            }
            .main-content {
                padding: 8px 6px;
            }
            .card {
                padding: 12px;
            }
            .card h3 {
                font-size: 0.95rem;
            }
            .card .number {
                font-size: 1.6rem;
            }
            .chart-container {
                padding: 10px;
            }
            .chart-container h3 {
                font-size: 1rem;
            }
            .table {
                min-width: 300px;
                font-size: 0.8rem;
            }
            .table th,
            .table td {
                padding: 4px 3px;
            }
            .sidebar {
                width: 200px;
            }
            .sidebar-close {
                font-size: 18px;
                top: 10px;
                right: 10px;
            }
        }
        
        /* Asegurar que las gráficas no se sobrepongan */
        .chart-container canvas {
            max-width: 100% !important;
            height: auto !important;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            /* Header responsive */
            .header-content {
                padding: 12px 20px;
            }
            
            .header-left {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                margin-left: 0;
                order: 1; /* Asegurar que header-left aparezca primero */
            }
            
            .header-right {
                gap: 1.5rem;
                justify-content: center;
                order: 2;
            }
            
            /* Menu icon responsive */
            .header-left .menu-icon {
                font-size: 20px;
                order: -1; /* Aparece primero dentro de header-left */
            }
            
            .logo-section {
                order: 1; /* Logo aparece después del menú */
            }
        }

        @media (max-width: 480px) {
            /* Header responsive para móviles pequeños */
            .header-content {
                padding: 10px 15px;
            }
            
            .header-left {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                margin-left: 0;
                order: 1;
            }
            
            .header-right {
                gap: 1rem;
                order: 2;
            }
            
            /* Menu icon para móviles pequeños */
            .header-left .menu-icon {
                font-size: 18px;
                order: -1;
            }
            
            .logo-section {
                order: 1;
            }
        }

        @media (max-width: 320px) {
            /* Header responsive para móviles extra pequeños */
            .header-content {
                padding: 8px 12px;
            }
            
            .header-left {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                margin-left: 0;
                order: 1;
            }
            
            .header-right {
                gap: 0.8rem;
                order: 2;
            }
            
            /* Menu icon para móviles extra pequeños */
            .header-left .menu-icon {
                font-size: 16px;
                order: -1;
            }
            
            .logo-section {
                order: 1;
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
            <li><a href="InicioAdminServlet"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
            <li><a href="CrearCoordinadorServlet"><i class="fa-solid fa-user-plus"></i> Crear nuevo usuario</a></li>
            <li><a href="GestionarCoordinadoresServlet"><i class="fa-solid fa-user-tie"></i> Gestionar Coordinadores</a></li>
            <li><a href="GestionarEncuestadoresServlet"><i class="fa-solid fa-user"></i> Gestionar Encuestadores</a></li>
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
                            Administrador
                        </c:otherwise>
                    </c:choose>
                </span>
                <i class="fas fa-chevron-down dropdown-arrow"></i>
                <div class="dropdown-menu">
                    <a href="VerPerfilServlet">Ver perfil</a>
                    <a href="CerrarSesionServlet">Cerrar sesión</a>
                </div>
            </div>
        </nav>
    </div>
</header>

<!-- Contenido principal -->
<main class="contenedor-principal">
    <div class="dashboard-wrapper">
        <!-- BARRA SUPERIOR SOLO CON BOTÓN DE EXPORTAR -->
        <div class="export-section" style="margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center;">
            <!-- Indicador de estado de las gráficas -->
            <div id="indicadorEstado" style="background: #fff3cd; border: 1px solid #ffc107; border-radius: 6px; padding: 8px 12px; font-size: 0.85rem; color: #856404;">
                🔄 Cargando gráficas...
            </div>
            
            <!-- Botón de exportar -->
            <button id="exportarReporte" class="export-btn" onclick="exportarReporteDashboard()">
                <i class="fas fa-file-excel"></i>
                Generar Reporte Excel
            </button>
        </div>

        <div class="dashboard-grid">
            <!-- Gráfico de Encuestadores -->
            <div class="main-chart-container" style="grid-column: 1; grid-row: 1;">
                <h3 class="chart-title">Encuestadores</h3>
                <div class="chart-container">
                    <canvas id="encuestadoresChart"></canvas>
                </div>
                <div class="chart-legend" id="encuestadoresLegend">
                    <!-- La leyenda se generará dinámicamente con JavaScript -->
                </div>
                <!-- DEBUG para Encuestadores -->
                <!--<div style="font-size: 0.8rem; color: #666; margin-top: 10px; background: #f8f9fa; padding: 8px; border-radius: 4px;">
                    Activos: ${encuestadoresActivos} | Inactivos: ${encuestadoresDesactivos}
                </div>-->
            </div>

            <!-- Gráfico de Coordinadores -->
            <div class="main-chart-container" style="grid-column: 1; grid-row: 2;">
                <h3 class="chart-title">Coordinadores</h3>
                <div class="chart-container">
                    <canvas id="coordinadoresChart"></canvas>
                </div>
                <div class="chart-legend" id="coordinadoresLegend">
                    <!-- La leyenda se generará dinámicamente con JavaScript -->
                </div>
                <!-- DEBUG para Coordinadores -->
                <!--<div style="font-size: 0.8rem; color: #666; margin-top: 10px; background: #f8f9fa; padding: 8px; border-radius: 4px;">
                    Activos: ${coordinadoresActivos} | Inactivos: ${coordinadoresDesactivos}
                </div>-->
            </div>

            <!-- Gráfico de líneas para formularios por zona -->
            <div class="bar-chart-container" style="grid-column: 2; grid-row: 1 / -1;">
                <h3 class="chart-title">Formularios por Zona Geográfica</h3>
                <div class="chart-container">
                    <canvas id="barChart"></canvas>
                </div>
                <!-- DEBUG para Gráfico de líneas -->
                <!--<div style="font-size: 0.8rem; color: #666; margin-top: 10px; background: #f8f9fa; padding: 8px; border-radius: 4px;">
                    Datos de gráfico: ${fn:length(datosGraficoLineas)} registros
                </div>-->
            </div>
        </div>
    </div>

    <!-- Nueva sección de análisis de formularios dinámicos -->
</main>

<!-- Nueva sección para análisis detallado de formularios -->
<section class="formularios-analysis-section">
    <h2><i class="fas fa-chart-bar"></i> Análisis de Respuestas por Formulario</h2>

    <!-- DEBUG: Información temporal -->
    <!--<div style="background: #fff3cd; border: 2px solid #ffc107; border-radius: 8px; padding: 20px; margin-bottom: 20px; font-family: monospace; font-size: 0.9rem;">
        <h4 style="color: #856404; margin-top: 0;">🔍 INFORMACIÓN DE DEBUG COMPLETA</h4>

        <div style="background: #f8f9fa; padding: 10px; border-radius: 5px; margin-bottom: 10px;">
            <strong>📊 Variables de Atributos:</strong><br>
            analisisFormularios: <c:out value="${analisisFormularios != null ? 'EXISTE' : 'ES NULL'}" /><br>
            Tamaño de analisisFormularios: <c:out value="${fn:length(analisisFormularios)}" /><br>
            metricasGenerales: <c:out value="${metricasGenerales != null ? 'EXISTE' : 'ES NULL'}" /><br>
            datosDebug: <c:out value="${datosDebug != null ? 'EXISTE' : 'ES NULL'}" /><br>
        </div>

        <c:if test="${not empty datosDebug}">
            <div style="background: #e8f5e8; padding: 10px; border-radius: 5px; margin-bottom: 10px;">
                <strong>📊 Datos de la Base de Datos:</strong><br>
                Total formularios: <c:out value="${datosDebug.totalFormularios}" /><br>
                Total preguntas: <c:out value="${datosDebug.totalPreguntas}" /><br>
                Total respuestas: <c:out value="${datosDebug.totalRespuestas}" /><br>
                Sesiones completadas: <c:out value="${datosDebug.sesionesCompletadas}" /><br>
                Ejemplos formularios: <c:out value="${datosDebug.ejemplosFormularios}" /><br>
                <c:if test="${not empty datosDebug.error}">
                    <span style="color: red; font-weight: bold;">ERROR: <c:out value="${datosDebug.error}" /></span><br>
                </c:if>
            </div>
        </c:if>

        <c:if test="${not empty metricasGenerales}">
            <div style="background: #f0f8ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;">
                <strong>📈 Métricas Generales:</strong><br>
                Total formularios completados: <c:out value="${metricasGenerales.total_formularios_completados}" /><br>
                Total respuestas registradas: <c:out value="${metricasGenerales.total_respuestas_registradas}" /><br>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${not empty analisisFormularios}">
                <div style="background: #e8f5e8; padding: 10px; border-radius: 5px; margin-bottom: 10px;">
                    <strong>✅ ANÁLISIS DE FORMULARIOS CARGADO EXITOSAMENTE</strong><br>
                    Total formularios encontrados: <strong>${fn:length(analisisFormularios)}</strong><br>

                        <%-- Contar preguntas de opción múltiple --%>
                    <c:set var="preguntasOpcionMultiple" value="0" />
                    <c:set var="preguntasTextoLibre" value="0" />
                    <c:set var="totalPreguntas" value="0" />
                    <c:forEach var="form" items="${analisisFormularios}">
                        <c:forEach var="pregunta" items="${form.preguntas}">
                            <c:set var="totalPreguntas" value="${totalPreguntas + 1}" />
                            <c:if test="${pregunta.tipoAnalisis eq 'opciones_multiples'}">
                                <c:set var="preguntasOpcionMultiple" value="${preguntasOpcionMultiple + 1}" />
                            </c:if>
                            <c:if test="${pregunta.tipoAnalisis eq 'texto_libre'}">
                                <c:set var="preguntasTextoLibre" value="${preguntasTextoLibre + 1}" />
                            </c:if>
                        </c:forEach>
                    </c:forEach>

                    <strong>📊 RESUMEN DE PREGUNTAS:</strong><br>
                    - Total preguntas procesadas: <strong>${totalPreguntas}</strong><br>
                    - Preguntas de opción múltiple: <strong>${preguntasOpcionMultiple}</strong><br>
                    - Preguntas de texto libre: <strong>${preguntasTextoLibre}</strong><br>
                </div>

                <details style="margin-bottom: 15px;">
                    <summary style="cursor: pointer; background: #f8f9fa; padding: 8px; border-radius: 4px;">
                        <strong>🔍 Ver detalle completo de formularios y preguntas</strong>
                    </summary>
                    <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-top: 5px; max-height: 400px; overflow-y: auto;">
                        <c:forEach var="form" items="${analisisFormularios}" varStatus="formStatus">
                            <div style="border-left: 3px solid #007bff; padding-left: 10px; margin-bottom: 15px;">
                                <strong>📝 FORMULARIO ${formStatus.index + 1}: "${form.nombreFormulario}" (ID: ${form.idFormulario})</strong><br>
                                <span style="color: #666;">Respuestas totales: ${form.totalRespuestas} | Preguntas: ${fn:length(form.preguntas)}</span><br>

                                <c:choose>
                                    <c:when test="${not empty form.preguntas}">
                                        <c:forEach var="pregunta" items="${form.preguntas}" varStatus="pregStatus">
                                            <div style="margin-left: 15px; margin-top: 8px; padding: 5px; background: #fff; border-radius: 3px;">
                                                <strong>${pregStatus.index + 1}.</strong> "${pregunta.textoPregunta}"<br>
                                                <span style="font-size: 0.85em; color: #666;">
                                                    Tipo: ${pregunta.tipoAnalisis} |
                                                    Opciones: ${pregunta.tieneOpciones} |
                                                    Respuestas: ${pregunta.totalRespuestas}
                                                </span>
                                                <c:if test="${pregunta.tipoAnalisis eq 'opciones_multiples' and not empty pregunta.opcionesMultiples}">
                                                    <div style="font-size: 0.8em; margin-left: 10px; color: #495057;">
                                                        Opciones disponibles: ${fn:length(pregunta.opcionesMultiples)}
                                                    </div>
                                                </c:if>
                                                <c:if test="${pregunta.tipoAnalisis eq 'texto_libre'}">
                                                    <div style="font-size: 0.8em; margin-left: 10px; color: #e74c3c;">
                                                        Respuestas texto libre: ${fn:length(pregunta.respuestasTexto)}
                                                        <c:if test="${fn:length(pregunta.respuestasTexto) > 0}">
                                                            <br>Ejemplo: "${fn:substring(pregunta.respuestasTexto[0].texto, 0, 50)}..."
                                                        </c:if>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div style="margin-left: 15px; color: red; font-weight: bold;">
                                            ❌ No hay preguntas en este formulario
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>
                </details>
            </c:when>
            <c:otherwise>
                <div style="background: #f8d7da; padding: 15px; border-radius: 5px; color: #721c24;">
                    <strong>❌ PROBLEMA CON ANÁLISIS DE FORMULARIOS</strong><br>
                    La variable analisisFormularios está vacía o es null.<br>
                    Esto significa que no se están obteniendo datos del DAO o hay un error en el servlet.
                </div>
            </c:otherwise>
        </c:choose>
    </div>-->

    <c:choose>
        <c:when test="${not empty analisisFormularios}">
            <c:forEach var="formulario" items="${analisisFormularios}" varStatus="formStatus">
                <div class="formulario-card">
                    <div class="formulario-header">
                        <div class="formulario-info">
                            <h3>${fn:escapeXml(formulario.nombreFormulario)}</h3>
                            <c:if test="${not empty formulario.descripcion}">
                                <p>${fn:escapeXml(formulario.descripcion)}</p>
                            </c:if>
                        </div>
                        <div class="formulario-stats">
                            <!--<div class="stat-item">
                                <div class="stat-number">${formulario.totalRespuestas}</div>
                                <div class="stat-label">Respuestas</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-number">${formulario.encuestadoresAsignados}</div>
                                <div class="stat-label">Encuestadores</div>
                            </div>-->
                        </div>
                    </div>

                    <div class="formulario-content">
                        <c:forEach var="pregunta" items="${formulario.preguntas}" varStatus="pregStatus">
                            <!-- Filtrar preguntas específicas que no queremos mostrar -->
                            <c:set var="textoMinuscula" value="${fn:toLowerCase(pregunta.textoPregunta)}" />
                            
                            <!-- Detectar preguntas especiales de datos numéricos -->
                            <c:set var="esPreguntaEdad" value="${
                                fn:contains(textoMinuscula, 'edad de la persona entrevistada') or
                                fn:contains(textoMinuscula, '¿qué edad tiene?')
                            }" />
                            
                            <c:set var="esPreguntaCantidad" value="${
                                fn:contains(textoMinuscula, '¿cuántos niños/niñas de 0 a 5 años hay en el hogar?') or
                                fn:contains(textoMinuscula, '¿cuántas personas adultas mayores hay en el hogar?') or
                                fn:contains(textoMinuscula, '¿cuántas personas con discapacidad o enfermedad crónica hay en el hogar?')
                            }" />
                            
                            <c:set var="esPreguntaNumerica" value="${esPreguntaEdad or esPreguntaCantidad}" />
                            
                            <c:set var="mostrarPregunta" value="${
                                (not fn:contains(textoMinuscula, 'nombre del asentamiento humano') and
                                not fn:contains(textoMinuscula, 'sector') and
                                not fn:contains(textoMinuscula, 'nombres y apellidos de la persona entrevistada') and
                                not fn:contains(textoMinuscula, 'dni de la persona entrevistada') and
                                not fn:contains(textoMinuscula, 'dirección de la persona entrevistada') and
                                not fn:contains(textoMinuscula, 'celular de contacto') and
                                not fn:contains(textoMinuscula, '¿padecen alguna enfermedad?') and
                                not fn:contains(textoMinuscula, '¿qué tipo de discapacidad o enfermedad tienen?') and
                                not fn:contains(textoMinuscula, '¿cuánto tiempo al día dedica al cuidado?')) or
                                esPreguntaNumerica
                            }" />
                            
                            <c:if test="${mostrarPregunta}">
                                <div class="pregunta-analysis">
                                    <div class="pregunta-header">
                                        <h4>${fn:escapeXml(pregunta.textoPregunta)}</h4>
                                        <div class="pregunta-badge ${pregunta.obligatorio ? 'obligatoria' : ''}">
                                                ${pregunta.obligatorio ? 'Obligatoria' : 'Opcional'}
                                        </div>
                                    </div>

                                <c:choose>
                                    <c:when test="${esPreguntaNumerica and pregunta.tipoAnalisis eq 'texto_libre'}">
                                        <!-- Gráfico especializado para datos numéricos -->
                                        <div class="chart-section">
                                            <h5 style="margin-bottom: 10px; color: #333;">
                                                <i class="fas fa-chart-line"></i>
                                                <c:choose>
                                                    <c:when test="${esPreguntaEdad}">
                                                        Distribución de Edades
                                                    </c:when>
                                                    <c:when test="${esPreguntaCantidad}">
                                                        Distribución de Cantidades
                                                    </c:when>
                                                    <c:otherwise>
                                                        Análisis de Datos Numéricos
                                                    </c:otherwise>
                                                </c:choose>
                                            </h5>
                                            <div class="pregunta-chart" style="height: 300px; position: relative;">
                                                <canvas id="chart_${formulario.idFormulario}_${pregunta.idPregunta}"
                                                        style="max-width: 100%; max-height: 100%;"></canvas>
                                            </div>
                                            <!-- Debug para preguntas numéricas -->
                                            <!--<div style="font-size: 0.8rem; color: #666; margin-top: 10px; background: #e8f5e8; padding: 8px; border-radius: 4px;">
                                                📊 Canvas ID: chart_${formulario.idFormulario}_${pregunta.idPregunta}<br>
                                                📈 Tipo: ${pregunta.tipoAnalisis} (Numérica)<br>
                                                📈 Es pregunta edad: ${esPreguntaEdad}<br>
                                                📈 Es pregunta cantidad: ${esPreguntaCantidad}<br>
                                                📈 Respuestas texto: ${fn:length(pregunta.respuestasTexto)}
                                                <c:choose>
                                                    <c:when test="${not empty pregunta.respuestasTexto}">
                                                        <br>🔢 Primeras respuestas:
                                                        <c:forEach var="respuesta" items="${pregunta.respuestasTexto}" varStatus="respStatus" begin="0" end="4">
                                                            <br>&nbsp;&nbsp;• "${respuesta.texto}"
                                                        </c:forEach>
                                                        <c:if test="${fn:length(pregunta.respuestasTexto) > 5}">
                                                            <br>&nbsp;&nbsp;... y ${fn:length(pregunta.respuestasTexto) - 5} más
                                                        </c:if>
                                                        <br><strong>✅ Datos numéricos listos para procesar</strong>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <br><strong style="color: red;">❌ Sin respuestas de texto para procesar</strong>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>-->

                                            <!-- DEBUG JAVASCRIPT TEMPORAL para numéricos -->
                                            <!--<div style="font-size: 0.7rem; color: #999; margin-top: 5px; padding: 5px; background: #fff3cd; border-radius: 3px;">
                                                <strong>🔧 Debug JavaScript:</strong><br>
                                                <span id="debug_chart_${formulario.idFormulario}_${pregunta.idPregunta}">Esperando inicialización...</span>
                                            </div>-->
                                        </div>
                                    </c:when>
                                    <c:when test="${pregunta.tipoAnalisis eq 'opciones_multiples' or pregunta.tipoAnalisis eq 'si_no'}">
                                        <!-- Gráfico de barras para opciones múltiples y preguntas de Sí/No -->
                                        <div class="chart-section">
                                            <h5 style="margin-bottom: 10px; color: #333;">
                                                <i class="fas fa-chart-bar"></i>
                                                <c:choose>
                                                    <c:when test="${pregunta.tipoAnalisis eq 'si_no'}">
                                                        Distribución de Respuestas (Sí/No)
                                                    </c:when>
                                                    <c:otherwise>
                                                        Distribución de Respuestas (Opciones Múltiples)
                                                    </c:otherwise>
                                                </c:choose>
                                            </h5>
                                            <div class="pregunta-chart" style="height: 300px; position: relative;">
                                                <canvas id="chart_${formulario.idFormulario}_${pregunta.idPregunta}"
                                                        style="max-width: 100%; max-height: 100%;"></canvas>
                                            </div>
                                            <!-- Debug temporal MEJORADO -->
                                            <!-- <div style="font-size: 0.8rem; color: #666; margin-top: 10px; background: #f8f9fa; padding: 8px; border-radius: 4px;">
                                                📊 Canvas ID: chart_${formulario.idFormulario}_${pregunta.idPregunta}<br>
                                                📈 Tipo: ${pregunta.tipoAnalisis}<br>
                                                📈 Opciones disponibles: ${fn:length(pregunta.opcionesMultiples)}
                                                <c:choose>
                                                    <c:when test="${not empty pregunta.opcionesMultiples}">
                                                        <br>🔢 Datos detallados:
                                                        <c:forEach var="opcion" items="${pregunta.opcionesMultiples}" varStatus="opcionStatus">
                                                            <br>&nbsp;&nbsp;• "${opcion.textoOpcion}" = ${opcion.cantidadRespuestas} respuestas
                                                        </c:forEach>
                                                        <br><strong>✅ Datos presentes para gráfico</strong>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <br><strong style="color: red;">❌ Sin datos de opciones múltiples</strong>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>-->

                                            <!-- DEBUG JAVASCRIPT TEMPORAL -->
                                            <!--<div style="font-size: 0.7rem; color: #999; margin-top: 5px; padding: 5px; background: #fff3cd; border-radius: 3px;">
                                                <strong>🔧 Debug JavaScript:</strong><br>
                                                <span id="debug_chart_${formulario.idFormulario}_${pregunta.idPregunta}">Esperando inicialización...</span>
                                            </div>-->
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Respuestas de texto libre -->
                                        <div class="respuestas-texto-section">
                                            <h5>
                                                <i class="fas fa-comments"></i>
                                                Respuestas de Texto Libre (${fn:length(pregunta.respuestasTexto)})
                                            </h5>

                                            <c:choose>
                                                <c:when test="${not empty pregunta.respuestasTexto}">
                                                    <div class="respuestas-grid">
                                                        <c:forEach var="respuesta" items="${pregunta.respuestasTexto}" varStatus="respStatus">
                                                            <div class="respuesta-item">
                                                                <div class="respuesta-texto">
                                                                    "${fn:escapeXml(respuesta.texto)}"
                                                                </div>
                                                                <div class="respuesta-meta">
                                                                    <span class="respuesta-fecha">
                                                                        <i class="fas fa-calendar-alt"></i>
                                                                        <c:choose>
                                                                            <c:when test="${respuesta.fecha != 'N/A'}">
                                                                                <fmt:formatDate value="${respuesta.fecha}" pattern="dd/MM/yyyy"/>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                ${respuesta.fecha}
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </span>
                                                                    <span class="respuesta-zona">
                                                                            ${fn:escapeXml(respuesta.zona)}
                                                                    </span>
                                                                </div>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div style="text-align: center; color: #666; font-style: italic; padding: 20px;">
                                                        No hay respuestas de texto libre para esta pregunta
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div style="text-align: center; color: #666; font-size: 1.1rem; padding: 40px;">
                <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 15px; opacity: 0.5;"></i><br>
                No hay datos de formularios disponibles para mostrar
            </div>
        </c:otherwise>
    </c:choose>
</section>

<script>
    // Datos dinámicos desde el backend
    const encuestadores = {
        activos: Number('${encuestadoresActivos}') || 0,
        inactivos: Number('${encuestadoresDesactivos}') || 0
    };
    const coordinadores = {
        activos: Number('${coordinadoresActivos}') || 0,
        inactivos: Number('${coordinadoresDesactivos}') || 0
    };

    // Datos del gráfico
    const datosReales = <c:out value="${jsonDatosGrafico}" escapeXml="false" />;
    const datosAUsar = datosReales;

    // Variables globales para los gráficos
    let chartEncuestadores, chartCoordinadores, chartFormularios;

    console.log('=== DIAGNÓSTICO COMPLETO DE DASHBOARD ===');
    console.log('🔍 Chart.js disponible:', typeof Chart !== 'undefined');
    console.log('📊 Encuestadores:', encuestadores);
    console.log('📊 Coordinadores:', coordinadores);
    console.log('📊 Datos gráfico:', datosAUsar);
    console.log('📊 Zonas disponibles:', Object.keys(datosAUsar));
    
    // Verificar elementos canvas
    setTimeout(() => {
        console.log('🎯 Verificando elementos Canvas:');
        console.log('- encuestadoresChart:', document.getElementById('encuestadoresChart') ? '✅ Existe' : '❌ No existe');
        console.log('- coordinadoresChart:', document.getElementById('coordinadoresChart') ? '✅ Existe' : '❌ No existe');
        console.log('- barChart:', document.getElementById('barChart') ? '✅ Existe' : '❌ No existe');
        
        // Verificar si los contenedores están visibles
        const containers = document.querySelectorAll('.chart-container');
        console.log('📦 Contenedores de gráficos encontrados:', containers.length);
        containers.forEach((container, index) => {
            const rect = container.getBoundingClientRect();
            console.log(`- Contenedor ${index}: width=${rect.width}, height=${rect.height}, visible=${rect.width > 0 && rect.height > 0}`);
        });
    }, 100);

    document.addEventListener("DOMContentLoaded", function() {
        console.log('=== 🚀 INICIALIZANDO DASHBOARD ===');
        console.log('⏰ DOM cargado completamente');
        
        // Verificar Chart.js nuevamente
        if (typeof Chart === 'undefined') {
            console.error('❌ ERROR CRÍTICO: Chart.js no está disponible!');
            alert('Error: Chart.js no se ha cargado correctamente. Las gráficas no funcionarán.');
            return;
        } else {
            console.log('✅ Chart.js versión:', Chart.version || 'Versión no detectada');
        }
        
        // Verificar datos
        console.log('📋 Verificando datos disponibles:');
        console.log('- Encuestadores activos:', encuestadores.activos);
        console.log('- Encuestadores inactivos:', encuestadores.inactivos);
        console.log('- Coordinadores activos:', coordinadores.activos);
        console.log('- Coordinadores inactivos:', coordinadores.inactivos);
        console.log('- Datos de formularios por zona:', datosAUsar);
        
        try {
            // Crear todos los gráficos principales primero
            console.log('📊 Iniciando creación de gráficos principales...');
            crearGraficos();
            console.log('✅ Gráficos principales creados exitosamente');
        } catch (error) {
            console.error('❌ Error creando gráficos principales:', error);
        }

        // Esperar un poco para que los elementos canvas estén listos y luego crear gráficos de preguntas
        setTimeout(function() {
            console.log('🎯 Iniciando gráficos de preguntas con retraso...');
            try {
                crearGraficosPreguntas();
                console.log('✅ Gráficos de preguntas procesados');
            } catch (error) {
                console.error('❌ Error creando gráficos de preguntas:', error);
            }
        }, 1000);
    });

    function crearGraficos() {
        console.log('📊 === INICIANDO CREACIÓN DE GRÁFICOS PRINCIPALES ===');
        
        try {
            console.log('1️⃣ Creando gráfico de encuestadores...');
            crearGraficoEncuestadores();
            console.log('✅ Gráfico de encuestadores creado');
        } catch (error) {
            console.error('❌ Error en gráfico de encuestadores:', error);
        }
        
        try {
            console.log('2️⃣ Creando gráfico de coordinadores...');
            crearGraficoCoordinadores();
            console.log('✅ Gráfico de coordinadores creado');
        } catch (error) {
            console.error('❌ Error en gráfico de coordinadores:', error);
        }
        
        try {
            console.log('3️⃣ Creando gráfico de formularios...');
            crearGraficoFormularios();
            console.log('✅ Gráfico de formularios creado');
        } catch (error) {
            console.error('❌ Error en gráfico de formularios:', error);
        }
        
        console.log('📊 === FIN CREACIÓN DE GRÁFICOS PRINCIPALES ===');
        // Nota: crearGraficosPreguntas() se llama por separado con retraso
    }

    function crearGraficoEncuestadores() {
        console.log('👥 === CREANDO GRÁFICO DE ENCUESTADORES ===');
        
        // Verificar elemento canvas
        const canvasElement = document.getElementById('encuestadoresChart');
        console.log('🎯 Canvas element:', canvasElement);
        
        if (!canvasElement) {
            console.error('❌ ERROR: No se encontró el canvas #encuestadoresChart');
            return;
        }
        
        // Verificar contexto
        let encCtx;
        try {
            encCtx = canvasElement.getContext('2d');
            console.log('🎨 Contexto 2D obtenido:', encCtx);
        } catch (error) {
            console.error('❌ ERROR obteniendo contexto 2D:', error);
            return;
        }

        // Destruir gráfico existente
        if (chartEncuestadores) {
            console.log('🗑️ Destruyendo gráfico existente');
            chartEncuestadores.destroy();
        }

        console.log('📊 Datos de encuestadores:', encuestadores);
        const totalEncuestadores = encuestadores.activos + encuestadores.inactivos;
        console.log('📊 Total encuestadores:', totalEncuestadores);

        if (totalEncuestadores === 0) {
            console.warn('⚠️ No hay datos de encuestadores');
            const container = canvasElement.parentNode;
            container.innerHTML = '<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #666; font-size: 0.9rem;">No hay datos de encuestadores</div>';
            return;
        }

        // Plugin para mostrar el número total en el centro
        const centerTextPlugin = {
            id: 'centerText',
            beforeDraw: function(chart) {
                if (chart.config.type === 'doughnut') {
                    const width = chart.width;
                    const height = chart.height;
                    const ctx = chart.ctx;

                    ctx.restore();
                    const fontSize = (height / 114).toFixed(2);
                    ctx.font = fontSize + "em sans-serif";
                    ctx.textBaseline = "middle";
                    ctx.fillStyle = "#333";

                    const total = chart.config.data.datasets[0].data.reduce((a, b) => a + b, 0);
                    const text = total.toString();
                    const textX = Math.round((width - ctx.measureText(text).width) / 2);
                    const textY = height / 2;

                    ctx.fillText(text, textX, textY);
                    ctx.save();
                }
            }
        };

        chartEncuestadores = new Chart(encCtx, {
            type: 'doughnut',
            data: {
                labels: ['Activos', 'Inactivos'],
                datasets: [{
                    data: [encuestadores.activos, encuestadores.inactivos],
                    backgroundColor: ['#27ae60', '#e74c3c'],
                    borderColor: ['#ffffff', '#ffffff'],
                    borderWidth: 3,
                    hoverBorderWidth: 5,
                    hoverBorderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                cutout: '60%',
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0,0,0,0.9)',
                        titleColor: '#ffffff',
                        bodyColor: '#ffffff',
                        borderColor: '#3498db',
                        borderWidth: 2,
                        cornerRadius: 10,
                        padding: 12,
                        displayColors: true,
                        titleFont: { size: 14, weight: 'bold' },
                        bodyFont: { size: 13 },
                        callbacks: {
                            title: function(context) {
                                return 'Encuestadores ' + context[0].label;
                            },
                            label: function(context) {
                                const value = context.parsed;
                                return 'Cantidad: ' + value + ' usuarios';
                            }
                        }
                    }
                },
                animation: {
                    animateRotate: true,
                    duration: 1000,
                    easing: 'easeInOutQuart'
                },
                hover: { animationDuration: 300 }
            },
            plugins: [centerTextPlugin]
        });

        console.log('📊 Gráfico de encuestadores creado exitosamente');
        console.log('📊 Chart object:', chartEncuestadores);

        // Crear leyenda
        console.log('🏷️ Creando leyenda de encuestadores');
        crearLeyenda('encuestadoresLegend',
            [encuestadores.activos, encuestadores.inactivos],
            ['#27ae60', '#e74c3c'],
            ['Activos', 'Inactivos']
        );
        console.log('✅ Gráfico de encuestadores completado');
    }

    function crearGraficoCoordinadores() {
        const coordCtx = document.getElementById('coordinadoresChart').getContext('2d');

        // Destruir gráfico existente
        if (chartCoordinadores) {
            chartCoordinadores.destroy();
        }

        if (coordinadores.activos + coordinadores.inactivos === 0) {
            const container = document.querySelector('#coordinadoresChart').parentNode;
            container.innerHTML = '<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #666; font-size: 0.9rem;">No hay datos de coordinadores</div>';
            return;
        }

        // Plugin para mostrar el número total en el centro
        const centerTextPlugin = {
            id: 'centerText',
            beforeDraw: function(chart) {
                if (chart.config.type === 'doughnut') {
                    const width = chart.width;
                    const height = chart.height;
                    const ctx = chart.ctx;

                    ctx.restore();
                    const fontSize = (height / 114).toFixed(2);
                    ctx.font = fontSize + "em sans-serif";
                    ctx.textBaseline = "middle";
                    ctx.fillStyle = "#333";

                    const total = chart.config.data.datasets[0].data.reduce((a, b) => a + b, 0);
                    const text = total.toString();
                    const textX = Math.round((width - ctx.measureText(text).width) / 2);
                    const textY = height / 2;

                    ctx.fillText(text, textX, textY);
                    ctx.save();
                }
            }
        };

        chartCoordinadores = new Chart(coordCtx, {
            type: 'doughnut',
            data: {
                labels: ['Activos', 'Inactivos'],
                datasets: [{
                    data: [coordinadores.activos, coordinadores.inactivos],
                    backgroundColor: ['#3498db', '#f39c12'],
                    borderColor: ['#ffffff', '#ffffff'],
                    borderWidth: 3,
                    hoverBorderWidth: 5,
                    hoverBorderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                cutout: '60%',
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0,0,0,0.9)',
                        titleColor: '#ffffff',
                        bodyColor: '#ffffff',
                        borderColor: '#3498db',
                        borderWidth: 2,
                        cornerRadius: 10,
                        padding: 12,
                        displayColors: true,
                        titleFont: { size: 14, weight: 'bold' },
                        bodyFont: { size: 13 },
                        callbacks: {
                            title: function(context) {
                                return 'Coordinadores ' + context[0].label;
                            },
                            label: function(context) {
                                const value = context.parsed;
                                return 'Cantidad: ' + value + ' usuarios';
                            }
                        }
                    }
                },
                animation: {
                    animateRotate: true,
                    duration: 1000,
                    easing: 'easeInOutQuart'
                },
                hover: { animationDuration: 300 }
            },
            plugins: [centerTextPlugin]
        });

        // Crear leyenda
        crearLeyenda('coordinadoresLegend',
            [coordinadores.activos, coordinadores.inactivos],
            ['#3498db', '#f39c12'],
            ['Activos', 'Inactivos']
        );
    }

    function crearGraficoFormularios() {
        const barCtx = document.getElementById('barChart').getContext('2d');

        // Destruir gráfico existente
        if (chartFormularios) {
            chartFormularios.destroy();
        }

        // Obtener todas las zonas
        const zonasAMostrar = Object.keys(datosAUsar);

        if (zonasAMostrar.length === 0) {
            const chartContainer = document.querySelector('.bar-chart-container .chart-container');
            chartContainer.innerHTML = '<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #666; font-size: 1.1rem;">No hay datos disponibles para mostrar</div>';
            return;
        }

        const colores = ['#e74c3c', '#27ae60', '#3498db', '#f39c12', '#9b59b6', '#e67e22', '#1abc9c', '#34495e'];

        const datasets = zonasAMostrar.map((zona, index) => ({
            label: zona,
            data: Array.from({length: 12}, (_, mes) => {
                if (datosAUsar[zona] && datosAUsar[zona][mes] !== undefined) {
                    return datosAUsar[zona][mes];
                }
                return 0;
            }),
            borderColor: colores[index % colores.length],
            backgroundColor: colores[index % colores.length].replace('rgb', 'rgba').replace(')', ', 0.1)'),
            borderWidth: 3,
            pointBackgroundColor: colores[index % colores.length],
            pointBorderColor: '#ffffff',
            pointBorderWidth: 2,
            pointRadius: 6,
            pointHoverRadius: 8,
            tension: 0.4
        }));

        // Calcular el valor máximo de todos los datos para ajustar el eje Y dinámicamente
        let valorMaximo = 0;
        datasets.forEach(dataset => {
            const maxEnDataset = Math.max(...dataset.data);
            if (maxEnDataset > valorMaximo) {
                valorMaximo = maxEnDataset;
            }
        });

        // Sumar 5 al valor máximo para dar espacio visual
        const maxEjeY = valorMaximo + 5;

        chartFormularios = new Chart(barCtx, {
            type: 'line',
            data: {
                labels: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
                datasets: datasets
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                interaction: {
                    intersect: false,
                    mode: 'index'
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: maxEjeY,
                        ticks: {
                            stepSize: 1, // Mostrar cada valor entero
                            precision: 0, // Sin decimales
                            color: '#666',
                            font: { size: 11 }
                        },
                        grid: {
                            color: '#e1e1e1',
                            lineWidth: 1
                        },
                        title: {
                            display: true,
                            text: 'Cantidad de Formularios',
                            color: '#666',
                            font: { size: 12, weight: 'bold' }
                        }
                    },
                    x: {
                        ticks: {
                            color: '#666',
                            font: { size: 11 }
                        },
                        grid: {
                            color: '#e1e1e1',
                            lineWidth: 1
                        },
                        title: {
                            display: true,
                            text: 'Meses del Año',
                            color: '#666',
                            font: { size: 12, weight: 'bold' }
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'bottom',
                        labels: {
                            usePointStyle: true,
                            pointStyle: 'circle',
                            padding: 15,
                            font: {
                                size: 12,
                                weight: 'normal'
                            }
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0,0,0,0.8)',
                        titleColor: '#ffffff',
                        bodyColor: '#ffffff',
                        borderColor: '#3498db',
                        borderWidth: 1,
                        cornerRadius: 8,
                        callbacks: {
                            title: function(context) {
                                return context[0].label;
                            },
                            label: function(context) {
                                return context.dataset.label + ': ' + (context.parsed.y || 'Sin datos') + ' formularios';
                            }
                        }
                    }
                },
                animation: {
                    duration: 1000,
                    easing: 'easeInOutQuart'
                },
                hover: {
                    animationDuration: 300
                }
            }
        });
    }

    function crearLeyenda(containerId, data, colors, labels) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';

        data.forEach((value, index) => {
            const legendItem = document.createElement('div');
            legendItem.className = 'legend-item';

            const colorBox = document.createElement('div');
            colorBox.className = 'legend-color';
            colorBox.style.backgroundColor = colors[index];

            const text = document.createElement('span');
            text.textContent = labels[index] + ': (' + value + ')';

            legendItem.appendChild(colorBox);
            legendItem.appendChild(text);
            container.appendChild(legendItem);
        });
    }

    // Función para exportar el reporte del dashboard
    function exportarReporteDashboard() {
        const btn = document.getElementById('exportarReporte');
        const originalText = btn.innerHTML;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Generando...';
        btn.disabled = true;

        console.log('=== INICIANDO EXPORTACIÓN COMPLETA ===');
        console.log('Encuestadores:', encuestadores);
        console.log('Coordinadores:', coordinadores);
        console.log('Datos gráfico disponibles:', datosAUsar);
        console.log('Datos de preguntas para exportar:', datosPreguntas);

        try {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'ExportarReporteDashboardServlet';
            form.target = '_blank';
            form.style.display = 'none';

            // Preparar datos de gráficas de preguntas para exportación
            const datosGraficasPreguntas = datosPreguntas.map(pregunta => {
                return {
                    idPregunta: pregunta.idPregunta,
                    textoPregunta: pregunta.textoPregunta,
                    tipoAnalisis: pregunta.tipoAnalisis,
                    esPreguntaNumerica: pregunta.esPreguntaNumerica,
                    esPreguntaEdad: pregunta.esPreguntaEdad,
                    esPreguntaCantidad: pregunta.esPreguntaCantidad,
                    opcionesMultiples: pregunta.opcionesMultiples || [],
                    respuestasTexto: pregunta.respuestasTexto || []
                };
            });

            console.log('Datos procesados para exportación:', datosGraficasPreguntas);

            const campos = {
                'encuestadoresActivos': encuestadores.activos || 0,
                'encuestadoresInactivos': encuestadores.inactivos || 0,
                'coordinadoresActivos': coordinadores.activos || 0,
                'coordinadoresInactivos': coordinadores.inactivos || 0,
                'datosGraficoFormularios': JSON.stringify(datosAUsar || {}),
                'datosGraficasPreguntas': JSON.stringify(datosGraficasPreguntas)
            };

            Object.keys(campos).forEach(key => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = key;
                input.value = campos[key];
                form.appendChild(input);
            });

            document.body.appendChild(form);
            form.submit();
            document.body.removeChild(form);

            setTimeout(() => {
                btn.innerHTML = '<i class="fas fa-check"></i> ¡Enviado!';
                setTimeout(() => {
                    btn.innerHTML = originalText;
                    btn.disabled = false;
                }, 2000);
            }, 1000);

        } catch (error) {
            console.error('Error en JavaScript:', error);
            alert('Error al generar el reporte: ' + error.message);
            btn.innerHTML = originalText;
            btn.disabled = false;
        }
    }

    // Datos de las preguntas para los gráficos (generados desde el backend)
    const datosPreguntas = [];

    <c:if test="${not empty analisisFormularios}">
    <c:forEach var="formulario" items="${analisisFormularios}">
    <c:forEach var="pregunta" items="${formulario.preguntas}">
    <!-- Aplicar el mismo filtro que en la visualización -->
    <c:set var="textoMinuscula" value="${fn:toLowerCase(pregunta.textoPregunta)}" />
    
    <!-- Detectar preguntas especiales de datos numéricos -->
    <c:set var="esPreguntaEdad" value="${
        fn:contains(textoMinuscula, 'edad de la persona entrevistada') or
        fn:contains(textoMinuscula, '¿qué edad tiene?')
    }" />
    
    <c:set var="esPreguntaCantidad" value="${
        fn:contains(textoMinuscula, '¿cuántos niños/niñas de 0 a 5 años hay en el hogar?') or
        fn:contains(textoMinuscula, '¿cuántas personas adultas mayores hay en el hogar?') or
        fn:contains(textoMinuscula, '¿cuántas personas con discapacidad o enfermedad crónica hay en el hogar?')
    }" />
    
    <c:set var="esPreguntaNumerica" value="${esPreguntaEdad or esPreguntaCantidad}" />
    
    <c:set var="mostrarPregunta" value="${
        (not fn:contains(textoMinuscula, 'nombre del asentamiento humano') and
        not fn:contains(textoMinuscula, 'sector') and
        not fn:contains(textoMinuscula, 'nombres y apellidos de la persona entrevistada') and
        not fn:contains(textoMinuscula, 'dni de la persona entrevistada') and
        not fn:contains(textoMinuscula, 'dirección de la persona entrevistada') and
        not fn:contains(textoMinuscula, 'celular de contacto') and
        not fn:contains(textoMinuscula, '¿padecen alguna enfermedad?') and
        not fn:contains(textoMinuscula, '¿qué tipo de discapacidad o enfermedad tienen?') and
        not fn:contains(textoMinuscula, '¿cuánto tiempo al día dedica al cuidado?')) or
        esPreguntaNumerica
    }" />
    
    <c:if test="${mostrarPregunta and ((pregunta.tipoAnalisis eq 'opciones_multiples' or pregunta.tipoAnalisis eq 'si_no') or (esPreguntaNumerica and pregunta.tipoAnalisis eq 'texto_libre'))}">
    console.log('🔧 Agregando pregunta al array JavaScript:', '<c:out value="${pregunta.textoPregunta}" escapeXml="true"/>');
    console.log('🔧 Tipo de pregunta:', '<c:out value="${pregunta.tipoAnalisis}" escapeXml="true"/>');
    console.log('🔧 Canvas ID que se generará:', "chart_${formulario.idFormulario}_${pregunta.idPregunta}");
    console.log('🔧 Cantidad de opciones:', ${fn:length(pregunta.opcionesMultiples)});

    datosPreguntas.push({
        canvasId: "chart_${formulario.idFormulario}_${pregunta.idPregunta}",
        idPregunta: ${pregunta.idPregunta},
        textoPregunta: `<c:out value='${pregunta.textoPregunta}' escapeXml='true'/>`,
        tipoAnalisis: '<c:out value="${pregunta.tipoAnalisis}" escapeXml="true"/>',
        esPreguntaEdad: ${esPreguntaEdad},
        esPreguntaCantidad: ${esPreguntaCantidad},
        esPreguntaNumerica: ${esPreguntaNumerica},
        opcionesMultiples: [
            <c:forEach var="opcion" items="${pregunta.opcionesMultiples}" varStatus="opcionStatus">
            {
                textoOpcion: `<c:out value='${opcion.textoOpcion}' escapeXml='true'/>`,
                cantidadRespuestas: ${opcion.cantidadRespuestas}
            }<c:if test="${!opcionStatus.last}">,</c:if>
            </c:forEach>
        ],
        respuestasTexto: [
            <c:forEach var="respuesta" items="${pregunta.respuestasTexto}" varStatus="respStatus">
            `<c:out value='${respuesta.texto}' escapeXml='true'/>`<c:if test="${!respStatus.last}">,</c:if>
            </c:forEach>
        ]
    });
    </c:if>
    </c:forEach>
    </c:forEach>
    </c:if>

    console.log('🎯 DATOS FINALES para gráficos:');
    console.log('Total preguntas encontradas:', datosPreguntas.length);
    console.log('Tipos de preguntas encontradas:', datosPreguntas.map(p => p.tipoAnalisis));
    console.log('Datos completos:', datosPreguntas);

    // Debug adicional: verificar si hay canvas en el DOM
    setTimeout(() => {
        console.log('🔍 Verificando canvas en DOM...');
        const todosCanvas = document.querySelectorAll('canvas[id^="chart_"]');
        console.log('Canvas encontrados:', todosCanvas.length);
        todosCanvas.forEach(canvas => {
            console.log('Canvas ID:', canvas.id);
        });
    }, 500);

    /**
     * Crea gráficos de barras para preguntas de opción múltiple
     */
    function crearGraficosPreguntas() {
        console.log('=== INICIANDO CREACIÓN DE GRÁFICOS DE PREGUNTAS ===');
        console.log('Datos de preguntas disponibles:', datosPreguntas);
        console.log('Cantidad de preguntas de opción múltiple:', datosPreguntas.length);

        // Listar todos los canvas existentes en el DOM
        const todosLosCanvas = document.querySelectorAll('canvas[id^="chart_"]');
        console.log('Canvas encontrados en el DOM:', todosLosCanvas);

        if (datosPreguntas.length === 0) {
            console.warn('No hay datos de preguntas de opción múltiple para mostrar');
            // Agregar mensaje visual en los canvas vacíos
            todosLosCanvas.forEach(canvas => {
                const container = canvas.parentElement;
                if (container) {
                    container.innerHTML = '<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #999; font-size: 0.9rem; text-align: center; padding: 20px;">📊<br>No hay datos suficientes para mostrar el gráfico</div>';
                }
            });
            return;
        }

        datosPreguntas.forEach((pregunta, index) => {
            console.log(`Procesando pregunta ${index + 1}:`, pregunta.textoPregunta);
            console.log(`Canvas ID: ${pregunta.canvasId}`);
            console.log('Opciones de la pregunta:', pregunta.opcionesMultiples);

            // Actualizar debug en la página
            const debugElement = document.getElementById(`debug_${pregunta.canvasId}`);
            if (debugElement) {
                debugElement.innerHTML = `Canvas: ${pregunta.canvasId}<br>Opciones: ${pregunta.opcionesMultiples ? pregunta.opcionesMultiples.length : 0}<br>Estado: Procesando...`;
            }

            const canvas = document.getElementById(pregunta.canvasId);

            if (canvas) {
                console.log(`✅ Canvas encontrado para: ${pregunta.canvasId}`);
                console.log(`🔍 Es pregunta numérica: ${pregunta.esPreguntaNumerica}`);
                console.log(`🔍 Tipo análisis: ${pregunta.tipoAnalisis}`);
                console.log(`🔍 Opciones múltiples: ${pregunta.opcionesMultiples ? pregunta.opcionesMultiples.length : 0}`);
                console.log(`🔍 Respuestas texto: ${pregunta.respuestasTexto ? pregunta.respuestasTexto.length : 0}`);
                
                // Verificar si tiene datos válidos (opciones múltiples O respuestas de texto para preguntas numéricas)
                const tieneOpcionesMultiples = pregunta.opcionesMultiples && pregunta.opcionesMultiples.length > 0;
                const tieneRespuestasTextoNumericas = pregunta.esPreguntaNumerica && pregunta.respuestasTexto && pregunta.respuestasTexto.length > 0;
                
                if (tieneOpcionesMultiples || tieneRespuestasTextoNumericas) {
                    console.log('✅ Datos válidos encontrados, creando gráfico...');

                    // Actualizar debug
                    if (debugElement) {
                        const tipoDetectado = tieneOpcionesMultiples ? 'Opciones múltiples' : 'Datos numéricos';
                        const cantidad = tieneOpcionesMultiples ? pregunta.opcionesMultiples.length : pregunta.respuestasTexto.length;
                        debugElement.innerHTML = `Canvas: ${pregunta.canvasId}<br>Tipo: ${tipoDetectado}<br>Datos: ${cantidad}<br>Estado: ✅ Creando gráfico...`;
                    }

                    crearGraficoBarrasPregunta(pregunta.canvasId, pregunta);

                    // Actualizar debug final
                    if (debugElement) {
                        debugElement.innerHTML = `Canvas: ${pregunta.canvasId}<br>Estado: ✅ Gráfico creado exitosamente`;
                    }
                } else {
                    console.warn(`❌ No hay datos válidos para esta pregunta: ${pregunta.textoPregunta}`);
                    console.warn(`   - Opciones múltiples: ${pregunta.opcionesMultiples ? pregunta.opcionesMultiples.length : 0}`);
                    console.warn(`   - Respuestas texto: ${pregunta.respuestasTexto ? pregunta.respuestasTexto.length : 0}`);
                    console.warn(`   - Es numérica: ${pregunta.esPreguntaNumerica}`);

                    // Actualizar debug
                    if (debugElement) {
                        debugElement.innerHTML = `Canvas: ${pregunta.canvasId}<br>Estado: ❌ Sin datos válidos`;
                    }

                    const container = canvas.parentElement;
                    if (container) {
                        const mensaje = pregunta.esPreguntaNumerica ? 
                            'Sin respuestas de texto para procesar' : 
                            'Sin opciones múltiples disponibles';
                        container.innerHTML = `<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #999; font-size: 0.9rem; text-align: center; padding: 20px;">📊<br>${mensaje}</div>`;
                    }
                }
            } else {
                console.error(`❌ Canvas NO encontrado: ${pregunta.canvasId}`);

                // Actualizar debug
                if (debugElement) {
                    debugElement.innerHTML = `Canvas: ${pregunta.canvasId}<br>Estado: ❌ Canvas NO encontrado`;
                }
            }
        });

        console.log('=== FIN CREACIÓN DE GRÁFICOS DE PREGUNTAS ===');
    }

    /**
     * Procesa respuestas de edad y crea rangos estadísticos
     */
    function crearGraficoEdades(ctx, respuestasTexto, pregunta) {
        console.log('Creando gráfico de edades para:', pregunta.textoPregunta);
        console.log('Respuestas recibidas:', respuestasTexto);
        
        // Procesar edades en rangos
        const rangos = {
            '0-17': 0,
            '18-25': 0,
            '26-35': 0,
            '36-45': 0,
            '46-55': 0,
            '56-65': 0,
            '66+': 0,
            'Inválido': 0
        };
        
        respuestasTexto.forEach(respuestaTexto => {
            const edad = parseInt(respuestaTexto.toString().trim());
            
            if (isNaN(edad) || edad < 0 || edad > 120) {
                rangos['Inválido']++;
            } else if (edad <= 17) {
                rangos['0-17']++;
            } else if (edad <= 25) {
                rangos['18-25']++;
            } else if (edad <= 35) {
                rangos['26-35']++;
            } else if (edad <= 45) {
                rangos['36-45']++;
            } else if (edad <= 55) {
                rangos['46-55']++;
            } else if (edad <= 65) {
                rangos['56-65']++;
            } else {
                rangos['66+']++;
            }
        });
        
        // Filtrar rangos que tienen datos
        const labels = Object.keys(rangos).filter(rango => rangos[rango] > 0);
        const data = labels.map(label => rangos[label]);
        const colores = ['#3498db', '#27ae60', '#f39c12', '#e74c3c', '#9b59b6', '#1abc9c', '#34495e', '#95a5a6'];
        
        console.log('Rangos de edad procesados:', rangos);
        console.log('Labels para gráfico:', labels);
        console.log('Datos para gráfico:', data);
        
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Cantidad de Personas',
                    data: data,
                    backgroundColor: colores.slice(0, labels.length).map(color => color + '80'),
                    borderColor: colores.slice(0, labels.length),
                    borderWidth: 2,
                    borderRadius: 4,
                    borderSkipped: false
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'bottom'
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0,0,0,0.9)',
                        callbacks: {
                            title: function(context) {
                                return `Rango de edad: ${context[0].label} años`;
                            },
                            label: function(context) {
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const porcentaje = ((context.parsed.y / total) * 100).toFixed(1);
                                return `${context.parsed.y} personas (${porcentaje}%)`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, precision: 0 },
                        title: { display: true, text: 'Cantidad de Personas' }
                    },
                    x: {
                        title: { display: true, text: 'Rangos de Edad' }
                    }
                }
            }
        });
    }

    /**
     * Procesa respuestas de cantidad y crea gráfico de distribución
     */
    function crearGraficoCantidades(ctx, respuestasTexto, pregunta) {
        console.log('Creando gráfico de cantidades para:', pregunta.textoPregunta);
        console.log('Respuestas recibidas:', respuestasTexto);
        
        // Procesar cantidades
        const conteos = {};
        let maxCantidad = 0;
        
        respuestasTexto.forEach(respuestaTexto => {
            const cantidad = parseInt(respuestaTexto.toString().trim());
            
            if (!isNaN(cantidad) && cantidad >= 0 && cantidad <= 20) { // Limitar a rangos razonables
                const key = cantidad.toString();
                conteos[key] = (conteos[key] || 0) + 1;
                if (cantidad > maxCantidad) maxCantidad = cantidad;
            } else {
                // Agrupar valores inválidos o muy altos
                conteos['Otros/Inválidos'] = (conteos['Otros/Inválidos'] || 0) + 1;
            }
        });
        
        // Preparar datos para el gráfico
        const labels = Object.keys(conteos).sort((a, b) => {
            if (a === 'Otros/Inválidos') return 1;
            if (b === 'Otros/Inválidos') return -1;
            return parseInt(a) - parseInt(b);
        });
        const data = labels.map(label => conteos[label]);
        const colores = ['#3498db', '#27ae60', '#f39c12', '#e74c3c', '#9b59b6', '#1abc9c', '#34495e', '#95a5a6', '#16a085', '#f1c40f'];
        
        console.log('Conteos procesados:', conteos);
        console.log('Labels para gráfico:', labels);
        console.log('Datos para gráfico:', data);
        
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Cantidad de Respuestas',
                    data: data,
                    backgroundColor: colores.slice(0, labels.length).map(color => color + '80'),
                    borderColor: colores.slice(0, labels.length),
                    borderWidth: 2,
                    borderRadius: 4,
                    borderSkipped: false
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'bottom'
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0,0,0,0.9)',
                        callbacks: {
                            title: function(context) {
                                const valor = context[0].label;
                                if (valor === 'Otros/Inválidos') {
                                    return 'Respuestas inválidas o fuera de rango';
                                }
                                return `Cantidad: ${valor}`;
                            },
                            label: function(context) {
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const porcentaje = ((context.parsed.y / total) * 100).toFixed(1);
                                return `${context.parsed.y} respuestas (${porcentaje}%)`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, precision: 0 },
                        title: { display: true, text: 'Número de Respuestas' }
                    },
                    x: {
                        title: { display: true, text: 'Cantidad Reportada' }
                    }
                }
            }
        });
    }

    /**
     * Crea un gráfico de barras para una pregunta específica
     */
    function crearGraficoBarrasPregunta(canvasId, pregunta) {
        console.log('🎨 === INICIANDO CREACIÓN DE GRÁFICO ===');
        console.log('🎯 Canvas ID:', canvasId);
        console.log('📝 Pregunta:', pregunta.textoPregunta);
        console.log('🔍 Objeto pregunta completo:', pregunta);
        console.log('📊 Tipo análisis:', pregunta.tipoAnalisis);
        console.log('🔢 Es pregunta numérica:', pregunta.esPreguntaNumerica);
        console.log('👴 Es pregunta edad:', pregunta.esPreguntaEdad);
        console.log('🔢 Es pregunta cantidad:', pregunta.esPreguntaCantidad);
        console.log('📋 Opciones múltiples:', pregunta.opcionesMultiples);
        console.log('📝 Respuestas texto:', pregunta.respuestasTexto);
        console.log('📊 Cantidad opciones múltiples:', pregunta.opcionesMultiples ? pregunta.opcionesMultiples.length : 0);
        console.log('📝 Cantidad respuestas texto:', pregunta.respuestasTexto ? pregunta.respuestasTexto.length : 0);
        
        try {
            const canvas = document.getElementById(canvasId);
            if (!canvas) {
                console.error('❌ No se encontró el canvas:', canvasId);
                return;
            }
            console.log('✅ Canvas encontrado:', canvas);

            const ctx = canvas.getContext('2d');
            console.log('✅ Contexto 2D obtenido:', ctx);

            // Verificar si es una pregunta numérica especial
            if (pregunta.esPreguntaNumerica && pregunta.respuestasTexto && pregunta.respuestasTexto.length > 0) {
                console.log('🔢 ✅ PROCESANDO PREGUNTA NUMÉRICA');
                console.log('📝 Respuestas de texto disponibles:', pregunta.respuestasTexto);
                
                if (pregunta.esPreguntaEdad) {
                    console.log('👴 Creando gráfico de edades...');
                    crearGraficoEdades(ctx, pregunta.respuestasTexto, pregunta);
                } else if (pregunta.esPreguntaCantidad) {
                    console.log('🔢 Creando gráfico de cantidades...');
                    crearGraficoCantidades(ctx, pregunta.respuestasTexto, pregunta);
                }
                console.log('✅ Gráfico numérico completado');
                return;
            }

            // Lógica original para opciones múltiples y si/no
            console.log('📊 Procesando pregunta de opciones múltiples/si_no');
            
            if (!pregunta.opcionesMultiples || pregunta.opcionesMultiples.length === 0) {
                console.error('❌ ERROR: No hay opciones múltiples para procesar');
                console.error('❌ Pregunta:', pregunta.textoPregunta);
                console.error('❌ Tipo análisis:', pregunta.tipoAnalisis);
                const container = canvas.parentElement;
                if (container) {
                    container.innerHTML = '<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #dc3545; font-size: 0.9rem; text-align: center; padding: 20px;">❌<br>Sin datos de opciones múltiples<br>para mostrar</div>';
                }
                return;
            }
            
            const labels = pregunta.opcionesMultiples.map(item => item.textoOpcion);
            const data = pregunta.opcionesMultiples.map(item => item.cantidadRespuestas);
            
            console.log('📊 Labels extraídos:', labels);
            console.log('📊 Datos extraídos:', data);

            // Determinar el tipo de gráfico basado en el tipo de pregunta
            let tipoGrafico = 'bar';
            let colores = generarColoresDinamicos(data.length);

            // Para preguntas de Sí/No, usar gráfico de dona
            if (pregunta.tipoAnalisis === 'si_no' && data.length === 2) {
                tipoGrafico = 'doughnut';
                colores = ['#27ae60', '#e74c3c']; // Verde para Sí, Rojo para No
            }

            console.log('Creando gráfico para:', pregunta.textoPregunta);
            console.log('Tipo de gráfico:', tipoGrafico);
            console.log('Tipo de análisis:', pregunta.tipoAnalisis);
            console.log('Datos:', data);
            console.log('Labels:', labels);

            const configGrafico = {
                type: tipoGrafico,
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Cantidad de Respuestas',
                        data: data,
                        backgroundColor: tipoGrafico === 'doughnut' ? colores : colores.map(color => color + '80'),
                        borderColor: tipoGrafico === 'doughnut' ? ['#ffffff', '#ffffff'] : colores,
                        borderWidth: tipoGrafico === 'doughnut' ? 3 : 2,
                        borderRadius: tipoGrafico === 'bar' ? 4 : 0,
                        borderSkipped: tipoGrafico === 'bar' ? false : undefined,
                        hoverBorderWidth: tipoGrafico === 'doughnut' ? 5 : undefined,
                        hoverBorderColor: tipoGrafico === 'doughnut' ? '#ffffff' : undefined
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: tipoGrafico === 'doughnut' ? '50%' : undefined,
                    plugins: {
                        legend: {
                            display: tipoGrafico === 'doughnut',
                            position: 'bottom'
                        },
                        tooltip: {
                            backgroundColor: 'rgba(0,0,0,0.8)',
                            titleColor: '#ffffff',
                            bodyColor: '#ffffff',
                            borderColor: '#3498db',
                            borderWidth: 1,
                            cornerRadius: 6,
                            padding: 10,
                            callbacks: {
                                title: function(context) {
                                    return 'Opción: ' + context[0].label;
                                },
                                label: function(context) {
                                    const valor = tipoGrafico === 'doughnut' ? context.parsed : context.parsed.y;
                                    const total = data.reduce((a, b) => a + b, 0);
                                    const porcentaje = total > 0 ? ((valor / total) * 100).toFixed(1) : 0;
                                    return [
                                        'Respuestas: ' + valor,
                                        'Porcentaje: ' + porcentaje + '%'
                                    ];
                                }
                            }
                        }
                    },
                    scales: tipoGrafico === 'bar' ? {
                        y: {
                            beginAtZero: true,
                            max: Math.max(...data) + 1, // Establecer el máximo como el valor más alto + 1
                            ticks: {
                                stepSize: 1,
                                precision: 0,
                                color: '#666',
                                font: { size: 11 }
                            },
                            grid: {
                                color: '#e1e1e1',
                                lineWidth: 1
                            },
                            title: {
                                display: true,
                                text: 'Cantidad de Respuestas',
                                color: '#666',
                                font: { size: 12, weight: 'bold' }
                            }
                        },
                        x: {
                            ticks: {
                                color: '#666',
                                font: { size: 10 },
                                maxRotation: 45,
                                minRotation: 0
                            },
                            grid: {
                                display: false
                            },
                            title: {
                                display: true,
                                text: 'Opciones de Respuesta',
                                color: '#666',
                                font: { size: 12, weight: 'bold' }
                            }
                        }
                    } : undefined,
                    animation: {
                        duration: 1000,
                        easing: 'easeInOutQuart'
                    },
                    hover: {
                        animationDuration: 300
                    }
                }
            };

            new Chart(ctx, configGrafico);

            console.log('✅ Gráfico de opciones múltiples creado exitosamente para:', canvasId);

        } catch (error) {
            console.error('❌ ERROR CREANDO GRÁFICO', canvasId, ':', error);
            console.error('❌ Detalles del error:', error.stack);
            console.error('❌ Datos de la pregunta que causó el error:', pregunta);
            
            // Mostrar error visual en el canvas
            const canvas = document.getElementById(canvasId);
            if (canvas) {
                const container = canvas.parentElement;
                if (container) {
                    container.innerHTML = `<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #dc3545; font-size: 0.9rem; text-align: center; padding: 20px;">❌<br>Error al crear gráfico<br><small>${error.message}</small></div>`;
                }
            }
        }
    }

    /**
     * Genera colores dinámicos para los gráficos
     */
    function generarColoresDinamicos(cantidad) {
        const coloresBase = [
            '#3498db', '#27ae60', '#f39c12', '#e74c3c', '#9b59b6',
            '#1abc9c', '#34495e', '#16a085', '#f1c40f', '#e67e22',
            '#2ecc71', '#3742fa', '#ff6348', '#ffc048', '#7bed9f'
        ];

        const colores = [];
        for (let i = 0; i < cantidad; i++) {
            if (i < coloresBase.length) {
                colores.push(coloresBase[i]);
            } else {
                // Generar color aleatorio si se excede la paleta base
                const hue = (i * 137.508) % 360; // Distribución áurea para mejores colores
                colores.push(`hsl(${hue}, 70%, 60%)`);
            }
        }
        return colores;
    }

    // Función de diagnóstico para verificar el estado del dashboard
    function diagnosticarDashboard() {
        console.log('🩺 === DIAGNÓSTICO COMPLETO DEL DASHBOARD ===');
        
        const indicador = document.getElementById('indicadorEstado');
        
        // Verificar Chart.js
        const chartJSDisponible = typeof Chart !== 'undefined';
        console.log('📊 Chart.js disponible:', chartJSDisponible ? '✅ SÍ' : '❌ NO');
        
        if (!chartJSDisponible) {
            if (indicador) {
                indicador.innerHTML = '❌ ERROR: Chart.js no se cargó correctamente';
                indicador.style.background = '#f8d7da';
                indicador.style.borderColor = '#dc3545';
                indicador.style.color = '#721c24';
            }
            console.log('🩺 === FIN DIAGNÓSTICO - ERROR CRÍTICO ===');
            return;
        }
        
        if (chartJSDisponible) {
            console.log('📊 Chart.js versión:', Chart.version || 'No detectada');
        }
        
        // Verificar canvas elements
        const canvasIds = ['encuestadoresChart', 'coordinadoresChart', 'barChart'];
        let canvasProblemas = 0;
        
        canvasIds.forEach(id => {
            const element = document.getElementById(id);
            console.log(`🎯 Canvas ${id}:`, element ? '✅ Existe' : '❌ No existe');
            if (element) {
                const rect = element.getBoundingClientRect();
                console.log(`   📐 Dimensiones: ${rect.width}x${rect.height}`);
                const visible = rect.width > 0 && rect.height > 0;
                console.log(`   👁️ Visible:`, visible ? '✅ SÍ' : '❌ NO');
                if (!visible) canvasProblemas++;
            } else {
                canvasProblemas++;
            }
        });
        
        // Verificar datos
        console.log('📊 Datos disponibles:');
        console.log('   👥 Encuestadores activos:', encuestadores.activos);
        console.log('   👥 Encuestadores inactivos:', encuestadores.inactivos);
        console.log('   👑 Coordinadores activos:', coordinadores.activos);
        console.log('   👑 Coordinadores inactivos:', coordinadores.inactivos);
        console.log('   📋 Datos formularios:', datosAUsar);
        
        // Verificar gráficos creados
        console.log('🎨 Gráficos creados:');
        console.log('   👥 chartEncuestadores:', chartEncuestadores ? '✅ Creado' : '❌ No creado');
        console.log('   👑 chartCoordinadores:', chartCoordinadores ? '✅ Creado' : '❌ No creado');
        console.log('   📋 chartFormularios:', chartFormularios ? '✅ Creado' : '❌ No creado');
        
        const graficosCreados = (chartEncuestadores ? 1 : 0) + (chartCoordinadores ? 1 : 0) + (chartFormularios ? 1 : 0);
        
        // Actualizar indicador visual
        if (indicador) {
            if (canvasProblemas > 0) {
                indicador.innerHTML = `⚠️ Problemas detectados: ${canvasProblemas} canvas con problemas`;
                indicador.style.background = '#fff3cd';
                indicador.style.borderColor = '#ffc107';
                indicador.style.color = '#856404';
            } else if (graficosCreados === 3) {
                indicador.innerHTML = '✅ Todas las gráficas se cargaron correctamente';
                indicador.style.background = '#d4edda';
                indicador.style.borderColor = '#28a745';
                indicador.style.color = '#155724';
            } else {
                indicador.innerHTML = `⚠️ Solo ${graficosCreados}/3 gráficas se crearon correctamente`;
                indicador.style.background = '#fff3cd';
                indicador.style.borderColor = '#ffc107';
                indicador.style.color = '#856404';
            }
        }
        
        console.log('🩺 === FIN DIAGNÓSTICO ===');
    }

    // Ejecutar diagnóstico después de 3 segundos
    setTimeout(diagnosticarDashboard, 3000);
</script>
<script>
    // Mostrar/ocultar menú desplegable del botón Encuestador
    const btnEncuestador = document.getElementById('btn-encuestador');
    btnEncuestador.addEventListener('click', () => {
        btnEncuestador.classList.toggle('dropdown-active');
    });
    // Cerrar el dropdown si se hace click fuera
    document.addEventListener('click', (e) => {
        if (!btnEncuestador.contains(e.target)) {
            btnEncuestador.classList.remove('dropdown-active');
        }
    });
</script>
</body>
</html>