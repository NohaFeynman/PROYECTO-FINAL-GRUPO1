<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <title>Registro Exitoso - ONU Mujeres</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #333;
            overflow: hidden;
            position: relative;
        }

        /* Animaciones de fondo */
        .bg-animation {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 1;
        }

        .floating-shapes {
            position: absolute;
            width: 100%;
            height: 100%;
        }

        .shape {
            position: absolute;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            animation: float 6s ease-in-out infinite;
        }

        .shape:nth-child(1) {
            width: 80px;
            height: 80px;
            top: 20%;
            left: 10%;
            animation-delay: 0s;
        }

        .shape:nth-child(2) {
            width: 60px;
            height: 60px;
            top: 70%;
            left: 80%;
            animation-delay: 2s;
        }

        .shape:nth-child(3) {
            width: 100px;
            height: 100px;
            top: 40%;
            left: 70%;
            animation-delay: 4s;
        }

        .shape:nth-child(4) {
            width: 40px;
            height: 40px;
            top: 10%;
            left: 70%;
            animation-delay: 1s;
        }

        .shape:nth-child(5) {
            width: 120px;
            height: 120px;
            top: 80%;
            left: 20%;
            animation-delay: 3s;
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
                opacity: 0.7;
            }
            50% {
                transform: translateY(-20px) rotate(180deg);
                opacity: 1;
            }
        }

        /* Contenedor principal */
        .success-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 25px;
            padding: 60px 50px;
            text-align: center;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.2);
            max-width: 500px;
            width: 90%;
            position: relative;
            z-index: 10;
            border: 1px solid rgba(255, 255, 255, 0.3);
            animation: slideInUp 0.8s ease-out;
        }

        @keyframes slideInUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Icono de éxito */
        .success-icon {
            width: 90px;
            height: 90px;
            margin: 20px auto 30px;
            background: linear-gradient(135deg, #28a745, #20c997);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            animation: scaleIn 0.6s ease-out 0.3s both;
        }

        @keyframes scaleIn {
            from {
                transform: scale(0);
                opacity: 0;
            }
            to {
                transform: scale(1);
                opacity: 1;
            }
        }

        .success-icon::before {
            content: '';
            position: absolute;
            width: 100px;
            height: 100px;
            border: 3px solid rgba(40, 167, 69, 0.3);
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% {
                transform: scale(1);
                opacity: 1;
            }
            100% {
                transform: scale(1.1);
                opacity: 0;
            }
        }

        .success-icon i {
            font-size: 35px;
            color: white;
            animation: checkmark 0.8s ease-out 0.6s both;
        }

        @keyframes checkmark {
            from {
                transform: scale(0) rotate(-45deg);
                opacity: 0;
            }
            to {
                transform: scale(1) rotate(0deg);
                opacity: 1;
            }
        }

        /* Textos */
        .success-title {
            font-size: 32px;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 15px;
            animation: fadeInUp 0.6s ease-out 0.9s both;
        }

        .success-subtitle {
            font-size: 18px;
            color: #718096;
            margin-bottom: 30px;
            line-height: 1.6;
            animation: fadeInUp 0.6s ease-out 1.1s both;
        }

        .success-message {
            background: linear-gradient(135deg, #e6fffa, #f0fff4);
            border: 1px solid #9ae6b4;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 35px;
            font-size: 16px;
            color: #2d5a3d;
            animation: fadeInUp 0.6s ease-out 1.3s both;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Botón */
        .login-btn {
            background: linear-gradient(135deg, #5fa3d3, #4a8db8);
            color: white;
            padding: 15px 40px;
            border: none;
            border-radius: 50px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
            position: relative;
            overflow: hidden;
            animation: fadeInUp 0.6s ease-out 1.5s both;
        }

        .login-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s;
        }

        .login-btn:hover::before {
            left: 100%;
        }

        .login-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(95, 163, 211, 0.4);
        }

        .login-btn:active {
            transform: translateY(0);
        }

        /* Contador regresivo */
        .countdown {
            margin-top: 25px;
            font-size: 14px;
            color: #718096;
            animation: fadeInUp 0.6s ease-out 1.7s both;
        }

        .countdown-number {
            font-weight: 700;
            color: #5fa3d3;
            font-size: 16px;
        }

        /* Logo ONU Mujeres */
        .logo-container {
            position: absolute;
            top: 30px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 15;
            animation: fadeInDown 0.6s ease-out 0.2s both;
        }

        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateX(-50%) translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(-50%) translateY(0);
            }
        }

        .logo-container img {
            height: 50px;
            width: auto;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .success-container {
                padding: 40px 30px;
                margin: 20px;
            }

            .success-title {
                font-size: 26px;
            }

            .success-subtitle {
                font-size: 16px;
            }

            .success-icon {
                width: 100px;
                height: 100px;
            }

            .success-icon i {
                font-size: 40px;
    </style>
</head>
<body>
    <!-- Logo -->
    <div class="logo-container">
        <img src="imagenes/logo.jpg" alt="ONU Mujeres" onerror="this.style.display='none'">
    </div>

    <!-- Animación de fondo -->
    <div class="bg-animation">
        <div class="floating-shapes">
            <div class="shape"></div>
            <div class="shape"></div>
            <div class="shape"></div>
            <div class="shape"></div>
            <div class="shape"></div>
        </div>
    </div>

    <!-- Contenedor principal -->
    <div class="success-container">
        <!-- Icono de éxito -->
        <div class="success-icon">
            <i class="fas fa-user-check"></i>
        </div>

        <!-- Títulos -->
        <h1 class="success-title">¡Registro Exitoso!</h1>
        <p class="success-subtitle">Tu cuenta ha sido creada correctamente</p>

        <!-- Mensaje de confirmación -->
        <div class="success-message">
            <i class="fas fa-shield-alt" style="color: #28a745; margin-right: 8px;"></i>
            Tu cuenta ha sido creada exitosamente. Ya puedes iniciar sesión con tu nueva credencial y acceder a todas las funcionalidades de la plataforma.
        </div>

        <!-- Botón para ir al login -->
        <a href="LoginServlet" class="login-btn" id="loginBtn">
            <i class="fas fa-sign-in-alt" style="margin-right: 8px;"></i>
            Iniciar Sesión
        </a>

        <!-- Contador regresivo -->
        <div class="countdown">
            Serás redirigido automáticamente en <span class="countdown-number" id="countdown">10</span> segundos
        </div>
    </div>

    <script>
        // Contador regresivo y redirección automática
        let timeLeft = 10;
        const countdownElement = document.getElementById('countdown');
        const loginBtn = document.getElementById('loginBtn');

        const timer = setInterval(() => {
            timeLeft--;
            countdownElement.textContent = timeLeft;
            
            if (timeLeft <= 0) {
                clearInterval(timer);
                window.location.href = 'LoginServlet';
            }
        }, 1000);

        // Detener el contador si el usuario hace clic en el botón
        loginBtn.addEventListener('click', () => {
            clearInterval(timer);
        });

        // Prevenir el botón de retroceso del navegador
        history.pushState(null, null, location.href);
        window.onpopstate = function () {
            history.go(1);
        };

        // Efectos de partículas adicionales
        function createFloatingParticle() {
            const particle = document.createElement('div');
            particle.style.cssText = `
                position: absolute;
                width: 4px;
                height: 4px;
                background: rgba(255, 255, 255, 0.7);
                border-radius: 50%;
                pointer-events: none;
                z-index: 5;
            `;
            
            particle.style.left = Math.random() * 100 + '%';
            particle.style.top = '100%';
            
            document.querySelector('.bg-animation').appendChild(particle);
            
            const animateParticle = () => {
                const duration = Math.random() * 3000 + 2000;
                const drift = (Math.random() - 0.5) * 100;
                
                particle.animate([
                    { 
                        transform: `translateY(0px) translateX(0px)`,
                        opacity: 0
                    },
                    { 
                        transform: `translateY(-100vh) translateX(${drift}px)`,
                        opacity: 1
                    },
                    { 
                        transform: `translateY(-200vh) translateX(${drift * 2}px)`,
                        opacity: 0
                    }
                ], {
                    duration: duration,
                    easing: 'linear'
                }).onfinish = () => {
                    particle.remove();
                };
            };
            
            animateParticle();
        }

        // Crear partículas flotantes cada cierto tiempo
        setInterval(createFloatingParticle, 500);

        // Efecto de celebración al cargar la página
        window.addEventListener('load', () => {
            setTimeout(() => {
                // Crear confeti
                for (let i = 0; i < 50; i++) {
                    setTimeout(() => createFloatingParticle(), i * 100);
                }
            }, 1000);
        });
    </script>
</body>
</html>
