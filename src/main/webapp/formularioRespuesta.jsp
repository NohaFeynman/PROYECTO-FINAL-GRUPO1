<%--
  Created by IntelliJ IDEA.
  User: Nilton
  Date: 14/05/2025
  Time: 14:38
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title>Responder Formulario</title>
    <link rel="stylesheet" href="formularioRespuesta.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        /* Estilos críticos incrustados para garantizar la visualización correcta */
        .preguntas-grid {
            display: grid !important;
            grid-template-columns: repeat(2, 1fr) !important;
            gap: 15px !important;
        }
        @media (min-width: 1200px) {
            .preguntas-grid {
                grid-template-columns: repeat(3, 1fr) !important;
            }
        }
        @media (max-width: 767px) {
            .preguntas-grid {
                grid-template-columns: 1fr !important;
            }
        }
        
        /* Estilo especial para las advertencias de navegación */
        .advertencia-navegacion {
            background-color: #fff3cd;
            color: #856404;
            padding: 6px 10px;
            border-radius: 4px;
            margin: 8px 0 12px;
            border-left: 4px solid #ffc107;
            font-weight: 500;
            font-size: 0.9em;
            display: inline-block;
            max-width: 90%;
        }
        
        /* Mejorar espaciado de opciones */
        .opciones-container {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }
        
        /* Opciones Sí/No con mejor espaciado */
        .opciones-container label:first-child {
            margin-right: 25px;
        }
        
        /* Contenedor especial para advertencias de navegación */
        .advertencia-container {
            margin: 0;
            padding: 0;
            clear: both;
        }
        
        /* Asegurar que la pregunta 11 tenga suficiente espacio respecto a las advertencias */
        [data-pregunta-id="11"] {
            margin-top: 10px;
            padding-top: 5px;
        }
        
        /* Estilos para validaciones numéricas */
        .validacion-help {
            font-size: 0.8em !important;
            margin-top: 5px !important;
            font-style: italic !important;
            padding: 3px 8px !important;
            border-radius: 3px !important;
            background-color: #f8f9fa !important;
            border-left: 3px solid #007bff !important;
        }
        
        .validacion-help.error {
            background-color: #fff5f5 !important;
            border-left-color: #dc3545 !important;
            color: #dc3545 !important;
        }
        
        .validacion-help.success {
            background-color: #f8fff9 !important;
            border-left-color: #28a745 !important;
            color: #28a745 !important;
        }
        
        /* Resaltar campos numéricos */
        textarea[data-tipo-numerico] {
            transition: all 0.3s ease !important;
        }
        
        textarea[data-tipo-numerico]:focus {
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25) !important;
        }
        
        /* Estilos para botón cerrar sidebar */
        .sidebar-close-btn {
            position: absolute;
            top: 10px;
            right: 15px;
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: #333;
            font-size: 24px;
            font-weight: bold;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            z-index: 100;
        }
        .sidebar-close-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.1);
            color: #000;
        }
        
        /* Estilos para mostrar el nombre del usuario en el header */
        .nav-item#btn-encuestador {
            flex-direction: row;
            justify-content: flex-start;
            gap: 8px;
            color: #007bff;
            font-weight: bold;
        }
        
        .nav-item#btn-encuestador span {
            display: inline-block;
        }
        
        /* Botones modernos */
        .btn-primary,
        .btn-secondary {
            padding: 12px 24px;
            border: none;
            border-radius: 50px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
            text-decoration: none;
            min-width: 140px;
            justify-content: center;
            height: 44px;
            white-space: nowrap;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        .btn-primary {
            background: linear-gradient(135deg, #87ceeb 0%, #5fa3d3 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(135,206,235,0.4);
        }

        .btn-secondary {
            background: white;
            color: #6c757d;
            border: 2px solid #e9ecef;
            box-shadow: 0 2px 8px rgba(108, 117, 125, 0.1);
        }

        .btn-secondary:hover {
            background: #f8f9fa;
            color: #5a6268;
            border-color: #dee2e6;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(108, 117, 125, 0.2);
        }
        
        /* Botón cerrar en la esquina del formulario */
        .form-close-btn {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(220, 53, 69, 0.1);
            border: 2px solid rgba(220, 53, 69, 0.2);
            color: #dc3545;
            font-size: 18px;
            font-weight: bold;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            z-index: 1000;
        }
        
        .form-close-btn:hover {
            background: rgba(220, 53, 69, 0.15);
            border-color: rgba(220, 53, 69, 0.4);
            transform: scale(1.1);
            color: #c82333;
        }
        
        /* Contenedor del formulario con posición relativa */
        .form-container {
            position: relative;
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin: 20px auto;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }
    </style>
    <script src="js/formularioMejorado.js" defer></script>
</head>
<body>
<input type="checkbox" id="menu-toggle" class="menu-toggle" />
<div class="sidebar">
    <div class="sidebar-content">
        <button class="sidebar-close-btn" onclick="document.getElementById('menu-toggle').checked = false;">×</button>
        <div class="sidebar-separator"></div>
        <ul class="menu-links">
            <li>
                <a href="InicioEncuestadorServlet">
                    <i class="fa-solid fa-chart-line"></i> Ver Dashboard
                </a>
            </li>
            <li>
                <a href="FormulariosAsignadosServlet">
                    <i class="fa-solid fa-list-check"></i> Ver formularios asignados
                </a>
            </li>
            <li>
                <a href="HistorialFormulariosServlet">
                    <i class="fa-solid fa-clock-rotate-left"></i> Ver historial de formulario
                </a>
            </li>
            <li>
                <a href="CerrarSesionServlet">
                    <i class="fa-solid fa-right-from-bracket"></i> Cerrar sesión
                </a>
            </li>
        </ul>
    </div>
</div>
<label for="menu-toggle" class="overlay"></label>
<header class="header-bar">
    <div class="header-content">
        <div class="header-left">
            <label for="menu-toggle" class="menu-icon">&#9776;</label>
            <div class="logo-section">
                <div class="logo-large">
                    <img src="${pageContext.request.contextPath}/imagenes/logo.jpg" alt="Logo Combinado" />
                </div>
            </div>
        </div>
        <nav class="header-right">
            <div class="nav-item dropdown" id="btn-encuestador" tabindex="0">
                <img src="${pageContext.request.contextPath}/imagenes/usuario.png" alt="Icono Usuario" class="nav-icon">
                <span id="user-name-display">
                    <c:choose>
                        <c:when test="${not empty datosPerfil.usuario.nombre && not empty datosPerfil.usuario.apellidopaterno}">
                            <c:choose>
                                <c:when test="${fn:length(datosPerfil.usuario.nombre) > 0}">
                                    ${fn:substring(datosPerfil.usuario.nombre, 0, 1)}. ${datosPerfil.usuario.apellidopaterno}
                                </c:when>
                                <c:otherwise>
                                    ${datosPerfil.usuario.apellidopaterno}
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:when test="${not empty sessionScope.datosPerfil.usuario.nombre && not empty sessionScope.datosPerfil.usuario.apellidopaterno}">
                            <c:choose>
                                <c:when test="${fn:length(sessionScope.datosPerfil.usuario.nombre) > 0}">
                                    ${fn:substring(sessionScope.datosPerfil.usuario.nombre, 0, 1)}. ${sessionScope.datosPerfil.usuario.apellidopaterno}
                                </c:when>
                                <c:otherwise>
                                    ${sessionScope.datosPerfil.usuario.apellidopaterno}
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:when test="${not empty sessionScope.usuario.nombre && not empty sessionScope.usuario.apellidopaterno}">
                            <c:choose>
                                <c:when test="${fn:length(sessionScope.usuario.nombre) > 0}">
                                    ${fn:substring(sessionScope.usuario.nombre, 0, 1)}. ${sessionScope.usuario.apellidopaterno}
                                </c:when>
                                <c:otherwise>
                                    ${sessionScope.usuario.apellidopaterno}
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            ${sessionScope.nombre}
                        </c:otherwise>
                    </c:choose>
                </span>
                
                <!-- JavaScript alternativo para formatear el nombre -->
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        const userNameElement = document.getElementById('user-name-display');
                        if (userNameElement) {
                            let currentText = userNameElement.textContent.trim();
                            console.log('Texto actual del usuario:', currentText);
                            
                            // Si el texto actual es solo el nombre completo sin formato, intentar formatearlo
                            if (currentText && !currentText.includes('.') && currentText.split(' ').length >= 2) {
                                const parts = currentText.split(' ');
                                const firstName = parts[0];
                                const lastName = parts[parts.length - 1]; // Último apellido
                                
                                if (firstName && lastName && firstName.length > 0) {
                                    const formattedName = firstName.charAt(0).toUpperCase() + '. ' + lastName;
                                    userNameElement.textContent = formattedName;
                                    console.log('Nombre formateado con JS:', formattedName);
                                }
                            }
                        }
                    });
                </script>
                <div class="dropdown-menu">
                    <a href="VerPerfilServlet">Ver perfil</a>
                    <a href="CerrarSesionServlet">Cerrar sesión</a>
                </div>
            </div>
            <a href="InicioEncuestadorServlet" class="nav-item" id="btn-inicio">
                <img src="${pageContext.request.contextPath}/imagenes/inicio.png" alt="Icono de perfil" class="nav-icon" />
            </a>
        </nav>
    </div>
</header>
<main class="main-content">
    <h2>${titulo}</h2>

    <div class="form-container">
        <button class="form-close-btn" onclick="window.history.back();" title="Cerrar formulario">
            <i class="fas fa-times"></i>
        </button>
        
        <form action="GuardarRespuestasServlet" method="post" onsubmit="return confirmarEnvio(event);">
            <input type="hidden" name="accion" id="accion-hidden" value="" />
            <input type="hidden" name="idFormulario" value="${idFormulario}" />
            <input type="hidden" name="idEncuestador" value="${sessionScope.idUsuario}" />
            <input type="hidden" name="fechaEntrevista" value="<%= java.time.LocalDate.now().toString() %>" />
            <input type="hidden" name="idAsignacionFormulario" value="${idAsignacionFormulario}" />
            <c:if test="${modoReingreso}">
                <input type="hidden" name="idSesion" value="${idSesion}" />
            </c:if>

        <c:set var="seccionActual" value="" />
        <div class="preguntas-container">
        <c:forEach var="pregunta" items="${preguntas}" varStatus="status">
            <c:if test="${pregunta.seccion ne seccionActual}">
                <c:if test="${seccionActual ne ''}">
                    </div> <!-- Cerrar grid de sección anterior -->
                </c:if>
                <h3 class="seccion-titulo">
                        ${pregunta.seccion}
                </h3>
                <c:set var="seccionActual" value="${pregunta.seccion}" />
                <div class="preguntas-grid">
            </c:if>

            <div class="pregunta-item" data-obligatorio="${pregunta.obligatorio}">
                <p class="pregunta-texto"><strong>${pregunta.orden}. ${pregunta.textoPregunta}</strong></p>

                <c:if test="${not empty pregunta.descripcion}">
                    <p class="pregunta-descripcion">${pregunta.descripcion}</p>
                </c:if>

                <c:set var="respuestaAnterior" value="${respuestasAnteriores[pregunta.idPregunta]}" />

                <div class="respuesta-container">
                    <c:choose>
                        <c:when test="${pregunta.tipoPregunta == 0}">
                            <div class="opciones-container">
                                <c:forEach var="opcion" items="${pregunta.opciones}">
                                    <label class="opcion-label">
                                        <input type="radio"
                                               name="respuesta_${pregunta.idPregunta}"
                                               value="${opcion.idOpcion}"
                                                <c:if test="${modoReingreso and respuestaAnterior != null and opcion.idOpcion == respuestaAnterior.idOpcion}">
                                                    checked
                                                </c:if> />
                                        <span class="opcion-texto">${opcion.textoOpcion}</span>
                                    </label>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <textarea name="respuesta_${pregunta.idPregunta}" 
                                      rows="3" 
                                      class="textarea-respuesta" 
                                      placeholder="Escribe tu respuesta...">${modoReingreso and respuestaAnterior != null ? respuestaAnterior.textoRespuesta : ''}</textarea>
                        </c:otherwise>
                    </c:choose>
                </div>

                <input type="hidden" name="tipo_${pregunta.idPregunta}" value="${pregunta.tipoPregunta}" />
                <input type="hidden" name="obligatorio_${pregunta.idPregunta}" value="${pregunta.obligatorio}" />
            </div>
        </c:forEach>
        
        <!-- Cerrar último grid si existe -->
        <c:if test="${seccionActual ne ''}">
            </div>
        </c:if>
        </div> <!-- Cerrar preguntas-container -->

        <div style="text-align: right; margin-top: 40px; display: flex; gap: 12px; justify-content: flex-end;">
            <button type="submit" name="accion" value="borrador" class="btn-secondary">
                <i class="fas fa-save"></i>
                Guardar Borrador
            </button>
            <button type="submit" name="accion" value="terminar" class="btn-primary">
                <i class="fas fa-paper-plane"></i>
                Terminar y Enviar
            </button>
        </div>
    </form>
    </div> <!-- Cerrar form-container -->

    <!-- POPUPS -->
    <div id="popup-vacio" class="popup-centrado" style="display:none;">
        <div class="popup-contenido">
            <h3 style="color:#dc3545;">¡Formulario vacío!</h3>
            <p>No se ha respondido a ninguna pregunta. Debes completar al menos una.</p>
            <button onclick="cerrarPopups()">Aceptar</button>
        </div>
    </div>

    <div id="popup-obligatorias" class="popup-centrado" style="display:none;">
        <div class="popup-contenido">
            <h3 style="color:#dc3545;">¡Faltan preguntas obligatorias!</h3>
            <p>Debes completar todas las preguntas obligatorias de las secciones B y C.</p>
            <button onclick="cerrarPopups()">Aceptar</button>
        </div>
    </div>

    <div id="popup-confirmar-borrador" class="popup-centrado" style="display:none;">
        <div class="popup-contenido">
            <h3 style="color:#ffc107;">¿Guardar como borrador?</h3>
            <p>¿Estás seguro de guardar este formulario como borrador?</p>
            <button onclick="enviarFormulario()">Sí</button>
            <button onclick="cerrarPopups()">Cancelar</button>
        </div>
    </div>

    <div id="popup-confirmar-envio" class="popup-centrado" style="display:none;">
        <div class="popup-contenido">
            <h3 style="color:#28a745;">¿Enviar formulario?</h3>
            <p>¿Estás seguro de terminar y enviar el formulario?</p>
            <button onclick="enviarFormulario()">Sí</button>
            <button onclick="cerrarPopups()">Cancelar</button>
        </div>
    </div>

    <style>
        .popup-centrado {
            position: fixed;
            top: 0; left: 0;
            width: 100vw; height: 100vh;
            background: rgba(0,0,0,0.35);
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .popup-contenido {
            background: #fff;
            padding: 2rem 2.5rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
            text-align: center;
        }

        .popup-contenido button {
            margin-top: 1.5rem;
            padding: 0.5rem 1.5rem;
            border: none;
            border-radius: 5px;
            font-size: 1rem;
            cursor: pointer;
        }

        .popup-contenido button:first-child {
            background: #007bff;
            color: white;
            margin-right: 1rem;
        }

        .popup-contenido button:last-child {
            background: #ccc;
        }
    </style>

    <script>
        let formGlobal = null;

        function confirmarEnvio(event) {
            event.preventDefault();
            const form = event.target;
            formGlobal = form;
            const accion = event.submitter?.value || '';
            document.getElementById('accion-hidden').value = accion;

            const elementos = form.elements;
            let respondidas = new Set();
            let obligatoriasNoRespondidas = [];

            for (let i = 0; i < elementos.length; i++) {
                const el = elementos[i];
                if (el.name.startsWith("respuesta_")) {
                    const id = el.name.split("_")[1];
                    if ((el.type === "radio" && el.checked) || (el.tagName === "TEXTAREA" && el.value.trim() !== "")) {
                        respondidas.add(id);
                    }
                }
            }

            if (respondidas.size === 0) {
                document.getElementById('popup-vacio').style.display = 'flex';
                return false;
            }

            if (accion === "borrador") {
                document.getElementById('popup-confirmar-borrador').style.display = 'flex';
                return false;
            }

            for (let i = 0; i < elementos.length; i++) {
                const el = elementos[i];
                if (el.name.startsWith("obligatorio_") && el.value === "1") {
                    const idPregunta = el.name.split("_")[1];
                    if (!respondidas.has(idPregunta)) {
                        obligatoriasNoRespondidas.push(idPregunta);
                    }
                }
            }

            if (obligatoriasNoRespondidas.length > 0) {
                document.getElementById('popup-obligatorias').style.display = 'flex';
                return false;
            }

            // Validar campos numéricos antes del envío
            const camposInvalidos = validarCamposNumericos();
            if (camposInvalidos.length > 0) {
                mostrarErrorCamposNumericos(camposInvalidos);
                return false;
            }

            document.getElementById('popup-confirmar-envio').style.display = 'flex';
            return false;
        }

        function cerrarPopups() {
            document.querySelectorAll('[id^="popup-"]').forEach(p => p.style.display = 'none');
        }

        function enviarFormulario() {
            cerrarPopups();
            if (formGlobal) formGlobal.submit();
        }

        // Función para validar campos numéricos antes del envío
        function validarCamposNumericos() {
            const camposInvalidos = [];
            const textareas = document.querySelectorAll('textarea');
            
            textareas.forEach(textarea => {
                const preguntaItem = textarea.closest('.pregunta-item');
                if (!preguntaItem) return;
                
                const numeroPregunta = preguntaItem.getAttribute('data-pregunta-id');
                const preguntaTexto = preguntaItem.querySelector('.pregunta-texto').textContent.toLowerCase();
                
                // Solo validar si hay contenido
                const valor = textarea.value.trim();
                if (valor === '') return;
                
                let esInvalido = false;
                let tipoError = '';
                
                // Solo validar preguntas específicas por número
                if (numeroPregunta === '4' && preguntaTexto.includes('dni')) {
                    if (valor.length !== 8 || isNaN(parseInt(valor))) {
                        esInvalido = true;
                        tipoError = 'DNI debe tener exactamente 8 dígitos';
                    }
                } else if ((numeroPregunta === '5' || numeroPregunta === '21') && preguntaTexto.includes('edad')) {
                    const edad = parseInt(valor);
                    if (isNaN(edad) || edad < 1 || edad > 110) {
                        esInvalido = true;
                        tipoError = 'Edad debe ser un número entre 1 y 110';
                    }
                } else if (numeroPregunta === '17' && preguntaTexto.includes('cuántas personas')) {
                    const cantidad = parseInt(valor);
                    if (isNaN(cantidad) || cantidad < 0 || cantidad > 99) {
                        esInvalido = true;
                        tipoError = 'Cantidad debe ser un número entre 0 y 99';
                    }
                } else if (preguntaTexto.includes('celular de contacto') || (preguntaTexto.includes('celular') && preguntaTexto.includes('opcional'))) {
                    if (valor.length !== 9 || isNaN(parseInt(valor))) {
                        esInvalido = true;
                        tipoError = 'Celular debe tener exactamente 9 dígitos';
                    }
                } else if (preguntaTexto.includes('¿cuánto tiempo al día dedica al cuidado?')) {
                    if (isNaN(parseInt(valor)) || parseInt(valor) < 0) {
                        esInvalido = true;
                        tipoError = 'Tiempo debe ser un número válido';
                    }
                }
                
                if (esInvalido) {
                    camposInvalidos.push({
                        pregunta: numeroPregunta,
                        error: tipoError,
                        elemento: textarea
                    });
                }
            });
            
            return camposInvalidos;
        }

        // Función para mostrar errores de campos numéricos
        function mostrarErrorCamposNumericos(camposInvalidos) {
            let mensaje = 'Por favor corrija los siguientes campos:\n\n';
            
            camposInvalidos.forEach(campo => {
                mensaje += `• Pregunta ${campo.pregunta}: ${campo.error}\n`;
                // Resaltar el campo con error
                campo.elemento.style.borderColor = '#dc3545';
                campo.elemento.style.backgroundColor = '#fff5f5';
                campo.elemento.focus();
            });
            
            alert(mensaje);
        }

        window.onload = function () {
            const params = new URLSearchParams(window.location.search);
            if (params.get("error") === "vacio") {
                document.getElementById("popup-vacio").style.display = "flex";
            } else if (params.get("error") === "obligatorias") {
                document.getElementById("popup-obligatorias").style.display = "flex";
            }
        }
    </script>
</main>


<script>
    // Mostrar/ocultar menú desplegable del botón Encuestador
    const btnEncuestador = document.getElementById('btn-encuestador');
    btnEncuestador.addEventListener('click', () => {
        btnEncuestador.classList.toggle('dropdown-active');
    });
    // Cerrar el dropdown si se hace click fuera
    document.addEventListener('click', (e) => {
        if (!btnEncuestador.contains(e.target)) {
            btnEncuestador.classList.remove('dropdown-active');
        }
    });
    
    // Script para forzar la distribución en columnas y mejorar el espaciado
    document.addEventListener('DOMContentLoaded', function() {
        const grids = document.querySelectorAll('.preguntas-grid');
        
        // Identificar preguntas por número para aplicar estilos específicos
        const preguntasItems = document.querySelectorAll('.pregunta-item');
        preguntasItems.forEach(item => {
            const preguntaTexto = item.querySelector('.pregunta-texto');
            if (preguntaTexto) {
                const numeroMatch = preguntaTexto.textContent.match(/^(\d+)\./);
                if (numeroMatch && numeroMatch[1]) {
                    item.setAttribute('data-pregunta-id', numeroMatch[1]);
                    
                    // Aplicar validaciones numéricas específicas
                    aplicarValidacionesNumericas(item, numeroMatch[1], preguntaTexto.textContent);
                }
            }
            
            // Buscar advertencias de navegación y mejorar su presentación
            const advertencia = item.querySelector('.advertencia-navegacion');
            if (advertencia) {
                advertencia.style.width = 'auto';
                advertencia.style.display = 'inline-block';
                item.style.paddingBottom = '8px';
            }
        });
        
        grids.forEach(grid => {
            // Forzar el estilo inline para garantizar el comportamiento de grid
            grid.style.cssText = `
                display: grid !important;
                grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
                gap: 25px !important; 
                width: 100% !important;
            `;
            
            // En pantallas grandes, usar 3 columnas
            if (window.innerWidth >= 1200) {
                grid.style.gridTemplateColumns = 'repeat(3, minmax(0, 1fr)) !important';
            }
            
            // Asegurarse de que los items de pregunta tengan el ancho correcto
            const items = grid.querySelectorAll('.pregunta-item');
            items.forEach(item => {
                item.style.cssText = `
                    width: 100% !important;
                    box-sizing: border-box !important;
                    margin: 0 !important;
                `;
                
                // Mejorar espaciado de opciones Sí/No
                const siNoOptions = item.querySelectorAll('input[type="radio"]');
                if (siNoOptions.length === 2) {
                    const container = item.querySelector('.opciones-container');
                    if (container) {
                        container.style.cssText = `
                            display: flex !important;
                            gap: 30px !important;
                            margin-top: 15px !important;
                        `;
                    }
                }
            });
            
            // Forzar espaciado entre opciones múltiples
            const opcionesMultiples = grid.querySelectorAll('.opciones-container:not(.opciones-horizontal)');
            opcionesMultiples.forEach(container => {
                const labels = container.querySelectorAll('.opcion-label');
                labels.forEach(label => {
                    label.style.marginRight = '15px';
                    label.style.marginBottom = '10px';
                });
            });
        });
    });
    
    // Función para aplicar validaciones numéricas específicas
    function aplicarValidacionesNumericas(item, numeroPregunta, textoPregunta) {
        const textarea = item.querySelector('textarea');
        if (!textarea) return; // Solo aplicar a preguntas de texto libre
        
        const preguntaLower = textoPregunta.toLowerCase();
        
        // Identificar tipo de validación necesaria SOLO para preguntas específicas
        let tipoValidacion = '';
        let maxLength = 0;
        let placeholder = '';
        
        // PREGUNTA 4: DNI de la persona entrevistada
        if (numeroPregunta === '4' && preguntaLower.includes('dni')) {
            tipoValidacion = 'dni';
            maxLength = 8;
            placeholder = 'Ingrese 8 dígitos del DNI';
        } 
        // PREGUNTA 5: Edad de la persona entrevistada
        else if (numeroPregunta === '5' && preguntaLower.includes('edad')) {
            tipoValidacion = 'edad';
            maxLength = 3;
            placeholder = 'Ingrese edad';
        }
        // PREGUNTA 21: ¿Qué edad tiene?
        else if (numeroPregunta === '21' && preguntaLower.includes('¿qué edad tiene?')) {
            tipoValidacion = 'edad';
            maxLength = 3;
            placeholder = 'Ingrese edad';
        }
        // PREGUNTA 17: ¿Cuántas personas con discapacidad? (permitir 0)
        else if (numeroPregunta === '17' && preguntaLower.includes('cuántas personas')) {
            tipoValidacion = 'cantidad';
            maxLength = 2;
            placeholder = 'Ingrese cantidad (puede ser 0)';
        }
        // CELULAR (pregunta de contacto - buscar por contenido específico)
        else if (preguntaLower.includes('celular de contacto') || (preguntaLower.includes('celular') && preguntaLower.includes('opcional'))) {
            tipoValidacion = 'celular';
            maxLength = 9;
            placeholder = 'Ingrese 9 dígitos del celular';
        }
        // TIEMPO DE CUIDADO (buscar pregunta específica)
        else if (preguntaLower.includes('¿cuánto tiempo al día dedica al cuidado?')) {
            tipoValidacion = 'tiempo';
            maxLength = 3;
            placeholder = 'Ingrese tiempo en horas';
        }
        
        if (tipoValidacion) {
            // Configurar textarea
            textarea.placeholder = placeholder;
            textarea.style.backgroundColor = '#f8f9fa';
            textarea.style.border = '2px solid #007bff';
            
            // Crear mensaje de ayuda
            const helpDiv = document.createElement('div');
            helpDiv.className = 'validacion-help';
            helpDiv.style.cssText = `
                font-size: 0.8em;
                color: #6c757d;
                margin-top: 5px;
                font-style: italic;
            `;
            
            switch(tipoValidacion) {
                case 'dni':
                    helpDiv.textContent = '📋 Solo números, exactamente 8 dígitos';
                    break;
                case 'edad':
                    helpDiv.textContent = '🎂 Solo números';
                    break;
                case 'celular':
                    helpDiv.textContent = '📱 Solo números, exactamente 9 dígitos';
                    break;
                case 'tiempo':
                    helpDiv.textContent = '⏰ Solo números (horas)';
                    break;
                case 'cantidad':
                    helpDiv.textContent = '👥 Solo números (puede ser 0)';
                    break;
            }
            
            textarea.parentNode.appendChild(helpDiv);
            
            // Aplicar validación en tiempo real
            textarea.addEventListener('input', function(e) {
                validarEntradaNumerica(e.target, tipoValidacion, maxLength);
            });
            
            // Validar al perder foco
            textarea.addEventListener('blur', function(e) {
                validarFormatoFinal(e.target, tipoValidacion);
            });
        }
    }
    
    // Función para validar entrada numérica en tiempo real
    function validarEntradaNumerica(textarea, tipo, maxLength) {
        let valor = textarea.value;
        
        // Eliminar caracteres no numéricos
        valor = valor.replace(/[^0-9]/g, '');
        
        // Aplicar longitud máxima
        if (valor.length > maxLength) {
            valor = valor.substring(0, maxLength);
        }
        
        // Validaciones específicas
        if (tipo === 'edad') {
            const edad = parseInt(valor);
            if (edad > 110) {
                valor = '110';
            }
        }
        
        textarea.value = valor;
        
        // Cambiar color del borde según validez
        if (esValido(valor, tipo)) {
            textarea.style.borderColor = '#28a745';
            textarea.style.backgroundColor = '#f8fff9';
        } else {
            textarea.style.borderColor = '#dc3545';
            textarea.style.backgroundColor = '#fff5f5';
        }
    }
    
    // Función para validar formato final
    function validarFormatoFinal(textarea, tipo) {
        const valor = textarea.value.trim();
        const helpDiv = textarea.parentNode.querySelector('.validacion-help');
        
        if (valor === '') {
            // Campo vacío, restaurar estilo normal
            textarea.style.borderColor = '#007bff';
            textarea.style.backgroundColor = '#f8f9fa';
            if (helpDiv) helpDiv.style.color = '#6c757d';
            return;
        }
        
        if (!esValido(valor, tipo)) {
            // Mostrar error específico
            if (helpDiv) {
                helpDiv.style.color = '#dc3545';
                helpDiv.style.fontWeight = 'bold';
                
                switch(tipo) {
                    case 'dni':
                        helpDiv.textContent = '❌ DNI debe tener exactamente 8 dígitos';
                        break;
                    case 'edad':
                        helpDiv.textContent = '❌ Edad debe ser un número entre 1 y 110';
                        break;
                    case 'celular':
                        helpDiv.textContent = '❌ Celular debe tener exactamente 9 dígitos';
                        break;
                    case 'tiempo':
                        helpDiv.textContent = '❌ Ingrese solo números para el tiempo';
                        break;
                    case 'cantidad':
                        helpDiv.textContent = '❌ Ingrese solo números (puede ser 0)';
                        break;
                }
            }
        } else {
            // Campo válido
            textarea.style.borderColor = '#28a745';
            textarea.style.backgroundColor = '#f8fff9';
            if (helpDiv) {
                helpDiv.style.color = '#28a745';
                helpDiv.style.fontWeight = 'bold';
                helpDiv.textContent = '✅ Formato correcto';
            }
        }
    }
    
    // Función para verificar si el valor es válido
    function esValido(valor, tipo) {
        if (!valor || valor.trim() === '') return true; // Campo vacío es válido (opcional)
        
        const numero = parseInt(valor);
        
        switch(tipo) {
            case 'dni':
                return valor.length === 8 && !isNaN(numero);
            case 'edad':
                return valor.length >= 1 && valor.length <= 3 && numero >= 1 && numero <= 110;
            case 'celular':
                return valor.length === 9 && !isNaN(numero);
            case 'tiempo':
                return !isNaN(numero) && numero >= 0;
            case 'cantidad':
                return !isNaN(numero) && numero >= 0 && numero <= 99; // Permitir 0 y hasta 99 personas
            default:
                return true;
        }
    }
</script>

<!-- RESPONSIVIDAD ADICIONAL -->
<style>
    /* ================== RESPONSIVIDAD ADICIONAL ================== */
    @media (max-width: 768px) {
        .header-content {
            flex-direction: column;
            height: auto;
            padding: 0.5rem 1rem;
            gap: 1rem;
            justify-content: center;
        }

        .header-left,
        .header-right {
            width: 100%;
            display: flex;
            justify-content: center;
        }

        .header-right {
            flex-wrap: wrap;
            gap: 1rem;
            margin-top: 0.5rem;
            position: relative;
        }
        
        .form-close-btn {
            width: 32px;
            height: 32px;
            font-size: 16px;
            top: 15px;
            right: 15px;
        }
        
        .form-container {
            margin: 10px;
            padding: 20px;
        }

        .nav-icon {
            width: 30px;
            height: 30px;
        }

        /* Main content responsive */
        .main-content {
            width: 95%;
            margin: 0.5rem auto;
            padding: 0 10px;
        }

        .main-content h2 {
            font-size: 1.4rem;
            margin-bottom: 1.5rem;
            text-align: center;
        }

        /* Formulario responsive */
        .preguntas-container {
            padding: 15px 10px;
        }

        .preguntas-grid {
            gap: 20px !important;
        }

        .pregunta-item {
            padding: 1rem;
            margin-bottom: 1rem;
        }

        .pregunta-item h3 {
            font-size: 1rem;
            line-height: 1.4;
        }

        .pregunta-item textarea {
            font-size: 1rem;
            padding: 0.8rem;
            min-height: 80px;
        }

        /* Botones responsive */
        form > div[style*="justify-content: flex-end"] {
            flex-direction: column !important;
            gap: 12px !important;
            margin-top: 2rem !important;
        }

        .btn-primary,
        .btn-secondary {
            width: 100% !important;
            margin: 0 !important;
            padding: 12px 16px !important;
            font-size: 1rem !important;
            min-width: auto !important;
        }

        /* Popups responsive */
        .popup-contenido {
            margin: 20px 10px !important;
            padding: 1.5rem 1rem !important;
            max-width: 90% !important;
        }
    }

    @media (max-width: 480px) {
        .main-content {
            width: 98%;
            margin: 0.25rem auto;
            padding: 0 5px;
        }

        .header-bar {
            height: auto;
            min-height: 56px;
        }

        .header-content {
            padding: 0.75rem 0.5rem;
        }

        .logo-large img {
            height: 35px;
        }

        .nav-item#btn-encuestador span {
            font-size: 0.8rem;
        }
        
        .form-container {
            margin: 5px;
            padding: 15px;
            border-radius: 8px;
        }
        
        .form-close-btn {
            width: 28px;
            height: 28px;
            font-size: 14px;
            top: 10px;
            right: 10px;
        }

        .main-content h2 {
            font-size: 1.2rem;
            margin-bottom: 1rem;
        }

        .preguntas-container {
            padding: 10px 5px;
        }

        .preguntas-grid {
            gap: 15px !important;
        }

        .pregunta-item {
            padding: 0.8rem;
            margin-bottom: 0.8rem;
        }

        .pregunta-item h3 {
            font-size: 0.95rem;
        }

        .pregunta-item textarea {
            font-size: 0.9rem;
            padding: 0.7rem;
        }

        /* Advertencias responsive */
        .advertencia-navegacion {
            font-size: 0.8rem;
            padding: 5px 8px;
            margin: 6px 0 10px;
        }

        /* Sidebar responsive */
        .sidebar {
            width: 260px;
            left: -260px;
        }

        .menu-toggle:checked ~ .sidebar {
            left: 0;
        }

        /* Popup muy responsive */
        .popup-contenido {
            margin: 10px 5px !important;
            padding: 1.2rem 0.8rem !important;
            max-width: 95% !important;
        }

        .popup-contenido h3 {
            font-size: 1.1rem !important;
        }

        .popup-contenido p {
            font-size: 0.9rem !important;
        }
    }
</style>
</body>
</html>
