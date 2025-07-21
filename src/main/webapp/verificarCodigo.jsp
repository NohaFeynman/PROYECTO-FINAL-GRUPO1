<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verificar Código - ONU Mujeres</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f0f8ff 0%, #e6f3ff 100%);
            min-height: 100vh;
            color: #333;
        }
        .main-container {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        .header-bar {
            background: linear-gradient(135deg, #87ceeb 0%, #b8d4f0 100%);
            height: 80px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 15px rgba(135,206,235,0.3);
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
            height: 60px;
            width: auto;
            border-radius: 8px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.2);
        }        .content {
            flex: 1;
            display: flex;
        }
        .image-section {
            flex: 2;
            background-image: url('imagenes/NuevaPortada.jpg');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            min-height: calc(100vh - 140px);
            position: relative;
        }
        .form-section {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background: linear-gradient(135deg, #f8fcff 0%, #f0f8ff 100%);
        }
        .verification-card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 15px 40px rgba(135,206,235,0.2);
            width: 100%;
            max-width: 500px;
            border: 1px solid rgba(135,206,235,0.2);
        }
        .verification-header {
            text-align: center;
            margin-bottom: 40px;
        }
        .verification-header h1 {
            color: #5fa3d3;
            font-size: 2.2em;
            font-weight: 700;
            margin-bottom: 15px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .verification-header p {
            color: #666;
            font-size: 1.1em;
            line-height: 1.6;
            margin-bottom: 10px;
        }
        .welcome-message {
            background: linear-gradient(135deg, #e8f5e8 0%, #d4edda 100%);
            border: 2px solid #c3e6cb;
            border-radius: 12px;
            padding: 20px;
            margin: 25px 0;
            color: #155724;
            text-align: center;
            width: 100%;
            box-sizing: border-box;
        }
        .welcome-message h5 {
            font-size: 1.2em;
            font-weight: 600;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .welcome-message p {
            margin: 5px 0;
            line-height: 1.5;
        }
        .email-display {
            background: linear-gradient(135deg, #fff8e1 0%, #fffacd 100%);
            border: 2px solid #ffd54f;
            border-radius: 12px;
            padding: 15px;
            margin: 20px 0;
            color: #f57f17;
            font-weight: 600;
            text-align: center;
            font-size: 1.05em;
            width: 100%;
            box-sizing: border-box;
        }
        .form-group {
            margin-bottom: 25px;
            width: 100%;
        }
        .form-group label {
            display: block;
            margin-bottom: 10px;
            color: #5fa3d3;
            font-weight: 600;
            font-size: 1em;
            width: 100%;
        }
        .form-group input[type="text"] {
            width: 100%;
            padding: 15px;
            border: 2px solid #e1e8ed;
            border-radius: 12px;
            font-size: 1.1em;
            transition: all 0.3s ease;
            background: #f8f9fa;
            text-align: center;
            font-weight: 600;
            letter-spacing: 2px;
            box-sizing: border-box;
        }
        .form-group input[type="text"]:focus {
            outline: none;
            border-color: #87ceeb;
            background: white;
            box-shadow: 0 0 0 3px rgba(135,206,235,0.15);
        }
        .info-message {
            background: linear-gradient(135deg, #fff8e1 0%, #fffacd 100%);
            border: 2px solid #ffd54f;
            border-radius: 12px;
            padding: 15px;
            margin: 20px 0;
            color: #f57f17;
            font-weight: 500;
            text-align: center;
            width: 100%;
            box-sizing: border-box;
        }
        .error-message {
            background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
            color: #c62828;
            padding: 15px;
            border-radius: 12px;
            margin: 20px 0;
            border: 2px solid #ef9a9a;
            font-weight: 600;
            text-align: center;
            width: 100%;
            box-sizing: border-box;
        }
        .success-message {
            background: linear-gradient(135deg, #e8f5e8 0%, #d4edda 100%);
            color: #2e7d32;
            padding: 15px;
            border-radius: 12px;
            margin: 20px 0;
            border: 2px solid #a5d6a7;
            font-weight: 600;
            text-align: center;
            width: 100%;
            box-sizing: border-box;
        }
        .form-actions {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-top: 30px;
            width: 100%;
        }
        .btn-primary {
            background: linear-gradient(135deg, #87ceeb 0%, #5fa3d3 100%);
            color: white;
            border: none;
            padding: 16px 30px;
            border-radius: 50px;
            font-size: 1.1em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 6px 20px rgba(135,206,235,0.3);
            width: 100%;
            box-sizing: border-box;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #7bb8db 0%, #4a90c2 100%);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(135,206,235,0.4);
        }
        .btn-secondary {
            background: transparent;
            color: #5fa3d3;
            border: 2px solid #5fa3d3;
            padding: 14px 30px;
            border-radius: 50px;
            font-size: 1em;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
            box-sizing: border-box;
        }
        .btn-secondary:hover {
            background: #5fa3d3;
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 4px 15px rgba(95,163,211,0.3);
        }
        .link-container {
            margin-top: 25px;
            text-align: center;
        }
        .link-container a {
            color: #5fa3d3;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95em;
            transition: color 0.3s ease;
        }
        .link-container a:hover {
            color: #87ceeb;
            text-decoration: underline;
        }
        
        /* Timer Styles - Matching coordinator style */
        .timer-container {
            background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
            border: 2px solid #ffc107;
            border-radius: 12px;
            padding: 12px;
            margin: 15px 0;
            color: #856404;
            font-weight: 600;
            font-size: 1.05em;
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
            text-align: center;
            width: 100%;
            box-sizing: border-box;
        }
        
        #timeLeft {
            color: #856404;
            font-family: 'Courier New', monospace;
            font-weight: 700;
        }
        .footer {
            background: linear-gradient(135deg, #87ceeb 0%, #b8d4f0 100%);
            padding: 20px;
            text-align: center;
            color: white;
            margin-top: auto;
        }
        .footer p {
            margin: 0;
            font-size: 0.95rem;
            font-weight: 500;
        }
        
        @media (max-width: 768px) {
            .content {
                flex-direction: column;
            }
            .image-section {
                display: none;
            }
            .form-section {
                padding: 15px;
                min-height: calc(100vh - 140px);
                justify-content: center;
            }
            .verification-card {
                padding: 25px 20px;
                border-radius: 15px;
                margin: 0;
                width: 100%;
                max-width: none;
            }
            .verification-header h1 {
                font-size: 1.8em;
            }
            .verification-header p {
                font-size: 1em;
            }
        }
        
        @media (max-width: 480px) {
            .header-bar {
                height: 70px;
            }
            .logo-container img {
                height: 50px;
            }
            .form-section {
                padding: 10px;
            }
            .verification-card {
                padding: 20px 15px;
                margin: 5px 0;
                width: 100%;
                max-width: none;
            }
            .verification-header h1 {
                font-size: 1.6em;
            }
            .form-group input[type="text"] {
                padding: 12px;
                font-size: 16px; /* Evita zoom en iOS */
            }
            .btn-primary, .btn-secondary {
                padding: 14px 20px;
                font-size: 1em;
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

        <!-- Main Content -->
        <div class="content">
            <!-- Image Section (hidden on mobile) -->
            <div class="image-section"></div>
            
            <!-- Form Section -->
            <div class="form-section">
                <div class="verification-card">
                    <div class="verification-header">
                        <h1>Verificar Código</h1>
                        <p>Ingresa el código de verificación que enviamos a tu correo electrónico</p>
                    </div>

                    <!-- Welcome Message -->
                    <c:if test="${not empty sessionScope.usuario}">
                        <div class="welcome-message">
                            <h5><i class="fas fa-user-check"></i> ¡Bienvenido/a, ${sessionScope.usuario.nombre}!</h5>
                            <p>Tu cuenta ha sido creada exitosamente.</p>
                            <p>Para completar el proceso, verifica tu correo electrónico.</p>
                        </div>
                    </c:if>

                    <!-- Info Display -->
                    <c:if test="${not empty sessionScope.usuario}">
                        <div class="email-display">
                            <i class="fas fa-envelope"></i> Revisa tu correo electrónico para obtener el código
                        </div>
                    </c:if>

                    <!-- Messages -->
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

                    <!-- Verification Form -->
                    <form action="verificarCodigo" method="post">
                        <div class="form-group">
                            <label for="codigo">
                                <i class="fas fa-key"></i> Código de Verificación
                            </label>
                            <input type="text" id="codigo" name="codigo" 
                                   class="form-control" 
                                   placeholder="ABC123" 
                                   maxlength="6" 
                                   required 
                                   autocomplete="off">
                        </div>

                        <div class="info-message">
                            <i class="fas fa-info-circle"></i>
                            El código contiene 6 caracteres (letras y números) y expira en 5 minutos
                        </div>

                        <!-- Timer -->
                        <div class="timer-container" id="timerInfo">
                            ⏰ Tiempo restante: <span id="timeLeft">5:00</span>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn-primary" id="submitBtn">
                                <i class="fas fa-check"></i> Verificar Código
                            </button>
                            
                            <button type="button" class="btn-secondary" id="reenviarBtn" onclick="reenviarCodigo()">
                                <i class="fas fa-redo"></i> Reenviar Código
                            </button>
                        </div>
                    </form>

                    <!-- Links -->
                    <div class="link-container">
                        <a href="LoginServlet">
                            <i class="fas fa-arrow-left"></i> Volver al inicio de sesión
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="footer">
            <p>&copy; 2024 ONU Mujeres. Todos los derechos reservados.</p>
        </div>
    </div>

    <script>
        // Variables globales del temporizador
        let timeRemaining = 300; // 5 minutos
        let timerInterval;

        // Inicializar la página
        document.addEventListener('DOMContentLoaded', async function() {
            // Elementos del DOM
            const codigoInput = document.getElementById('codigo');
            const timerInfo = document.getElementById('timerInfo');
            const timeLeft = document.getElementById('timeLeft');
            
            // Auto-focus en el campo de código
            if (codigoInput) {
                codigoInput.focus();
            }
            
            // Mostrar timer inmediatamente
            if (timerInfo) {
                timerInfo.style.display = 'block';
                timerInfo.style.visibility = 'visible';
            }
            
            // Obtener tiempo real del servidor (solo si NO es un reload)
            const esReload = performance.navigation.type === 1; // 1 = reload
            console.log('🔄 Es reload de página:', esReload);
            
            if (!esReload) {
                try {
                    const response = await fetch('tiempoRestanteVerificacion');
                    if (response.ok) {
                        const data = await response.json();
                        if (data.segundos > 0) {
                            timeRemaining = data.segundos;
                            console.log('⏰ Tiempo sincronizado del servidor:', timeRemaining, 'segundos');
                        } else {
                            console.log('⚠️ Código ya expirado en el servidor');
                            timeRemaining = 0;
                        }
                    }
                } catch (error) {
                    console.log('⚠️ No se pudo sincronizar tiempo, usando valor por defecto');
                    timeRemaining = 300;
                }
            } else {
                // En caso de reload, mantener el timer corriendo desde donde estaba
                try {
                    const response = await fetch('tiempoRestanteVerificacion');
                    if (response.ok) {
                        const data = await response.json();
                        timeRemaining = Math.max(0, data.segundos);
                        console.log('⏰ Tiempo continúa después de reload:', timeRemaining, 'segundos');
                    }
                } catch (error) {
                    console.log('⚠️ Error obteniendo tiempo en reload, usando 0');
                    timeRemaining = 0;
                }
            }
            
            // Iniciar temporizador
            iniciarTemporizador();
        });

        // Función del temporizador (igual que coordinador)
        function iniciarTemporizador() {
            const timeLeft = document.getElementById('timeLeft');
            const timerInfo = document.getElementById('timerInfo');
            
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
                    
                    // Deshabilitar formulario
                    expirarFormulario();
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
        
        // Función para expirar el formulario
        function expirarFormulario() {
            const codigoInput = document.getElementById('codigo');
            const submitBtn = document.getElementById('submitBtn');
            const reenviarBtn = document.getElementById('reenviarBtn');
            
            // Deshabilitar formulario
            if (codigoInput) codigoInput.disabled = true;
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.style.opacity = '0.5';
            }
            
            // Cambiar botón de reenviar
            if (reenviarBtn) {
                reenviarBtn.innerHTML = '<i class="fas fa-redo"></i> Código Expirado - Reenviar Nuevo';
                reenviarBtn.style.background = '#f44336';
                reenviarBtn.style.borderColor = '#f44336';
            }
            
            console.log('❌ Formulario expirado');
        }

        // Función para reiniciar el temporizador
        function reiniciarTimer() {
            console.log('🔄 Reiniciando timer...');
            clearInterval(timerInterval);
            
            // Resetear tiempo a 5 minutos
            timeRemaining = 300;
            
            const timerInfo = document.getElementById('timerInfo');
            const codigoInput = document.getElementById('codigo');
            const submitBtn = document.getElementById('submitBtn');
            const reenviarBtn = document.getElementById('reenviarBtn');
            
            // Rehabilitar formulario
            if (timerInfo) {
                timerInfo.innerHTML = '⏰ Tiempo restante: <span id="timeLeft">5:00</span>';
                timerInfo.style.background = 'linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%)';
                timerInfo.style.borderColor = '#ffc107';
                timerInfo.style.color = '#856404';
            }
            if (codigoInput) {
                codigoInput.disabled = false;
                codigoInput.focus();
            }
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.style.opacity = '1';
            }
            
            // Restaurar botón de reenviar
            if (reenviarBtn) {
                reenviarBtn.innerHTML = '<i class="fas fa-redo"></i> Reenviar Código';
                reenviarBtn.style.background = '';
                reenviarBtn.style.borderColor = '';
                reenviarBtn.disabled = false;
            }
            
            // Iniciar el temporizador
            iniciarTemporizador();
        }

        // Función para reenviar código
        function reenviarCodigo() {
            if (confirm('¿Deseas recibir un nuevo código de verificación?')) {
                const reenviarBtn = document.getElementById('reenviarBtn');
                if (reenviarBtn) {
                    reenviarBtn.disabled = true;
                    reenviarBtn.textContent = 'Enviando...';
                }
                
                // Enviar petición al servlet
                fetch('reenviarCodigo', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    }
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('Nuevo código enviado exitosamente a tu correo.');
                        
                        // Limpiar el campo de código
                        const codigoInput = document.getElementById('codigo');
                        if (codigoInput) {
                            codigoInput.value = '';
                        }
                        
                        // Reiniciar temporizador con nuevo tiempo
                        reiniciarTimer();
                    } else {
                        alert(data.message || 'Error al reenviar el código. Inténtalo nuevamente.');
                        // Re-habilitar botón en caso de error
                        if (reenviarBtn) {
                            reenviarBtn.disabled = false;
                            reenviarBtn.innerHTML = '<i class="fas fa-redo"></i> Reenviar Código';
                        }
                    }
                })
                .catch(error => {
                    console.error('Error al reenviar código:', error);
                    alert('Error de conexión. Inténtalo nuevamente.');
                    // Re-habilitar botón en caso de error
                    if (reenviarBtn) {
                        reenviarBtn.disabled = false;
                        reenviarBtn.innerHTML = '<i class="fas fa-redo"></i> Reenviar Código';
                    }
                });
            }
        }

        // Validación en tiempo real del código
        document.getElementById('codigo').addEventListener('input', function(e) {
            // Permitir letras y números, convertir a mayúsculas
            this.value = this.value.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
            
            // Limitar a 6 caracteres
            if (this.value.length > 6) {
                this.value = this.value.substring(0, 6);
            }
        });

        // Prevenir el pegado de texto que no sea alfanumérico
        document.getElementById('codigo').addEventListener('paste', function(e) {
            e.preventDefault();
            const paste = (e.clipboardData || window.clipboardData).getData('text');
            const alphanumericPaste = paste.replace(/[^a-zA-Z0-9]/g, '').toUpperCase().substring(0, 6);
            this.value = alphanumericPaste;
        });
    </script>
</body>
</html>
