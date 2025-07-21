<%--
  Created by IntelliJ IDEA.
  User: Nilton
  Date: 14/05/2025
  Time: 12:27
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Intranet - Formularios Asignados</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="formulariosAsignados.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<input type="checkbox" id="menu-toggle" class="menu-toggle" />
<div class="sidebar">
    <div class="sidebar-content">
        <button class="sidebar-close-btn" onclick="document.getElementById('menu-toggle').checked = false;">×</button>
        <div class="sidebar-separator"></div>
        <ul class="menu-links">
            <li>
                <a href="InicioEncuestadorServlet">
                    <i class="fa-solid fa-chart-line"></i> Ver Dashboard
                </a>
            </li>
            <li>
                <a href="FormulariosAsignadosServlet">
                    <i class="fa-solid fa-list-check"></i> Ver formularios asignados
                </a>
            </li>
            <li>
                <a href="HistorialFormulariosServlet">
                    <i class="fa-solid fa-clock-rotate-left"></i> Ver historial de formulario
                </a>
            </li>
            <li>
                <a href="CerrarSesionServlet">
                    <i class="fa-solid fa-right-from-bracket"></i> Cerrar sesión
                </a>
            </li>
        </ul>
    </div>
</div>
<label for="menu-toggle" class="overlay"></label>
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
                <span id="user-name-display">
                    <c:choose>
                        <c:when test="${not empty datosPerfil.usuario.nombre && not empty datosPerfil.usuario.apellidopaterno}">
                            <c:choose>
                                <c:when test="${fn:length(datosPerfil.usuario.nombre) > 0}">
                                    ${fn:substring(datosPerfil.usuario.nombre, 0, 1)}. ${datosPerfil.usuario.apellidopaterno}
                                </c:when>
                                <c:otherwise>
                                    ${datosPerfil.usuario.apellidopaterno}
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:when test="${not empty sessionScope.datosPerfil.usuario.nombre && not empty sessionScope.datosPerfil.usuario.apellidopaterno}">
                            <c:choose>
                                <c:when test="${fn:length(sessionScope.datosPerfil.usuario.nombre) > 0}">
                                    ${fn:substring(sessionScope.datosPerfil.usuario.nombre, 0, 1)}. ${sessionScope.datosPerfil.usuario.apellidopaterno}
                                </c:when>
                                <c:otherwise>
                                    ${sessionScope.datosPerfil.usuario.apellidopaterno}
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:when test="${not empty sessionScope.usuario.nombre && not empty sessionScope.usuario.apellidopaterno}">
                            <c:choose>
                                <c:when test="${fn:length(sessionScope.usuario.nombre) > 0}">
                                    ${fn:substring(sessionScope.usuario.nombre, 0, 1)}. ${sessionScope.usuario.apellidopaterno}
                                </c:when>
                                <c:otherwise>
                                    ${sessionScope.usuario.apellidopaterno}
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            ${sessionScope.nombre}
                        </c:otherwise>
                    </c:choose>
                </span>
                <i class="fas fa-chevron-down dropdown-arrow"></i>
                
                <!-- JavaScript alternativo para formatear el nombre -->
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        const userNameElement = document.getElementById('user-name-display');
                        if (userNameElement) {
                            let currentText = userNameElement.textContent.trim();
                            console.log('Texto actual del usuario:', currentText);
                            
                            // Si el texto actual es solo el nombre completo sin formato, intentar formatearlo
                            if (currentText && !currentText.includes('.') && currentText.split(' ').length >= 2) {
                                const parts = currentText.split(' ');
                                const firstName = parts[0];
                                const lastName = parts[parts.length - 1]; // Último apellido
                                
                                if (firstName && lastName && firstName.length > 0) {
                                    const formattedName = firstName.charAt(0).toUpperCase() + '. ' + lastName;
                                    userNameElement.textContent = formattedName;
                                    console.log('Nombre formateado con JS:', formattedName);
                                }
                            }
                        }
                    });
                </script>
                <div class="dropdown-menu">
                    <a href="VerPerfilServlet">Ver perfil</a>
                    <a href="CerrarSesionServlet">Cerrar sesión</a>
                </div>
            </div>
            <a href="InicioEncuestadorServlet" class="nav-item" id="btn-inicio">
                <img src="${pageContext.request.contextPath}/imagenes/inicio.png" alt="Icono de perfil" class="nav-icon" />
            </a>
        </nav>
    </div>
</header>

<!-- CONTENIDO PRINCIPAL -->
<main class="main-content">
    <div class="contenedor-grid">
        <c:choose>
            <c:when test="${empty formulariosAsignados}">
                <div style="
    margin: 2rem auto;
    padding: 2rem;
    max-width: 550px;
    background-color: #edf6ff;
    border: 1px solid #5e81ac;
    border-radius: 12px;
    text-align: center;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
">
                    <img src="${pageContext.request.contextPath}/imagenes/icono_info.png"
                         alt="Información" style="width: 48px; height: 48px; margin-bottom: 1rem;">
                    <p style="font-size: 1.1rem; color: #2e5c87;">
                        Aún no se te ha asignado ningún cuestionario.<br>
                        Cuando se te asigne uno, aparecerá aquí para ser respondido.
                    </p>
                </div>

            </c:when>
            <c:otherwise>
                <c:forEach var="asignacion" items="${formulariosAsignados}">
                    <section class="bloque-personalizado">
                        <div style="display: flex; justify-content: center; margin-bottom: 15px;">
                            <img src="imagenes/formulario_foto.png" alt="Foto de formulario" style="width: 150px; height: 150px; object-fit: cover; border: 1px solid #333;">
                        </div>
                        <div style="background-color: #ffffff; border: 1px solid #333; padding: 10px; margin-bottom: 15px; border-radius: 10px; text-align: center;">
                            <p style="margin: 0;">
                                    ${asignacion.formulario.titulo}
                            </p>
                        </div>
                        <div style="display: flex; justify-content: flex-end;">
                            <form action="RespuestaFormularioServlet" method="get">
                                <input type="hidden" name="idFormulario" value="${asignacion.formulario.idFormulario}" />
                                <input type="hidden" name="idAsignacionFormulario" value="${asignacion.idAsignacionFormulario}" />
                                <button type="submit" class="btn-respuesta">Crear Respuesta</button>
                            </form>
                        </div>
                    </section>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</main>

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
<style>
    /* RESET BÁSICO */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        background-color: #ffffff;
        color: #333;
    }
    :root {
        --color-primary: #3498db;
        --color-bg: #f5f7fa;
        --color-card: #c8dbff;
        --color-card-inner: #e6f0ff;
        --sidebar-bg: #e6f0ff;
        --header-bg: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
    }
    .menu-toggle {
        display: none;
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
    .menu-toggle:checked ~ .sidebar {
        left: 0;
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

    /* === HEADER === */
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
        margin-left: 4px;
        transition: transform 0.2s ease;
        color: #007bff;
    }
    .nav-item.dropdown-active .dropdown-arrow {
        transform: rotate(180deg);
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

    /* ================== CONTENIDO PRINCIPAL ================== */
    .main-content {
        width: 90%;
        max-width: 1200px;
        margin: 1rem auto;
        min-height: calc(100vh - 70px - 40px); /* Resta header y footer */
    }

    /* Sección de tarjetas estadísticas */
    .admin-stats {
        display: flex;
        flex-direction: column;
        gap: 1rem;
        margin-bottom: 1.5rem;
    }

    .stat-item {
        background-color: #dbeeff;
        padding: 1rem;
        border-radius: 6px;
        font-weight: bold;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .stat-title {
        font-size: 1rem;
    }

    .stat-value {
        font-size: 1rem;
        color: #333;
    }

    /* Sección de imagen grande */
    .admin-image {
        background-color: #f9f9f9;
        padding: 1rem;
        border-radius: 8px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }

    .large-image {
        display: block;
        width: 100%;
        height: auto;
        object-fit: cover;
        border-radius: 6px;
    }

    /* ================== PIE DE PÁGINA ================== */
    .footer-bar {
        height: 40px;
        background-color: #fff;
        border-top: 1px solid #ccc;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        margin-top: 1rem;
    }

    /* ================== RESPONSIVIDAD ================== */
    @media (max-width: 768px) {
        .header-content {
            flex-direction: column;
            height: auto;
            padding: 0.5rem 1rem;
            gap: 1rem;
            justify-content: center;
        }

        .header-left,
        .header-right {
            width: 100%;
            display: flex;
            justify-content: center;
        }

        .header-right {
            flex-wrap: wrap;
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .nav-icon {
            width: 30px;
            height: 30px;
        }

        .admin-stats {
            flex-direction: column;
            gap: 1rem;
        }

        /* Main content responsive */
        .main-content {
            width: 95%;
            margin: 0.5rem auto;
            padding: 0 10px;
        }

        .contenedor-grid {
            padding: 15px 10px;
        }

        /* Mensaje cuando no hay formularios */
        .contenedor-grid > div[style*="margin: 2rem auto"] {
            margin: 1rem auto !important;
            padding: 1.5rem !important;
            max-width: 90% !important;
        }

        .contenedor-grid img {
            width: 40px !important;
            height: 40px !important;
            margin-bottom: 0.8rem !important;
        }

        .contenedor-grid p {
            font-size: 1rem !important;
            line-height: 1.5 !important;
        }
    }

    @media (max-width: 480px) {
        .main-content {
            width: 98%;
            margin: 0.25rem auto;
            padding: 0 5px;
        }

        .header-bar {
            height: auto;
            min-height: 56px;
        }

        .header-content {
            padding: 0.75rem 0.5rem;
        }

        .logo-large img {
            height: 35px;
        }

        .nav-item#btn-encuestador span {
            font-size: 0.8rem;
        }

        .contenedor-grid {
            padding: 10px 5px;
        }

        /* Optimización para mensaje sin formularios */
        .contenedor-grid > div[style*="margin: 2rem auto"] {
            margin: 0.5rem auto !important;
            padding: 1.2rem 0.8rem !important;
            max-width: 95% !important;
            border-radius: 8px !important;
        }

        .contenedor-grid img {
            width: 35px !important;
            height: 35px !important;
            margin-bottom: 0.6rem !important;
        }

        .contenedor-grid p {
            font-size: 0.9rem !important;
            line-height: 1.4 !important;
        }

        /* Sidebar responsive */
        .sidebar {
            width: 260px;
            left: -260px;
        }

        .menu-toggle:checked ~ .sidebar {
            left: 0;
        }
    }

    .main-content {
        width: 90%;
        max-width: 1200px;
        margin: 1rem auto;
        min-height: calc(100vh - 70px - 40px); /* Considera header y footer */
    }

    /* Sección Encuestas Recientes y Historial */
    .section-encuestas,
    .section-historial {
        background-color: #f9f9f9;
        padding: 1rem;
        border-radius: 8px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        margin-bottom: 1.5rem;
    }

    .section-encuestas h2,
    .section-historial h2 {
        font-size: 1rem;
        margin-bottom: 0.5rem;
        font-weight: bold;
    }

    /* Tarjetas de Encuestas Recientes */
    .tablaresumen-container {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .secciones-item {
        background-color: #ffffff;
        border: 0.5px solid #ddd;
        border-radius: 6px;
        padding: 0.5rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .secciones-info {
        display: flex;
        flex-direction: column;
    }
    .secciones-titulo {
        font-weight: bold
    }
    .secciones-fecha {
        font-size: 0.9rem;
        color: #666;
    }

    .seccion-respuesta {
        padding: 0.5rem 1rem;
        background-color: #5e81ac;
        color: #fff;
        border: none;
        border-radius: 4px;
        font-weight: bold;
    }

    /* Botón Crear Respuesta */
    .btn-respuesta {
        padding: 0.5rem 1rem;
        background-color: #5e81ac;
        color: #fff;
        border: none;
        border-radius: 4px;
        font-weight: bold;
    }

    .btn-respuesta:hover {
        background-color: #4c669f;
    }

    /* Tarjetas de Historial de Formularios */
    .estadisticas-container {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    /* Paginación */
    .paginacion {
        margin-top: 1rem;
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 0.5rem;
    }

    .pag-arrow {
        background: none;
        border: none;
        font-size: 1.2rem;
        cursor: pointer;
        color: #5e81ac;
        transition: color 0.3s;
    }

    .pag-arrow:hover {
        color: #4c669f;
    }

    .pag-num {
        padding: 0.3rem 0.6rem;
        background-color: #fff;
        border: 1px solid #ccc;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.9rem;
        transition: background-color 0.3s;
    }

    .pag-num:hover {
        background-color: #eee;
    }

    /* ================== PIE DE PÁGINA ================== */
    /* .footer-bar {
      height: 40px;
      background-color: #ffffff;
      border-top: 1px solid #ccc;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
      margin-top: 1rem;
    } */

    /* ================== RESPONSIVIDAD ================== */
    @media (max-width: 768px) {
        .header-content {
            flex-direction: column;
            height: auto;
            padding: 0.5rem 1rem;
            gap: 1rem;
            justify-content: center;
        }

        .header-left,
        .header-right {
            width: 100%;
            display: flex;
            justify-content: center;
        }

        .header-right {
            flex-wrap: wrap;
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .nav-icon {
            width: 30px;
            height: 30px;
        }
    }

    /* ================== GRAFICOS ================== */
    body{
        background-color: #f4f7ff;
    }
    .board{
        margin: auto;
        width: 55%;
        height: 450px;
        background-color: #e2e2e2;
        padding: 10px;
        box-sizing: border-box;
        overflow: hidden;
    }
    .titulo_grafica{
        width: 100%;
        height: 10%;
    }
    .titulo_grafica>h3{
        padding: 0;
        margin: 0px;
        text-align: center;
        color: #666666;
    }
    .sub_board{
        width: 100%;
        height: 90%;
        padding: 10px;
        margin-top: 0px;
        background-color:#f4f4f4;
        overflow: hidden;
        box-sizing: border-box;
    }
    .sep_board{
        width: 100%;
        height: 10%;
    }
    .cont_board{
        width: 100%;
        height: 80%;
    }
    .graf_board{
        width: 85%;
        height: 100%;
        float: right;
        margin-top: 0px;
        background-color: darkgrey;
        border-left: 2px solid #999999;
        border-bottom: 2px solid #999999;
        box-sizing: border-box;
        display: flex;
        background: -moz-linear-gradient(top, rgba(0,0,0,0) 0%,
        rgba(0,0,0,0) 9.5%,  rgba(0,0,0,0.3) 10%, rgba(0,0,0,0) 10.5%,
        rgba(0,0,0,0) 19.5%, rgba(0,0,0,0.3) 20%, rgba(0,0,0,0) 20.5%,
        rgba(0,0,0,0) 29.5%, rgba(0,0,0,0.3) 30%, rgba(0,0,0,0) 30.5%,
        rgba(0,0,0,0) 39.5%, rgba(0,0,0,0.3) 40%, rgba(0,0,0,0) 40.5%,
        rgba(0,0,0,0) 49.5%, rgba(0,0,0,0.3) 50%, rgba(0,0,0,0) 50.5%,
        rgba(0,0,0,0) 59.5%, rgba(0,0,0,0.3) 60%, rgba(0,0,0,0) 60.5%,
        rgba(0,0,0,0) 69.5%, rgba(0,0,0,0.3) 70%, rgba(0,0,0,0) 70.5%,
        rgba(0,0,0,0) 79.5%, rgba(0,0,0,0.3) 80%, rgba(0,0,0,0) 80.5%,
        rgba(0,0,0,0) 89.5%, rgba(0,0,0,0.3) 90%, rgba(0,0,0,0) 90.5%,
        rgba(0,0,0,0) 100%);

        background: -webkit-linear-gradient(top, rgba(0,0,0,0) 0%,
        rgba(0,0,0,0) 9.5%,  rgba(0,0,0,0.3) 10%, rgba(0,0,0,0) 10.5%,
        rgba(0,0,0,0) 19.5%, rgba(0,0,0,0.3) 20%, rgba(0,0,0,0) 20.5%,
        rgba(0,0,0,0) 29.5%, rgba(0,0,0,0.3) 30%, rgba(0,0,0,0) 30.5%,
        rgba(0,0,0,0) 39.5%, rgba(0,0,0,0.3) 40%, rgba(0,0,0,0) 40.5%,
        rgba(0,0,0,0) 49.5%, rgba(0,0,0,0.3) 50%, rgba(0,0,0,0) 50.5%,
        rgba(0,0,0,0) 59.5%, rgba(0,0,0,0.3) 60%, rgba(0,0,0,0) 60.5%,
        rgba(0,0,0,0) 69.5%, rgba(0,0,0,0.3) 70%, rgba(0,0,0,0) 70.5%,
        rgba(0,0,0,0) 79.5%, rgba(0,0,0,0.3) 80%, rgba(0,0,0,0) 80.5%,
        rgba(0,0,0,0) 89.5%, rgba(0,0,0,0.3) 90%, rgba(0,0,0,0) 90.5%,
        rgba(0,0,0,0) 100%);

        background: linear-gradient(to bottom, rgba(0,0,0,0) 0%,
        rgba(0,0,0,0) 9.5%,  rgba(0,0,0,0.3) 10%, rgba(0,0,0,0) 10.5%,
        rgba(0,0,0,0) 19.5%, rgba(0,0,0,0.3) 20%, rgba(0,0,0,0) 20.5%,
        rgba(0,0,0,0) 29.5%, rgba(0,0,0,0.3) 30%, rgba(0,0,0,0) 30.5%,
        rgba(0,0,0,0) 39.5%, rgba(0,0,0,0.3) 40%, rgba(0,0,0,0) 40.5%,
        rgba(0,0,0,0) 49.5%, rgba(0,0,0,0.3) 50%, rgba(0,0,0,0) 50.5%,
        rgba(0,0,0,0) 59.5%, rgba(0,0,0,0.3) 60%, rgba(0,0,0,0) 60.5%,
        rgba(0,0,0,0) 69.5%, rgba(0,0,0,0.3) 70%, rgba(0,0,0,0) 70.5%,
        rgba(0,0,0,0) 79.5%, rgba(0,0,0,0.3) 80%, rgba(0,0,0,0) 80.5%,
        rgba(0,0,0,0) 89.5%, rgba(0,0,0,0.3) 90%, rgba(0,0,0,0) 90.5%,
        rgba(0,0,0,0) 100%);

        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#00ffffff', endColorstr='#00ffffff',GradientType=0 );
    }
    .barra{
        width:100%;
        height: 100%;
        margin-right: 15px;
        margin-left: 15px;
        background-color: none;
        display: flex;
        flex-wrap: wrap;
        align-items: flex-end;
    }
    .sub_barra{
        width: 100%;
        height: 80%;
        background: #00799b;
        background: -moz-linear-gradient(top, #00799b 0%, #64d1be 100%);
        background: -webkit-linear-gradient(top, #00799b 0%,#64d1be 100%);
        background: linear-gradient(to bottom, #00799b 0%,#64d1be 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#00799b', endColorstr='#64d1be',GradientType=0 );

        -webkit-border-radius: 3px 3px 0 0;
        border-radius: 3px 3px 0 0;
    }
    .tag_g{
        position: relative;
        width: 100%;
        height: 100%;
        margin-bottom: 30px;
        text-align: center;
        margin-top: -20px;
        z-index: 2;
    }
    .tag_leyenda{
        width: 100%;
        text-align: center;
        margin-top: 5px;
    }
    .tag_board{
        height: 100%;
        width: 15%;
        border-bottom: 2px solid rgba(0,0,0,0);
        box-sizing: border-box;
    }
    .sub_tag_board{
        height: 100%;
        width: 100%;
        display: flex;
        align-items: flex-end;
        flex-wrap: wrap;
    }
    .sub_tag_board>div{
        width: 100%;
        height: 10%;
        text-align: right;
        padding-right: 10px;
        box-sizing: border-box;
    }
    .b1{ height: 35%}
    .b2{ height: 45%}
    .b3{ height: 55%}
    .b4{ height: 75%}
    .b5{ height: 85%}
    footer{
        position: absolute;
        bottom: 0px;
        width: 100%;
        text-align: center;
        font-size: 12px;
        font-family: sans-serif;
    }

    /* === ESTILOS AÑADIDOS PARA ENCUESTADOR === */
    .encuestas-container {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .encuesta-item {
        background-color: #ffffff;
        border: 1px solid #ddd;
        border-radius: 6px;
        padding: 1rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .encuesta-info {
        display: flex;
        flex-direction: column;
    }

    .encuesta-titulo {
        font-weight: bold;
    }

    .encuesta-fecha {
        font-size: 0.9rem;
        color: #666;
    }

    .historial-container {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .formulario-item {
        background-color: #ffffff;
        border: 1px solid #ddd;
        border-radius: 6px;
        padding: 1rem;
        display: grid;
        grid-template-columns: 1fr auto;
        grid-template-rows: auto auto;
        gap: 0.5rem;
        align-items: center;
    }

    .formulario-info {
        grid-column: 1 / 2;
        grid-row: 1 / 2;
    }

    .formulario-titulo {
        font-weight: bold;
    }

    .formulario-fecha {
        font-size: 0.9rem;
        color: #666;
    }

    .barra-progreso {
        grid-column: 1 / 2;
        grid-row: 2 / 3;
        width: 80%;
        height: 8px;
        background-color: #e4e4e4;
        border-radius: 4px;
        overflow: hidden;
        margin-top: 0.3rem;
    }

    .barra-llenado {
        width: 30%;
        height: 100%;
        background-color: #5e81ac;
        border-radius: 4px 0 0 4px;
    }

    .btn-reingresar {
        text-decoration: none;
        display: inline-block;
        grid-column: 2 / 3;
        grid-row: 1 / 3;
        align-self: center;
        padding: 0.5rem 1rem;
        background-color: #5e81ac;
        color: #fff;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-weight: bold;
        font-size: 13.3px;
        transition: background-color 0.3s;
    }

    .btn-respuesta {
        text-decoration: none;
        display: inline-block;
        padding: 0.5rem 1rem;
        background-color: #5e81ac;
        color: #fff;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-weight: bold;
        transition: background-color 0.3s;
        font-size: 13.3px;
    }




</style>
</body>
</html>

