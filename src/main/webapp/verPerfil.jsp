<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page session="true" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Intranet - Ver Perfil</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        /* RESET BÁSICO */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #e6f0ff 0%, #b3ccff 100%);
            margin: 0;
            padding: 0;
            color: #333;
        }
        /* --- Sidebar estilo dashboardAdmin.jsp --- */
        :root {
            --color-primary: #3498db;
            --color-bg: #f5f7fa;
            --color-card: #c8dbff;
            --color-card-inner: #e6f0ff;
            --sidebar-bg: #e6f0ff;
            --header-bg: #dbeeff;
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
            transition: left 0.3s ease, box-shadow 0.2s; /* igual que dashboardAdmin */
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

        /* ================== CONTENIDO PRINCIPAL ================== */
        .main-content {
            width: 90%;
            max-width: 1200px;
            margin: 1.5rem auto;
            padding-bottom: 1.5rem;
            text-align: center;
        }

        .main-content h2 {
            margin-bottom: 1.5rem;
            font-size: 1.5rem;
            font-weight: bold;
            color: #007bff;
        }

        /* ================== INTERFAZ "VER PERFIL" ================== */
        .profile-container {
            background-color: #f5f5f5;
            margin: 0 auto;
            max-width: 800px;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            text-align: left;
        }

        .profile-header {
            display: flex;
            align-items: center;
            gap: 1.5rem;
            margin-bottom: 1.2rem;
        }

        .profile-photo {
            position: relative;
            display: inline-block;
        }

        .profile-photo img {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            background-color: #ccc;
            display: block;
        }

        .change-photo-btn {
            position: absolute;
            bottom: 10px;
            right: 10px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            font-size: 1.2rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 100;
            box-shadow: 0 2px 8px rgba(0, 123, 255, 0.3);
            transition: all 0.3s ease;
        }

        .change-photo-btn:hover {
            background-color: #0056b3;
            transform: scale(1.1);
            box-shadow: 0 4px 12px rgba(0, 123, 255, 0.4);
        }

        .change-photo-btn:active {
            transform: scale(0.95);
        }

        .profile-info h3 {
            margin-bottom: 0.5rem;
            font-size: 1.8rem;
            color: #007bff;
        }

        .profile-info p {
            margin: 0.3rem 0;
            font-size: 1rem;
        }

        .profile-details {
            margin-top: 1.5rem;
        }

        .profile-row {
            display: flex;
            margin-bottom: 0.8rem;
            padding-bottom: 0.8rem;
            border-bottom: 1px solid #e0e0e0;
        }

        .profile-label {
            flex: 0 0 200px;
            font-weight: bold;
            color: #555;
        }

        .profile-value {
            flex: 1;
        }

        .profile-value input {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .profile-actions {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            margin-top: 1.5rem;
        }

        .btn-edit, .btn-change-password {
            padding: 0.8rem 1.5rem;
            font-size: 1rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
            font-family: inherit;
            background-color: #3b82f6;
            color: #fff;
            border: 1px solid #3b82f6;
        }

        .btn-edit {
            background-color: #3b82f6;
            color: #fff;
            border: 1px solid #3b82f6;
        }

        .btn-edit:hover {
            background-color: #2563eb;
            border-color: #2563eb;
        }

        .btn-change-password {
            background-color: #3b82f6;
            color: #fff;
            border: 1px solid #3b82f6;
        }

        .btn-change-password:hover {
            background-color: #2563eb;
            border-color: #2563eb;
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

            /* Logo responsivo para tablets */
            .logo-large img {
                height: 35px;
            }

            /* Main content responsive */
            .main-content {
                width: 95%;
                margin: 1rem auto;
                padding: 0 10px;
            }

            .main-content h2 {
                font-size: 1.3rem;
                margin-bottom: 1.5rem;
            }

            /* Profile container responsive */
            .profile-container {
                padding: 1.5rem;
                margin: 0 auto;
            }

            .profile-header {
                flex-direction: column;
                align-items: center;
                gap: 1rem;
                margin-bottom: 1.2rem;
            }

            .profile-photo img {
                width: 120px;
                height: 120px;
            }

            .change-photo-btn {
                width: 35px;
                height: 35px;
                font-size: 1rem;
            }

            .profile-info h3 {
                font-size: 1.5rem;
                text-align: center;
                margin-bottom: 0.3rem;
            }

            .profile-info p {
                font-size: 0.9rem;
                margin: 0.2rem 0;
                text-align: center;
            }

            /* Profile details responsive */
            .profile-row {
                flex-direction: column;
                margin-bottom: 1rem;
                padding-bottom: 1rem;
            }

            .profile-label {
                flex: none;
                margin-bottom: 0.5rem;
                font-weight: bold;
                font-size: 0.95rem;
            }

            .profile-value {
                flex: none;
            }

            .profile-value input,
            .profile-static,
            .profile-input,
            .form-select {
                font-size: 0.95rem;
                padding: 0.6rem;
                min-height: 44px;
            }

            /* Actions responsive */
            .profile-actions {
                flex-direction: column;
                gap: 0.8rem;
                margin-top: 1.2rem;
            }

            .btn-edit, .btn-change-password {
                width: 100%;
                padding: 0.8rem;
                font-size: 0.95rem;
            }
        }

        @media (max-width: 480px) {
            /* Header para móviles pequeños */
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

            /* Ocultar logo en móviles */
            .logo-section {
                display: none;
            }

            /* Main content para móviles pequeños */
            .main-content {
                width: 98%;
                margin: 0.5rem auto;
                padding: 0 5px;
            }

            .main-content h2 {
                font-size: 1.2rem;
                margin-bottom: 1rem;
            }

            /* Profile container para móviles pequeños */
            .profile-container {
                padding: 1rem;
                border-radius: 6px;
            }

            .profile-header {
                gap: 0.8rem;
                margin-bottom: 1rem;
            }

            .profile-photo img {
                width: 100px;
                height: 100px;
            }

            .change-photo-btn {
                width: 30px;
                height: 30px;
                font-size: 0.9rem;
                bottom: 5px;
                right: 5px;
            }

            .profile-info h3 {
                font-size: 1.3rem;
            }

            .profile-info p {
                font-size: 0.85rem;
            }

            /* Profile details para móviles pequeños */
            .profile-details {
                margin-top: 1rem;
            }

            .profile-row {
                margin-bottom: 0.8rem;
                padding-bottom: 0.8rem;
            }

            .profile-label {
                font-size: 0.9rem;
                margin-bottom: 0.4rem;
            }

            .profile-value input,
            .profile-static,
            .profile-input,
            .form-select {
                font-size: 0.9rem;
                padding: 0.6rem;
                min-height: 42px;
            }

            /* Actions para móviles pequeños */
            .profile-actions {
                gap: 0.6rem;
                margin-top: 1rem;
            }

            .btn-edit, .btn-change-password {
                padding: 0.7rem;
                font-size: 0.9rem;
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

        .form-select {
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            width: 100%;
            background-color: #f8fbff;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            padding: 0.7rem 2.5rem 0.7rem 1rem;
            font-size: 1rem;
            color: #333;
            font-weight: 500;
            transition: border-color 0.3s, box-shadow 0.3s;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23666' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 1rem center;
            background-size: 1.3rem;
            box-sizing: border-box;
            min-height: 48px;
        }

        .form-select:focus {
            border-color: #999;
            outline: none;
        }

        /* Mejora visual para los campos de perfil */
        .profile-static {
            display: block;
            width: 100%;
            padding: 0.7rem 1rem;
            background: #e8e8e8;
            border-radius: 6px;
            border: 1px solid #d0d0d0;
            font-size: 1rem;
            color: #666;
            box-sizing: border-box;
            min-height: 48px;
            line-height: 1.4;
        }
        .profile-input {
            width: 100%;
            background: #f8fbff;
            border: 2px solid #007bff;
            border-radius: 8px;
            padding: 0.7rem 1rem;
            font-size: 1rem;
            color: #333;
            font-weight: 500;
            box-shadow: 0 2px 8px rgba(0,123,255,0.07);
            transition: border-color 0.3s, box-shadow 0.3s;
            box-sizing: border-box;
            min-height: 48px;
        }
        .profile-input:focus {
            border-color: #0056b3;
            box-shadow: 0 0 0 0.2rem rgba(0,123,255,0.15);
            outline: none;
        }

        /* ================== HEADER CSS ================== */
        .header-bar {
            /* background-color: var(--header-bg);*/
            background: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
            height: 56.8px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
        
        /* Iconos de Inicio y Encuestador */
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
        
        /* Texto debajo de inicio quitado */
        .nav-item#btn-inicio span {
            display: none;
        }
        
        /* Texto a la izquierda del ícono encuestador */
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
        
        /* Dropdown menu para botón Encuestador */
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
            min-height: calc(100vh - 70px - 40px);
        }

    </style>
</head>
<body>
<input type="checkbox" id="menu-toggle" class="menu-toggle" />
<div class="sidebar">
    <div class="sidebar-content">
        <button class="sidebar-close-btn" onclick="document.getElementById('menu-toggle').checked = false;">×</button>
        <div class="sidebar-separator"></div>
        <ul class="menu-links">
            <c:choose>
                <c:when test="${datosPerfil.nombreRol == 'Administrador'}">
                    <li><a href="InicioAdminServlet"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
                    <li><a href="CrearUsuarioServlet"><i class="fa-solid fa-user-plus"></i> Crear nuevo usuario</a></li>
                    <li><a href="GestionarCoordinadoresServlet"><i class="fa-solid fa-user-tie"></i> Gestionar Coordinadores</a></li>
                    <li><a href="GestionarEncuestadoresServlet"><i class="fa-solid fa-user"></i> Gestionar Encuestadores</a></li>
                    <li><a href="GenerarReportesServlet"><i class="fa-solid fa-file-lines"></i> Generar reportes</a></li>
                </c:when>
                <c:when test="${datosPerfil.nombreRol == 'Coordinador Interno'}">
                    <li><a href="DashboardServlet"><i class="fa-solid fa-chart-line"></i> Ver Dashboard</a></li>
                    <li><a href="GestionEncuestadoresServlet"><i class="fa-solid fa-users"></i> Gestionar Encuestadores</a></li>
                    <li><a href="GestionarFormulariosServlet"><i class="fa-solid fa-file-alt"></i> Gestionar Formularios</a></li>
                </c:when>
                <c:when test="${datosPerfil.nombreRol == 'Encuestador'}">
                    <li>
                        <a href="InicioEncuestadorServlet">
                            <i class="fa-solid fa-chart-line"></i>
                            Ver Dashboard
                        </a>
                    </li>
                    <li>
                        <a href="FormulariosAsignadosServlet">
                            <i class="fa-solid fa-list-check"></i>
                            Ver formularios asignados
                        </a>
                    </li>
                    <li>
                        <a href="HistorialFormulariosServlet">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                            Ver historial de formulario
                        </a>
                    </li>
                </c:when>
            </c:choose>
            <li>
                <a href="CerrarSesionServlet">
                    <i class="fa-solid fa-sign-out-alt"></i>
                    Cerrar sesión
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
                <span>
                    <c:choose>
                        <c:when test="${not empty datosPerfil.usuario.nombre}">
                            ${datosPerfil.usuario.nombre}
                        </c:when>
                        <c:otherwise>
                            ${sessionScope.nombre}
                        </c:otherwise>
                    </c:choose>
                </span>
                <span class="dropdown-arrow">▼</span>
                <div class="dropdown-menu">
                    <a href="VerPerfilServlet">Ver perfil</a>
                    <a href="CerrarSesionServlet">Cerrar sesión</a>
                </div>
            </div>
        </nav>
    </div>
</header>

<!------------------------------------------------------------------------------------------------------------------------------------->
<!-- CONTENIDO PRINCIPAL: Interfaz de Ver Perfil -->
<main class="main-content">
    <!-- Mensajes de éxito/error (mantén esto) -->
    <c:if test="${not empty sessionScope.mensajeExito}">
    <div class="alert alert-success">
            ${sessionScope.mensajeExito}
        <% session.removeAttribute("mensajeExito"); %>
    </div>
    </c:if>

    <c:if test="${not empty sessionScope.mensajeError}">
    <div class="alert alert-danger">
            ${sessionScope.mensajeError}
        <% session.removeAttribute("mensajeError"); %>
    </div>
    </c:if>

    <h2>PERFIL DEL USUARIO</h2>

    <form id="perfil-form" method="POST" action="${pageContext.request.contextPath}/ActualizarPerfilServlet" enctype="multipart/form-data">
        <div class="profile-container">
            <!-- Sección de foto de perfil con vista previa -->
            <div class="profile-header">
                <div class="profile-photo">
                    <c:choose>
                        <c:when test="${not empty datosPerfil.usuario.foto}">
                            <img id="user-photo"
                                 src="data:image/jpeg;base64,${datosPerfil.usuario.foto}"
                                 alt="Foto de usuario"
                                 onerror="this.src='${pageContext.request.contextPath}/imagenes/usuario.png'">
                        </c:when>
                        <c:otherwise>
                            <img id="user-photo"
                                 src="${pageContext.request.contextPath}/imagenes/usuario.png"
                                 alt="Foto de usuario">
                        </c:otherwise>
                    </c:choose>

                    <input type="file" id="file-input" name="fotoPerfil" accept="image/*,.jpg,.jpeg,.png,.gif,.bmp,.webp" style="display: none;">
                    <button type="button" class="change-photo-btn" id="trigger-file-input">+</button>
                </div>
                <div class="profile-info">
                    <h2>${nombreCompleto}</h2>
                    <p><strong>Rol:</strong> ${datosPerfil.nombreRol}</p>
                    <p><strong>Último acceso:</strong>
                        <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %>
                    </p>
                </div>
            </div>

            <div class="profile-details">
                <!-- Campos no editables -->
                <div class="profile-row">
                    <div class="profile-label">Nombres:</div>
                    <div class="profile-value">
                        <span class="profile-static">${datosPerfil.usuario.nombre}</span>
                    </div>
                </div>
                <div class="profile-row">
                    <div class="profile-label">Apellido Paterno:</div>
                    <div class="profile-value">
                        <span class="profile-static">${datosPerfil.usuario.apellidopaterno}</span>
                    </div>
                </div>
                <div class="profile-row">
                    <div class="profile-label">Apellido Materno:</div>
                    <div class="profile-value">
                        <span class="profile-static">${datosPerfil.usuario.apellidomaterno}</span>
                    </div>
                </div>
                <div class="profile-row">
                    <div class="profile-label">DNI:</div>
                    <div class="profile-value">
                        <span class="profile-static">${datosPerfil.usuario.dni}</span>
                    </div>
                </div>

                <!-- Campos editables -->
                <div class="profile-row">
                    <div class="profile-label">Dirección:</div>
                    <div class="profile-value">
                        <input type="text" name="direccion" value="${datosPerfil.usuario.direccion}" required class="profile-input">
                    </div>
                </div>

                <div class="profile-row">
                    <div class="profile-label">Zona:</div>
                    <div class="profile-value">
                        <select name="idZona" id="zona-select" class="form-select" required>
                            <c:forEach var="zona" items="${zonas}">
                                <option value="${zona.idZona}" ${zona.idZona == datosPerfil.idZona ? 'selected' : ''}>
                                        ${zona.nombreZona}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="profile-row">
                    <div class="profile-label">Distrito:</div>
                    <div class="profile-value">
                        <select name="idDistrito" id="distrito-select" class="form-select" required>
                            <c:forEach items="${distritos}" var="distrito">
                                <option value="${distrito.idDistrito}"
                                        data-zona="${distrito.idZona}"
                                    ${distrito.idDistrito == datosPerfil.usuario.idDistrito ? 'selected' : ''}>
                                        ${distrito.nombreDistrito}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="profile-row">
                    <div class="profile-label">Correo electrónico:</div>
                    <div class="profile-value">
                        <span class="profile-static">${datosPerfil.correo}</span>
                    </div>
                </div>
            </div>


            <div class="profile-actions">
                <button type="button" class="btn-change-password" onclick="window.location.href='CambiarContrasenhaServlet'">Cambiar Contraseña</button>
                <button type="submit" class="btn-edit">Guardar Cambios</button>
            </div>
        </div>
    </form>

</main>

    <script>
        // === FUNCIONES UTILITARIAS ===
        function cerrarPopupError() {
            document.getElementById('popup-error').style.display = 'none';
        }

        function mostrarErrorImagen(tamaño) {
            const popup = document.getElementById('popup-error');
            const sizeText = document.getElementById('popup-error-size');
            sizeText.textContent = 'Tamaño actual: ' + (tamaño / (1024 * 1024)).toFixed(2) + ' MB';
            popup.style.display = 'flex';
        }

        // === INICIALIZACIÓN ===
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Página cargada, iniciando configuraciones...');
            
            // === CONFIGURAR BOTÓN DE FOTO ===
            const fileInput = document.getElementById('file-input');
            const photoBtn = document.getElementById('trigger-file-input');
            
            console.log('DEBUG: fileInput =', fileInput);
            console.log('DEBUG: photoBtn =', photoBtn);
            
            if (fileInput && photoBtn) {
                console.log('Configurando funcionalidad de foto...');
                
                // Verificar que el botón es realmente clickeable
                const computedStyle = window.getComputedStyle(photoBtn);
                console.log('DEBUG: Estilos del botón:');
                console.log('- pointer-events:', computedStyle.pointerEvents);
                console.log('- z-index:', computedStyle.zIndex);
                console.log('- position:', computedStyle.position);
                console.log('- display:', computedStyle.display);
                
                // Evento para selección de archivo
                fileInput.addEventListener('change', function(e) {
                    const file = e.target.files[0];
                    if (file) {
                        console.log('Archivo seleccionado:', file.name);
                        console.log('Tipo de archivo:', file.type);
                        console.log('Tamaño del archivo:', file.size, 'bytes');
                        
                        // Lista de tipos de imagen válidos (más permisiva)
                        const tiposValidos = [
                            'image/jpeg',
                            'image/jpg', 
                            'image/png',
                            'image/gif',
                            'image/bmp',
                            'image/webp',
                            'image/svg+xml'
                        ];
                        
                        // Verificar por extensión también (backup)
                        const extension = file.name.toLowerCase().split('.').pop();
                        const extensionesValidas = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
                        
                        // Validación más flexible
                        const esImagenPorTipo = file.type && (file.type.startsWith('image/') || tiposValidos.includes(file.type));
                        const esImagenPorExtension = extensionesValidas.includes(extension);
                        
                        console.log('Es imagen por tipo MIME:', esImagenPorTipo);
                        console.log('Es imagen por extensión:', esImagenPorExtension);
                        
                        if (!esImagenPorTipo && !esImagenPorExtension) {
                            alert('Por favor seleccione un archivo de imagen válido (JPEG, PNG, GIF, BMP, WebP).\nArchivo detectado: ' + file.type + '\nExtensión: ' + extension);
                            this.value = '';
                            return;
                        }
                        
                        // Verificar tamaño del archivo
                        const maxSize = 5 * 1024 * 1024; // 5MB
                        console.log('Tamaño máximo permitido:', maxSize, 'bytes');
                        console.log('Tamaño del archivo:', file.size, 'bytes');
                        console.log('Archivo dentro del límite:', file.size <= maxSize);
                        
                        if (file.size > maxSize) {
                            console.log('ERROR: Archivo muy grande');
                            mostrarErrorImagen(file.size);
                            this.value = '';
                            return;
                        }
                        
                        // Si todo está bien, mostrar vista previa
                        console.log('Archivo válido, generando vista previa...');
                        const reader = new FileReader();
                        reader.onload = function(event) {
                            console.log('Vista previa cargada correctamente');
                            document.getElementById('user-photo').src = event.target.result;
                        };
                        reader.onerror = function(error) {
                            console.error('Error al cargar la vista previa:', error);
                            alert('Error al cargar la vista previa del archivo');
                        };
                        reader.readAsDataURL(file);
                    }
                });

                // LIMPIAR EVENTOS PREVIOS
                photoBtn.onclick = null;
                photoBtn.removeEventListener('click', arguments.callee);

                // Evento ÚNICO para botón de foto
                photoBtn.addEventListener('click', function(e) {
                    console.log('🔥 BOTÓN CLICKEADO - EVENTO ACTIVADO');
                    e.preventDefault();
                    e.stopPropagation();
                    
                    console.log('Activando file input...');
                    fileInput.click();
                    console.log('File input clickeado');
                    
                    return false;
                });

                // También agregar evento de mousedown como alternativa
                photoBtn.addEventListener('mousedown', function(e) {
                    console.log('🔥 MOUSEDOWN en botón de foto');
                });

                // Forzar estilos del botón para garantizar que sea clickeable
                photoBtn.style.pointerEvents = 'auto';
                photoBtn.style.cursor = 'pointer';
                photoBtn.style.zIndex = '1000';
                photoBtn.style.position = 'absolute';
                photoBtn.style.userSelect = 'none';
                
                // Test: agregar evento de hover para verificar que funciona
                photoBtn.addEventListener('mouseenter', function() {
                    console.log('🔥 HOVER: Mouse sobre el botón');
                });
                
                photoBtn.addEventListener('mouseleave', function() {
                    console.log('🔥 HOVER: Mouse fuera del botón');
                });
                
                console.log('Botón de foto configurado correctamente');
                
                // Test final: verificar que el elemento es clickeable
                setTimeout(() => {
                    const rect = photoBtn.getBoundingClientRect();
                    console.log('DEBUG: Posición del botón:', {
                        top: rect.top,
                        left: rect.left,
                        width: rect.width,
                        height: rect.height,
                        visible: rect.width > 0 && rect.height > 0
                    });
                }, 1000);
                
            } else {
                console.error('ERROR: No se encontraron elementos de foto');
                if (!fileInput) console.error('- fileInput no encontrado');
                if (!photoBtn) console.error('- photoBtn no encontrado');
            }
            
            // === CONFIGURAR ZONA/DISTRITO ===
            const zonaSelect = document.getElementById('zona-select');
            const distritoSelect = document.getElementById('distrito-select');
            
            if (zonaSelect && distritoSelect) {
                function filterDistritosByZona() {
                    const selectedZona = zonaSelect.value;
                    Array.from(distritoSelect.options).forEach(option => {
                        if (!option.value) return;
                        const zonaId = option.getAttribute('data-zona');
                        option.style.display = (zonaId === selectedZona) ? '' : 'none';
                    });
                }
                
                zonaSelect.addEventListener('change', filterDistritosByZona);
                filterDistritosByZona(); // Ejecutar al inicio
            }
            
            // === CONFIGURAR DROPDOWN USUARIO ===
            const btnEncuestador = document.getElementById('btn-encuestador');
            if (btnEncuestador) {
                btnEncuestador.addEventListener('click', function() {
                    this.classList.toggle('dropdown-active');
                });
                
                document.addEventListener('click', function(e) {
                    if (!btnEncuestador.contains(e.target)) {
                        btnEncuestador.classList.remove('dropdown-active');
                    }
                });
            }
        });

        // === ENVÍO DEL FORMULARIO ===
        window.addEventListener('load', function() {
            const form = document.getElementById('perfil-form');
            if (form) {
                form.addEventListener('submit', function(e) {
                    e.preventDefault();
                    
                    console.log('=== DEBUG ENVÍO FORMULARIO ===');
                    
                    const fileInput = document.getElementById('file-input');
                    
                    // Verificar si hay archivo seleccionado ANTES de crear FormData
                    if (fileInput.files.length > 0) {
                        const file = fileInput.files[0];
                        const maxSize = 5 * 1024 * 1024; // 5MB
                        
                        console.log('Archivo pre-envío:');
                        console.log('- Nombre:', file.name);
                        console.log('- Tamaño:', file.size, 'bytes');
                        console.log('- Tipo:', file.type);
                        console.log('- Máximo permitido:', maxSize, 'bytes');
                        
                        if (file.size > maxSize) {
                            console.log('ERROR: Archivo muy grande');
                            mostrarErrorImagen(file.size);
                            return;
                        }
                        
                        console.log('✅ Archivo válido, continuando con envío...');
                    } else {
                        console.log('ℹ️ No se seleccionó archivo (solo actualizar datos)');
                    }
                    
                    // Debug: mostrar datos del formulario DESPUÉS de validación
                    const formData = new FormData(form);
                    console.log('FormData final:');
                    for (let [key, value] of formData.entries()) {
                        if (key === 'fotoPerfil' && value instanceof File && value.size > 0) {
                            console.log('📸 ' + key + ': ' + value.name + ' (' + value.size + ' bytes, ' + value.type + ')');
                        } else if (key === 'fotoPerfil') {
                            console.log('📸 ' + key + ': (sin archivo - ' + value + ')');
                        } else {
                            console.log('📝 ' + key + ': ' + value);
                        }
                    }
                    
                    // Mostrar popup y enviar
                    const popup = document.getElementById('popup-exito');
                    popup.style.display = 'flex';
                    
                    setTimeout(function() {
                        popup.style.display = 'none';
                        console.log('🚀 Enviando formulario al servidor...');
                        
                        // Enviar el formulario directamente sin preventDefault adicional
                        form.removeEventListener('submit', arguments.callee);
                        form.submit();
                    }, 1000); // Reducir tiempo a 1 segundo
                });
            }
        });
    </script>

    <!-- Popup para éxito -->
    <div id="popup-exito" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.35); z-index:9999; align-items:center; justify-content:center;">
        <div style="background:#fff; padding:2rem 2.5rem; border-radius:10px; box-shadow:0 2px 10px rgba(0,0,0,0.2); text-align:center;">
            <h3 style="color:#28a745; margin-bottom:1rem;">¡Datos Cambiados!</h3>
            <p>Los datos del perfil se actualizaron correctamente.</p>
        </div>
    </div>

    <!-- Popup para error de imagen -->
    <div id="popup-error" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.5); z-index:10000; align-items:center; justify-content:center;">
        <div style="background:#fff; padding:2.5rem; border-radius:12px; box-shadow:0 4px 20px rgba(0,0,0,0.3); text-align:center; max-width:400px; margin:20px;">
            <div style="color:#dc3545; font-size:3rem; margin-bottom:1rem;">⚠️</div>
            <h3 style="color:#dc3545; margin-bottom:1.5rem; font-size:1.4rem;">Imagen muy pesada</h3>
            <p style="margin-bottom:1rem; line-height:1.6; color:#333;">
                El tamaño máximo permitido es de <strong>5MB</strong>
            </p>
            <p id="popup-error-size" style="margin-bottom:2rem; color:#666; font-size:0.9rem;"></p>
            <button onclick="cerrarPopupError()" style="background:#dc3545; color:white; border:none; padding:0.8rem 2rem; border-radius:6px; cursor:pointer; font-weight:bold; font-size:1rem;">
                Entendido
            </button>
        </div>
    </div>

</body>
</html>
