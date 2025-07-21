<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Verificación</title>
</head>
<body>
    <h1>Página de Prueba - Verificación</h1>
    
    <!-- Simular las variables JSP -->
    <script>
        // Variables simuladas para prueba
        const correoUsuario = 'a20206830@pucp.edu.pe';
        const iniciarTimer = true;
        
        console.log('🧪 Página de prueba cargada');
        console.log('📧 Correo simulado:', correoUsuario);
    </script>
    
    <div>
        <p><strong>Correo de prueba:</strong> a20206830@pucp.edu.pe</p>
        
        <div id="timerInfo" style="background: #fff3cd; padding: 10px; margin: 10px 0; border-radius: 5px;">
            ⏰ Tiempo restante: <span id="timeLeft">05:00</span>
        </div>
        
        <div id="debugInfo" style="background: #e7f3ff; border: 1px solid #b3d9ff; padding: 10px; margin: 10px 0; border-radius: 5px;">
            <strong>Debug Info:</strong><br>
            <span id="debugTimer">Cargando...</span><br>
            <span id="debugFetch">Sin sincronizar...</span>
        </div>
        
        <button onclick="testTiempoRestante()">Probar TiempoRestanteServlet</button>
    </div>
    
    <script>
        let timerInterval;
        let timeRemaining = 300;
        
        // Función de prueba para el servlet
        async function testTiempoRestante() {
            console.log('🧪 Probando TiempoRestanteServlet...');
            const debugFetch = document.getElementById('debugFetch');
            
            try {
                debugFetch.innerHTML = 'Probando servlet...';
                
                const response = await fetch('tiempoRestante?correo=' + encodeURIComponent(correoUsuario));
                const responseText = await response.text();
                
                console.log('📡 Respuesta del servidor:', responseText);
                debugFetch.innerHTML = `Respuesta: ${responseText}`;
                
                if (response.ok) {
                    const data = JSON.parse(responseText);
                    timeRemaining = data.segundos;
                    console.log('✅ Tiempo obtenido:', timeRemaining);
                    
                    // Actualizar display
                    const timeLeftSpan = document.getElementById('timeLeft');
                    const minutes = Math.floor(timeRemaining / 60);
                    const seconds = timeRemaining % 60;
                    const timeDisplay = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
                    timeLeftSpan.textContent = timeDisplay;
                } else {
                    console.error('❌ Error del servidor:', response.status);
                }
            } catch (error) {
                console.error('❌ Error:', error);
                debugFetch.innerHTML = `Error: ${error.message}`;
            }
        }
        
        // Probar automáticamente al cargar
        window.addEventListener('load', function() {
            setTimeout(testTiempoRestante, 1000);
        });
    </script>
</body>
</html>
