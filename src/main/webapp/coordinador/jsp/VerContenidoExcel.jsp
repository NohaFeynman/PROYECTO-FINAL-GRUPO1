<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">

    <title>Contenido del archivo Excel</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root {
            --header-bg: linear-gradient(135deg, #a8d8ff 0%, #87ceeb 100%);
        }
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f8fafc;
            margin: 0;
            padding: 20px;
        }
        table { border-collapse: collapse; width: 100%; background: #f8fafc; }
        th, td { border: 1px solid #b3ccff; padding: 8px; text-align: left; }
        th { background: #b3ccff; }
        .error { color: #dc3545; font-weight: bold; margin: 20px 0; }
    </style>
</head>
<body>
    <h2>Contenido de: <c:out value="${nombreArchivo}" /></h2>
    <c:if test="${not empty mensajeError}">
        <div class="error">${mensajeError}</div>
    </c:if>
    <c:if test="${not empty filasExcel}">
        <table>
            <c:forEach var="fila" items="${filasExcel}">
                <tr>
                    <c:forEach var="celda" items="${fila}">
                        <td
                            <c:if test="${celda.rowspan > 1}">rowspan="${celda.rowspan}"</c:if>
                            <c:if test="${celda.colspan > 1}">colspan="${celda.colspan}"</c:if>
                        >${celda.valor}</td>
                    </c:forEach>
                </tr>
            </c:forEach>
        </table>
    </c:if>
</body>
</html>