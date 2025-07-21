    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
    <%
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies
    %>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

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

        .main-content {
            padding: 20px;
        }

        h2, h4 {
            color: #1e2e4a;
        }

        .table th {
            background-color: #f5f5f5;
        }

        .btn-sm {
            font-size: 0.8rem;
        }


    </style>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
        <meta http-equiv="Pragma" content="no-cache">
        <meta http-equiv="Expires" content="0">
        <title>Gestión de Formularios</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <style>
            .custom-file-input::-webkit-file-upload-button {
                visibility: hidden;
            }
            .custom-file-input::before {
                content: 'Seleccionar archivo';
                display: inline-block;
                background: linear-gradient(to bottom, #f9f9f9, #e3e3e3);
                border: 1px solid #999;
                border-radius: 3px;
                padding: 5px 8px;
                outline: none;
                white-space: nowrap;
                cursor: pointer;
                text-shadow: 1px 1px #fff;
                font-weight: 700;
                font-size: 10pt;
            }
            .custom-file-input:hover::before {
                border-color: black;
            }
            .custom-file-input:active::before {
                background: -webkit-linear-gradient(top, #e3e3e3, #f9f9f9);
            }
            .badge {
                font-size: 0.9em;
                padding: 0.5em 0.8em;
            }
            .btn-group {
                gap: 0.5rem;
            }
            .table td {
                vertical-align: middle;
            }
            .alert-info {
                background-color: #f8f9fa;
                border-left: 4px solid #17a2b8;
            }
            .alert-info ol {
                margin-bottom: 0;
                padding-left: 1.2rem;
            }
        </style>
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
                <li><a href="${pageContext.request.contextPath}/GestionarFormulariosServlet"><i class="fa-solid fa-file-alt"></i> Gestionar Formularios</a></li>
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
    <main class="main-content">
        <div class="container mt-4">
            <div class="card shadow-lg border-0 rounded-lg">
                <div class="card-header bg-primary text-white">
                    <h3 class="mb-0"><i class="fas fa-upload me-2"></i>Subida Masiva de Respuestas</h3>
                </div>
                <div class="card-body">
                    <!-- Mensajes de estado -->
                    <c:if test="${not empty requestScope.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>
                            <strong>Error:</strong> ${requestScope.error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty requestScope.exito}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle me-2"></i>
                            <strong>¡Éxito!</strong> El archivo se ha procesado correctamente.
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <!-- Instrucciones -->
                    <div class="alert alert-info mb-4">
                        <h5 class="alert-heading"><i class="fas fa-info-circle me-2"></i>Instrucciones</h5>
                        <ol class="mb-0">
                            <li>Descargue la plantilla Excel</li>
                            <li>Complete las respuestas siguiendo el formato</li>
                            <li>Guarde el archivo y súbalo mediante el formulario</li>
                        </ol>
                    </div>

                    <!-- Descargar plantilla -->
                    <div class="mb-4">
                        <h5><i class="fas fa-file-download me-2"></i>1. Descargar Plantilla</h5>
                        <a href="DescargarPlantillaServlet?idFormulario=${idFormulario}"
                           class="btn btn-outline-primary">
                            <i class="fas fa-download me-2"></i>Descargar plantilla Excel
                        </a>
                    </div>

                    <!-- Formulario de carga -->
                    <div class="mb-4">
                        <h5><i class="fas fa-file-upload me-2"></i>2. Subir Archivo Completado</h5>
                        <form id="uploadForm" action="SubirRespuestasMasivasServlet" method="post"
                              enctype="multipart/form-data" class="needs-validation" novalidate>
                            <input type="hidden" name="idFormulario" value="${idFormulario}" />
                            <div class="mb-3">
                                <div class="custom-file">
                                    <input type="file" class="form-control" name="archivoExcel"
                                           id="archivoExcel" accept=".xlsx" required>
                                    <div class="invalid-feedback">
                                        Por favor, seleccione un archivo Excel (.xlsx)
                                    </div>
                                </div>
                            </div>
                            <div id="fileInfo" class="mb-3 d-none">
                                <div class="alert alert-secondary">
                                    <i class="fas fa-file-excel me-2"></i>
                                    <span id="fileName"></span>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-success" id="btnSubmit" disabled>
                                <i class="fas fa-upload me-2"></i>Subir archivo
                            </button>
                        </form>
                    </div>

                <!-- Historial -->
                <div class="mb-4">
                    <h5><i class="fas fa-history me-2"></i>3. Historial de Archivos</h5>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped">
                            <thead class="table-primary">
                                <tr>
                                    <th><i class="fas fa-file me-2"></i>Nombre del archivo</th>
                                    <th><i class="fas fa-calendar me-2"></i>Fecha de carga</th>
                                    <th><i class="fas fa-check-circle me-2"></i>Estado</th>
                                    <th><i class="fas fa-cogs me-2"></i>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                            <c:choose>
                                <c:when test="${not empty archivos}">
                                    <c:forEach var="archivo" items="${archivos}">
                                        <tr>
                                            <td>
                                                <i class="fas fa-file-excel text-success me-2"></i>
                                                ${archivo.nombreArchivoOriginal}
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${archivo.fechaCargaDate}" pattern="dd/MM/yyyy HH:mm:ss"/>

                                            </td>
                                            <td>
                                                <span class="badge bg-${archivo.estadoProcesamiento eq 'EXITOSO' ? 'success' :
                                                                        archivo.estadoProcesamiento eq 'ERROR' ? 'danger' : 'warning'}">
                                                    ${archivo.estadoProcesamiento}
                                                </span>
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <a href="DescargarArchivoServlet?idArchivo=${archivo.idArchivoCargado}"
                                                       class="btn btn-sm btn-outline-primary"
                                                       title="Descargar archivo">
                                                        <i class="fas fa-download"></i>
                                                    </a>
                                                    <c:if test="${archivo.estadoProcesamiento eq 'ERROR'}">
                                                        <button type="button"
                                                                class="btn btn-sm btn-outline-danger"
                                                                title="Ver detalles del error"
                                                                onclick="mostrarError('${archivo.mensajeProcesamiento}')">
                                                            <i class="fas fa-exclamation-circle"></i>
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4" class="text-center text-muted">
                                            <i class="fas fa-info-circle me-2"></i>
                                            No se han cargado archivos aún
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Paginación -->
                <nav>
                    <ul class="pagination justify-content-center">
                        <c:forEach var="i" begin="1" end="${totalPaginas}">
                            <li class="page-item ${i == paginaActual ? 'active' : ''}">
                                <a class="page-link" href="IrASubirRespuestasMasivasServlet?idFormulario=${idFormulario}&pagina=${i}">
                                        ${i}
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                </nav>
            </div>
        </div>
    </main>


        <script>
            // Validación del archivo
            document.getElementById('archivoExcel').addEventListener('change', function(e) {
                const file = e.target.files[0];
                const fileInfo = document.getElementById('fileInfo');
                const fileName = document.getElementById('fileName');
                const btnSubmit = document.getElementById('btnSubmit');

                if (file) {
                    const extension = file.name.split('.').pop().toLowerCase();
                    if (extension == 'xlsx') {
                        fileInfo.classList.remove('d-none');
                        fileName.textContent = file.name;
                        btnSubmit.disabled = false;

                        // Mostrar tamaño del archivo
                        const size = (file.size / 1024 / 1024).toFixed(2);
                        fileName.textContent = `${file.name} (${size} MB)`;
                    } else {
                        mostrarError('Por favor, seleccione un archivo Excel (.xlsx)');
                        this.value = '';
                        fileInfo.classList.add('d-none');
                        btnSubmit.disabled = true;
                    }
                } else {
                    fileInfo.classList.add('d-none');
                    btnSubmit.disabled = true;
                }
            });

            // Confirmación antes de subir
            document.getElementById('uploadForm').addEventListener('submit', function(e) {
                e.preventDefault(); // Siempre prevenir primero
                const modal = new bootstrap.Modal(document.getElementById('confirmModal'));
                modal.show();
            });


            // Función para mostrar errores
            function mostrarError(mensaje) {
                const alertDiv = document.createElement('div');
                alertDiv.className = 'alert alert-danger alert-dismissible fade show mt-3';
                alertDiv.innerHTML = `
                    <i class="fas fa-exclamation-circle me-2"></i>
                    <strong>Error:</strong> ${mensaje}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                `;
                document.getElementById('uploadForm').insertAdjacentElement('beforebegin', alertDiv);

                // Auto-cerrar después de 5 segundos
                setTimeout(() => {
                    alertDiv.remove();
                }, 5000);
            }

            // Mostrar toast de éxito
            <c:if test="${not empty requestScope.exito}">
                <script>
                    mostrarToast('Archivo subido exitosamente', 'success');
                </script>
            </c:if>
            <c:if test="${not empty requestScope.error}">
                <script>
                    mostrarToast('Error al subir el archivo: ${error}', 'danger');
                </script>
            </c:if>



        </script>
    <!-- Modal personalizado -->
    <div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="confirmModalLabel">Confirmación</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    ¿Está seguro de que desea subir este archivo?
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-primary" id="btnConfirmarSubida">Subir archivo</button>
                </div>
            </div>
        </div>
    </div>
    <script>
        document.getElementById('btnConfirmarSubida').addEventListener('click', function () {
            const form = document.getElementById('uploadForm');
            // Ahora sí enviamos el formulario
            form.submit();
        });
    </script>

    </body>
    </html>
