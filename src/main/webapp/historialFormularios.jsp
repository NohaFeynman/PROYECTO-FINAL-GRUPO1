<%--
  Created by IntelliJ IDEA.
  User: Nilton
  Date: 14/05/2025
  Time: 12:27
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
    <title>Intranet - Formularios Asignados</title>
    <link rel="stylesheet" href="historialFormularios_simple.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
                <i class="fas fa-chevron-down dropdown-arrow"></i>
                
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


<!-- Contenido principal -->
<main class="main-content">
    <h2>FORMULARIOS</h2>

    <!-- Filtro por fecha + botón limpiar -->
    <form method="get" action="HistorialFormulariosServlet" class="form-filtro">
        <div class="filter-group">
            <label class="filter-label">Fecha Inicio</label>
            <input type="date" name="fechaFiltroInicio" value="${fechaFiltroInicio}" placeholder="dd/mm/aaaa" />
            <span class="filter-hint">Selecciona la fecha de inicio del periodo</span>
        </div>
        
        <div class="filter-group">
            <label class="filter-label">Fecha Fin</label>
            <input type="date" name="fechaFiltroFin" value="${fechaFiltroFin}" placeholder="dd/mm/aaaa" />
            <span class="filter-hint">Selecciona la fecha final del periodo</span>
        </div>
        
        <div class="filter-actions">
            <button type="submit" class="btn-filtrar">
                <img src="${pageContext.request.contextPath}/imagenes/buscar.png" alt="Filtrar" style="width:18px;height:18px;vertical-align:middle;margin-right:6px;filter:invert(1);"> Filtrar
            </button>

            <!-- Botón limpiar filtros -->
            <a href="HistorialFormulariosServlet" class="btn-limpiar">Limpiar filtros</a>
        </div>
    </form>

    <!-- Lista paginada -->
    <div class="tabla-container">
        <table>
            <thead>
                <tr>
                    <th>Cuestionario</th>
                    <th>Última Modificación</th>
                    <th class="estado-col">Estado</th>
                    <th>Progreso</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty historialFormulariosPaginado}">
                        <tr>
                            <td colspan="5" class="sin-datos">
                                <i class="fas fa-inbox"></i>
                                <p>Aún no se ha registrado ninguna respuesta.</p>
                                <p>¡Cuando completes formularios, aparecerán aquí!</p>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="sesion" items="${historialFormulariosPaginado}">
                            <tr>
                                <td>
                                    <strong>Cuestionario ${sesion.numeroSesion}</strong>
                                </td>
                                <td>
                                    <span class="fecha-formateada">
                                        <c:choose>
                                            <c:when test="${not empty sesion.fechaenvio}">
                                                ${sesion.fechaenvio}
                                            </c:when>
                                            <c:otherwise>
                                                ${sesion.fechainicio}
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                                <td class="estado-col">
                                    <c:choose>
                                        <c:when test="${sesion.estadoTerminado == 1}">
                                            <span class="estado-completado">
                                                <i class="fas fa-check-circle"></i>
                                                Completado
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="estado-en-progreso">
                                                <i class="fas fa-clock"></i>
                                                En Progreso
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="barra-progreso-tabla">
                                        <div class="barra-llenado-tabla" style="width: ${sesion.estadoTerminado == 1 ? '100' : '75'}%"></div>
                                    </div>
                                    <span class="porcentaje-texto">${sesion.estadoTerminado == 1 ? '100' : '75'}%</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${sesion.estadoTerminado == 0}">
                                            <form action="ReingresarFormularioServlet" method="get" style="display: inline;">
                                                <input type="hidden" name="idSesion" value="${sesion.idsesion}" />
                                                <button type="submit" class="btn-reingresar-tabla">
                                                    <i class="fas fa-edit"></i>
                                                    Reingresar
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="texto-completado">
                                                <i class="fas fa-check"></i>
                                                Finalizado
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <!-- Paginación -->
    <c:if test="${not empty historialFormulariosPaginado}">
        <div class="paginacion">
            <c:forEach begin="1" end="${totalPaginas}" var="pagina">
                <form method="get" action="HistorialFormulariosServlet" style="display: inline;">
                    <input type="hidden" name="pagina" value="${pagina}" />
                    <input type="hidden" name="fechaFiltroInicio" value="${fechaFiltroInicio}" />
                    <input type="hidden" name="fechaFiltroFin" value="${fechaFiltroFin}" />
                    <button type="submit" class="${pagina == paginaActual ? 'pagina-activa' : ''}">
                            ${pagina}
                    </button>
                </form>
            </c:forEach>
        </div>
    </c:if>
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

    // Formatear fechas para eliminar segundos y milisegundos
    document.addEventListener('DOMContentLoaded', function() {
        // Mejorar inputs de fecha
        const dateInputs = document.querySelectorAll('input[type="date"]');
        
        dateInputs.forEach(input => {
            // Agregar evento para mostrar/ocultar hint
            input.addEventListener('focus', function() {
                const hint = this.parentNode.querySelector('.filter-hint');
                if (hint) {
                    hint.style.opacity = '1';
                    hint.style.transform = 'translateY(0)';
                }
            });
            
            input.addEventListener('blur', function() {
                const hint = this.parentNode.querySelector('.filter-hint');
                if (hint && !this.value) {
                    hint.style.opacity = '0';
                    hint.style.transform = 'translateY(-5px)';
                }
            });
            
            // Agregar efecto visual al seleccionar fecha
            input.addEventListener('change', function() {
                this.style.background = '#e8f5e8';
                setTimeout(() => {
                    this.style.background = '#f8f9fa';
                }, 300);
            });
        });
        
        // Formatear fechas mostradas en la tabla
        const fechasElements = document.querySelectorAll('.fecha-formateada');
        
        fechasElements.forEach(element => {
            const fechaTexto = element.textContent.trim();
            if (fechaTexto) {
                try {
                    // Intentar parsear diferentes formatos de fecha
                    let fecha;
                    if (fechaTexto.includes('T')) {
                        // Formato ISO: 2025-07-18T02:25:46.0
                        fecha = new Date(fechaTexto);
                    } else if (fechaTexto.includes('-') && fechaTexto.includes(':')) {
                        // Formato: 2025-07-18 02:25:46.0
                        fecha = new Date(fechaTexto.replace(' ', 'T'));
                    } else {
                        fecha = new Date(fechaTexto);
                    }
                    
                    if (!isNaN(fecha.getTime())) {
                        // Formatear la fecha sin segundos ni milisegundos
                        const opciones = {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit',
                            hour12: false
                        };
                        
                        const fechaFormateada = fecha.toLocaleDateString('es-ES', opciones);
                        element.textContent = fechaFormateada.replace(',', '');
                    }
                } catch (error) {
                    console.log('Error al formatear fecha:', fechaTexto, error);
                }
            }
        });
        
        // Agregar animación de entrada a las filas
        const filas = document.querySelectorAll('tbody tr');
        filas.forEach((fila, index) => {
            fila.style.opacity = '0';
            fila.style.transform = 'translateY(20px)';
            
            setTimeout(() => {
                fila.style.transition = 'all 0.4s ease';
                fila.style.opacity = '1';
                fila.style.transform = 'translateY(0)';
            }, index * 100);
        });
    });
</script>
<style>
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
    .sidebar-content {
        position: relative;
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
    
    /* Dropdown arrow styling */
    .dropdown-arrow {
        font-size: 0.7rem;
        margin-left: 4px;
        transition: transform 0.2s ease;
        color: #007bff;
    }
    .nav-item.dropdown-active .dropdown-arrow {
        transform: rotate(180deg);
    }

    /* ================== RESPONSIVIDAD ================== */
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
            font-size: 1.5rem;
            margin-bottom: 1.5rem;
        }

        /* Formulario de filtros responsive */
        .form-filtro {
            flex-direction: column;
            gap: 1rem;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }

        .filter-group {
            margin-bottom: 1rem;
        }

        .filter-group input[type="date"] {
            width: 100%;
            padding: 0.75rem;
            font-size: 1rem;
        }

        .filter-actions {
            flex-direction: column;
            gap: 0.8rem;
        }

        .btn-filtrar,
        .btn-limpiar {
            width: 100%;
            padding: 0.8rem;
            font-size: 1rem;
        }

        /* Tabla responsive */
        .tabla-container {
            overflow-x: auto;
            margin: 0 -10px;
        }

        .tabla-container table {
            min-width: 600px;
            font-size: 0.9rem;
        }

        .tabla-container th,
        .tabla-container td {
            padding: 0.6rem 0.4rem;
        }

        /* Paginación responsive */
        .paginacion {
            flex-wrap: wrap;
            justify-content: center;
            gap: 0.5rem;
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

        .main-content h2 {
            font-size: 1.3rem;
            margin-bottom: 1rem;
        }

        .form-filtro {
            padding: 0.8rem;
            margin-bottom: 1rem;
        }

        .filter-group input[type="date"] {
            padding: 0.7rem;
        }

        .btn-filtrar,
        .btn-limpiar {
            padding: 0.7rem;
            font-size: 0.9rem;
        }

        /* Tabla muy responsive */
        .tabla-container {
            margin: 0 -5px;
        }

        .tabla-container table {
            min-width: 500px;
            font-size: 0.8rem;
        }

        .tabla-container th,
        .tabla-container td {
            padding: 0.5rem 0.3rem;
        }

        /* Ocultar columnas menos importantes en móviles muy pequeños */
        .estado-col {
            display: none;
        }

        /* Sidebar responsive */
        .sidebar {
            width: 260px;
            left: -260px;
        }

        .menu-toggle:checked ~ .sidebar {
            left: 0;
        }
    }
</style>
</body>
</html>

