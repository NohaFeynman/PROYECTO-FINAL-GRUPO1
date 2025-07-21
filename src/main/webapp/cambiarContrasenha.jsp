<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
  <title>Intranet - Cambiar Contraseña</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    /* RESET BÁSICO */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background-color: #f8fafc;
      color: #333;
      line-height: 1.6;
    }
    
    :root {
      --color-primary: #3498db;
      --color-bg: #f5f7fa;
      --color-card: #c8dbff;
      --color-card-inner: #e6f0ff;
      --sidebar-bg: #e6f0ff;
      --header-bg: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
    }
    /* ================== MENÚ LATERAL (Sidebar) ================== */
    /* Oculta el checkbox */
    .menu-toggle {
      display: none;
    }

    /* Sidebar: se ensancha a 280px para mayor espacio */
    .sidebar {
      position: fixed;
      top: 0;
      left: -280px; /* Ancho del menú: 280px */
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

    /* Overlay: oscurece el fondo cuando el menú está abierto */
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

    /* Contenido del Sidebar */
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

    /* Lista de enlaces del Sidebar */
    .menu-links {
      list-style: none;
      width: 100%;
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

    .menu-links li a:hover {
      background-color: #b3ccff;
      transform: scale(1.05);
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.12);
      color: #003366;
    }

    .menu-links li a i {
      margin-right: 10px;
      font-size: 18px;
    }

    /* ================== CABECERA (Header) ================== */
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
      font-size: 22px;
      cursor: pointer;
      color: #fff;
      padding: 10px;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      justify-content: center;
      width: 40px;
      height: 40px;
      border-radius: 50%;
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
      color: #007bff;
    }

    .nav-item#btn-encuestador .nav-item {
      color: #007bff;
    }

    .nav-item#btn-encuestador .nav-item span {
      color: #007bff;
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

    .main-content h2 {
      margin-bottom: 1.5rem;
      font-size: 1.5rem;
      font-weight: bold;
      color: #007bff;
    }

    /* ================== INTERFAZ "CAMBIAR CONTRASEÑA" ================== */
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
    }

    .profile-photo img {
      width: 150px;
      height: 150px;
      border-radius: 50%;
      object-fit: cover;
      background-color: #ccc;
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

    .btn-back, .btn-confirm {
      padding: 0.8rem 1.5rem;
      font-size: 1rem;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.3s ease;
      font-weight: 500;
      font-family: inherit;
    }

    .btn-back {
      background-color: transparent;
      color: #6b7280;
      border: 1px solid #d1d5db;
    }

    .btn-back:hover {
      background-color: #f9fafb;
      border-color: #9ca3af;
      color: #374151;
    }

    .btn-confirm {
      background-color: #3b82f6;
      color: #fff;
      border: 1px solid #3b82f6;
    }

    .btn-confirm:hover {
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
        justify-content: center;
      }

      /* Reordenar íconos en móvil - menú primero */
      .menu-icon {
        order: -1;
        font-size: 24px;
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

      .profile-value input {
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

      .btn-back, .btn-confirm {
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

      /* Menu icon ajustado para móviles pequeños */
      .menu-icon {
        font-size: 22px;
        order: -1;
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

      .profile-value input {
        font-size: 0.9rem;
        padding: 0.6rem;
        min-height: 42px;
      }

      /* Actions para móviles pequeños */
      .profile-actions {
        gap: 0.6rem;
        margin-top: 1rem;
      }

      .btn-back, .btn-confirm {
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
  </style>
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
      <div class="logo-section">
        <div class="logo-large">
          <img src="${pageContext.request.contextPath}/imagenes/logo.jpg" alt="Logo Combinado" />
        </div>
      </div>
    </div>
    <nav class="header-right">
      <!-- Ícono del menú sidebar alineado con los otros íconos -->
      <label for="menu-toggle" class="menu-icon nav-item">&#9776;</label>
      <!-- Ícono de ver perfil separado -->
      <a href="VerPerfilServlet" class="nav-item" id="btn-perfil">
        <img src="${pageContext.request.contextPath}/imagenes/usuario.png" alt="Icono Usuario" class="nav-icon" />
      </a>
      <!-- Dropdown de usuario -->
      <div class="nav-item dropdown" id="btn-encuestador" tabindex="0">
        <span>${sessionScope.nombre}</span>
        <i class="fas fa-chevron-down dropdown-arrow"></i>
        <div class="dropdown-menu">
          <a href="VerPerfilServlet">Ver perfil</a>
          <a href="CerrarSesionServlet">Cerrar sesión</a>
        </div>
      </div>
    </nav>
  </div>
</header>

<!-- CONTENIDO PRINCIPAL: Interfaz de Cambiar Contraseña -->
<main class="main-content" style="text-align: center; padding: 20px;">
  <h2>Cambiar Contraseña</h2>
  <div class="profile-container">
    <div class="profile-header">
      <div class="profile-photo">
        <c:choose>
          <c:when test="${not empty datosPerfil.usuario.foto}">
            <img src="data:image/jpeg;base64,${datosPerfil.usuario.foto}" alt="Foto de usuario" style="width:150px;height:150px;border-radius:50%;object-fit:cover;background-color:#ccc;" onerror="this.src='${pageContext.request.contextPath}/imagenes/usuario.png'">
          </c:when>
          <c:otherwise>
            <img src="${pageContext.request.contextPath}/imagenes/usuario.png" alt="Foto de usuario" style="width:150px;height:150px;border-radius:50%;object-fit:cover;background-color:#ccc;">
          </c:otherwise>
        </c:choose>
      </div>
      <div class="profile-info">
        <h3>${nombreCompleto}</h3>
        <p><strong>Rol:</strong> ${datosPerfil.nombreRol}</p>
        <p><strong>Último acceso:</strong>
          <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %>
        </p>
      </div>
    </div>

    <form action="CambiarContrasenhaServlet" method="post">
      <!-- Mostrar mensajes de error/éxito solo si vienen del servlet -->

      <c:if test="${not empty requestScope.error}">
        <div class="alert alert-danger">${requestScope.error}</div>
      </c:if>


      <div class="profile-details">
        <div class="profile-row">
          <div class="profile-label">Contraseña actual:</div>
          <div class="profile-value">
            <input type="password" name="contrasenhaActual" placeholder="Ingrese su contraseña actual" required>
          </div>
        </div>
        <div class="profile-row">
          <div class="profile-label">Nueva contraseña:</div>
          <div class="profile-value">
            <input type="password" name="nuevaContrasenha" placeholder="Ingrese su nueva contraseña" required>
          </div>
        </div>
        <div class="profile-row">
          <div class="profile-label">Confirmar contraseña:</div>
          <div class="profile-value">
            <input type="password" name="confirmarContrasenha" placeholder="Confirme su nueva contraseña" required>
          </div>
        </div>
      </div>

      <div class="profile-actions">
        <button type="button" class="btn-back" onclick="window.location.href='VerPerfilServlet'">Cancelar</button>
        <button type="submit" class="btn-confirm">Cambiar Contraseña</button>
      </div>
    </form>
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

<div id="popup-exito" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.35); z-index:9999; align-items:center; justify-content:center;">
  <div style="background:#fff; padding:2rem 2.5rem; border-radius:10px; box-shadow:0 2px 10px rgba(0,0,0,0.2); text-align:center;">
    <h3 style="color:#28a745; margin-bottom:1rem;">¡Contraseña cambiada!</h3>
    <p>Su contraseña se ha cambiado exitosamente</p>
  </div>
</div>
<script>
  // Validación y popup al cambiar contraseña
  document.querySelector('.btn-confirm').addEventListener('click', function(e) {
    e.preventDefault();
    var form = this.closest('form');
    var nueva = form.querySelector('input[name="nuevaContrasenha"]').value;
    var confirmar = form.querySelector('input[name="confirmarContrasenha"]').value;

    // Validación de longitud mínima
    if (nueva.length < 8) {
      mostrarAlerta('La nueva contraseña debe tener al menos 8 caracteres.', 'danger');
      return;
    }
    // Validación de coincidencia
    if (nueva !== confirmar) {
      mostrarAlerta('Las contraseñas no coinciden.', 'danger');
      return;
    }

    // Si pasa la validación, mostrar popup de éxito y enviar
    var popup = document.getElementById('popup-exito');
    popup.style.display = 'flex';
    setTimeout(function() {
      popup.style.display = 'none';
      form.submit();
    }, 1500);
  });

  // Función para mostrar alertas de error
  function mostrarAlerta(mensaje, tipo) {
    // Elimina alertas previas
    var prev = document.getElementById('alerta-popup');
    if (prev) prev.remove();
    // Crea alerta
    var alerta = document.createElement('div');
    alerta.id = 'alerta-popup';
    alerta.className = 'alert alert-' + tipo;
    alerta.style.position = 'fixed';
    alerta.style.top = '30px';
    alerta.style.left = '50%';
    alerta.style.transform = 'translateX(-50%)';
    alerta.style.zIndex = '2001';
    alerta.style.minWidth = '250px';
    alerta.style.textAlign = 'center';
    alerta.innerText = mensaje;
    document.body.appendChild(alerta);
    setTimeout(function() {
      alerta.remove();
    }, 2000);
  }
</script>



<!-- Agregar estilos para mensajes de alerta -->
<style>
  .alert {
    padding: 1rem;
    margin-bottom: 1.5rem;
    border-radius: 4px;
  }
  .alert-danger {
    background-color: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
  }
  .alert-success {
    background-color: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
  }
</style>
</body>
</html>