package com.example.webproyecto.listeners;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.TimeZone;

@WebListener
public class TimezoneContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Configurar la zona horaria predeterminada de la aplicación a Perú
        TimeZone.setDefault(TimeZone.getTimeZone("America/Lima"));
        
        System.out.println("=== APLICACIÓN INICIADA ===");
        System.out.println("Zona horaria configurada: " + TimeZone.getDefault().getID());
        System.out.println("Hora actual del sistema: " + java.time.LocalDateTime.now());
        System.out.println("===========================");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Limpieza si es necesaria
    }
}
