<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
    
    // Procesar parámetros de error
    String errorParam = request.getParameter("error");
    String errorMessage = null;
    
    if (errorParam != null) {
        switch (errorParam) {
            case "1":
                errorMessage = "Credenciales inválidas. Verifica tu correo y contraseña.";
                break;
            case "campos-vacios":
                errorMessage = "Por favor, completa todos los campos.";
                break;
            case "rol":
                errorMessage = "Error en el sistema. Contacta al administrador.";
                break;
            case "sesion-expirada":
                errorMessage = "Tu sesión ha expirado. Por favor, inicia sesión nuevamente.";
                break;
            case "acceso-denegado":
                errorMessage = "No tienes permisos para acceder a esa página.";
                break;
            default:
                errorMessage = "Su cuenta está inctiva. Contacte al administrador.";
                break;
        }
        request.setAttribute("error", errorMessage);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Iniciar Sesión - ONU Mujeres</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: #f5f5f5;
      min-height: 100vh;
      color: #333;
      margin: 0;
      padding: 0;
    }
    .main-container {
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    .content-wrapper {
      flex: 1;
      display: flex;
      min-height: calc(100vh - 130px);
      background: transparent;
    }
    .image-section {
      flex: 2;
      background-image: url('imagenes/NuevaPortada.jpg');
      background-size: cover;
      background-position: center 0.25px;
      background-repeat: no-repeat;
      min-height: 100%;
      width: 100%;
    }
    .form-section {
      flex: 1;
      background-color: white;
      padding: 50px 30px 50px 45px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      min-width: 480px;
      border-radius: 0;
      box-shadow: none;
      position: relative;
      z-index: 2;
      margin-right: 0;
      width: 100%;
    }
    .header-bar {
      background: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
      height: 70px;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 2px 10px rgba(135,206,235,0.3);
      position: relative;
      overflow: hidden;
    }
    .header-bar::before {
      content: '';
      position: absolute;
      top: 0;
      left: -100%;
      width: 100%;
      height: 100%;
      background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
      animation: shine 3s infinite;
    }
    @keyframes shine {
      0% { left: -100%; }
      100% { left: 100%; }
    }
    .logo-container {
      display: flex;
      align-items: center;
      gap: 15px;
    }
    .logo-container img {
      height: 50px;
      width: auto;
      border-radius: 5px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .login-container {
      width: 100%;
      max-width: none;
      padding: 0;
      background: transparent;
      border-radius: 0;
      box-shadow: none;
      backdrop-filter: none;
      border: none;
      margin-right: 0;
    }
    .login-header {
      text-align: center;
      margin-bottom: 30px;
    }
    .login-header h1 {
      color: #5fa3d3;
      font-size: 22px;
      font-weight: 600;
      margin-bottom: 8px;
    }
    .login-header p {
      color: #666;
      font-size: 14px;
    }
    .form-group {
      margin-bottom: 20px;
    }
    .form-group label {
      display: block;
      margin-bottom: 6px;
      color: #5fa3d3;
      font-weight: 500;
      font-size: 14px;
    }
    .form-control {
      width: 100%;
      padding: 12px 15px;
      border: 1px solid #ddd;
      border-radius: 5px;
      font-size: 14px;
      transition: all 0.3s ease;
      background: white;
    }
    .form-control:focus {
      outline: none;
      border-color: #5fa3d3;
      box-shadow: 0 0 0 2px rgba(95, 163, 211, 0.2);
      background: white;
    }
    .btn-primary {
      width: 100%;
      padding: 12px;
      background-color: #5fa3d3;
      border: none;
      border-radius: 5px;
      color: white;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: background-color 0.3s ease;
      margin-top: 15px;
    }
    .btn-primary:hover {
      background-color: #4a8db8;
    }
    .links-container {
      text-align: center;
      margin-top: 20px;
    }
    .links-container a {
      color: #5fa3d3;
      text-decoration: none;
      font-size: 14px;
      margin: 0 10px;
      transition: color 0.3s ease;
    }
    .links-container a:hover {
      color: #87ceeb;
      text-decoration: underline;
    }
    .divider {
      margin: 15px 0;
      text-align: center;
      color: #666;
      font-size: 14px;
    }
    .alert {
      padding: 10px 12px;
      border-radius: 5px;
      margin-bottom: 15px;
      font-size: 14px;
      border-left: 4px solid;
    }
    .alert-success {
      background-color: #d4edda;
      border-color: #28a745;
      color: #155724;
    }
    .alert-error {
      background-color: #f8d7da;
      border-color: #dc3545;
      color: #721c24;
    }
    .alert-warning {
      background-color: #fff3cd;
      border-color: #ffc107;
      color: #856404;
    }
    .alert-info {
      background-color: #cce7ff;
      border-color: #87ceeb;
      color: #2c5aa0;
    }
    .footer {
      background: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
      color: #333;
      text-align: center;
      padding: 15px 0;
      margin-top: auto;
      box-shadow: 0 -2px 10px rgba(135,206,235,0.3);
    }
    .footer p {
      margin: 0;
      font-size: 14px;
      font-weight: 500;
    }
    @media (max-width: 768px) {
      .content-wrapper {
        flex-direction: column;
      }
      .image-section {
        display: none;
      }
      .form-section {
        border-radius: 0;
        box-shadow: none;
        min-width: auto;
        padding: 30px 20px;
      }
      .login-container {
        margin: 0;
        padding: 0;
      }
      .login-header h1 {
        font-size: 20px;
      }
      .header-bar {
        height: 60px;
      }
      .logo-container img {
        height: 40px;
      }
    }
    @media (max-width: 480px) {
      .form-section {
        padding: 20px 15px;
      }
      .login-header h1 {
        font-size: 18px;
      }
      .form-control {
        padding: 10px 12px;
      }
      .btn-primary {
        padding: 10px;
        font-size: 14px;
      }
    }
  </style>
</head>
<body>
  <div class="main-container">
    <!-- Header -->
    <div class="header-bar">
      <div class="logo-container">
        <img src="imagenes/logo.jpg" alt="ONU Mujeres">
      </div>
    </div>

    <!-- Contenido Principal -->
    <div class="content-wrapper">
      <!-- Sección de Imagen -->
      <div class="image-section"></div>
      
      <!-- Sección del Formulario -->
      <div class="form-section">
        <div class="login-container">
        <div class="login-header">
            <!-- <i class="fas fa-sign-in-alt"></i> -->
          <h1>Iniciar Sesión</h1>
          <p>Accede a tu cuenta para continuar</p>
        </div>

        <!-- Mensajes de estado -->
        <c:if test="${not empty sessionScope.success}">
          <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> ${sessionScope.success}
          </div>
          <% session.removeAttribute("success"); %> <%-- Limpiar mensaje después de mostrarlo --%>
        </c:if>
        
        <c:if test="${not empty mensaje}">
          <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> ${mensaje}
          </div>
        </c:if>
        
        <c:if test="${not empty error}">
          <div class="alert alert-error">
            <i class="fas fa-exclamation-triangle"></i> ${error}
          </div>
        </c:if>

        <c:if test="${not empty warning}">
          <div class="alert alert-warning">
            <i class="fas fa-exclamation-circle"></i> ${warning}
          </div>
        </c:if>

        <c:if test="${not empty info}">
          <div class="alert alert-info">
            <i class="fas fa-info-circle"></i> ${info}
          </div>
        </c:if>

        <!-- Formulario de Login -->
        <form action="LoginServlet" method="post" id="loginForm">
          <div class="form-group">
            <label for="correo">
              <i class="fas fa-envelope"></i> Correo Electrónico
            </label>
            <input type="email" 
                   class="form-control" 
                   id="correo" 
                   name="correo" 
                   placeholder="ejemplo@correo.com" 
                   required 
                   value="${param.correo}">
          </div>

          <div class="form-group">
            <label for="password">
              <i class="fas fa-lock"></i> Contraseña
            </label>
            <input type="password" 
                   class="form-control" 
                   id="password" 
                   name="password" 
                   placeholder="Ingresa tu contraseña" 
                   required>
          </div>

          <button type="submit" class="btn-primary">
            <i class="fas fa-sign-in-alt"></i> Ingresa a tu cuenta
          </button>
        </form>

        <!-- Enlaces adicionales -->
        <div class="links-container">
          <a href="enviarCodigoRecuperacion">
            <i class="fas fa-key"></i> ¿Olvidaste tu contraseña?
          </a>

            <!-- <div class="divider">|</div>-->
          
          <a href="registro">
            <i class="fas fa-user-plus"></i> Crear nueva cuenta
          </a>
        </div>
      </div>
      </div>
    </div>

    <!-- Footer -->
    <div class="footer">
      <p>&copy; 2025 ONU Mujeres. Todos los derechos reservados.</p>
    </div>
  </div>

  <script>
    // Validación del formulario
    document.getElementById('loginForm').addEventListener('submit', function(e) {
      const correo = document.getElementById('correo').value.trim();
      const password = document.getElementById('password').value.trim();
      
      if (!correo || !password) {
        e.preventDefault();
        alert('Por favor, completa todos los campos requeridos.');
        return false;
      }
      
      // Validación básica de email
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(correo)) {
        e.preventDefault();
        alert('Por favor, ingresa un correo electrónico válido.');
        return false;
      }
      
      return true;
    });

    // Auto-ocultar mensajes después de 5 segundos
    setTimeout(function() {
      const alerts = document.querySelectorAll('.alert');
      alerts.forEach(alert => {
        alert.style.transition = 'opacity 0.5s ease';
        alert.style.opacity = '0';
        setTimeout(() => alert.remove(), 500);
      });
    }, 5000);
  </script>
</body>
</html>
