<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<html>
<style>
    :root {
        --color-primary: #3498db;
        --color-success: #2ecc71;
        --color-danger: #e74c3c;
        --color-gray: #95a5a6;
        --header-bg: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
    }

    /* ---- Estilos para el contenido principal (ajustados por el sidebar) ---- */
    body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        background-color: #f5f7fa;
        margin: 0;
        padding: 0;
        color: #333;
        transition: margin-left 0.3s;
    }
    .menu-toggle {
        display: none !important;
    }
    /* Ajuste cuando el sidebar está abierto */
    .menu-toggle:checked ~ .sidebar {
        left: 0;
    }
    .menu-toggle:checked ~ .overlay {
        display: block;
        opacity: 1;
    }

    /* Contenedor principal */
    .contenedor-principal, .main-content {
        width: 100%;
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        background: #fff;
        min-height: calc(100vh - 56.8px);
    }

    /* ---- Estilos específicos para la tabla ---- */
    .contenedor {
        background: #fff;
        border-radius: 0;
        box-shadow: none;
        border: none;
        width: 100vw;
        max-width: 100vw;
        margin: 0;
        padding: 32px 5vw 24px 5vw;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: stretch;
        justify-content: flex-start;
        box-sizing: border-box;
    }
    .tabla-container {
        overflow-x: auto;
        margin-top: 20px;
    }

    table {
        width: 100%;
        max-width: 1600px;
        margin: 0 auto;
        border-collapse: separate;
        border-spacing: 0;
        background: #fff;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    }

    th, td {
        padding: 15px;
        text-align: left;
        border-bottom: 1px solid #e0e0e0;
    }

    th {
        background-color: #f8f9fa;
        color: #2c3e50;
        font-weight: 600;
        text-transform: uppercase;
        font-size: 0.85em;
        letter-spacing: 0.5px;
    }

    th.estado-col {
        text-align: center;
    }

    td.estado-col {
        text-align: center;
    }

    tr:hover {
        background-color: #f8f9fa;
    }

    .estado-activo, .estado-inactivo {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 5px 10px;
        border-radius: 20px;
        font-size: 0.85em;
        font-weight: 500;
    }

    .estado-activo {
        background-color: rgba(46, 204, 113, 0.1);
        color: var(--color-success);
    }

    .estado-inactivo {
        background-color: rgba(231, 76, 60, 0.1);
        color: var(--color-danger);
    }

    /* Sidebar estilo unificado */
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
        transition: left 0.3s ease, box-shadow 0.2s;
        z-index: 2001;
        overflow-y: auto;
        padding: 24px 0 20px 0;
        backdrop-filter: blur(6px);
    }
    .menu-toggle:checked ~ .sidebar { left: 0; }

    .sidebar-content {
        height: 100%;
        display: flex;
        flex-direction: column;
        gap: 18px;
        position: relative;
    }
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
    .sidebar-separator {
        width: 80%;
        height: 2px;
        background: linear-gradient(90deg, #b3ccff 0%, #3498db 100%);
        border-radius: 2px;
        margin: 18px auto 18px auto;
        opacity: 0.7;
    }
    .sidebar-content .menu-links {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .sidebar-content .menu-links li {
        margin-bottom: 15px;
    }

    .sidebar-content .menu-links a {
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

    .sidebar-content .menu-links a i {
        margin-right: 10px;
        font-size: 18px;
    }

    .sidebar-content .menu-links a:hover {
        background-color: #b3ccff;
        transform: scale(1.05);
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.12);
        color: #003366;
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

    .header-bar {
        background: var(--header-bg);
        height: 56.8px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 2px 10px rgba(135,206,235,0.3);
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
        margin: 0;
        padding: 0 20px;
        box-sizing: border-box;
    }

    .header-left {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        margin-left: 0;
    }
    .menu-icon {
        font-size: 26px;
        cursor: pointer;
        color: #333;
        display: inline-block;
        margin-left: 0;
    }
    .logo-section {
        display: flex;
        flex-direction: column;
        gap: 0.2rem;
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
    .nav-item#btn-inicio span {
        display: none;
    }
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
    /* Dropdown arrow styling */
    .dropdown-arrow {
        font-size: 12px;
        transition: transform 0.2s ease;
        margin-left: 4px;
    }
    .nav-item.dropdown-active .dropdown-arrow {
        transform: rotate(180deg);
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
    .nav-item.dropdown:focus-within .dropdown-menu,
    .nav-item.dropdown:hover .dropdown-menu {
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
    .dropdown-estado {
        position: relative;
        display: inline-block;
    }
    .btn-estado {
        cursor: pointer;
        background: none;
        border: none;
        outline: none;
        padding: 0;
        font: inherit;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .dropdown-menu-estado {
        position: absolute;
        top: 110%;
        left: 0;
        min-width: 120px;
        background: #fff;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        z-index: 10;
        padding: 4px 0;
    }
    .dropdown-option {
        padding: 8px 16px;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 6px;
        transition: background 0.2s;
    }
    .dropdown-option:hover {
        background: #f0f4fa;
    }
    .busqueda-form {
        margin-bottom: 20px;
        text-align: left;
    }
    .filtros-container {
        display: flex;
        flex-wrap: wrap;
        justify-content: flex-start;
        gap: 10px;
        align-items: center;
        margin-top: 18px;
        margin-bottom: 18px;
    }
    .input-filtro {
        padding: 8px 12px;
        border: 1px solid #ccc;
        border-radius: 6px;
        font-size: 14px;
        min-width: 180px;
    }
    .input-busqueda, .select-zona {
        height: 40px;
        min-width: 140px;
        padding: 8px 20px;
        border: 1px solid #ccc;
        border-radius: 6px;
        font-size: 16px;
        box-sizing: border-box;
        margin-right: 0;
        background: #fff;
        color: #333;
        outline: none;
        transition: border 0.2s;
        display: flex;
        align-items: center;
    }
    .input-busqueda:focus, .select-zona:focus {
        border: 1.5px solid #2196f3;
    }
    .btn-filtrar, .btn-excel {
        height: 40px;
        min-width: 140px;
        padding: 8px 20px;
        border: none;
        border-radius: 6px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        box-sizing: border-box;
    }
    .btn-filtrar {
        background: #2196f3;
        color: #fff;
    }
    .btn-excel {
        background: #219653;
        color: #fff;
    }
    .btn-filtrar:hover {
        background: #1769aa;
    }
    .btn-excel:hover {
        background: #17693a;
    }

    .paginacion {
        margin-top: 24px;
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 8px;
        font-family: inherit;
    }
    .paginacion a {
        color: #3498db;
        font-weight: bold;
        text-decoration: none;
        padding: 6px 12px;
        border-radius: 6px;
        transition: background 0.2s;
        font-size: 0.95rem;
    }
    .paginacion a.active,
    .paginacion a:hover {
        background-color: #e6f0ff;
    }
    .btn-cambiar-estado {
        color: white;
        border: none;
        border-radius: 20px;
        padding: 8px 0;
        font-weight: bold;
        cursor: pointer;
        min-width: 140px;
        width: 140px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        font-size: 1rem;
        transition: background 0.2s, box-shadow 0.2s;
        box-shadow: 0 2px 8px rgba(44,62,80,0.04);
        text-align: center;
    }
    .btn-estado-activo {
        background-color: #2ecc71;
    }
    .btn-estado-inactivo {
        background-color: #e74c3c;
    }
    .filtros-superior {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-top: 18px;
        margin-bottom: 18px;
    }
    .btn-asignar-formulario {
        background-color: #3498db;
        color: white;
        border: none;
        border-radius: 20px;
        padding: 8px 14px;
        font-weight: bold;
        font-size: 0.9rem;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }
    .btn-asignar-formulario:hover {
        background-color: #217dbb;
    }

</style>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Gestión de Encuestadores</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<input type="checkbox" id="menu-toggle" class="menu-toggle" style="display:none;" />
<div id="toast" style="
  visibility: hidden;
  position: fixed;
  top: 32px;
  left: 50%;
  transform: translateX(-50%);
  background-color: #2ecc71;
  color: white;
  text-align: center;
  border-radius: 10px;
  padding: 20px 25px;
  font-size: 1.1rem;
  font-weight: bold;
  z-index: 9999;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
  opacity: 0;
  transition: opacity 0.5s ease, top 0.5s ease;
">
    Mensaje
</div>
<div class="sidebar">
    <div class="sidebar-content">
        <button class="sidebar-close-btn" onclick="document.getElementById('menu-toggle').checked = false;">×</button>
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
                <span style="color: #007bff;">${sessionScope.nombre}</span>
                <i class="fas fa-chevron-down dropdown-arrow"></i>
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
<main class="contenedor-principal">
    <div class="contenedor">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h2 style="margin-bottom: 0.5em;">Gestión de Encuestadores</h2>
        </div>
        <div style="display: flex; justify-content: flex-start; margin-bottom: 24px;">
            <form method="get" action="GestionEncuestadoresServlet" style="display: flex; gap: 10px; align-items: center;">
                <input type="text" name="nombre" placeholder="Buscar por nombre o DNI" value="${param.nombre}" class="input-busqueda" />
                <select name="estado" class="select-zona">
                    <option value="">Todos</option>
                    <option value="2" ${param.estado == '2' ? 'selected' : ''}>Activado</option>
                    <option value="3" ${param.estado == '3' ? 'selected' : ''}>Desactivado</option>
                </select>
                <button type="submit" class="btn-filtrar">
                    <i class="fa fa-search"></i> Filtrar
                </button>
            </form>
        </div>
        <div class="tabla-container">
            <table>
                <thead>
                <tr>
                    <th>Nombre</th>
                    <th>DNI</th>
                    <th>Correo electrónico</th>
                    <th>Distrito</th>
                    <th class="estado-col">Estado</th>
                    <th>Acciones</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty encuestadores}">
                        <tr>
                            <td colspan="6" style="text-align:center; color:#e74c3c; font-weight:bold; font-size:1.1em; padding:32px 0;">
                                No se encontraron resultados.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="encuestador" items="${encuestadores}">
                            <tr data-id="${encuestador.usuario.idUsuario}">
                                <td>${encuestador.usuario.nombre} ${encuestador.usuario.apellidopaterno} ${encuestador.usuario.apellidomaterno}</td>
                                <td>${encuestador.usuario.dni}</td>
                                <td>${encuestador.credencial.correo}</td>
                                <td>${encuestador.distritoNombre}</td>
                                <td class="estado-col">
                                    <button class="btn-cambiar-estado ${encuestador.usuario.idEstado == 2 ? 'btn-estado-activo' : 'btn-estado-inactivo'}"
                                            data-id="${encuestador.usuario.idUsuario}"
                                            data-estado="${encuestador.usuario.idEstado}">
                                        <i class="fas fa-power-off"></i>
                                            ${encuestador.usuario.idEstado == 2 ? 'Activado' : 'Desactivado'}
                                    </button>
                                </td>
                                <td>
                                    <form method="get" action="${pageContext.request.contextPath}/AsignarFormularioServlet" style="margin: 0;">
                                        <input type="hidden" name="idEncuestador" value="${encuestador.usuario.idUsuario}" />
                                        <button type="submit" class="btn-asignar-formulario">
                                            <i class="fa-solid fa-file-circle-plus"></i> Asignar
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
        <div class="paginacion">
            <c:if test="${paginaActual > 1}">
                <a href="GestionEncuestadoresServlet?pagina=${paginaActual - 1}&nombre=${fn:escapeXml(param.nombre)}&estado=${param.estado}">&lt;</a>
            </c:if>
            <c:forEach var="i" begin="1" end="${totalPaginas}">
                <a href="GestionEncuestadoresServlet?pagina=${i}&nombre=${fn:escapeXml(param.nombre)}&estado=${param.estado}"
                   class="${i == paginaActual ? 'active' : ''}">${i}</a>
            </c:forEach>
            <c:if test="${paginaActual < totalPaginas}">
                <a href="GestionEncuestadoresServlet?pagina=${paginaActual + 1}&nombre=${fn:escapeXml(param.nombre)}&estado=${param.estado}">&gt;</a>
            </c:if>
        </div>
    </div>
</main>

<div id="modal-confirm" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.35); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; padding:32px 28px; border-radius:12px; box-shadow:0 8px 32px rgba(0,0,0,0.18); min-width:320px; max-width:90vw; text-align:center;">
        <div id="modal-msg" style="font-size:1.1rem; margin-bottom:18px;"></div>
        <button id="modal-confirm-btn" style="background:#2ecc71; color:#fff; border:none; border-radius:8px; padding:8px 22px; font-weight:bold; margin-right:12px; cursor:pointer;">Confirmar</button>
        <button id="modal-cancel-btn" style="background:#e74c3c; color:#fff; border:none; border-radius:8px; padding:8px 22px; font-weight:bold; cursor:pointer;">Cancelar</button>
    </div>
</div>
<script>
    let cambiosPendientes = {};
    let idPendiente = null, nuevoEstadoPendiente = null;
    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.btn-cambiar-estado').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                idPendiente = btn.getAttribute('data-id');
                const estadoActual = btn.getAttribute('data-estado');
                nuevoEstadoPendiente = (estadoActual === '2') ? '3' : '2';
                document.getElementById('modal-msg').innerText = (nuevoEstadoPendiente === '2') ?
                    '¿Está seguro que desea ACTIVAR a este encuestador?' :
                    '¿Está seguro que desea DESACTIVAR a este encuestador?';
                document.getElementById('modal-confirm').style.display = 'flex';
            });
        });
        document.getElementById('modal-cancel-btn').onclick = function() {
            document.getElementById('modal-confirm').style.display = 'none';
            idPendiente = null; nuevoEstadoPendiente = null;
        };
        document.getElementById('modal-confirm-btn').onclick = function() {
            if (!idPendiente || !nuevoEstadoPendiente) return;
            const idUsuarioLocal = idPendiente;
            const nuevoEstadoLocal = nuevoEstadoPendiente;
            console.log('Enviando cambio de estado', { idUsuarioLocal, nuevoEstadoLocal });

            fetch('${pageContext.request.contextPath}/GestionEncuestadoresServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'accion=cambiarEstado&idUsuario=' + encodeURIComponent(idUsuarioLocal) + '&nuevoEstado=' + encodeURIComponent(nuevoEstadoLocal)
            })
                .then((res) => {
                    if (!res.ok) throw new Error('HTTP error ' + res.status);
                    return res.json().catch(async () => {
                        const text = await res.text();
                        mostrarToast('Respuesta inesperada: ' + text.substring(0, 100), false);
                        throw new Error('Respuesta no JSON: ' + text);
                    });
                })
                .then((data) => {
                    if (data.success) {
                        const allBtns = document.querySelectorAll('.btn-cambiar-estado');
                        const btn = Array.from(allBtns).find(b => b.getAttribute('data-id') == idUsuarioLocal);
                        if (!btn) {
                            mostrarToast('Error: botón no encontrado en DOM (id=' + idUsuarioLocal + ')', false);
                            return;
                        }
                        btn.setAttribute('data-estado', nuevoEstadoLocal);
                        console.log('Estado actualizado en botón:', btn.getAttribute('data-estado'));

                        btn.innerHTML = '<i class="fas fa-power-off"></i> ' + (nuevoEstadoLocal === '2' ? 'Activado' : 'Desactivado');
                        btn.classList.toggle('btn-estado-activo', nuevoEstadoLocal === '2');
                        btn.classList.toggle('btn-estado-inactivo', nuevoEstadoLocal !== '2');
                        mostrarToast('¡Estado actualizado con éxito!', true);

                    } else {
                        mostrarToast('Error al cambiar estado', false);
                    }
                })
                .catch((err) => {
                    console.error("Error en fetch:", err);
                    mostrarToast('Error de red al cambiar estado', false);
                });
            document.getElementById('modal-confirm').style.display = 'none';
            idPendiente = null; nuevoEstadoPendiente = null;
        };
    });
    function mostrarToast(mensaje, exito) {
        const toast = document.getElementById("toast");
        toast.innerText = mensaje;
        toast.style.backgroundColor = exito ? '#2ecc71' : '#e74c3c';
        toast.style.visibility = "visible";
        toast.style.opacity = "1";
        toast.style.top = "32px";
        toast.style.left = "50%";
        toast.style.transform = "translateX(-50%)";
        setTimeout(() => {
            toast.style.opacity = "0";
            toast.style.top = "0px";
            setTimeout(() => {
                toast.style.visibility = "hidden";
            }, 500);
        }, 3000);
    }
</script>
</body>
</html>