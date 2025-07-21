package com.example.webproyecto.utils;

/**
 * Clase utilitaria para envío de emails.
 * Por ahora es una implementación simplificada que simula el envío.
 * En producción se debería integrar con un servicio real de email como JavaMail, SendGrid, etc.
 */
public class EmailSender {
    
    /**
     * Simula el envío de un email.
     * @param destinatario El correo del destinatario
     * @param asunto El asunto del email
     * @param mensaje El contenido del mensaje
     * @return true si el envío fue exitoso, false en caso contrario
     */
    public static boolean enviarEmail(String destinatario, String asunto, String mensaje) {
        System.out.println("📧 ========================================");
        System.out.println("📧 SIMULANDO ENVÍO DE EMAIL:");
        System.out.println("📧 Para: " + destinatario);
        System.out.println("📧 Asunto: " + asunto);
        System.out.println("📧 Mensaje:");
        System.out.println("📧 " + mensaje);
        System.out.println("📧 ========================================");
        System.out.println("📧 EMAIL ENVIADO EXITOSAMENTE (SIMULADO)");
        
        // Extraer el código del mensaje para mostrarlo más claramente
        if (mensaje.contains("código de verificación es:")) {
            String[] partes = mensaje.split("código de verificación es: ");
            if (partes.length > 1) {
                String codigoParte = partes[1].split("\n")[0].trim();
                System.out.println("🎯 CÓDIGO EXTRAÍDO: " + codigoParte);
            }
        }
        
        // Por ahora siempre devolvemos true (envío exitoso)
        // En una implementación real, aquí iría el código para enviar el email
        return true;
    }
    
    /**
     * Método sobrecargado para envío con formato HTML
     */
    public static boolean enviarEmailHTML(String destinatario, String asunto, String mensajeHTML) {
        System.out.println("📧 SIMULANDO ENVÍO DE EMAIL HTML:");
        System.out.println("   Para: " + destinatario);
        System.out.println("   Asunto: " + asunto);
        System.out.println("   Mensaje HTML: " + mensajeHTML);
        System.out.println("📧 EMAIL HTML ENVIADO EXITOSAMENTE (SIMULADO)");
        
        return true;
    }
}
