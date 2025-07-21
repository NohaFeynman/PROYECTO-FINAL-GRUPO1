<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<%
    // Obtener correo del parámetro o de los atributos
    String correoUsuario = request.getParameter("correo");
    if (correoUsuario == null || correoUsuario.trim().isEmpty()) {
        correoUsuario = (String) request.getAttribute("correoUsuario");
    }
    if (correoUsuario == null || correoUsuario.trim().isEmpty()) {
        correoUsuario = (String) session.getAttribute("correoCoordinador");
    }
    // Si no hay correo, redirigir
    if (correoUsuario == null || correoUsuario.trim().isEmpty()) {
        response.sendRedirect("LoginServlet");
        return;
    }
    request.setAttribute("correoUsuario", correoUsuario);
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Establecer Contraseña - Coordinador Interno - ONU Mujeres</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #f0f8ff 0%, #e6f3ff 50%, #ddeeff 100%);
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
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .logo-text {
      color: white;
      font-size: 1.4em;
      font-weight: 700;
      text-shadow: 0 2px 4px rgba(0,0,0,0.3);
    }
    .content {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px 10px;
      width: 100%;
      min-height: calc(100vh - 140px);
    }
    .verification-section {
      background: white;
      border-radius: 20px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.1);
      padding: 30px 20px;
      width: 100%;
      max-width: 100%;
      margin: 0 auto;
      text-align: center;
      position: relative;
      overflow: hidden;
      box-sizing: border-box;
    }
    .verification-section::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 5px;
      background: linear-gradient(90deg, #87ceeb, #98d8c8, #ffd3a5, #f093fb);
      border-radius: 20px 20px 0 0;
    }
    .coordinator-badge {
      display: inline-block;
      background: linear-gradient(135deg, #87ceeb 0%, #98d8c8 100%);
      color: white;
      padding: 8px 20px;
      border-radius: 25px;
      font-size: 0.9em;
      font-weight: 600;
      margin-bottom: 20px;
      box-shadow: 0 4px 15px rgba(135,206,235,0.3);
    }
    .verification-section h4 {
      color: #5fa3d3;
      margin-bottom: 15px;
      font-size: 1.8em;
      font-weight: 700;
    }
    .welcome-message {
      background: linear-gradient(135deg, #e3f2fd 0%, #e1f5fe 100%);
      border: 2px solid #87ceeb;
      border-radius: 15px;
      padding: 20px;
      margin: 20px 0;
      color: #2e7d9a;
    }
    .welcome-message h5 {
      margin-bottom: 10px;
      font-size: 1.2em;
      color: #1a5d7a;
    }
    .welcome-message p {
      margin: 8px 0;
      line-height: 1.6;
    }
    .email-info {
      background: #f8f9fa;
      border: 2px solid #dee2e6;
      border-radius: 12px;
      padding: 15px;
      margin: 20px 0;
      color: #495057;
    }
    .email-info p {
      margin-bottom: 5px;
      font-weight: 500;
    }
    .email-info strong {
      color: #5fa3d3;
      font-size: 1.1em;
    }
    .timer-info {
      background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
      border: 2px solid #ffc107;
      border-radius: 12px;
      padding: 12px;
      margin: 15px 0;
      color: #856404;
      font-weight: 600;
      font-size: 1.05em;
      display: none;
    }
    .form-group {
      margin-bottom: 20px;
      text-align: left;
    }
    .form-group label {
      display: block;
      margin-bottom: 8px;
      font-weight: 600;
      color: #333;
      font-size: 0.95em;
    }
    .form-group input[type="text"],
    .form-group input[type="password"] {
      width: 100%;
      padding: 15px;
      border: 2px solid #e1e5e9;
      border-radius: 10px;
      font-size: 1em;
      transition: all 0.3s ease;
      background: #f8f9fa;
    }
    .form-group input[type="text"]:focus,
    .form-group input[type="password"]:focus {
      outline: none;
      border-color: #87ceeb;
      background: white;
      box-shadow: 0 0 0 3px rgba(135,206,235,0.2);
    }
    .password-requirements {
      margin-top: 8px;
      padding: 12px;
      background: #f8f9fa;
      border-radius: 8px;
      font-size: 0.85em;
    }
    .password-requirements ul {
      margin: 8px 0 0 20px;
      padding: 0;
    }
    .password-requirements li {
      margin: 4px 0;
      transition: color 0.3s ease;
    }
    .password-requirements li.valid {
      color: #28a745;
      font-weight: 600;
    }
    .password-requirements li.invalid {
      color: #dc3545;
    }
    .error-message {
      background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
      color: #721c24;
      padding: 15px;
      border-radius: 10px;
      margin: 15px 0;
      border: 2px solid #f1aeb5;
      font-weight: 600;
      text-align: center;
    }
    .success-message {
      background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
      color: #155724;
      padding: 15px;
      border-radius: 10px;
      margin: 15px 0;
      border: 2px solid #b8dacc;
      font-weight: 600;
      text-align: center;
    }
    .form-actions {
      display: flex;
      gap: 25px;
      justify-content: center;
      margin-top: 25px;
    }
    .btn-primary {
      background: linear-gradient(135deg, #87ceeb 0%, #5fa3d3 100%);
      color: white;
      border: none;
      padding: 15px 30px;
      border-radius: 50px;
      font-size: 1.05em;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;
      box-shadow: 0 6px 20px rgba(135,206,235,0.4);
      min-width: 160px;
    }
    .btn-primary:hover:not(:disabled) {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(135,206,235,0.5);
    }
    .btn-primary:disabled {
      opacity: 0.6;
      cursor: not-allowed;
      transform: none;
      box-shadow: 0 6px 20px rgba(135,206,235,0.2);
    }
    .btn-secondary {
      background: linear-gradient(135deg, #6c757d 0%, #5a6268 100%);
      color: white;
      border: none;
      padding: 12px 25px;
      border-radius: 50px;
      font-size: 0.95em;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;
      box-shadow: 0 4px 15px rgba(108,117,125,0.3);
    }
    .btn-secondary:hover {
      transform: translateY(-1px);
      box-shadow: 0 6px 20px rgba(108,117,125,0.4);
    }
    .back-link {
      margin-top: 25px;
    }
    .back-link a {
      color: #6c757d;
      text-decoration: none;
      font-weight: 500;
      font-size: 0.95em;
      transition: color 0.3s ease;
    }
    .back-link a:hover {
      color: #5fa3d3;
    }
    .footer-bar {
      background: #343a40;
      color: white;
      text-align: center;
      padding: 15px;
      font-size: 0.9em;
      font-weight: 500;
    }
    
    @media (max-width: 600px) {
      .verification-section {
        margin: 0;
        padding: 25px 15px;
        border-radius: 0;
        min-height: calc(100vh - 140px);
        display: flex;
        flex-direction: column;
        justify-content: center;
      }
      .content {
        padding: 0;
        align-items: stretch;
      }
      .form-actions {
        flex-direction: column;
        align-items: center;
      }
      .btn-primary, .btn-secondary {
        width: 100%;
        max-width: 300px;
        margin-bottom: 10px;
      }
      .welcome-message {
        margin: 15px 0;
        padding: 15px;
      }
      .welcome-message h5 {
        font-size: 1.1em;
      }
      .verification-section h4 {
        font-size: 1.6em;
        margin-bottom: 10px;
      }
      .coordinator-badge {
        padding: 6px 15px;
        font-size: 0.85em;
        margin-bottom: 15px;
      }
      .form-group input[type="text"],
      .form-group input[type="password"] {
        padding: 12px;
        font-size: 16px; /* Evita zoom en iOS */
      }
      .logo-text {
        font-size: 1.2em;
      }
      .header-bar {
        height: 60px;
      }
      .logo-container img {
        height: 40px;
      }
    }
    
    @media (max-width: 480px) {
      .verification-section {
        padding: 20px 10px;
      }
      .welcome-message {
        padding: 12px;
        margin: 10px 0;
      }
      .verification-section h4 {
        font-size: 1.4em;
      }
      .form-group {
        margin-bottom: 15px;
      }
      .password-requirements {
        font-size: 0.8em;
        padding: 10px;
      }
      .btn-primary, .btn-secondary {
        padding: 12px 20px;
        font-size: 1em;
      }
    }
    
    /* Mejoras adicionales para dispositivos móviles */
    @media (max-width: 768px) {
      body {
        font-size: 14px;
      }
      .main-container {
        min-height: 100vh;
      }
      .content {
        width: 100%;
        box-sizing: border-box;
      }
      .verification-section {
        box-shadow: none;
        border-radius: 0;
        width: 100vw;
        max-width: 100vw;
        margin: 0;
        padding: 20px;
      }
      .footer-bar {
        padding: 10px;
        font-size: 0.8em;
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
  </style>
</head>
<body>
<div class="main-container">
  <!-- Header -->
  <header class="header-bar">
    <div class="logo-container">
      <img src="${pageContext.request.contextPath}/imagenes/logo.jpg" alt="Logo ONU Mujeres" />
    </div>
  </header>

  <!-- Contenido principal -->
  <main class="content">
    <section class="verification-section">
      <div class="coordinator-badge">
        <i class="fas fa-user-tie"></i> Coordinador Interno
      </div>
      
      <h4>ESTABLECER CONTRASEÑA</h4>
      
      <div class="welcome-message">
        <h5><i class="fas fa-star"></i> ¡Bienvenido/a al equipo!</h5>
        <p>Has sido designado/a como <strong>Coordinador Interno</strong> en la plataforma de ONU Mujeres.</p>
        <p>Para completar la activación de tu cuenta, necesitas establecer tu contraseña.</p>
      </div>
      
      <div class="email-info">
        <p>Se ha enviado un código de verificación a:</p>
        <strong>${correoUsuario}</strong>
      </div>
      
      <div class="timer-info" id="timerInfo">
        ⏰ Tiempo restante: <span id="timeLeft">05:00</span>
      </div>
      
      <c:if test="${not empty error}">
        <div class="error-message">
          <i class="fas fa-exclamation-triangle"></i> ${error}
        </div>
      </c:if>
      <c:if test="${not empty success}">
        <div class="success-message">
          <i class="fas fa-check-circle"></i> ${success}
        </div>
      </c:if>
      <div id="errorContainer" class="error-message" style="display: none;">
        <i class="fas fa-exclamation-triangle"></i> <span id="errorMessage"></span>
      </div>
      <div id="successContainer" class="success-message" style="display: none;">
        <i class="fas fa-check-circle"></i> <span id="successMessage"></span>
      </div>

      <form id="verificationForm" action="verificarCoordinador" method="post">
        <input type="hidden" name="correo" value="${correoUsuario}">
        
        <!-- Campo de código -->
        <div class="form-group">
          <label for="codigo"><i class="fas fa-key"></i> Código de Verificación *</label>
          <input type="text"
                 id="codigo"
                 name="codigo"
                 maxlength="6"
                 placeholder="Ingresa el código de 6 caracteres"
                 pattern="[A-Za-z0-9]{6}"
                 style="text-transform: uppercase;"
                 required>
          <div class="password-requirements">
            <i class="fas fa-info-circle"></i> Ingresa el código de 6 caracteres (números y letras) que recibiste por correo electrónico
          </div>
        </div>

        <!-- Campo de contraseña -->
        <div class="form-group">
          <label for="password"><i class="fas fa-lock"></i> Nueva Contraseña *</label>
          <input type="password"
                 id="password"
                 name="password"
                 placeholder="Crea tu contraseña de acceso"
                 required>
          <div class="password-requirements">
            <strong>La contraseña debe contener:</strong>
            <ul id="passwordChecklist">
              <li id="length" class="invalid">• Mínimo 8 caracteres</li>
              <li id="uppercase" class="invalid">• Al menos una letra mayúscula</li>
              <li id="lowercase" class="invalid">• Al menos una letra minúscula</li>
              <li id="number" class="invalid">• Al menos un número</li>
              <li id="special" class="invalid">• Al menos un carácter especial (!@#$%^&*)</li>
            </ul>
          </div>
        </div>

        <!-- Campo de confirmación -->
        <div class="form-group">
          <label for="confirmPassword"><i class="fas fa-check-double"></i> Confirmar Contraseña *</label>
          <input type="password"
                 id="confirmPassword"
                 name="confirmPassword"
                 placeholder="Confirma tu contraseña"
                 required>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn-primary" id="submitBtn" disabled>
            <i class="fas fa-check"></i> Activar Cuenta
          </button>
        </div>
      </form>

      <button type="button" class="btn-secondary" id="resendBtn" onclick="reenviarCodigoCoordinador()">
        <i class="fas fa-paper-plane"></i> Reenviar Código
      </button>

      <div class="back-link">
        <a href="LoginServlet"><i class="fas fa-arrow-left"></i> Volver al inicio de sesión</a>
      </div>
    </section>
  </main>

  <!-- Pie de página -->
  <footer class="footer-bar">
    <i class="fas fa-heart"></i> Defensora mundial de la igualdad de género
  </footer>
</div>

<!-- Pop-up de confirmación de activación -->
<div id="activationPopup" class="popup-overlay">
  <div class="popup-content">
    <div class="popup-icon">
      <i class="fas fa-check-circle"></i>
    </div>
    <div class="popup-title">¡Cuenta Activada!</div>
    <div class="popup-message">
      Tu cuenta de coordinador interno ha sido activada exitosamente.<br>
      Ya puedes acceder a la plataforma con tus credenciales.
    </div>
    <button class="popup-btn" onclick="redirectToLogin()">
      <i class="fas fa-sign-in-alt"></i> Ir al Login
    </button>
  </div>
</div>

<script>
  // Variables globales
  let timerInterval;
  let timeRemaining = 300; // 5 minutos en segundos

  // INICIALIZAR con sincronización
  document.addEventListener('DOMContentLoaded', async function() {
    // Verificar que existe el correo del usuario
    const correo = '${correoUsuario}';
    if (!correo || correo.trim() === '') {
      window.location.href = 'LoginServlet';
      return;
    }

    // Elementos del DOM
    const codigoInput = document.getElementById('codigo');
    const passwordInput = document.getElementById('password');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const submitBtn = document.getElementById('submitBtn');
    const timerInfo = document.getElementById('timerInfo');
    const timeLeft = document.getElementById('timeLeft');

    // Mostrar el temporizador inmediatamente
    if (timerInfo) {
      timerInfo.style.display = 'block';
      timerInfo.style.visibility = 'visible';
    }

    // Obtener tiempo real del servidor
    try {
      const response = await fetch('obtenerTiempoRestanteCoordinador?correo=' + encodeURIComponent(correo));
      if (response.ok) {
        const data = await response.json();
        if (data.tiempoRestante > 0) {
          timeRemaining = data.tiempoRestante;
          console.log('⏰ Tiempo sincronizado del servidor:', timeRemaining, 'segundos');
        }
      }
    } catch (error) {
      console.log('⚠️ No se pudo sincronizar tiempo, usando valor por defecto');
    }

    // Iniciar temporizador
    iniciarTemporizador();

    // Validación en tiempo real de contraseña
    passwordInput.addEventListener('input', validarPassword);
    confirmPasswordInput.addEventListener('input', validarFormulario);
    codigoInput.addEventListener('input', validarFormulario);

    function validarPassword() {
      const password = passwordInput.value;
      const requirements = {
        length: password.length >= 8,
        uppercase: /[A-Z]/.test(password),
        lowercase: /[a-z]/.test(password),
        number: /\d/.test(password),
        special: /[!@#$%^&*(),.?":{}|<>]/.test(password)
      };

      // Actualizar lista visual
      Object.keys(requirements).forEach(req => {
        const element = document.getElementById(req);
        if (element) {
          element.className = requirements[req] ? 'valid' : 'invalid';
        }
      });

      validarFormulario();
    }

    function validarFormulario() {
      const codigo = codigoInput.value.trim();
      const password = passwordInput.value;
      const confirmPassword = confirmPasswordInput.value;

      const codigoValido = codigo.length === 6;
      const passwordValido = password.length >= 8 && 
                           /[A-Z]/.test(password) && 
                           /[a-z]/.test(password) && 
                           /\d/.test(password) && 
                           /[!@#$%^&*(),.?":{}|<>]/.test(password);
      const passwordsCoinciden = password === confirmPassword && password.length > 0;

      submitBtn.disabled = !(codigoValido && passwordValido && passwordsCoinciden);
    }

    function iniciarTemporizador() {
      function actualizarTemporizador() {
        if (timeRemaining <= 0) {
          clearInterval(timerInterval);
          if (timeLeft) {
            timeLeft.textContent = '00:00';
            timeLeft.style.color = '#dc3545';
          }
          if (timerInfo) {
            timerInfo.innerHTML = '⏰ <span style="color: #dc3545;">Código expirado</span>';
            timerInfo.style.background = 'linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%)';
            timerInfo.style.borderColor = '#f1aeb5';
          }
          
          // Deshabilitar el formulario
          submitBtn.disabled = true;
          submitBtn.style.opacity = '0.5';
          return;
        }

        const minutes = Math.floor(timeRemaining / 60);
        const seconds = timeRemaining % 60;
        const timeString = String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
        
        if (timeLeft) {
          timeLeft.textContent = timeString;
          
          // Cambiar color según el tiempo restante
          if (timeRemaining <= 60) {
            timeLeft.style.color = '#dc3545'; // Rojo último minuto
          } else if (timeRemaining <= 120) {
            timeLeft.style.color = '#fd7e14'; // Naranja últimos 2 minutos
          } else {
            timeLeft.style.color = '#856404'; // Color normal
          }
        }

        timeRemaining--;
      }

      // Ejecutar inmediatamente y luego cada segundo
      actualizarTemporizador();
      timerInterval = setInterval(actualizarTemporizador, 1000);
    }
  });

  // Función para reenviar código (específica para coordinadores)
  async function reenviarCodigoCoordinador() {
    const correo = '${correoUsuario}';
    const resendBtn = document.getElementById('resendBtn');
    const errorContainer = document.getElementById('errorContainer');
    const successContainer = document.getElementById('successContainer');
    const errorMessage = document.getElementById('errorMessage');
    const successMessage = document.getElementById('successMessage');

    // Deshabilitar botón temporalmente
    resendBtn.disabled = true;
    resendBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Enviando...';

    try {
      const response = await fetch('reenviarCodigoCoordinador', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'correo=' + encodeURIComponent(correo)
      });

      const data = await response.json();

      if (data.success) {
        // Ocultar errores y mostrar éxito
        errorContainer.style.display = 'none';
        successContainer.style.display = 'block';
        successMessage.textContent = data.message || 'Código reenviado exitosamente';

        // Reiniciar temporizador
        timeRemaining = 300;
        console.log('🔄 Código reenviado, reiniciando temporizador');

        // Rehabilitar formulario si estaba deshabilitado
        const submitBtn = document.getElementById('submitBtn');
        submitBtn.style.opacity = '1';

        setTimeout(() => {
          successContainer.style.display = 'none';
        }, 5000);
      } else {
        // Mostrar error
        successContainer.style.display = 'none';
        errorContainer.style.display = 'block';
        errorMessage.textContent = data.message || 'Error al reenviar el código';

        setTimeout(() => {
          errorContainer.style.display = 'none';
        }, 5000);
      }
    } catch (error) {
      console.error('Error al reenviar código:', error);
      successContainer.style.display = 'none';
      errorContainer.style.display = 'block';
      errorMessage.textContent = 'Error de conexión. Inténtalo nuevamente.';

      setTimeout(() => {
        errorContainer.style.display = 'none';
      }, 5000);
    } finally {
      // Rehabilitar botón
      resendBtn.disabled = false;
      resendBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Reenviar Código';
    }
  }

  // Validación de envío del formulario
  document.getElementById('verificationForm').addEventListener('submit', function(e) {
    if (timeRemaining <= 0) {
      e.preventDefault();
      alert('El código ha expirado. Por favor, solicita un nuevo código.');
      return false;
    }

    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirmPassword').value;

    if (password !== confirmPassword) {
      e.preventDefault();
      alert('Las contraseñas no coinciden.');
      return false;
    }

    return true;
  });

  // Función para mostrar pop-up de activación exitosa
  function mostrarPopupActivacion() {
    document.getElementById('activationPopup').style.display = 'flex';
  }

  // Función para redirigir al login
  function redirectToLogin() {
    window.location.href = 'LoginServlet';
  }

  // Verificar si hay un mensaje de éxito del servidor
  window.addEventListener('DOMContentLoaded', function() {
    const successMessage = '${success}';
    const cuentaActivada = '${cuentaActivada}';
    
    if (cuentaActivada && cuentaActivada === 'true') {
      // Mostrar el pop-up inmediatamente para cuenta activada
      setTimeout(mostrarPopupActivacion, 500);
    } else if (successMessage && successMessage.trim() !== '' && successMessage.includes('activada')) {
      // Esperar un poco antes de mostrar el pop-up para que se vea el mensaje de éxito
      setTimeout(mostrarPopupActivacion, 1500);
    }
  });
</script>
</body>
</html>
