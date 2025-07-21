package com.example.webproyecto.daos;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;


/**
 * BaseDao - Clase base para todos los DAOs que proporciona conexión a la base de datos
 * Diseñada para funcionar tanto en desarrollo local como en la nube (Railway, Heroku, etc.)
 * Prioriza variables de entorno para configuración en producción
 */
public abstract class BaseDao {
    
    // Configuración por defecto para desarrollo local
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/proyecto";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "root";
    private static final String DEFAULT_DRIVER = "com.mysql.cj.jdbc.Driver";
    
    // Variables de configuración
    private static String databaseUrl;
    private static String databaseUser;
    private static String databasePassword;
    private static String databaseDriver;
    private static boolean configurationLoaded = false;
    
    /**
     * Configuración estática que se carga una vez al inicializar la clase
     */
    static {
        loadDatabaseConfiguration();
        loadDriver();
    }
    
    /**
     * Carga la configuración de la base de datos desde variables de entorno
     * o usa valores por defecto para desarrollo local
     */
    private static void loadDatabaseConfiguration() {
        try {
            System.out.println("🔧 BaseDao: Cargando configuración de base de datos...");
            
            // Verificar si estamos en un entorno de nube (Railway, Heroku, etc.)
            String railwayUrl = System.getenv("DATABASE_URL");
            String herokuUrl = System.getenv("JAWSDB_URL");
            String mysqlUrl = System.getenv("MYSQL_URL");
            
            if (railwayUrl != null && !railwayUrl.isEmpty()) {
                // Configuración para Railway
                System.out.println("🚂 Detectado entorno Railway");
                parseDatabaseUrl(railwayUrl);
            } else if (herokuUrl != null && !herokuUrl.isEmpty()) {
                // Configuración para Heroku con JawsDB
                System.out.println("🌐 Detectado entorno Heroku con JawsDB");
                parseDatabaseUrl(herokuUrl);
            } else if (mysqlUrl != null && !mysqlUrl.isEmpty()) {
                // Configuración genérica MySQL
                System.out.println("🗄️ Detectado configuración MySQL genérica");
                parseDatabaseUrl(mysqlUrl);
            } else {
                // Variables de entorno individuales (preferido para producción)
                databaseUrl = System.getenv("DB_URL");
                databaseUser = System.getenv("DB_USER");
                databasePassword = System.getenv("DB_PASSWORD");
                databaseDriver = System.getenv("DB_DRIVER");
                
                if (databaseUrl != null && !databaseUrl.isEmpty()) {
                    System.out.println("⚙️ Usando variables de entorno individuales");
                } else {
                    // Configuración local por defecto
                    System.out.println("🏠 Usando configuración local por defecto");
                    databaseUrl = DEFAULT_URL;
                    databaseUser = DEFAULT_USER;
                    databasePassword = DEFAULT_PASSWORD;
                    databaseDriver = DEFAULT_DRIVER;
                }
            }
            
            // Si no se especificó driver, usar el por defecto
            if (databaseDriver == null || databaseDriver.isEmpty()) {
                databaseDriver = DEFAULT_DRIVER;
            }
            
            System.out.println("✅ Configuración cargada:");
            System.out.println("   URL: " + maskPassword(databaseUrl));
            System.out.println("   Usuario: " + databaseUser);
            System.out.println("   Driver: " + databaseDriver);
            
            configurationLoaded = true;
            
        } catch (Exception e) {
            System.err.println("❌ Error cargando configuración de base de datos: " + e.getMessage());
            // Usar configuración por defecto en caso de error
            databaseUrl = DEFAULT_URL;
            databaseUser = DEFAULT_USER;
            databasePassword = DEFAULT_PASSWORD;
            databaseDriver = DEFAULT_DRIVER;
            configurationLoaded = true;
        }
    }
    
    /**
     * Parsea una URL de base de datos completa (como las que proporcionan Railway/Heroku)
     * Formato esperado: mysql://usuario:password@host:puerto/database
     */
    private static void parseDatabaseUrl(String fullUrl) {
        try {
            // Remover el prefijo mysql:// si existe
            String cleanUrl = fullUrl;
            if (cleanUrl.startsWith("mysql://")) {
                cleanUrl = cleanUrl.substring(8); // Remover "mysql://"
            }
            
            // Dividir en credenciales@host/database
            String[] parts = cleanUrl.split("@");
            if (parts.length != 2) {
                throw new IllegalArgumentException("Formato de URL inválido");
            }
            
            // Extraer credenciales
            String credentials = parts[0];
            String[] credParts = credentials.split(":");
            if (credParts.length != 2) {
                throw new IllegalArgumentException("Credenciales inválidas en URL");
            }
            
            databaseUser = credParts[0];
            databasePassword = credParts[1];
            
            // Extraer host, puerto y database
            String hostAndDb = parts[1];
            String[] hostParts = hostAndDb.split("/");
            if (hostParts.length != 2) {
                throw new IllegalArgumentException("Host/database inválido en URL");
            }
            
            String hostPort = hostParts[0];
            String database = hostParts[1];
            
            // Construir URL JDBC
            databaseUrl = "jdbc:mysql://" + hostPort + "/" + database;
            
        } catch (Exception e) {
            System.err.println("❌ Error parseando URL de base de datos: " + e.getMessage());
            throw new RuntimeException("No se pudo parsear la URL de base de datos", e);
        }
    }
    
    /**
     * Carga el driver de base de datos
     */
    private static void loadDriver() {
        try {
            Class.forName(databaseDriver);
            System.out.println("✅ Driver MySQL cargado correctamente: " + databaseDriver);
        } catch (ClassNotFoundException e) {
            System.err.println("❌ Driver MySQL no encontrado: " + databaseDriver);
            throw new RuntimeException("Driver MySQL no encontrado", e);
        }
    }
    
    /**
     * Obtiene una conexión a la base de datos
     * @return Connection objeto de conexión a la base de datos
     * @throws SQLException si hay error en la conexión
     */
    protected Connection getConnection() throws SQLException {
        if (!configurationLoaded) {
            loadDatabaseConfiguration();
        }
        
        try {
            System.out.println("🔗 BaseDao: Estableciendo conexión a la base de datos...");
            
            // Configurar propiedades de conexión para mejor rendimiento y compatibilidad
            Properties props = new Properties();
            props.setProperty("user", databaseUser);
            props.setProperty("password", databasePassword);
            props.setProperty("useSSL", "true");
            props.setProperty("verifyServerCertificate", "false");
            props.setProperty("allowPublicKeyRetrieval", "true");
            props.setProperty("useUnicode", "true");
            props.setProperty("characterEncoding", "UTF-8");
            props.setProperty("serverTimezone", "UTC");
            props.setProperty("rewriteBatchedStatements", "true");
            props.setProperty("cachePrepStmts", "true");
            props.setProperty("prepStmtCacheSize", "250");
            props.setProperty("prepStmtCacheSqlLimit", "2048");
            
            Connection conn = DriverManager.getConnection(databaseUrl, props);
            
            // Verificar que la conexión esté activa
            if (conn != null && !conn.isClosed()) {
                System.out.println("✅ Conexión exitosa a la base de datos");
                return conn;
            } else {
                throw new SQLException("La conexión está cerrada");
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al conectar a la base de datos:");
            System.err.println("   URL: " + maskPassword(databaseUrl));
            System.err.println("   Usuario: " + databaseUser);
            System.err.println("   Mensaje: " + e.getMessage());
            System.err.println("   Código: " + e.getErrorCode());
            System.err.println("   SQLState: " + e.getSQLState());
            throw e;
        }
    }
    
    /**
     * Cierra una conexión de forma segura
     * @param connection la conexión a cerrar
     */
    protected void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                if (!connection.isClosed()) {
                    connection.close();
                    System.out.println("🔒 Conexión cerrada correctamente");
                }
            } catch (SQLException e) {
                System.err.println("⚠️ Error al cerrar la conexión: " + e.getMessage());
            }
        }
    }
    
    /**
     * Método utilitario para probar la conexión
     * @return true si la conexión es exitosa, false en caso contrario
     */
    public static boolean testConnection() {
        BaseDao testDao = new BaseDao() {}; // Instancia anónima para testing
        
        try (Connection conn = testDao.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("🧪 Test de conexión exitoso");
                return true;
            } else {
                System.err.println("🧪 Test de conexión fallido: conexión nula o cerrada");
                return false;
            }
        } catch (SQLException e) {
            System.err.println("🧪 Test de conexión fallido: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Obtiene información sobre la configuración actual (para debugging)
     * @return String con información de configuración (passwords enmascarados)
     */
    public static String getConfigurationInfo() {
        return String.format(
            "BaseDao Configuration:\n" +
            "  URL: %s\n" +
            "  User: %s\n" +
            "  Driver: %s\n" +
            "  Configuration Loaded: %s",
            maskPassword(databaseUrl),
            databaseUser,
            databaseDriver,
            configurationLoaded
        );
    }
    
    /**
     * Enmascara passwords en URLs para logging seguro
     * @param url la URL que puede contener password
     * @return URL con password enmascarado
     */
    private static String maskPassword(String url) {
        if (url == null) return "null";
        
        // Enmascarar passwords en URLs del tipo: mysql://user:password@host/db
        return url.replaceAll("://([^:]+):([^@]+)@", "://$1:****@");
    }
    
    /**
     * Recarga la configuración (útil para cambios en runtime)
     */
    public static void reloadConfiguration() {
        System.out.println("🔄 Recargando configuración de BaseDao...");
        configurationLoaded = false;
        loadDatabaseConfiguration();
        loadDriver();
    }
}
