<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">

    <title>Crear Coordinador Interno</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
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
        html, body {
            height: 100%;
            min-height: 100vh;
            background: #fff !important;
            margin: 0;
            padding: 0;
            color: #333;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        .menu-toggle:checked ~ .sidebar { left: 0; }
        .menu-toggle:checked ~ .overlay { display: block; opacity: 1; }
        /* Fix: NO empujar el contenido al abrir sidebar */
        /* .menu-toggle:checked ~ .contenedor-principal { margin-left: 280px; } */
        .contenedor-principal {
            width: 100vw;
            min-height: 100vh;
            margin: 0;
            padding: 0;
            background: #fff;
            box-sizing: border-box;
            display: flex;
            align-items: center; /* Centra verticalmente */
            justify-content: center;
        }
        /* Sidebar y header igual que dashboardAdmin.jsp */
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
        .sidebar-close {
            position: absolute;
            top: 15px;
            right: 15px;
            width: 30px;
            height: 30px;
            background: rgba(255, 255, 255, 0.2);
            border: none;
            border-radius: 50%;
            color: #333;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
            z-index: 2002;
        }
        .sidebar-close:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.1);
        }
        .sidebar-content {
            height: 100%;
            display: flex;
            flex-direction: column;
            gap: 18px;
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
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            letter-spacing: 0.01em;
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
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15), 0 2px 4px rgba(0, 0, 0, 0.1);
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            padding: 0;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            font-weight: bold;
            letter-spacing: 0.01em;
            z-index: 9999;
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
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
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
        /* ----------- Formulario Mejorado: más grande, sin scroll ----------- */
        .crear-coordinador-wrapper {
            background: #fff;
            border-radius: 0;
            box-shadow: none;
            border: none;
            width: 100vw;
            max-width: 100vw;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center; /* Centra verticalmente */
            justify-content: center;
        }
        .crear-coordinador-form {
            background: #fff;
            box-shadow: none;
            border-radius: 0;
            border: none;
            width: 100%;
            max-width: 1100px;
            margin: 0 auto;
            padding: 36px 48px 36px 48px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 26px 36px;
            align-items: start;
            min-height: unset;
            margin-top: 38px;
        }
        .form-section {
            display: contents;
        }
        .section-title {
            grid-column: 1 / -1;
            margin-bottom: 12px;
            font-size: 1.1em;
            font-weight: bold;
            color: #222;
            letter-spacing: 0.5px;
            text-align: left;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .section-title i {
            color: #888;
            font-size: 1.1em;
            margin-right: 4px;
        }
        .form-group {
            margin-bottom: 12px;
            width: 100%;
            position: relative;
        }
        .form-btns {
            grid-column: 1 / -1;
            display: flex;
            gap: 18px;
            margin-top: 32px;
            justify-content: center;
        }
        .form-group i {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #bbb;
            font-size: 1em;
            pointer-events: none;
        }
        .form-input {
            width: 100%;
            padding: 16px 16px 16px 44px;
            border: 2.2px solid #b3ccff;
            border-radius: 8px;
            font-size: 1.11em;
            background: #fff;
            color: #333;
            font-weight: normal;
            transition: border 0.2s;
            box-sizing: border-box;
        }
        .form-input:focus {
            border: 2.5px solid #3498db;
            outline: none;
        }
        .form-input::placeholder {
            color: #aaa;
            opacity: 1;
            font-weight: normal;
        }
        .form-btns {
            display: flex;
            gap: 18px;
            margin-top: 32px;
            justify-content: center;
        }
        .btn {
            background: #3498db;
            color: #fff;
            border: none;
            border-radius: 6px;
            padding: 12px 32px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s, box-shadow 0.2s;
            box-shadow: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .btn:hover {
            background: #2166c1;
        }
        .btn i {
            color: #fff;
            font-size: 1em;
            margin-right: 2px;
        }
        .crear-coordinador-title, .section-separator {
            display: none;
        }
        @media (max-width: 1200px) {
            .crear-coordinador-form {
                max-width: 98vw;
                padding: 24px 2vw 24px 2vw;
                gap: 18px 18px;
            }
        }
        @media (max-width: 900px) {
            .crear-coordinador-form {
                margin-top: 18px;
                grid-template-columns: 1fr;
                gap: 10px;
                padding: 0 4vw 32px 4vw;
            }
            .form-group {
                margin-bottom: 8px;
            }
        }
        
        /* Pop-up styles */
        .popup-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 10000;
        }
        .popup-content {
            background: white;
            border-radius: 15px;
            padding: 30px;
            max-width: 450px;
            width: 90%;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            animation: popupFadeIn 0.3s ease-out;
        }
        @keyframes popupFadeIn {
            from {
                opacity: 0;
                transform: scale(0.8) translateY(-20px);
            }
            to {
                opacity: 1;
                transform: scale(1) translateY(0);
            }
        }
        .popup-icon {
            font-size: 3em;
            color: #28a745;
            margin-bottom: 15px;
        }
        .popup-title {
            font-size: 1.4em;
            font-weight: 700;
            color: #333;
            margin-bottom: 10px;
        }
        .popup-message {
            font-size: 1.05em;
            color: #666;
            margin-bottom: 25px;
            line-height: 1.5;
        }
        .popup-btn {
            background: linear-gradient(135deg, #87ceeb 0%, #5fa3d3 100%);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            font-size: 1.05em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(135,206,235,0.4);
            min-width: 120px;
        }
        .popup-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(135,206,235,0.5);
        }

        /* Responsive Design */
        @media (max-width: 1024px) {
            .header h1 {
                font-size: 2rem;
            }
            .crear-coordinador-wrapper {
                padding: 20px 16px;
            }
            .btn-group {
                gap: 8px;
            }
            .btn {
                padding: 10px 20px;
                font-size: 0.9rem;
            }
            .popup-btn {
                min-width: 100px;
                font-size: 1rem;
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
            
            /* Header responsive */
            .header-content {
                padding: 12px 20px;
            }
            
            .header-right {
                gap: 1.5rem;
                justify-content: center;
            }
            
            /* Menu icon responsive */
            .menu-icon {
                font-size: 20px;
                order: -1; /* Aparece primero en móviles */
            }
            
            .crear-coordinador-wrapper {
                padding: 16px 12px;
                margin: 10px;
                border-radius: 8px;
            }
            .input-group {
                margin-bottom: 16px;
            }
            .input-group label {
                font-size: 0.9rem;
                margin-bottom: 6px;
            }
            .input-group input,
            .input-group select {
                padding: 12px 14px;
                font-size: 1rem;
            }
            .form-btns {
                flex-direction: column;
                gap: 12px;
                margin-top: 20px;
            }
            .btn {
                width: 100%;
                padding: 14px;
                font-size: 1rem;
            }
            .btn-group {
                flex-direction: column;
                gap: 12px;
            }
            .popup-btn {
                width: 100%;
                padding: 12px;
                font-size: 1rem;
                min-width: auto;
            }
            .popup {
                width: 90%;
                max-width: none;
                margin: 5%;
                padding: 20px;
            }
            .popup h2 {
                font-size: 1.3rem;
                margin-bottom: 15px;
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
            
            /* Header responsive para móviles pequeños */
            .header-content {
                padding: 10px 15px;
            }
            
            .header-right {
                gap: 1rem;
            }
            
            /* Menu icon para móviles pequeños */
            .menu-icon {
                font-size: 18px;
                order: -1;
            }
            
            .crear-coordinador-wrapper {
                padding: 14px 10px;
                margin: 8px;
            }
            .input-group {
                margin-bottom: 14px;
            }
            .input-group label {
                font-size: 0.85rem;
            }
            .input-group input,
            .input-group select {
                padding: 10px 12px;
                font-size: 0.95rem;
            }
            .btn {
                padding: 12px;
                font-size: 0.95rem;
            }
            .popup-btn {
                padding: 10px;
                font-size: 0.95rem;
            }
            .popup {
                width: 95%;
                margin: 2.5%;
                padding: 15px;
            }
            .popup h2 {
                font-size: 1.2rem;
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
            
            /* Header responsive para móviles extra pequeños */
            .header-content {
                padding: 8px 12px;
            }
            
            .header-right {
                gap: 0.8rem;
            }
            
            /* Menu icon para móviles extra pequeños */
            .menu-icon {
                font-size: 16px;
                order: -1;
            }
            
            .crear-coordinador-wrapper {
                padding: 12px 8px;
                margin: 5px;
            }
            .input-group {
                margin-bottom: 12px;
            }
            .input-group input,
            .input-group select {
                padding: 8px 10px;
                font-size: 0.9rem;
            }
            .btn {
                padding: 10px;
                font-size: 0.9rem;
            }
            .popup-btn {
                padding: 8px;
                font-size: 0.9rem;
            }
            .popup {
                width: 98%;
                margin: 1%;
                padding: 12px;
            }
            .popup h2 {
                font-size: 1.1rem;
            }
        }
    </style>
</head>
<body>
<c:if test="${param.error == 'existe'}">
  <script>
    alert('Ya existe un usuario con el mismo DNI o correo. No se puede repetir la información.');
  </script>
</c:if>
<c:if test="${param.error == 'dni'}">
  <script>
    alert('El DNI ingresado ya se encuentra registrado.');
  </script>
</c:if>
<c:if test="${param.error == 'correo'}">
  <script>
    alert('El correo ingresado ya se encuentra registrado.');
  </script>
</c:if>
<c:if test="${param.error == 'ambos'}">
  <script>
    alert('El DNI y el correo ingresados ya se encuentran registrados.');
  </script>
</c:if>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    var forms = document.querySelectorAll('form');
    forms.forEach(function(form) {
      var dniInput = form.querySelector('input[name="dni"]');
      if (dniInput) {
        form.addEventListener('submit', function(e) {
          var dniValue = dniInput.value.trim();
          if (!/^\d{8}$/.test(dniValue)) {
            alert('El DNI debe contener exactamente 8 números.');
            dniInput.focus();
            e.preventDefault();
          }
        });
      }
    });
  });
</script>
<!-- Checkbox oculto para controlar el sidebar -->
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

<!-- Contenido principal -->
<main class="contenedor-principal">
    <div class="crear-coordinador-wrapper">
        <form class="crear-coordinador-form" action="${pageContext.request.contextPath}/CrearCoordinadorServlet" method="post">
            <div class="section-title"><i class="fa-solid fa-user"></i>Datos Personales</div>
            <div class="form-group">
                <i class="fa-solid fa-user"></i>
                <input type="text" name="nombre" class="form-input" placeholder="Nombre" required value="${param.nombre != null ? param.nombre : ''}">
            </div>
            <div class="form-group">
                <i class="fa-solid fa-user"></i>
                <input type="text" name="apellidopaterno" class="form-input" placeholder="Apellido Paterno" required value="${param.apellidopaterno != null ? param.apellidopaterno : ''}">
            </div>
            <div class="form-group">
                <i class="fa-solid fa-user"></i>
                <input type="text" name="apellidomaterno" class="form-input" placeholder="Apellido Materno" required value="${param.apellidomaterno != null ? param.apellidomaterno : ''}">
            </div>
            <div class="form-group">
                <i class="fa-solid fa-id-card"></i>
                <input type="text" name="dni" class="form-input" placeholder="DNI" required value="${(param.error == 'dni' || param.error == 'ambos') ? '' : (param.dni != null ? param.dni : '')}">
            </div>
            <div class="form-group">
                <i class="fa-solid fa-location-dot"></i>
                <input type="text" name="direccion" class="form-input" placeholder="Dirección" required value="${param.direccion != null ? param.direccion : ''}">
            </div>
            <div class="form-group">
                <i class="fa-solid fa-city"></i>
                <select id="idDistritoResidencia" name="idDistrito" class="form-input" required>
                    <option value="">Distrito de Residencia</option>
                    <c:forEach var="distrito" items="${distritos}">
                        <option value="${distrito.idDistrito}" ${param.idDistrito == distrito.idDistrito ? 'selected' : ''}>${distrito.nombreDistrito}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <i class="fa-solid fa-envelope"></i>
                <input type="email" name="correo" class="form-input" placeholder="Correo" required value="${(param.error == 'correo' || param.error == 'ambos') ? '' : (param.correo != null ? param.correo : '')}">
            </div>
            <div class="section-title"><i class="fa-solid fa-info-circle"></i>Información de Verificación</div>
            <div class="form-group" style="grid-column: 1 / -1;">
                <div style="background: #e3f2fd; border: 2px solid #2196f3; border-radius: 8px; padding: 15px; text-align: center; color: #1565c0;">
                    <i class="fa-solid fa-envelope" style="font-size: 1.2em; margin-bottom: 8px;"></i>
                    <p style="margin: 0; font-weight: 600; font-size: 1.05em;">El coordinador recibirá un correo de verificación</p>
                    <p style="margin: 5px 0 0 0; font-size: 0.95em;">Se enviará un enlace para que pueda establecer su contraseña y activar su cuenta</p>
                </div>
            </div>
            <div class="section-title"><i class="fa-solid fa-briefcase"></i>Datos de Trabajo</div>
            <div class="form-group">
                <i class="fa-solid fa-map-marker-alt"></i>
                <select id="idZonaTrabajo" name="idZonaTrabajo" class="form-input" required>
                    <option value="">Seleccion zona de trabajo:</option>
                    <c:forEach var="zona" items="${zonas}">
                        <option value="${zona.idZona}" ${param.idZonaTrabajo == zona.idZona ? 'selected' : ''}>${zona.nombreZona}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <i class="fa-solid fa-file-alt"></i>
                <!-- DEBUG: Mostrar si la lista de formularios está vacía o nula -->
                <c:if test="${empty formularios}">
                  <div style="color:red; font-weight:bold;">No hay formularios disponibles o hubo un error al cargarlos.</div>
                </c:if>
                <select id="idFormularioAsignado" name="idFormularioAsignado" class="form-input" required>
                    <option value="">Seleccione formulario a asignar</option>
                    <c:forEach var="formulario" items="${formularios}">
                        <option value="${formulario.idFormulario}" ${param.idFormularioAsignado == formulario.idFormulario ? 'selected' : ''}>
                            ${formulario.titulo}
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-btns">
                <button type="button" class="btn" onclick="window.history.back()"><i class="fa-solid fa-arrow-left"></i> Volver</button>
                <button type="submit" class="btn"><i class="fa-solid fa-floppy-disk"></i> Guardar</button>
            </div>
        </form>
    </div>
</main>

<!-- Pop-up de confirmación de creación de coordinador -->
<div id="creationPopup" class="popup-overlay">
    <div class="popup-content">
        <div class="popup-icon">
            <i class="fas fa-check-circle"></i>
        </div>
        <div class="popup-title">¡Coordinador Creado!</div>
        <div class="popup-message">
            El coordinador interno ha sido creado exitosamente.<br>
            Se ha enviado un correo de verificación para activar su cuenta.
        </div>
        <button class="popup-btn" onclick="redirectToManageCoordinators()">
            <i class="fas fa-users"></i> Gestionar Coordinadores
        </button>
    </div>
</div>

<script>
  // Función para mostrar el pop-up de creación exitosa
  function mostrarPopupCreacion() {
    document.getElementById('creationPopup').style.display = 'flex';
  }

  // Función para redirigir a gestionar coordinadores
  function redirectToManageCoordinators() {
    window.location.href = 'GestionarCoordinadoresServlet';
  }

  // Verificar si hay un mensaje de éxito del servidor
  window.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const success = urlParams.get('success');
    
    if (success && success === 'true') {
      // Mostrar el pop-up después de un breve delay
      setTimeout(mostrarPopupCreacion, 500);
    }
  });
</script>
</body>
</html>