<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Crear Respuesta Manual</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>

<style>
    /* ===== ESTILOS CABECERA Y SIDEBAR ===== */
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background-color: #f5f7fa;
        margin: 0;
        padding: 0;
        color: #333;
        transition: margin-left 0.3s;
    }

    .menu-toggle {
        display: none !important;
    }

    .sidebar {
        position: fixed;
        top: 0;
        left: -280px;
        width: 280px;
        height: 100%;
        background: linear-gradient(135deg, #dbeeff 60%, #b3ccff 100%);
        box-shadow: 8px 0 32px rgba(52, 152, 219, 0.13), 2px 0 8px rgba(52, 152, 219, 0.10);
        border-right: 3px solid #3498db;
        border-radius: 0 28px 0 0;
        transition: left 0.3s ease;
        z-index: 2001;
        overflow-y: auto;
        padding: 24px 0 20px 0;
        backdrop-filter: blur(6px);
    }

    .menu-toggle:checked ~ .sidebar {
        left: 0;
    }

    .overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background: rgba(0,0,0,0.5);
        opacity: 0;
        visibility: hidden;
        transition: opacity 0.3s ease;
        z-index: 2000;
    }

    .menu-toggle:checked ~ .overlay {
        opacity: 1;
        visibility: visible;
    }

    .sidebar-content {
        height: 100%;
        display: flex;
        flex-direction: column;
        gap: 18px;
    }

    .sidebar-separator {
        width: 80%;
        height: 2px;
        background: linear-gradient(90deg, #b3ccff 0%, #3498db 100%);
        border-radius: 2px;
        margin: 18px auto;
        opacity: 0.7;
    }

    .menu-links {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .menu-links li {
        margin-bottom: 15px;
    }

    .menu-links a {
        display: flex;
        align-items: center;
        padding: 12px 20px;
        margin: 0 15px;
        border-radius: 8px;
        color: #1a1a1a;
        text-decoration: none;
        background-color: transparent;
        transition: all 0.3s ease;
        font-size: 16px;
        font-weight: bold;
    }

    .menu-links a i {
        margin-right: 10px;
        font-size: 18px;
    }

    .menu-links a:hover {
        background-color: #b3ccff;
        transform: scale(1.05);
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.12);
        color: #003366;
    }

    .header-bar {
        background-color: #dbeeff;
        height: 56.8px;
        display: flex;
        align-items: center;
        justify-content: flex-start;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        position: relative;
        z-index: 800;
        width: 100%;
        padding: 0;
    }

    .header-content {
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: flex-start;
        gap: 1rem;
        padding: 0 20px;
        box-sizing: border-box;
    }

    .header-left {
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }

    .menu-icon {
        font-size: 26px;
        cursor: pointer;
        color: #333;
    }

    .logo-section {
        display: flex;
        flex-direction: column;
        margin-left: 10px;
    }

    .logo-large img {
        height: 40px;
        object-fit: contain;
    }

    .header-right {
        display: flex;
        gap: 2.5rem;
        margin-left: auto;
    }

    .nav-item {
        display: flex;
        align-items: center;
        gap: 6px;
        cursor: pointer;
        font-weight: bold;
        color: #333;
        text-transform: uppercase;
        font-size: 0.9rem;
        user-select: none;
        position: relative;
    }

    .nav-icon {
        width: 28px;
        height: 28px;
        object-fit: cover;
    }

    .dropdown-menu {
        display: none;
        position: absolute;
        top: 110%;
        left: 0;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        min-width: 140px;
        z-index: 1001;
        padding: 8px 0;
    }

    .nav-item.dropdown:hover .dropdown-menu,
    .nav-item.dropdown:focus-within .dropdown-menu {
        display: block;
    }

    .dropdown-menu a {
        display: block;
        padding: 8px 18px;
        color: #333;
        text-decoration: none;
        font-size: 0.95em;
        transition: background 0.2s;
    }

    .dropdown-menu a:hover {
        background: #e6f0ff;
        color: #007bff;
    }

    /* ===== ESTILOS DEL FORMULARIO ===== */
    .main-content {
        width: 90%;
        max-width: 1000px;
        margin: 2rem auto;
        padding-bottom: 3rem;
    }

    .main-content h2 {
        font-size: 1.8rem;
        text-align: center;
        margin-bottom: 2rem;
        color: #007bff;
    }

    .main-content h3 {
        font-size: 1.3rem;
        margin-bottom: 1rem;
        margin-top: 2.5rem;
        color: #003366;
        border-left: 4px solid #007bff;
        padding-left: 10px;
    }

    .bloque-pregunta {
        background-color: #e6f0ff;
        border: 1px solid #c8dbff;
        border-radius: 6px;
        padding: 1.2rem;
        margin-bottom: 1.5rem;
    }

    .bloque-pregunta p {
        font-weight: bold;
        margin-bottom: 0.5rem;
        color: #333;
    }

    .bloque-pregunta .descripcion {
        font-style: italic;
        color: #666;
        font-size: 0.9rem;
        margin-bottom: 0.8rem;
    }

    .bloque-pregunta label {
        display: block;
        margin: 0.4rem 0;
        font-weight: normal;
        cursor: pointer;
    }

    .bloque-pregunta input[type="radio"] {
        accent-color: #2196f3;
        margin-right: 8px;
    }

    textarea {
        width: 100%;
        border: 1px solid #ccc;
        border-radius: 4px;
        padding: 0.6rem;
        resize: vertical;
        font-size: 1rem;
        font-family: inherit;
    }

    .formulario-acciones {
        text-align: center;
        margin-top: 2.5rem;
    }

    .formulario-acciones button {
        padding: 10px 20px;
        font-size: 1rem;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        background-color: #28a745;
        color: #fff;
        transition: background-color 0.2s ease;
    }

    .formulario-acciones button:hover {
        background-color: #218838;
    }

    @media (max-width: 768px) {
        .main-content {
            width: 95%;
            padding: 1rem;
        }

        .main-content h2 {
            font-size: 1.5rem;
        }

        .main-content h3 {
            font-size: 1.1rem;
        }
    }
</style>

<body>
<input type="checkbox" id="menu-toggle" class="menu-toggle" />
<div class="sidebar">
    <div class="sidebar-content">
        <div class="sidebar-separator"></div>
        <ul class="menu-links">
            <li><a href="DashboardServlet"><i class="fa-solid fa-chart-line"></i> Ver Dashboard</a></li>
            <li><a href="GestionEncuestadoresServlet"><i class="fa-solid fa-users"></i> Gestionar Encuestadores</a></li>
            <li><a href="GestionarFormulariosServlet"><i class="fa-solid fa-file-alt"></i> Gestionar Formularios</a></li>
            <li><a href="CerrarSesionServlet"><i class="fa-solid fa-sign-out-alt"></i> Cerrar sesión</a></li>
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
                <span>${sessionScope.nombre}</span>
                <div class="dropdown-menu">
                    <a href="VerPerfilServlet">Ver perfil</a>
                    <a href="CerrarSesionServlet">Cerrar sesión</a>
                </div>
            </div>
            <a href="InicioCoordinadorServlet" class="nav-item" id="btn-inicio">
                <img src="${pageContext.request.contextPath}/imagenes/inicio.png" alt="Icono de perfil" class="nav-icon" />
            </a>
        </nav>
    </div>
</header>

<div class="main-content">
    <h2>${formulario.titulo}</h2>

    <form action="GuardarRespuestasManualServlet" method="post" onsubmit="return confirmarEnvio(event)">
        <input type="hidden" name="idFormulario" value="${formulario.idFormulario}" />
        <input type="hidden" name="idAsignacionFormulario" value="${idAsignacionFormulario}" />

        <input type="hidden" id="accion-hidden" name="accion" value="terminar" />

        <c:set var="ultimaSeccion" value="" />

        <c:forEach var="pregunta" items="${preguntas}" varStatus="status">
            <c:if test="${pregunta.seccion != ultimaSeccion}">
                <h3>${pregunta.seccion}</h3>
                <c:set var="ultimaSeccion" value="${pregunta.seccion}" />
            </c:if>

            <div class="bloque-pregunta">
                <p>${pregunta.orden}. ${pregunta.textoPregunta}</p>

                <c:if test="${not empty pregunta.descripcion}">
                    <div class="descripcion">${pregunta.descripcion}</div>
                </c:if>

                <input type="hidden" name="obligatorio_${pregunta.idPregunta}" value="${pregunta.obligatorio}" />

                <c:choose>
                    <c:when test="${pregunta.tipoPregunta == 1}">
                        <textarea name="respuesta_${pregunta.idPregunta}" placeholder="Escribe tu respuesta..."></textarea>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="opcion" items="${pregunta.opciones}">
                            <label>
                                <input type="radio" name="respuesta_${pregunta.idPregunta}" value="${opcion.idOpcion}" />
                                    ${opcion.textoOpcion}
                            </label>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:forEach>

        <div class="formulario-acciones">
            <button type="submit">Terminar y Enviar</button>
        </div>
    </form>
</div>

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
        const accion = "terminar";
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

    window.onload = function () {
        const params = new URLSearchParams(window.location.search);
        if (params.get("error") === "vacio") {
            document.getElementById("popup-vacio").style.display = "flex";
        } else if (params.get("error") === "obligatorias") {
            document.getElementById("popup-obligatorias").style.display = "flex";
        }
    }
</script>
</body>
</html>
