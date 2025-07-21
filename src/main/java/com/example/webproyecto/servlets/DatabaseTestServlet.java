package com.example.webproyecto.servlets;

import com.example.webproyecto.daos.BaseDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Servlet para probar la conexión a la base de datos
 * Útil para debugging en desarrollo y producción
 * 
 * Acceso: /test-database
 */
@WebServlet(name = "DatabaseTestServlet", urlPatterns = {"/test-database"})
public class DatabaseTestServlet extends HttpServlet {

    /**
     * Clase auxiliar para acceder a los métodos protected de BaseDao
     */
    private static class TestDao extends BaseDao {
        public Connection getTestConnection() throws SQLException {
            return super.getConnection();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Prueba de Conexión - Base de Datos</title>");
            out.println("<style>");
            out.println("body { font-family: Arial, sans-serif; margin: 40px; }");
            out.println(".success { color: #28a745; background: #d4edda; padding: 15px; border-radius: 5px; margin: 10px 0; }");
            out.println(".error { color: #dc3545; background: #f8d7da; padding: 15px; border-radius: 5px; margin: 10px 0; }");
            out.println(".info { color: #0c5460; background: #d1ecf1; padding: 15px; border-radius: 5px; margin: 10px 0; }");
            out.println("pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }");
            out.println("</style>");
            out.println("</head>");
            out.println("<body>");
            
            out.println("<h1>🔧 Prueba de Conexión a Base de Datos</h1>");
            out.println("<p><em>Servlet para verificar la configuración de la base de datos</em></p>");
            
            // Mostrar información de configuración
            out.println("<h2>📋 Configuración Actual</h2>");
            out.println("<div class='info'>");
            out.println("<pre>" + BaseDao.getConfigurationInfo() + "</pre>");
            out.println("</div>");
            
            // Mostrar variables de entorno relevantes (sin passwords)
            out.println("<h2>🌍 Variables de Entorno</h2>");
            out.println("<div class='info'>");
            out.println("<pre>");
            out.println("DATABASE_URL: " + maskValue(System.getenv("DATABASE_URL")));
            out.println("JAWSDB_URL: " + maskValue(System.getenv("JAWSDB_URL")));
            out.println("MYSQL_URL: " + maskValue(System.getenv("MYSQL_URL")));
            out.println("DB_URL: " + maskValue(System.getenv("DB_URL")));
            out.println("DB_USER: " + System.getenv("DB_USER"));
            out.println("DB_DRIVER: " + System.getenv("DB_DRIVER"));
            out.println("</pre>");
            out.println("</div>");
            
            // Probar conexión
            out.println("<h2>🔌 Prueba de Conexión</h2>");
            
            try {
                boolean connectionSuccess = BaseDao.testConnection();
                
                if (connectionSuccess) {
                    out.println("<div class='success'>");
                    out.println("✅ <strong>Conexión exitosa!</strong><br>");
                    out.println("La aplicación puede conectarse correctamente a la base de datos.");
                    out.println("</div>");
                    
                    // Información adicional de la conexión
                    TestDao testDao = new TestDao(); // Instancia de clase auxiliar
                    try (Connection conn = testDao.getTestConnection()) {
                        out.println("<div class='info'>");
                        out.println("<strong>Detalles de la conexión:</strong><br>");
                        out.println("URL: " + maskPassword(conn.getMetaData().getURL()) + "<br>");
                        out.println("Driver: " + conn.getMetaData().getDriverName() + "<br>");
                        out.println("Versión del Driver: " + conn.getMetaData().getDriverVersion() + "<br>");
                        out.println("Base de datos: " + conn.getMetaData().getDatabaseProductName() + "<br>");
                        out.println("Versión de la BD: " + conn.getMetaData().getDatabaseProductVersion() + "<br>");
                        out.println("Usuario: " + conn.getMetaData().getUserName() + "<br>");
                        out.println("</div>");
                    }
                    
                } else {
                    out.println("<div class='error'>");
                    out.println("❌ <strong>Error de conexión!</strong><br>");
                    out.println("No se pudo establecer conexión con la base de datos.");
                    out.println("</div>");
                }
                
            } catch (Exception e) {
                out.println("<div class='error'>");
                out.println("❌ <strong>Error durante la prueba:</strong><br>");
                out.println("Mensaje: " + e.getMessage() + "<br>");
                out.println("Tipo: " + e.getClass().getSimpleName());
                out.println("</div>");
                
                out.println("<h3>🔍 Stack Trace</h3>");
                out.println("<pre>");
                e.printStackTrace(out);
                out.println("</pre>");
            }
            
            // Instrucciones para configuración en la nube
            out.println("<h2>☁️ Configuración para la Nube</h2>");
            out.println("<div class='info'>");
            out.println("<strong>Para Railway:</strong><br>");
            out.println("1. Agrega el plugin MySQL a tu proyecto<br>");
            out.println("2. Railway automáticamente establecerá DATABASE_URL<br>");
            out.println("3. No necesitas configuración adicional<br><br>");
            
            out.println("<strong>Para Heroku con JawsDB:</strong><br>");
            out.println("1. Instala el addon: heroku addons:create jawsdb:kitefin<br>");
            out.println("2. Heroku establecerá JAWSDB_URL automáticamente<br><br>");
            
            out.println("<strong>Para configuración manual:</strong><br>");
            out.println("Establece estas variables de entorno:<br>");
            out.println("• DB_URL=jdbc:mysql://host:puerto/database<br>");
            out.println("• DB_USER=tu_usuario<br>");
            out.println("• DB_PASSWORD=tu_password<br>");
            out.println("• DB_DRIVER=com.mysql.cj.jdbc.Driver (opcional)<br>");
            out.println("</div>");
            
            out.println("<h2>🔄 Acciones</h2>");
            out.println("<button onclick='location.reload()'>🔄 Refrescar Prueba</button>");
            out.println("<button onclick='reloadConfig()'>⚙️ Recargar Configuración</button>");
            
            out.println("<script>");
            out.println("function reloadConfig() {");
            out.println("  fetch('/test-database?action=reload', {method: 'POST'})");
            out.println("    .then(() => location.reload())");
            out.println("    .catch(err => alert('Error: ' + err));");
            out.println("}");
            out.println("</script>");
            
            out.println("</body>");
            out.println("</html>");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("reload".equals(action)) {
            // Recargar configuración de BaseDao
            BaseDao.reloadConfiguration();
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Configuration reloaded");
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid action");
        }
    }
    
    /**
     * Enmascara valores sensibles para mostrar en logs
     */
    private String maskValue(String value) {
        if (value == null || value.isEmpty()) {
            return "(no configurado)";
        }
        if (value.length() <= 6) {
            return "****";
        }
        return value.substring(0, 3) + "****" + value.substring(value.length() - 3);
    }
    
    /**
     * Enmascara passwords en URLs
     */
    private String maskPassword(String url) {
        if (url == null) return "null";
        return url.replaceAll("://([^:]+):([^@]+)@", "://$1:****@");
    }
}
