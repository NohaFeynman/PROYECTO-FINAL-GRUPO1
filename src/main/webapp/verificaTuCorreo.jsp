<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verifica tu Correo - ONU Mujeres</title>
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
            width: auto;
            border-radius: 5px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .content-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .success-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(135,206,235,0.2);
            padding: 50px 40px;
            width: 100%;
            max-width: 500px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.2);
            text-align: center;
        }
        .success-icon {
            font-size: 4rem;
            color: #28a745;
            margin-bottom: 20px;
            animation: bounce 2s infinite;
        }
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-10px); }
            60% { transform: translateY(-5px); }
        }
        .success-title {
            color: #0066cc;
            font-size: 2.5rem;
            font-weight: 600;
            margin-bottom: 15px;
        }
        .success-message {
            color: #666;
            font-size: 1.1rem;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .info-box {
            background: #f8f9fa;
            border: 2px solid #87ceeb;
            border-radius: 15px;
            padding: 25px;
            margin: 25px 0;
        }
        .info-box h3 {
            color: #0066cc;
            margin-bottom: 15px;
            font-size: 1.3rem;
        }
        .info-list {
            text-align: left;
            color: #555;
        }
        .info-list li {
            margin: 10px 0;
            padding-left: 10px;
            position: relative;
        }
        .info-list li::before {
            content: '✓';
            color: #28a745;
            font-weight: bold;
            position: absolute;
            left: -10px;
        }
        .btn-primary {
            display: inline-block;
            padding: 15px 30px;
            background: linear-gradient(135deg, #87ceeb 0%, #a8d8ff 100%);
            border: none;
            border-radius: 12px;
            color: white;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            margin: 10px;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #7bb8db 0%, #98c8ef 100%);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(135,206,235,0.4);
            text-decoration: none;
            color: white;
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
            .success-container {
                margin: 10px;
                padding: 40px 30px;
            }
            .success-title {
                font-size: 2rem;
            }
            .success-icon {
                font-size: 3rem;
            }
            .header-bar {
                height: 60px;
            }
            .logo-container img {
                height: 40px;
            }
        }
        @media (max-width: 480px) {
            .content-wrapper {
                padding: 10px;
            }
            .success-container {
                padding: 30px 20px;
            }
            .success-title {
                font-size: 1.8rem;
            }
            .success-message {
                font-size: 1rem;
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
            <div class="success-container">
                <div class="success-icon">
                    <i class="fas fa-envelope-circle-check"></i>
                </div>
                
                <c:choose>
                    <c:when test="${tipoOperacion == 'recuperacion'}">
                        <h1 class="success-title">¡Código Enviado!</h1>
                        
                        <p class="success-message">
                            Hemos enviado un código de verificación a tu correo electrónico:
                            <br><strong>${correoUsuario}</strong>
                        </p>

                        <div class="info-box">
                            <h3><i class="fas fa-info-circle"></i> Próximos Pasos</h3>
                            <ul class="info-list">
                                <li>Revisa tu bandeja de entrada de correo</li>
                                <li>Busca el correo de ONU Mujeres con el código de verificación</li>
                                <li>Si no lo encuentras, revisa la carpeta de spam</li>
                                <li>El código expira en 5 minutos por seguridad</li>
                                <li>Ingresa el código en la siguiente pantalla para restablecer tu contraseña</li>
                            </ul>
                        </div>

                        <div style="margin-top: 30px;">
                            <a href="restablecerPassword?correo=${correoUsuario}" class="btn-primary">
                                <i class="fas fa-key"></i> Ingresar Código de Verificación
                            </a>
                            
                            <a href="LoginServlet" class="btn-primary">
                                <i class="fas fa-arrow-left"></i> Volver al Login
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <h1 class="success-title">¡Registro Exitoso!</h1>
                        
                        <p class="success-message">
                            Tu cuenta ha sido creada correctamente. Te hemos enviado un correo electrónico 
                            con un enlace para establecer tu contraseña.
                        </p>

                        <div class="info-box">
                            <h3><i class="fas fa-info-circle"></i> Próximos Pasos</h3>
                            <ul class="info-list">
                                <li>Revisa tu bandeja de entrada de correo</li>
                                <li>Busca el correo de ONU Mujeres</li>
                                <li>Si no lo encuentras, revisa la carpeta de spam</li>
                                <li>Haz clic en el enlace para establecer tu contraseña</li>
                                <li>Una vez configurada, podrás iniciar sesión</li>
                            </ul>
                        </div>

                        <div style="margin-top: 30px;">
                            <a href="LoginServlet" class="btn-primary">
                                <i class="fas fa-sign-in-alt"></i> Ir al Login
                            </a>
                            
                            <a href="registro" class="btn-primary">
                                <i class="fas fa-user-plus"></i> Nuevo Registro
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Footer -->
        <div class="footer">
            <p>&copy; 2025 ONU Mujeres. Todos los derechos reservados.</p>
        </div>
    </div>

    <script>
        // Auto-scroll suave hacia el contenido principal
        window.addEventListener('load', function() {
            document.querySelector('.success-container').scrollIntoView({ 
                behavior: 'smooth',
                block: 'center'
            });
        });

        // Efecto de confeti (opcional)
        function createConfetti() {
            const colors = ['#87ceeb', '#a8d8ff', '#ddeeff', '#f0f8ff'];
            for (let i = 0; i < 50; i++) {
                setTimeout(() => {
                    const confetti = document.createElement('div');
                    confetti.style.position = 'fixed';
                    confetti.style.left = Math.random() * 100 + 'vw';
                    confetti.style.top = '-10px';
                    confetti.style.width = '10px';
                    confetti.style.height = '10px';
                    confetti.style.background = colors[Math.floor(Math.random() * colors.length)];
                    confetti.style.borderRadius = '50%';
                    confetti.style.pointerEvents = 'none';
                    confetti.style.animation = 'fall 3s linear forwards';
                    document.body.appendChild(confetti);
                    
                    setTimeout(() => confetti.remove(), 3000);
                }, i * 100);
            }
        }

        // CSS para la animación de confeti
        const style = document.createElement('style');
        style.textContent = `
            @keyframes fall {
                0% { transform: translateY(-10px) rotate(0deg); opacity: 1; }
                100% { transform: translateY(100vh) rotate(360deg); opacity: 0; }
            }
        `;
        document.head.appendChild(style);

        // Activar confeti al cargar la página
        window.addEventListener('load', () => {
            setTimeout(createConfetti, 500);
        });
    </script>
</body>
</html>