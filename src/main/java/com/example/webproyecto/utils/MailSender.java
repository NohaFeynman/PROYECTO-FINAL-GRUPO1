package com.example.webproyecto.utils;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.security.cert.X509Certificate;
import java.util.Properties;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.security.SecureRandom;
import java.security.GeneralSecurityException;
import javax.net.ssl.HttpsURLConnection;

public class MailSender {
    public static void sendEmail(String toEmail, String subject, String body) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        
        final String username = "onu.mujeres.oficial@gmail.com";
        final String password = "bdds kkkm vydt lvrh";
        
        System.out.println("=== INTENTANDO ENVIAR EMAIL ==="); 
        System.out.println("Para: " + toEmail);
        System.out.println("Asunto: " + subject);
        System.out.println("De: " + username);
        
        // Configuración de la sesión de correo
        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            // DESACTIVAR VALIDACIÓN SSL (solo para pruebas)
            TrustManager[] trustAllCerts = new TrustManager[]{
                new X509TrustManager() {
                    public java.security.cert.X509Certificate[] getAcceptedIssuers() { return null; }
                    public void checkClientTrusted(X509Certificate[] certs, String authType) { }
                    public void checkServerTrusted(X509Certificate[] certs, String authType) { }
                }
            };
            SSLContext sc = SSLContext.getInstance("SSL");
            sc.init(null, trustAllCerts, new SecureRandom());
            HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

            System.out.println("🔄 Creando mensaje...");
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(body);
            
            System.out.println("📤 Enviando mensaje...");
            Transport.send(message);
            
            System.out.println("✅ EMAIL ENVIADO EXITOSAMENTE");
            System.out.println("===============================");
            
        } catch (MessagingException e) {
            System.err.println("❌ ERROR DE MENSAJERÍA: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error al enviar email: " + e.getMessage(), e);
        } catch (GeneralSecurityException e) {
            System.err.println("❌ ERROR DE SEGURIDAD: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error de seguridad SSL: " + e.getMessage(), e);
        }
    }
}
