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
  <title>Crear Encuestador</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    :root {
      --color-primary: #3498db;
      --color-bg: #f5f7fa;
      --color-card: #c8dbff;
      --color-card-inner: #e6f0ff;
      --sidebar-bg: #e6f0ff;
      --header-bg: #dbeeff;
      --color-btn: #5a9cf8;
      --color-btn-hover: #357ae8;
    }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #e6f0ff 0%, #b3ccff 100%);
      margin: 0;
      padding: 0;
      color: #333;
    }
    .menu-toggle:checked ~ .sidebar { left: 0; }
    .menu-toggle:checked ~ .overlay { display: block; opacity: 1; }
    /* Fix: NO empujar el contenido al abrir sidebar */
    /* .menu-toggle:checked ~ .contenedor-principal { margin-left: 280px; } */
    .contenedor-principal {
      width: 100%;
      margin: 0;
      padding: 30px 30px 0 30px;
      box-sizing: border-box;
      min-height: calc(100vh - 70px);
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
      background-color: var(--header-bg);
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
    /* ----------- Formulario ----------- */
    .crear-coordinador-wrapper {
      background: rgba(255,255,255,0.92);
      border-radius: 24px;
      box-shadow: 0 8px 32px rgba(52, 152, 219, 0.12), 0 1.5px 8px rgba(52, 152, 219, 0.10);
      border: 2px solid #b3ccff;
      max-width: 440px;
      margin: 40px auto 32px auto;
      padding: 36px 32px 32px 32px;
      text-align: center;
    }
    .crear-coordinador-title {
      font-size: 1.2em;
      font-weight: bold;
      margin-bottom: 28px;
      letter-spacing: 1px;
      color: #2166c1;
    }
    .form-group {
      margin-bottom: 18px;
    }
    .form-input {
      width: 100%;
      padding: 12px 14px;
      border: 2px solid #333;
      border-radius: 6px;
      font-size: 1em;
      margin-bottom: 0;
      background: #fff;
      box-sizing: border-box;
    }
    .form-btns {
      display: flex;
      justify-content: space-between;
      margin-top: 28px;
    }
    .btn {
      background: var(--color-btn);
      color: #fff;
      border: none;
      border-radius: 8px;
      padding: 12px 38px;
      font-size: 1em;
      font-weight: 500;
      cursor: pointer;
      transition: background 0.2s, box-shadow 0.2s;
      box-shadow: 0 2px 8px rgba(52, 152, 219, 0.10);
    }
    .btn:hover {
      background: var(--color-btn-hover);
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
    }
  </style>
</head>
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
<body>
<c:if test="${param.error == 'existe'}">
  <script>
    alert('Ya existe un usuario con el mismo DNI o correo. No se puede repetir la información.');
  </script>
</c:if>
<!-- Checkbox oculto para controlar el sidebar -->
<input type="checkbox" id="menu-toggle" class="menu-toggle" style="display:none;" />

<!-- Sidebar -->
<div class="sidebar">
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
        <div class="dropdown-menu">
          <a href="VerPerfilServlet">Ver perfil</a>
          <a href="CerrarSesionServlet">Cerrar sesión</a>
        </div>
      </div>
      <a href="InicioAdminServlet" class="nav-item" id="btn-inicio">
        <img src="${pageContext.request.contextPath}/imagenes/inicio.png" alt="Icono de perfil" class="nav-icon" />
      </a>
    </nav>
  </div>
</header>

<!-- Contenido principal -->
<main class="contenedor-principal">
  <div class="crear-coordinador-wrapper">
    <div class="crear-coordinador-title">INGRESE LOS DATOS DEL ENCUESTADOR</div>
    <form action="${pageContext.request.contextPath}/CrearEncuestadorServlet" method="post">
      <div class="form-group">
        <input type="text" name="nombre" class="form-input" placeholder="Nombre" required>
      </div>
      <div class="form-group">
        <input type="text" name="apellidopaterno" class="form-input" placeholder="Apellido Paterno" required>
      </div>
      <div class="form-group">
        <input type="text" name="apellidomaterno" class="form-input" placeholder="Apellido Materno" required>
      </div>
      <div class="form-group">
        <input type="text" name="dni" class="form-input" placeholder="DNI" required>
      </div>
      <div class="form-group">
        <input type="text" name="direccion" class="form-input" placeholder="Dirección" required>
      </div>
      <div class="form-group">
        <select name="idDistrito" class="form-input" required>
            <option value="">Seleccione un distrito</option>
            <c:forEach var="distrito" items="${distritos}">
                <option value="${distrito.idDistrito}">${distrito.nombreDistrito}</option>
            </c:forEach>
        </select>
      </div>
      <div class="form-group">
        <input type="email" name="correo" class="form-input" placeholder="Correo" required>
      </div>
      <div class="form-group">
        <input type="password" name="contrasenha" class="form-input" placeholder="Contraseña" required>
      </div>
      <div class="form-btns">
        <button type="button" class="btn" onclick="window.history.back()">Volver</button>
        <button type="submit" class="btn">Guardar</button>
      </div>
    </form>
  </div>
</main>
</body>
</html>