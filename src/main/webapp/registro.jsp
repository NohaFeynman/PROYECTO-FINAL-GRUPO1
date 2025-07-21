<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    // Verificar si hay distritos cargados
    java.util.List distritos = (java.util.List) request.getAttribute("distritos");
    if (distritos == null) {
        System.out.println("⚠️ JSP: No hay distritos en request, redirigiendo al servlet...");
        response.sendRedirect("registro");
        return;
    } else {
        System.out.println("✅ JSP: " + distritos.size() + " distritos encontrados en request");
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Usuario - ONU Mujeres</title>
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
            padding: 50px 40px 50px 45px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            min-width: 520px;
            border-radius: 0;
            box-shadow: none;
            position: relative;
            z-index: 2;
            margin-right: 0;
            width: 100%;
            overflow-x: visible;
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
        .registro-section {
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
        .registro-section h4 {
            color: #5fa3d3;
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 15px;
            text-align: center;
        }
        .welcome-message {
            background: linear-gradient(135deg, #e8f4f8 0%, #d4edda 100%);
            border: 2px solid #b8dacc;
            border-radius: 12px;
            padding: 20px;
            margin: 20px 0;
            color: #155724;
        }
        .welcome-message h5 {
            font-size: 1.2em;
            font-weight: 600;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .welcome-message p {
            margin: 8px 0;
            line-height: 1.6;
        }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 20px;
            text-align: left;
            width: 100%;
            box-sizing: border-box;
            align-items: start;
        }
        .form-group {
            display: flex;
            flex-direction: column;
            min-width: 0;
            overflow: visible;
            width: 100%;
        }
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        .form-group label {
            margin-bottom: 8px;
            font-weight: 600;
            color: #5fa3d3;
            font-size: 0.95em;
        }
        .form-group input,
        .form-group select {
            padding: 15px;
            border: 2px solid #e1e5e9;
            border-radius: 10px;
            font-size: 1em;
            transition: all 0.3s ease;
            background: #f8f9fa;
            width: 100%;
            box-sizing: border-box;
            min-width: 0;
        }
        .form-group input:focus,
        .form-group select:focus {
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
            width: 100%;
            box-sizing: border-box;
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
            gap: 15px;
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
            text-align: center;
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
        .footer {
            background: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
            padding: 15px;
            text-align: center;
            color: white;
            margin-top: auto;
        }
        .footer p {
            margin: 0;
            font-size: 0.9rem;
        }
        
        @media (max-width: 768px) {
            .content-wrapper {
                flex-direction: column;
            }
            .image-section {
                display: none;
            }
            .form-section {
                padding: 30px 20px;
                justify-content: center;
                min-width: auto;
            }
            .form-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            .registro-section {
                margin: 0;
                margin-right: 0;
                padding: 25px 15px;
                border-radius: 15px;
                border-right: 1px solid rgba(255,255,255,0.2);
                max-width: none;
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
            .registro-section h4 {
                font-size: 1.6em;
                margin-bottom: 10px;
            }
            .form-group input,
            .form-group select {
                padding: 12px;
                font-size: 16px; /* Evita zoom en iOS */
            }
            .header-bar {
                height: 60px;
            }
            .logo-container img {
                height: 40px;
            }
        }
        
        @media (max-width: 480px) {
            .registro-section {
                padding: 20px 10px;
            }
            .welcome-message {
                padding: 12px;
                margin: 10px 0;
            }
            .registro-section h4 {
                font-size: 1.4em;
            }
            .form-group {
                margin-bottom: 15px;
            }
            .password-requirements {
                font-size: 0.8em;
                padding: 10px;
                width: 100%;
                box-sizing: border-box;
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
            .registro-section {
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

        /* Estilos del popup de éxito */
        .popup-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(5px);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 10000;
            animation: fadeIn 0.3s ease;
        }

        .popup-overlay.show {
            display: flex;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes popupSlide {
            from { 
                transform: scale(0.8) translateY(-20px);
                opacity: 0;
            }
            to { 
                transform: scale(1) translateY(0);
                opacity: 1;
            }
        }

        .popup-content {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            text-align: center;
            max-width: 450px;
            width: 90%;
            animation: popupSlide 0.4s ease;
            border: 2px solid #87ceeb;
        }

        .popup-icon {
            font-size: 4rem;
            color: #28a745;
            margin-bottom: 20px;
            animation: bounce 1s infinite;
        }

        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-10px); }
            60% { transform: translateY(-5px); }
        }

        .popup-title {
            color: #2c5aa0;
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .popup-message {
            color: #666;
            font-size: 1.1rem;
            line-height: 1.6;
            margin-bottom: 25px;
        }

        .popup-info {
            background: #f8f9fa;
            border: 2px solid #87ceeb;
            border-radius: 10px;
            padding: 15px;
            margin: 15px 0;
            font-size: 0.95rem;
            color: #495057;
        }

        .popup-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 25px;
        }

        .popup-btn {
            padding: 12px 25px;
            border: none;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            min-width: 120px;
        }

        .popup-btn-primary {
            background: linear-gradient(135deg, #87ceeb 0%, #5fa3d3 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(135,206,235,0.4);
        }

        .popup-btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(135,206,235,0.6);
        }

        .popup-btn-secondary {
            background: transparent;
            color: #0066cc;
            border: 2px solid #0066cc;
        }

        .popup-btn-secondary:hover {
            background: #0066cc;
            color: white;
        }
    </style>
</head>
<body>
<div class="main-container">
    <!-- Popup de registro exitoso -->
    <div id="successPopup" class="popup-overlay">
        <div class="popup-content">
            <div class="popup-icon">
                <i class="fas fa-check-circle"></i>
            </div>
            <h2 class="popup-title">¡Registro Exitoso!</h2>
            <p class="popup-message">
                Tu cuenta ha sido creada correctamente.
            </p>
            <div class="popup-info">
                <strong>📧 Verificación requerida:</strong><br>
                Hemos enviado un correo de verificación a tu dirección de email. 
                Por favor, revisa tu bandeja de entrada y sigue las instrucciones para activar tu cuenta.
            </div>
            <div class="popup-buttons">
                <button class="popup-btn popup-btn-primary" onclick="irAlLogin()">
                    <i class="fas fa-sign-in-alt"></i> Ir al Login
                </button>
                <button class="popup-btn popup-btn-secondary" onclick="cerrarPopup()">
                    Cerrar
                </button>
            </div>
        </div>
    </div>

    <!-- Header -->
    <header class="header-bar">
        <div class="logo-container">
            <img src="${pageContext.request.contextPath}/imagenes/logo.jpg" alt="Logo ONU Mujeres" />
        </div>
    </header>

    <!-- Contenido principal -->
    <main class="content-wrapper">
        <!-- Sección de Imagen -->
        <div class="image-section"></div>
        
        <!-- Sección del Formulario -->
        <div class="form-section">
            <section class="registro-section">
            <h4>CREAR CUENTA</h4>
            
            <div class="welcome-message">
                <h5><i class="fas fa-user-plus"></i> Únete a la Plataforma</h5>
                <p>Completa el formulario para crear tu cuenta en el sistema de encuestas de ONU Mujeres.</p>
                <p><strong>Nota:</strong> Recibirás un correo de verificación para activar tu cuenta.</p>
            </div>
            
            <!-- Mensaje cuando hay proceso en curso -->
            <c:if test="${not empty sessionScope.registroEnProceso}">
                <div class="info-message" style="background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%); color: #0d47a1; padding: 15px; border-radius: 10px; margin: 15px 0; border: 2px solid #64b5f6; font-weight: 600; text-align: center;">
                    <i class="fas fa-info-circle"></i> Ya tienes un proceso de verificación en curso para <strong>${sessionScope.registroEnProceso}</strong>. 
                    <a href="verificarCodigo" style="color: #0d47a1; text-decoration: underline;">Continuar verificación</a>
                </div>
            </c:if>
            
            <!-- Mensajes de error y éxito -->
            <c:if test="${not empty error}">
                <div class="error-message">
                    <i class="fas fa-exclamation-triangle"></i> ${error}
                    <c:if test="${fn:contains(error, 'ya está registrado')}">
                        <div style="margin-top: 10px; font-size: 0.9em;">
                            <a href="enviarCodigoRecuperacion" style="color: #721c24; text-decoration: underline;">
                                ¿Olvidaste tu contraseña? Recupérala aquí
                            </a>
                        </div>
                    </c:if>
                </div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="success-message">
                    <i class="fas fa-check-circle"></i> ${success}
                </div>
            </c:if>
            <c:if test="${not empty info}">
                <div class="info-message" style="background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%); color: #0d47a1; padding: 15px; border-radius: 10px; margin: 15px 0; border: 2px solid #64b5f6; font-weight: 600; text-align: center;">
                    <i class="fas fa-info-circle"></i> ${info}
                </div>
            </c:if>

            <form id="registroForm" action="registro" method="post">
                <div class="form-grid">
                    <!-- Datos personales -->
                    <div class="form-group">
                        <label for="nombre"><i class="fas fa-user"></i> Nombre:</label>
                        <input type="text"
                               id="nombre"
                               name="nombre"
                               placeholder="Ingresa tu nombre"
                               value="${param.nombre}"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="apellidopaterno"><i class="fas fa-user"></i> Apellido Paterno:</label>
                        <input type="text"
                               id="apellidopaterno"
                               name="apellidopaterno"
                               placeholder="Apellido paterno"
                               value="${param.apellidopaterno}"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="apellidomaterno"><i class="fas fa-user"></i> Apellido Materno:</label>
                        <input type="text"
                               id="apellidomaterno"
                               name="apellidomaterno"
                               placeholder="Apellido materno"
                               value="${param.apellidomaterno}"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="dni"><i class="fas fa-id-card"></i> DNI:</label>
                        <input type="text"
                               id="dni"
                               name="dni"
                               placeholder="12345678"
                               pattern="[0-9]{8}"
                               maxlength="8"
                               value="${param.dni}"
                               required>
                    </div>

                    <div class="form-group full-width">
                        <label for="direccion"><i class="fas fa-map-marker-alt"></i> Dirección:</label>
                        <input type="text"
                               id="direccion"
                               name="direccion"
                               placeholder="Ingresa tu dirección completa"
                               value="${param.direccion}"
                               required>
                    </div>

                    <!-- Distrito -->
                    <div class="form-group full-width">
                        <label for="idDistrito"><i class="fas fa-city"></i> Distrito de Residencia:</label>
                        <select id="idDistrito" name="idDistrito" required>
                            <option value="">Selecciona tu distrito</option>
                            <c:choose>
                                <c:when test="${empty distritos}">
                                    <option value="" disabled>No hay distritos disponibles</option>
                                    <%
                                        System.out.println("❌ JSP: Lista de distritos está vacía o es null");
                                    %>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="distrito" items="${distritos}">
                                        <option value="${distrito.idDistrito}" 
                                            ${param.idDistrito == distrito.idDistrito ? 'selected' : ''}>
                                            ${distrito.nombreDistrito}
                                        </option>
                                    </c:forEach>
                                    <%
                                        System.out.println("✅ JSP: Distritos renderizados exitosamente");
                                    %>
                                </c:otherwise>
                            </c:choose>
                        </select>
                    </div>

                    <!-- Credenciales -->
                    <div class="form-group full-width">
                        <label for="correo"><i class="fas fa-envelope"></i> Correo Electrónico:</label>
                        <input type="email"
                               id="correo"
                               name="correo"
                               placeholder="ejemplo@correo.com"
                               value="${param.correo}"
                               required>
                    </div>

                    <div class="form-group full-width">
                        <label for="password"><i class="fas fa-lock"></i> Contraseña:</label>
                        <input type="password"
                               id="password"
                               name="password"
                               placeholder="Crea tu contraseña"
                               required>
                        <div class="password-requirements">
                            <strong>La contraseña debe contener:</strong>
                            <ul id="passwordChecklist">
                                <li id="length" class="invalid">Mínimo 8 caracteres</li>
                                <li id="uppercase" class="invalid">Al menos una letra mayúscula</li>
                                <li id="lowercase" class="invalid">Al menos una letra minúscula</li>
                                <li id="number" class="invalid">Al menos un número</li>
                                <li id="special" class="invalid">Al menos un carácter especial (!@#$%^&*)</li>
                            </ul>
                        </div>
                    </div>

                    <div class="form-group full-width">
                        <label for="confirmPassword"><i class="fas fa-check-double"></i> Confirmar Contraseña:</label>
                        <input type="password"
                               id="confirmPassword"
                               name="confirmPassword"
                               placeholder="Confirma tu contraseña"
                               required>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-primary" id="submitBtn" disabled>
                        <i class="fas fa-user-plus"></i> Crear Cuenta
                    </button>
                    <button type="button" class="btn-secondary" onclick="window.location.href='LoginServlet'">
                        <i class="fas fa-arrow-left"></i> Volver al Login
                    </button>
                </div>
            </form>

            <div class="back-link">
                <a href="LoginServlet"><i class="fas fa-sign-in-alt"></i> ¿Ya tienes cuenta? Inicia sesión aquí</a>
            </div>
        </section>
        </div>
    </main>

    <!-- Pie de página -->
    <!-- Footer -->
    <div class="footer">
        <p>&copy; 2025 ONU Mujeres. Todos los derechos reservados.</p>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const passwordInput = document.getElementById('password');
        const confirmPasswordInput = document.getElementById('confirmPassword');
        const submitBtn = document.getElementById('submitBtn');
        const dniInput = document.getElementById('dni');

        // Detectar si es una recarga de página y limpiar formulario si es necesario
        if (performance.navigation.type === 1) {
            // Es una recarga - limpiar campos sensibles
            console.log('🔄 Recarga detectada - limpiando formulario');
            const form = document.getElementById('registroForm');
            if (form) {
                // Limpiar solo campos de contraseña para evitar pérdida de datos
                if (passwordInput) passwordInput.value = '';
                if (confirmPasswordInput) confirmPasswordInput.value = '';
                // Re-deshabilitar el botón submit
                if (submitBtn) submitBtn.disabled = true;
            }
        }

        // Validación de DNI
        dniInput.addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '');
        });

        // Validación en tiempo real de contraseña
        passwordInput.addEventListener('input', validarPassword);
        confirmPasswordInput.addEventListener('input', validarFormulario);

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
            const password = passwordInput.value;
            const confirmPassword = confirmPasswordInput.value;

            const passwordValido = password.length >= 8 && 
                                   /[A-Z]/.test(password) && 
                                   /[a-z]/.test(password) && 
                                   /\d/.test(password) && 
                                   /[!@#$%^&*(),.?":{}|<>]/.test(password);
            const passwordsCoinciden = password === confirmPassword && password.length > 0;

            submitBtn.disabled = !(passwordValido && passwordsCoinciden);
        }

        // Validación antes del envío
        document.getElementById('registroForm').addEventListener('submit', function(e) {
            const password = passwordInput.value;
            const confirmPassword = confirmPasswordInput.value;

            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Las contraseñas no coinciden.');
                return false;
            }

            if (dniInput.value.length !== 8) {
                e.preventDefault();
                alert('El DNI debe tener exactamente 8 dígitos.');
                return false;
            }

            return true;
        });

        // Verificar si hay mensaje de éxito y mostrar popup
        <c:if test="${not empty success}">
            mostrarPopupExito();
        </c:if>
        
        // Verificar si los distritos se cargaron correctamente
        const selectDistrito = document.getElementById('idDistrito');
        const options = selectDistrito.querySelectorAll('option');
        
        console.log('🔍 Opciones en select de distrito:', options.length);
        
        // Si solo hay la opción por defecto, intentar cargar distritos vía AJAX
        if (options.length <= 1) {
            console.log('⚠️ No hay distritos cargados, intentando cargar vía AJAX...');
            cargarDistritosAjax();
        } else {
            console.log('✅ Distritos cargados correctamente:', options.length - 1);
        }
    });
    
    // Función para cargar distritos vía AJAX como fallback
    function cargarDistritosAjax() {
        fetch('/WebProyecto-1.0-SNAPSHOT/api/distritos')
            .then(response => response.json())
            .then(distritos => {
                console.log('📋 Distritos recibidos vía AJAX:', distritos.length);
                const select = document.getElementById('idDistrito');
                
                // Limpiar opciones existentes excepto la primera
                while (select.children.length > 1) {
                    select.removeChild(select.lastChild);
                }
                
                // Añadir distritos
                distritos.forEach(distrito => {
                    const option = document.createElement('option');
                    option.value = distrito.idDistrito;
                    option.textContent = distrito.nombreDistrito;
                    select.appendChild(option);
                });
                
                console.log('✅ Distritos cargados vía AJAX exitosamente');
            })
            .catch(error => {
                console.error('❌ Error cargando distritos vía AJAX:', error);
                // Como último recurso, cargar distritos manualmente
                cargarDistritosManual();
            });
    }
    
    // Función para cargar distritos manualmente como último recurso
    function cargarDistritosManual() {
        console.log('🔧 Cargando distritos manualmente...');
        const distritos = [
            {id: 1, nombre: 'Ancón'},
            {id: 2, nombre: 'Ate'},
            {id: 3, nombre: 'Barranco'},
            {id: 4, nombre: 'Breña'},
            {id: 5, nombre: 'Carabayllo'},
            {id: 6, nombre: 'Chaclacayo'},
            {id: 7, nombre: 'Chorrillos'},
            {id: 8, nombre: 'Cieneguilla'},
            {id: 9, nombre: 'Comas'},
            {id: 10, nombre: 'El Agustino'},
            {id: 11, nombre: 'Independencia'},
            {id: 12, nombre: 'Jesús María'},
            {id: 13, nombre: 'La Molina'},
            {id: 14, nombre: 'La Victoria'},
            {id: 15, nombre: 'Lima'},
            {id: 16, nombre: 'Lince'},
            {id: 17, nombre: 'Los Olivos'},
            {id: 18, nombre: 'Lurigancho'},
            {id: 19, nombre: 'Lurín'},
            {id: 20, nombre: 'Magdalena del Mar'},
            {id: 21, nombre: 'Miraflores'},
            {id: 22, nombre: 'Pachacámac'},
            {id: 23, nombre: 'Pucusana'},
            {id: 24, nombre: 'Pueblo Libre'},
            {id: 25, nombre: 'Puente Piedra'},
            {id: 26, nombre: 'Punta Hermosa'},
            {id: 27, nombre: 'Punta Negra'},
            {id: 28, nombre: 'Rímac'},
            {id: 29, nombre: 'San Bartolo'},
            {id: 30, nombre: 'San Borja'},
            {id: 31, nombre: 'San Isidro'},
            {id: 32, nombre: 'San Juan de Lurigancho'},
            {id: 33, nombre: 'San Juan de Miraflores'},
            {id: 34, nombre: 'San Luis'},
            {id: 35, nombre: 'San Martín de Porres'},
            {id: 36, nombre: 'San Miguel'},
            {id: 37, nombre: 'Santa Anita'},
            {id: 38, nombre: 'Santa María del Mar'},
            {id: 39, nombre: 'Santa Rosa'},
            {id: 40, nombre: 'Santiago de Surco'},
            {id: 41, nombre: 'Surquillo'},
            {id: 42, nombre: 'Villa El Salvador'},
            {id: 43, nombre: 'Villa María del Triunfo'}
        ];
        
        const select = document.getElementById('idDistrito');
        
        distritos.forEach(distrito => {
            const option = document.createElement('option');
            option.value = distrito.id;
            option.textContent = distrito.nombre;
            select.appendChild(option);
        });
        
        console.log('✅ Distritos de Lima cargados manualmente');
    }

    // Función para mostrar el popup de éxito
    function mostrarPopupExito() {
        const popup = document.getElementById('successPopup');
        popup.classList.add('show');
        
        // Ocultar el mensaje de éxito estándar si existe
        const successMessage = document.querySelector('.success-message');
        if (successMessage) {
            successMessage.style.display = 'none';
        }
    }

    // Función para cerrar el popup
    function cerrarPopup() {
        const popup = document.getElementById('successPopup');
        popup.classList.remove('show');
    }

    // Función para ir al login
    function irAlLogin() {
        window.location.href = 'LoginServlet';
    }

    // Cerrar popup al hacer clic fuera de él
    document.getElementById('successPopup').addEventListener('click', function(e) {
        if (e.target === this) {
            cerrarPopup();
        }
    });
</script>
</body>
</html>