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
    <title>Recuperar Contraseña - ONU Mujeres</title>
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
            background-position: center;
            background-repeat: no-repeat;
            min-height: 100%;
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
        .recovery-section {
            width: 100%;
            max-width: none;
            padding: 0;
            background: transparent;
            border-radius: 0;
            box-shadow: none;
            backdrop-filter: none;
            border: none;
            margin-right: 0;
            text-align: center;
        }
        .recovery-section h4 {
            color: #5fa3d3;
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 8px;
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
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            color: #5fa3d3;
            font-weight: 500;
            font-size: 14px;
            text-align: left;
        }
        .form-group input[type="email"] {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: all 0.3s ease;
            background: white;
        }
        .form-group input[type="email"]:focus {
            outline: none;
            border-color: #5fa3d3;
            box-shadow: 0 0 0 2px rgba(95, 163, 211, 0.2);
            background: white;
        }
        .info-message {
            padding: 10px 12px;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 14px;
            border-left: 4px solid;
            background-color: #cce7ff;
            border-color: #87ceeb;
            color: #2c5aa0;
        }
        .error-message {
            padding: 10px 12px;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 14px;
            border-left: 4px solid;
            background-color: #f8d7da;
            border-color: #dc3545;
            color: #721c24;
        }
        .success-message {
            padding: 10px 12px;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 14px;
            border-left: 4px solid;
            background-color: #d4edda;
            border-color: #28a745;
            color: #155724;
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
            margin-top: 10px;
        }
        .links-container a {
            color: #5fa3d3;
            text-decoration: none;
            font-size: 14px;
            margin: 0 5px;
            transition: color 0.3s ease;
            display: inline-block;
            margin-bottom: 5px;
        }
        .links-container a:hover {
            color: #87ceeb;
            text-decoration: underline;
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
                border-radius: 0;
                box-shadow: none;
                min-width: auto;
                padding: 30px 20px;
            }
            .recovery-section {
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
            .form-group input[type="email"] {
                padding: 10px 12px;
            }
            .btn-primary {
                padding: 10px;
                font-size: 14px;
            }
            .links-container {
                margin-top: 8px;
            }
            .links-container a {
                display: block;
                margin: 5px 0;
                font-size: 13px;
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
            .content-wrapper {
                width: 100%;
                box-sizing: border-box;
            }
            .recovery-section {
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

    <!-- Contenido principal -->
    <div class="content-wrapper">
        <!-- Sección de Imagen -->
        <div class="image-section"></div>
        
        <!-- Sección del Formulario -->
        <div class="form-section">
            <section class="recovery-section">
            <div class="login-header">
                <h1>Recuperar Contraseña</h1>
                <p>Ingresa tu correo para restablecer tu acceso</p>
            </div>
            
            <div class="welcome-message">
                <h5><i class="fas fa-key"></i> Restablece tu Acceso</h5>
                <p>Ingresa tu correo electrónico para recibir un enlace de recuperación de contraseña.</p>
            </div>
            
            <div class="info-message">
                <i class="fas fa-info-circle"></i>
                <strong>Importante:</strong> Revisa tu bandeja de entrada y la carpeta de spam. 
                El enlace de recuperación será válido por 10 minutos.
            </div>
            
            <!-- Mensajes de error y éxito -->
            <c:if test="${not empty error}">
                <div class="error-message">
                    <i class="fas fa-exclamation-triangle"></i>
                    <c:choose>
                        <c:when test="${error == 'usuario_no_encontrado'}">
                            No se encontró una cuenta con ese correo electrónico.
                        </c:when>
                        <c:when test="${error == 'email_error'}">
                            Error al enviar el correo. Inténtalo nuevamente.
                        </c:when>
                        <c:otherwise>
                            ${error}
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <c:if test="${not empty success}">
                <div class="success-message">
                    <i class="fas fa-check-circle"></i> ${success}
                </div>
            </c:if>

            <form action="enviarCodigoRecuperacion" method="post">
                <!-- Campo de correo -->
                <div class="form-group">
                    <label for="correo"><i class="fas fa-envelope"></i> Correo Electrónico</label>
                    <input type="email"
                           id="correo"
                           name="correo"
                           placeholder="Ingresa tu correo electrónico"
                           value="${param.correo}"
                           required>
                </div>

                <button type="submit" class="btn-primary">
                    <i class="fas fa-paper-plane"></i> Enviar código de recuperación
                </button>
            </form>

            <div class="links-container">
                <a href="LoginServlet">
                    <i class="fas fa-arrow-left"></i> Volver al inicio de sesión
                </a>
                <a href="registro">
                    <i class="fas fa-user-plus"></i> ¿No tienes cuenta? Regístrate aquí
                </a>
            </div>
        </section>
        </div>
    </div>

    <!-- Footer -->
    <div class="footer">
        <p>&copy; 2025 ONU Mujeres. Todos los derechos reservados.</p>
    </div>
</div>
</body>
</html>
