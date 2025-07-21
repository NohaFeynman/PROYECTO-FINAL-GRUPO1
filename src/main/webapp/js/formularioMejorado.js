/**
 * Script para mejorar el aspecto de los formularios
 */
document.addEventListener('DOMContentLoaded', function() {
    // Aplicar estilos a las advertencias de navegación
    const textoPreguntas = document.querySelectorAll('.pregunta-texto');
    textoPreguntas.forEach(texto => {
        // Buscar texto que inicia con "Si la respuesta es" para darle formato especial
        const siguienteParrafo = texto.nextElementSibling;
        if (siguienteParrafo && siguienteParrafo.textContent.trim().toLowerCase().includes('si la respuesta es')) {
            siguienteParrafo.classList.add('advertencia-navegacion');
            
            // Añadir un estilo más compacto y menos prominente
            siguienteParrafo.style.fontSize = '0.85em';
            siguienteParrafo.style.marginTop = '5px';
            siguienteParrafo.style.marginBottom = '10px';
            
            // Creamos un contenedor para la advertencia que permita mejor posicionamiento
            const advertenciaContainer = document.createElement('div');
            advertenciaContainer.className = 'advertencia-container';
            siguienteParrafo.parentNode.insertBefore(advertenciaContainer, siguienteParrafo);
            advertenciaContainer.appendChild(siguienteParrafo);
        }
    });
    
    // Formatear las opciones radio en grupo
    const opcionesContainers = document.querySelectorAll('.opciones-container');
    opcionesContainers.forEach(container => {
        const opciones = container.querySelectorAll('.opcion-label');
        
        // Si son pocas opciones (Sí/No), mostrarlas horizontalmente con mejor espaciado
        if (opciones.length <= 2) {
            container.classList.add('opciones-horizontal');
            
            // Para opciones Sí/No específicamente
            const opcionesTexto = Array.from(opciones).map(opt => opt.querySelector('.opcion-texto').textContent.trim().toLowerCase());
            if (opcionesTexto.includes('sí') && opcionesTexto.includes('no') || 
                opcionesTexto.includes('si') && opcionesTexto.includes('no')) {
                container.classList.add('opciones-si-no');
                opciones.forEach(opt => opt.classList.add('opcion-si-no'));
            }
        } else if (opciones.length <= 5) {
            // Para pocas opciones pero más de 2
            container.classList.add('opciones-pocas');
        } else {
            container.classList.add('opciones-vertical');
        }
    });
    
    // Ajustar espaciado de opciones en preguntas específicas
    const preguntasMultiples = document.querySelectorAll('.pregunta-item');
    preguntasMultiples.forEach(pregunta => {
        const textoPreg = pregunta.querySelector('.pregunta-texto').textContent.toLowerCase();
        const opcionesContainer = pregunta.querySelector('.opciones-container');
        
        // Si es una pregunta con muchas opciones como la 11
        if (textoPreg.includes('por qué no usa') || textoPreg.includes('servicios de cuidados')) {
            if (opcionesContainer) {
                opcionesContainer.classList.add('opciones-separadas');
            }
        }
    });
});
