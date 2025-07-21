<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies

    // Guardar en sesión solo la lista que se muestra en la tabla (página actual)
    session.setAttribute("encuestadoresFiltrados", request.getAttribute("encuestadores"));
%>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">

    <title>Generar Reporte de Encuestadores</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        /* Copiado de generarReportesCoordi.jsp para uniformidad visual */
        :root {
            --color-primary: #3498db;
            --color-bg: #f5f7fa;
            --color-card: #c8dbff;
            --color-card-inner: #e6f0ff;
            --sidebar-bg: #e6f0ff;
            --header-bg: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
            --color-btn: #5a9cf8;
            --color-btn-hover: #357ae8;
        }
        html, body { height: 100%; }
        body {
            min-height: 100vh;
            height: 100%;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #e6f0ff 0%, #b3ccff 100%);
            margin: 0;
            padding: 0;
            color: #333;
        }
        .menu-toggle:checked ~ .sidebar { left: 0; }
        .menu-toggle:checked ~ .overlay { display: block; opacity: 1; }
        .contenedor-principal {
            width: 100%;
            margin: 0;
            padding: 10px 10px 0 32px;
            box-sizing: border-box;
            min-height: calc(100vh - 56.8px);
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
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
        .sidebar-content .menu-links li { margin-bottom: 15px; }
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
        .nav-item.dropdown:hover .dropdown-menu {
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
        .dropdown-arrow {
            margin-left: 8px;
            transition: transform 0.2s ease;
            font-size: 0.8em;
        }
        .dropdown:hover .dropdown-arrow,
        .dropdown:focus-within .dropdown-arrow {
            transform: rotate(180deg);
        }
        .btn-descargar {
            background: var(--color-btn);
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 14px 38px;
            font-size: 1.1em;
            font-weight: 500;
            cursor: pointer;
            float: right;
            margin-top: 10px;
            transition: background 0.2s, box-shadow 0.2s;
            box-shadow: 0 2px 8px rgba(52, 152, 219, 0.10);
        }
        .btn-descargar.btn-descargar-mini {
            padding: 7px 14px;
            font-size: 18px;
            border-radius: 50%;
            min-width: 0;
            width: 44px;
            height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #43e97b 60%, #38f9d7 100%);
            color: #fff;
            border: none;
            box-shadow: 0 2px 8px rgba(67, 233, 123, 0.13);
            transition: background 0.2s, box-shadow 0.2s, transform 0.15s;
            cursor: pointer;
        }
        .btn-descargar.btn-descargar-mini:hover {
            background: linear-gradient(135deg, #38f9d7 60%, #43e97b 100%);
            color: #fff;
            box-shadow: 0 4px 16px rgba(67, 233, 123, 0.18);
            transform: scale(1.08) rotate(-8deg);
        }
        .contenedor {
            background-color: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
            padding: 18px 18px 10px 18px;
            max-width: 98vw;
            width: 100%;
            margin: 0 auto 18px auto;
            box-sizing: border-box;
            position: relative;
            left: 50%;
            transform: translateX(-50%);
        }
        .tabla-container {
            overflow-x: auto;
            margin-top: 0;
        }
        table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: #f8faff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04);
        }
        th, td {
            padding: 12px 10px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
        }
        th {
            background-color: #eaf1fb;
            color: #2c3e50;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.93em;
            letter-spacing: 0.5px;
        }
        .estado-activo {
            background-color: rgba(46, 204, 113, 0.13);
            color: #2ecc71;
            border-radius: 20px;
            padding: 5px 14px;
            font-weight: 600;
        }
        .estado-inactivo {
            background-color: rgba(231, 76, 60, 0.13);
            color: #e74c3c;
            border-radius: 20px;
            padding: 5px 14px;
            font-weight: 600;
        }
        @media (max-width: 900px) {
            .contenedor-principal { padding: 8px 1vw 0 1vw; }
            .contenedor { padding: 10px 2vw 6px 2vw; }
        }
        @media (max-width: 600px) {
            .btn-descargar { width: 100%; }
        }
        
        /* ================== RESPONSIVIDAD COMPLETA ================== */
        
        /* Tablet - Portrait (768px - 1024px) */
        @media (max-width: 1024px) {
            .sidebar {
                width: 260px;
                left: -260px;
            }
            
            .contenedor {
                padding: 15px 3vw 20px 3vw;
            }
            
            table {
                font-size: 14px;
            }
            
            th, td {
                padding: 10px 8px;
            }
            
            form[style*="position: absolute"] {
                position: static !important;
                margin-bottom: 20px;
                display: flex;
                justify-content: center;
            }
        }
        
        /* Mobile - Large (481px - 768px) */
        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                height: auto;
                padding: 0.75rem 1rem;
                gap: 1rem;
            }
            
            .header-left,
            .header-right {
                width: 100%;
                justify-content: center;
            }
            
            .header-right {
                flex-wrap: wrap;
                gap: 1rem;
                margin-top: 0.5rem;
            }
            
            .logo-large img {
                height: 35px;
            }
            
            .nav-icon {
                width: 26px;
                height: 26px;
            }
            
            .contenedor {
                padding: 15px 2vw 20px 2vw;
                margin-top: 0 !important;
                position: static !important;
            }
            
            h2 {
                font-size: 1.5rem;
                text-align: center;
                margin-bottom: 1rem;
            }
            
            .tabla-container {
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
                border-radius: 8px;
                margin-top: 20px;
            }
            
            table {
                min-width: 600px;
                font-size: 13px;
            }
            
            th, td {
                padding: 8px 6px;
                white-space: nowrap;
            }
            
            th:first-child,
            td:first-child {
                position: sticky;
                left: 0;
                background: inherit;
                z-index: 1;
            }
            
            .btn-descargar {
                width: 100%;
                margin-bottom: 15px;
                padding: 12px;
                font-size: 16px;
            }
            
            form[style*="position: absolute"] {
                position: static !important;
                top: auto !important;
                right: auto !important;
                margin: 0 0 20px 0 !important;
                z-index: auto !important;
                text-align: center;
            }
        }
        
        /* Mobile - Small (320px - 480px) */
        @media (max-width: 480px) {
            .sidebar {
                width: 240px;
                left: -240px;
            }
            
            .header-bar {
                height: auto;
                min-height: 56px;
            }
            
            .header-content {
                padding: 0.5rem;
            }
            
            .logo-large img {
                height: 30px;
            }
            
            .nav-item#btn-encuestador span {
                font-size: 0.8rem;
            }
            
            .contenedor {
                padding: 10px 1vw 15px 1vw;
            }
            
            h2 {
                font-size: 1.3rem;
                margin-bottom: 1rem;
            }
            
            table {
                font-size: 12px;
                min-width: 500px;
            }
            
            th, td {
                padding: 6px 4px;
            }
            
            .estado-activo,
            .estado-inactivo {
                font-size: 11px;
                padding: 4px 8px;
            }
            
            .btn-descargar {
                font-size: 14px;
                padding: 10px;
            }
        }
        
        /* Extra Small Mobile (320px and below) */
        @media (max-width: 320px) {
            .contenedor {
                padding: 5px;
            }
            
            table {
                min-width: 400px;
                font-size: 11px;
            }
            
            th, td {
                padding: 4px 2px;
            }
            
            h2 {
                font-size: 1.2rem;
            }
            
            .btn-descargar {
                font-size: 13px;
                padding: 8px;
            }
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
<input type="checkbox" id="menu-toggle" class="menu-toggle" style="display:none;" />
<!-- Sidebar -->
<div class="sidebar">
    <label for="menu-toggle" class="sidebar-close">&times;</label>
    <div class="sidebar-content">
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
<main class="contenedor-principal">
    <div class="contenedor" style="margin-top: 0; position: relative;">
        <form method="get" action="GenerarReportesEncuestadorServlet" style="position: absolute; top: 18px; right: 18px; z-index: 10; margin:0;">
            <button type="submit" class="btn-descargar btn-descargar-mini" name="action" value="excel" title="Descargar Excel">
                <i class="fa-solid fa-file-excel"></i>
            </button>
        </form>
        <h2>Vista previa de Reporte de Encuestadores</h2>
        <div class="tabla-container">
            <table>
                <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>DNI</th>
                        <th>Correo electrónico</th>
                        <th>Zona</th>
                        <th>Estado</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty encuestadores}">
                            <tr>
                                <td colspan="5" style="text-align:center; color:#888; font-style:italic; background:#f5f7fa;">No se encontró información para los filtros seleccionados.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="encuestador" items="${encuestadores}">
                                <tr>
                                    <td>${encuestador.usuario.nombre} ${encuestador.usuario.apellidopaterno} ${encuestador.usuario.apellidomaterno}</td>
                                    <td>${encuestador.usuario.dni}</td>
                                    <td>${encuestador.credencial.correo}</td>
                                    <td>${encuestador.zonaTrabajoNombre}</td>
                                    <td class="estado-col">
                                        <span class="${encuestador.usuario.idEstado == 2 ? 'estado-activo' : 'estado-inactivo'}">
                                            ${encuestador.usuario.idEstado == 2 ? 'Activado' : 'Desactivado'}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        <c:if test="${not empty errorExcel}">
            <div style="text-align:center; color:#e74c3c; font-weight:bold; margin-top:18px; font-size:1.1em;">${errorExcel}</div>
        </c:if>
    </div>
</main>
</body>
</html>
