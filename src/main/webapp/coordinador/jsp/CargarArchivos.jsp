<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Subida Masiva de Respuestas</title>
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
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        .container {
            background-color: white;
            max-width: 800px;
            margin: auto;
            padding: 30px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 12px;
        }
        h1 {
            text-align: center;
            color: #333;
        }
        .btn {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            font-size: 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .btn-descargar {
            background-color: #3498db;
            color: white;
            text-decoration: none;
        }
        .btn-subir {
            background-color: #2ecc71;
            color: white;
        }
        .archivo-input {
            margin-top: 20px;
            font-size: 15px;
        }
        .botones {
            text-align: center;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Subida Masiva de Respuestas</h1>

    <p>Descarga la plantilla de Excel y complétala con las respuestas. Luego súbela usando el formulario.</p>

    <div class="botones">
        <a href="plantillas/plantilla_subida.xlsx" class="btn btn-descargar" download>📥 Descargar plantilla</a>
    </div>

    <form action="SubidaMasivaServlet" method="post" enctype="multipart/form-data" class="botones">
        <input type="file" name="archivoExcel" accept=".xlsx" required class="archivo-input"><br>
        <button type="submit" class="btn btn-subir">📤 Subir archivo</button>
    </form>
</div>
</body>
</html>
