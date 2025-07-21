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
        correoUsuario = (String) session.getAttribute("correoRecuperacion");
    }
    
    // Si no hay correo, redirigir
    if (correoUsuario == null || correoUsuario.trim().isEmpty()) {
        response.sendRedirect("enviarCodigoRecuperacion");
        return;
    }
    
    request.setAttribute("correoUsuario", correoUsuario);
%>
<!DOCTYPE html>
<html lang="es">
<head>

  <meta charset="UTF-8">

  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Restablecer Contraseña - ONU Mujeres</title>
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

    .content {
      flex: 1;
      display: flex;
      min-height: calc(100vh - 130px);
    }

    .image-section {
      flex: 2;
      background-image: url('imagenes/NuevaPortada.jpg');
      background-size: cover;
      background-position: center;
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

    .form-section h4 {
      color: #5fa3d3;
      margin-bottom: 20px;
      font-size: 22px;
      text-align: center;
      font-weight: 600;
    }

    .email-info {
      background-color: #e7f3ff;
      border: 1px solid #b3d9ff;
      border-radius: 8px;
      padding: 12px;
      margin-bottom: 15px;
      text-align: center;
      font-size: 14px;
    }

    .email-info strong {
      color: #5fa3d3;
      font-size: 14px;
    }

    .form-group {
      margin-bottom: 15px;
    }

    .form-group label {
      display: block;
      margin-bottom: 6px;
      color: #5fa3d3;
      font-weight: 500;
      font-size: 14px;
    }

    .form-group input {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #ddd;
      border-radius: 5px;
      font-size: 14px;
      transition: border-color 0.3s ease;
    }

    .form-group input:focus {
      outline: none;
      border-color: #5fa3d3;
      box-shadow: 0 0 0 2px rgba(95, 163, 211, 0.2);
    }

    .form-group input.error {
      border-color: #dc3545;
    }

    .form-group input.success {
      border-color: #28a745;
    }

    .password-requirements {
      font-size: 14px;
      color: #666;
      margin-top: 4px;
      line-height: 1.3;
    }

    .password-requirements ul {
      margin: 4px 0;
      padding-left: 18px;
    }

    .password-requirements li {
      margin-bottom: 1px;
    }

    .password-requirements li.valid {
      color: #28a745;
    }

    .password-requirements li.invalid {
      color: #dc3545;
    }

    .password-match {
      font-size: 14px;
      margin-top: 4px;
    }

    .password-match.valid {
      color: #28a745;
    }

    .password-match.invalid {
      color: #dc3545;
    }

    .btn-primary {
      background-color: #5fa3d3;
      color: white;
      padding: 10px 25px;
      border: none;
      border-radius: 5px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      width: 100%;
      margin-top: 15px;
      transition: background-color 0.3s ease;
    }

    .btn-primary:hover {
      background-color: #4a8db8;
    }

    .btn-primary:disabled {
      background-color: #ccc;
      cursor: not-allowed;
    }

    .btn-secondary {
      background-color: transparent;
      color: #5fa3d3;
      padding: 8px 16px;
      border: 2px solid #5fa3d3;
      border-radius: 5px;
      font-size: 14px;
      cursor: pointer;
      width: 100%;
      margin-top: 12px;
      transition: all 0.3s ease;
    }

    .btn-secondary:hover {
      background-color: #5fa3d3;
      color: white;
    }

    .error-message {
      background-color: #f8d7da;
      color: #721c24;
      padding: 10px 12px;
      border: 1px solid #f5c6cb;
      border-radius: 5px;
      margin-bottom: 15px;
      font-size: 14px;
    }

    .success-message {
      background-color: #d4edda;
      color: #155724;
      padding: 10px 12px;
      border: 1px solid #c3e6cb;
      border-radius: 5px;
      margin-bottom: 15px;
      font-size: 14px;
    }

    .back-link {
      text-align: center;
      margin-top: 15px;
    }

    .back-link a {
      color: #5fa3d3;
      text-decoration: none;
      font-size: 14px;
    }

    .back-link a:hover {
      text-decoration: underline;
    }

    .timer-info {
      background-color: #fff3cd;
      border: 1px solid #ffeaa7;
      border-radius: 8px;
      padding: 10px 12px;
      margin-bottom: 15px;
      text-align: center;
      font-size: 14px;
      color: #856404;
      display: block !important;
      visibility: visible !important;
    }

    /* Popup de éxito */
    .popup-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.5);
      display: none;
      justify-content: center;
      align-items: center;
      z-index: 9999;
      animation: fadeIn 0.3s ease;
    }

    .popup-overlay.show {
      display: flex;
    }

    .popup-content {
      background: white;
      border-radius: 15px;
      padding: 40px 30px;
      text-align: center;
      max-width: 400px;
      width: 90%;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
      animation: slideIn 0.3s ease;
      position: relative;
    }

    .popup-icon {
      width: 80px;
      height: 80px;
      background-color: #28a745;
      border-radius: 15px;
      margin: 0 auto 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 40px;
      color: white;
      box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
    }

    .popup-title {
      color: #28a745;
      font-size: 22px;
      font-weight: 600;
      margin-bottom: 15px;
    }

    .popup-message {
      color: #666;
      font-size: 16px;
      line-height: 1.5;
      margin-bottom: 25px;
    }

    .popup-btn {
      background-color: #28a745;
      color: white;
      border: none;
      padding: 12px 30px;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: background-color 0.3s ease;
      min-width: 120px;
    }

    .popup-btn:hover {
      background-color: #218838;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    @keyframes slideIn {
      from { 
        opacity: 0;
        transform: scale(0.8) translateY(-20px);
      }
      to { 
        opacity: 1;
        transform: scale(1) translateY(0);
      }
    }

    @media (max-width: 768px) {
      .content {
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
      
      .popup-content {
        margin: 20px;
        padding: 30px 20px;
      }
      
      .popup-icon {
        width: 70px;
        height: 70px;
        font-size: 35px;
      }
      
      .popup-title {
        font-size: 20px;
      }
      
      .popup-message {
        font-size: 15px;
      }
    }
  </style>
</head>

<body>
<div class="main-container">
  <!-- Popup de éxito -->
  <div class="popup-overlay" id="successPopup">
    <div class="popup-content">
      <div class="popup-icon">
        <i class="fas fa-check"></i>
      </div>
      <h3 class="popup-title">¡Contraseña Cambiada!</h3>
      <p class="popup-message">
        Tu contraseña ha sido restablecida exitosamente.<br>
        Ya puedes iniciar sesión con tus nuevas credenciales.
      </p>
      <button class="popup-btn" onclick="redirectToLogin()">Continuar</button>
    </div>
  </div>

  <!-- Barra superior -->
  <header class="header-bar">
    <img src="imagenes/logo.jpg" alt="Logo ONU Mujeres">
  </header>

  <!-- Contenido principal -->
  <main class="content">
    <!-- Sección de imagen -->
    <section class="image-section">
    </section>

    <!-- Sección de verificación -->
    <section class="form-section">
      <h4>RESTABLECER CONTRASEÑA</h4>

      <div class="email-info">
        <p>Se ha enviado un código de verificación a:</p>
        <strong>${correoUsuario}</strong>
      </div>

      <div class="timer-info" id="timerInfo">
        ⏰ Tiempo restante: <span id="timeLeft">05:00</span>
      </div>

      <c:if test="${not empty error}">
        <div class="error-message">${error}</div>
      </c:if>

      <c:if test="${not empty success}">
        <div class="success-message">${success}</div>
      </c:if>

      <div id="errorContainer" class="error-message" style="display: none;">
        <span id="errorMessage"></span>
      </div>

      <div id="successContainer" class="success-message" style="display: none;">
        <span id="successMessage"></span>
      </div>

      <form id="resetPasswordForm" action="restablecerPassword" method="post">
        <input type="hidden" name="correo" value="${correoUsuario}">

        <!-- Campo de código -->
        <div class="form-group">
          <label for="codigo">Código de Verificación *</label>
          <input type="text" 
                 id="codigo" 
                 name="codigo" 
                 maxlength="6" 
                 placeholder="Ingresa el código de 6 caracteres"
                 pattern="[A-Za-z0-9]{6}"
                 style="text-transform: uppercase;"
                 required>
          <div class="password-requirements">
            Ingresa el código de 6 caracteres (números y letras) que recibiste por correo electrónico
          </div>
        </div>

        <!-- Campo de contraseña -->
        <div class="form-group">
          <label for="password">Nueva Contraseña *</label>
          <input type="password" 
                 id="password" 
                 name="password" 
                 placeholder="Ingresa tu nueva contraseña"
                 required>
          <div class="password-requirements">
            <strong>La contraseña debe contener:</strong>
            <ul id="passwordChecklist">
              <li id="length" class="invalid"> Mínimo 8 caracteres</li>
              <li id="uppercase" class="invalid"> Al menos 1 letra mayúscula</li>
              <li id="lowercase" class="invalid"> Al menos 1 letra minúscula</li>
              <li id="number" class="invalid"> Al menos 1 número</li>
              <li id="special" class="invalid"> Al menos 1 carácter especial (@$!%*?&)</li>
            </ul>
          </div>
        </div>

        <!-- Campo de confirmar contraseña -->
        <div class="form-group">
          <label for="confirmPassword">Confirmar Contraseña *</label>
          <input type="password" 
                 id="confirmPassword" 
                 name="confirmPassword" 
                 placeholder="Confirma tu nueva contraseña"
                 required>
          <div id="passwordMatch" class="password-match"></div>
        </div>

        <button type="submit" class="btn-primary" id="submitBtn" disabled>
          Restablecer Contraseña
        </button>
      </form>

      <!-- Botón para reenviar código -->
      <button type="button" class="btn-secondary" id="resendBtn" onclick="reenviarCodigo()">
        Reenviar Código
      </button>

      <div class="back-link">
        <a href="enviarCodigoRecuperacion">← Volver a recuperación</a>
      </div>
    </section>
  </main>

  <!-- Footer -->
  <footer style="background: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%); color: #333; text-align: center; padding: 15px 0; margin-top: auto; box-shadow: 0 -2px 10px rgba(135,206,235,0.3);">
    <p style="margin: 0; font-size: 14px; font-weight: 500;">© 2025 ONU Mujeres - Sistema de Encuestas. Todos los derechos reservados.</p>
  </footer>
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
      window.location.href = 'enviarCodigoRecuperacion';
      return;
    }
    
    // Elementos del DOM
    const codigoInput = document.getElementById('codigo');
    const timerInfo = document.getElementById('timerInfo');
    const timeLeft = document.getElementById('timeLeft');

    // Mostrar el temporizador inmediatamente
    if (timerInfo) {
      timerInfo.style.display = 'block';
      timerInfo.style.visibility = 'visible';
    }

    // Configurar validación
    setupValidation();
    
    // Enfocar en el campo de código
    if (codigoInput) {
      codigoInput.focus();
    }
    
    // Sincronizar tiempo con el servidor e iniciar temporizador
    await sincronizarTiempo();
    startTimer();
    
    // Sincronizar cada 30 segundos
    setInterval(async () => {
      await sincronizarTiempo();
    }, 30000);
  });

  // Función para sincronizar tiempo con el servidor
  async function sincronizarTiempo() {
    const correo = '${correoUsuario}';
    
    try {
      const response = await fetch('tiempoRestanteRecuperacion?correo=' + encodeURIComponent(correo));
      const data = await response.json();
      
      timeRemaining = data.segundos;
      
      if (timeRemaining <= 0) {
          // Código expirado
          clearInterval(timerInterval);
          const timerInfo = document.getElementById('timerInfo');
          timerInfo.style.backgroundColor = '#f8d7da';
          timerInfo.style.color = '#721c24';
          timerInfo.style.borderColor = '#f5c6cb';
          timerInfo.innerHTML = '⚠️ El código ha expirado. Solicita uno nuevo.';
          
          // Deshabilitar formulario
          document.getElementById('codigo').disabled = true;
          document.getElementById('submitBtn').disabled = true;
      } else {
          // Actualizar el display del timer
          const timeLeftSpan = document.getElementById('timeLeft');
          if (timeLeftSpan) {
              const minutes = Math.floor(timeRemaining / 60);
              const seconds = timeRemaining % 60;
              const timeDisplay = minutes.toString().padStart(2, '0') + ':' + seconds.toString().padStart(2, '0');
              timeLeftSpan.textContent = timeDisplay;
          }
      }
      
      return timeRemaining;
    } catch (error) {
        return 300; // Valor por defecto
    }
  }

  // FUNCIÓN para iniciar el temporizador
  function startTimer() {
    const timerInfo = document.getElementById('timerInfo');
    const timeLeftSpan = document.getElementById('timeLeft');
    
    if (!timerInfo || !timeLeftSpan) {
      return;
    }
    
    // Limpiar timer existente si existe
    if (timerInterval) {
        clearInterval(timerInterval);
    }
    
    // Mostrar el tiempo inicial inmediatamente
    const initialMinutes = Math.floor(timeRemaining / 60);
    const initialSeconds = timeRemaining % 60;
    const initialDisplay = initialMinutes.toString().padStart(2, '0') + ':' + initialSeconds.toString().padStart(2, '0');
    timeLeftSpan.textContent = initialDisplay;
    
    // Configurar el timer
    timerInterval = setInterval(function() {
      if (timeRemaining <= 0) {
        clearInterval(timerInterval);
        timerInfo.style.backgroundColor = '#f8d7da';
        timerInfo.style.color = '#721c24';
        timerInfo.style.borderColor = '#f5c6cb';
        timerInfo.innerHTML = '⚠️ El código ha expirado. Solicita uno nuevo.';
        
        // Deshabilitar código input
        const codigoInput = document.getElementById('codigo');
        const submitBtn = document.getElementById('submitBtn');
        if (codigoInput) codigoInput.disabled = true;
        if (submitBtn) submitBtn.disabled = true;
        return;
      }
      
      const minutes = Math.floor(timeRemaining / 60);
      const seconds = timeRemaining % 60;
      
      const timeDisplay = minutes.toString().padStart(2, '0') + ':' + seconds.toString().padStart(2, '0');
      timeLeftSpan.textContent = timeDisplay;
      
      timeRemaining--;
    }, 1000);
  }

  // Reenviar código
  function reenviarCodigo() {
    const correo = '${correoUsuario}';
    const resendBtn = document.getElementById('resendBtn');
    
    resendBtn.disabled = true;
    resendBtn.textContent = 'Enviando...';
    
    fetch('reenviarCodigoRecuperacion', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'correo=' + encodeURIComponent(correo)
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        showMessage('Código reenviado exitosamente', 'success');
        
        // Reiniciar timer
        clearInterval(timerInterval);
        timeRemaining = 300;
        
        const timerInfo = document.getElementById('timerInfo');
        timerInfo.style.backgroundColor = '#fff3cd';
        timerInfo.style.color = '#856404';
        timerInfo.style.borderColor = '#ffeaa7';
        timerInfo.innerHTML = '⏰ Tiempo restante: <span id="timeLeft">05:00</span>';
        
        startTimer();
        
        // Habilitar código input
        const codigoInput = document.getElementById('codigo');
        codigoInput.disabled = false;
        codigoInput.value = '';
        codigoInput.focus();
        validateForm();
        
      } else {
        showMessage(data.message || 'Error al reenviar el código', 'error');
      }
    })
    .catch(error => {
      showMessage('Error de conexión. Inténtalo nuevamente.', 'error');
    })
    .finally(() => {
      resendBtn.disabled = false;
      resendBtn.textContent = 'Reenviar Código';
    });
  }

  // Mostrar mensajes
  function showMessage(message, type) {
    const errorContainer = document.getElementById('errorContainer');
    const successContainer = document.getElementById('successContainer');
    
    // Ocultar ambos primero
    errorContainer.style.display = 'none';
    successContainer.style.display = 'none';
    
    if (type === 'error') {
      document.getElementById('errorMessage').textContent = message;
      errorContainer.style.display = 'block';
    } else {
      document.getElementById('successMessage').textContent = message;
      successContainer.style.display = 'block';
    }
    
    // Auto-ocultar después de 5 segundos
    setTimeout(() => {
      errorContainer.style.display = 'none';
      successContainer.style.display = 'none';
    }, 5000);
  }

  // Configurar validación en tiempo real
  function setupValidation() {
    const codigoInput = document.getElementById('codigo');
    const passwordInput = document.getElementById('password');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    
    // Validación del código
    codigoInput.addEventListener('input', function() {
      // Permitir solo letras y números, convertir a mayúsculas y limitar a 6 caracteres
      this.value = this.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase().substring(0, 6);
      validateForm();
    });

    // Validación de la contraseña
    passwordInput.addEventListener('input', function() {
      validatePassword();
      validatePasswordMatch();
      validateForm();
    });

    // Validación de confirmar contraseña
    confirmPasswordInput.addEventListener('input', function() {
      validatePasswordMatch();
      validateForm();
    });
  }

  // Validar contraseña
  function validatePassword() {
    const passwordInput = document.getElementById('password');
    const password = passwordInput.value;
    const checks = {
      length: password.length >= 8,
      uppercase: /[A-Z]/.test(password),
      lowercase: /[a-z]/.test(password),
      number: /[0-9]/.test(password),
      special: /[@$!%*?&]/.test(password)
    };

    // Actualizar indicadores visuales
    Object.keys(checks).forEach(check => {
      const element = document.getElementById(check);
      if (element) {
        if (checks[check]) {
          element.classList.remove('invalid');
          element.classList.add('valid');
        } else {
          element.classList.remove('valid');
          element.classList.add('invalid');
        }
      }
    });

    // Cambiar color del borde
    if (Object.values(checks).every(check => check)) {
      passwordInput.classList.remove('error');
      passwordInput.classList.add('success');
    } else {
      passwordInput.classList.remove('success');
      if (password.length > 0) {
        passwordInput.classList.add('error');
      }
    }

    return Object.values(checks).every(check => check);
  }

  // Validar coincidencia de contraseñas
  function validatePasswordMatch() {
    const passwordInput = document.getElementById('password');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const passwordMatch = document.getElementById('passwordMatch');
    const password = passwordInput.value;
    const confirmPassword = confirmPasswordInput.value;

    if (confirmPassword.length === 0) {
      passwordMatch.textContent = '';
      confirmPasswordInput.classList.remove('success', 'error');
      return false;
    }

    if (password === confirmPassword) {
      passwordMatch.textContent = '✓ Las contraseñas coinciden';
      passwordMatch.classList.remove('invalid');
      passwordMatch.classList.add('valid');
      confirmPasswordInput.classList.remove('error');
      confirmPasswordInput.classList.add('success');
      return true;
    } else {
      passwordMatch.textContent = '✗ Las contraseñas no coinciden';
      passwordMatch.classList.remove('valid');
      passwordMatch.classList.add('invalid');
      confirmPasswordInput.classList.remove('success');
      confirmPasswordInput.classList.add('error');
      return false;
    }
  }

  // Validar formulario completo
  function validateForm() {
    const codigoInput = document.getElementById('codigo');
    const submitBtn = document.getElementById('submitBtn');
    const code = codigoInput.value;
    const isCodeValid = code.length === 6 && /^[A-Z0-9]{6}$/.test(code);
    const isPasswordValid = validatePassword();
    const isPasswordMatchValid = validatePasswordMatch();

    // Cambiar color del borde del código
    if (code.length === 0) {
      codigoInput.classList.remove('success', 'error');
    } else if (isCodeValid) {
      codigoInput.classList.remove('error');
      codigoInput.classList.add('success');
    } else {
      codigoInput.classList.remove('success');
      codigoInput.classList.add('error');
    }

    const isFormValid = isCodeValid && isPasswordValid && isPasswordMatchValid;
    submitBtn.disabled = !isFormValid;

    return isFormValid;
  }

  // Manejar envío del formulario
  document.getElementById('resetPasswordForm').addEventListener('submit', function(e) {
    console.log('📝 Formulario enviado - iniciando validación');
    
    if (!validateForm()) {
      e.preventDefault();
      showMessage('Por favor, completa todos los campos correctamente', 'error');
      return false;
    }
    
    // Si la validación pasa, enviar el formulario y manejar la respuesta
    e.preventDefault();
    
    const formData = new FormData(this);
    const submitBtn = document.getElementById('submitBtn');
    
    // Debug: Mostrar datos del formulario
    console.log('📋 Datos del formulario:');
    for (let [key, value] of formData.entries()) {
      console.log(`   - ${key}: ${value}`);
    }
    
    console.log('🔄 Enviando petición al servidor...');
    
    // Deshabilitar botón mientras se procesa
    submitBtn.disabled = true;
    submitBtn.textContent = 'Procesando...';
    
    fetch('restablecerPassword', {
      method: 'POST',
      body: formData
    })
    .then(response => {
      console.log('📡 Respuesta recibida del servidor:');
      console.log('   - Status:', response.status);
      console.log('   - Headers:', response.headers);
      
      // Si la respuesta es una redirección, seguirla
      if (response.redirected) {
        console.log('🔄 Redirección detectada a:', response.url);
        window.location.href = response.url;
        return;
      }
      
      return response.text();
    })
    .then(data => {
      if (!data) return; // Si fue una redirección, data será undefined
      
      console.log('📄 Contenido de la respuesta:', data);
      
      // Intentar parsear como JSON primero
      try {
        const jsonResponse = JSON.parse(data);
        if (jsonResponse.success) {
          console.log('✅ Respuesta JSON exitosa detectada');
          if (jsonResponse.redirect) {
            console.log('🔄 Redirigiendo a:', jsonResponse.redirect);
            window.location.href = jsonResponse.redirect;
          } else {
            // Mostrar popup de éxito y redirigir al login
            showSuccessPopup();
          }
          return;
        }
      } catch (e) {
        // No es JSON, continuar con el procesamiento de texto
        console.log('📝 Respuesta de texto, procesando...');
      }
      
      // Verificar si la respuesta contiene éxito
      if (data.includes('success') || data.includes('exitoso') || data.includes('Contraseña restablecida')) {
        console.log('✅ Respuesta exitosa detectada');
        // Redirigir directamente a la página de confirmación
        window.location.href = 'passwordActualizada.jsp';
      } else if (data.includes('error') || data.includes('Error') || data.includes('incorrecto')) {
        console.log('❌ Error detectado en la respuesta');
        // Mostrar mensaje de error
        if (data.includes('código incorrecto') || data.includes('código no válido')) {
          showMessage('El código ingresado es incorrecto o ha expirado', 'error');
        } else if (data.includes('expirado')) {
          showMessage('El código ha expirado. Solicita uno nuevo', 'error');
        } else {
          showMessage('Error al restablecer la contraseña. Verifica los datos', 'error');
        }
        
        // Rehabilitar botón
        submitBtn.disabled = false;
        submitBtn.textContent = 'Restablecer Contraseña';
      } else {
        console.log('⚠️ Respuesta indeterminada, recargando página');
        // Si no podemos determinar el estado, recargar la página para ver los mensajes del servidor
        location.reload();
      }
    })
    .catch(error => {
      console.error('❌ Error en la petición:', error);
      showMessage('Error de conexión. Inténtalo nuevamente.', 'error');
      
      // Rehabilitar botón
      submitBtn.disabled = false;
      submitBtn.textContent = 'Restablecer Contraseña';
    });
  });

  // Función para mostrar el popup de éxito
  function showSuccessPopup() {
    console.log('🎉 Mostrando popup de éxito y redirigiendo...');
    // Redirigir directamente a la página de confirmación
    window.location.href = 'passwordActualizada.jsp';
  }

  // Función para redirigir al login
  function redirectToLogin() {
    window.location.href = 'LoginServlet';
  }
</script>
</body>
</html>
