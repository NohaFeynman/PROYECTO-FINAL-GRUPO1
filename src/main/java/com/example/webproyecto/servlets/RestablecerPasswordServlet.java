package com.example.webproyecto.servlets;

import com.example.webproyecto.daos.CodigoDao;
import com.example.webproyecto.beans.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.Collection;

@WebServlet("/restablecerPassword")
@MultipartConfig
public class RestablecerPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("🔐 RestablecerPasswordServlet - Iniciando proceso");
        
        // Debug: Información de la petición
        System.out.println("� Información de la petición:");
        System.out.println("   - Content Type: " + request.getContentType());
        System.out.println("   - Method: " + request.getMethod());
        System.out.println("   - Content Length: " + request.getContentLength());
        System.out.println("   - Character Encoding: " + request.getCharacterEncoding());
        
        String correo = null;
        String codigo = null;
        String password = null;
        String confirmPassword = null;
        
        // Verificar el tipo de contenido
        String contentType = request.getContentType();
        if (contentType != null && contentType.startsWith("multipart/form-data")) {
            System.out.println("📋 Procesando datos multipart/form-data");
            
            // Procesar datos multipart
            try {
                Collection<Part> parts = request.getParts();
                System.out.println("📦 Total de parts encontradas: " + parts.size());
                
                for (Part part : parts) {
                    String fieldName = part.getName();
                    String fieldValue = extractValue(part);
                    
                    System.out.println("   - Part: " + fieldName + " = " + fieldValue);
                    
                    switch (fieldName) {
                        case "correo":
                            correo = fieldValue;
                            break;
                        case "codigo":
                            codigo = fieldValue;
                            break;
                        case "password":
                            password = fieldValue;
                            break;
                        case "confirmPassword":
                            confirmPassword = fieldValue;
                            break;
                    }
                }
            } catch (Exception e) {
                System.err.println("❌ Error procesando multipart: " + e.getMessage());
                e.printStackTrace();
            }
        } else {
            System.out.println("📋 Procesando datos application/x-www-form-urlencoded");
            
            // Procesar datos normales
            correo = request.getParameter("correo");
            codigo = request.getParameter("codigo");
            password = request.getParameter("password");
            confirmPassword = request.getParameter("confirmPassword");
            
            // Debug: Imprimir todos los parámetros recibidos
            System.out.println("� Todos los parámetros de la petición:");
            request.getParameterMap().forEach((key, values) -> {
                System.out.println("   - " + key + ": " + String.join(", ", values));
            });
        }
        
        System.out.println("📥 Parámetros procesados:");
        System.out.println("   - Correo: " + correo);
        System.out.println("   - Código: " + codigo);
        System.out.println("   - Password length: " + (password != null ? password.length() : "null"));
        System.out.println("   - Confirm password length: " + (confirmPassword != null ? confirmPassword.length() : "null"));
        
        // Validaciones básicas
        if (correo == null || correo.trim().isEmpty()) {
            System.out.println("❌ Correo vacío");
            request.setAttribute("error", "Correo no válido");
            request.setAttribute("correoUsuario", correo);
            request.getRequestDispatcher("restablecerPassword.jsp").forward(request, response);
            return;
        }
        
        if (codigo == null || codigo.trim().isEmpty() || codigo.length() != 6) {
            System.out.println("❌ Código inválido: " + codigo);
            request.setAttribute("error", "Código de verificación inválido");
            request.setAttribute("correoUsuario", correo);
            request.getRequestDispatcher("restablecerPassword.jsp").forward(request, response);
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            System.out.println("❌ Contraseña vacía");
            request.setAttribute("error", "La contraseña es requerida");
            request.setAttribute("correoUsuario", correo);
            request.getRequestDispatcher("restablecerPassword.jsp").forward(request, response);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            System.out.println("❌ Contraseñas no coinciden");
            request.setAttribute("error", "Las contraseñas no coinciden");
            request.setAttribute("correoUsuario", correo);
            request.getRequestDispatcher("restablecerPassword.jsp").forward(request, response);
            return;
        }
        
        // Validar fortaleza de contraseña
        if (!isValidPassword(password)) {
            System.out.println("❌ Contraseña no cumple requisitos");
            request.setAttribute("error", "La contraseña debe tener al menos 8 caracteres, incluyendo mayúsculas, minúsculas, números y caracteres especiales");
            request.setAttribute("correoUsuario", correo);
            request.getRequestDispatcher("restablecerPassword.jsp").forward(request, response);
            return;
        }
        
        correo = correo.trim().toLowerCase();
        codigo = codigo.trim().toUpperCase();
        
        System.out.println("🔐 Procesando restablecimiento para: " + correo + " con código: " + codigo);
        
        CodigoDao codigoDao = new CodigoDao();
        
        try {
            // Verificar que el usuario existe
            Usuario usuario = codigoDao.getUsuarioByCorreo(correo);
            if (usuario == null) {
                System.out.println("❌ Usuario no encontrado: " + correo);
                request.setAttribute("error", "Usuario no encontrado");
                request.setAttribute("correoUsuario", correo);
                request.getRequestDispatcher("restablecerPassword.jsp").forward(request, response);
                return;
            }
            
            // Verificar código usando el método específico para recuperación de contraseña
            boolean codigoValido = codigoDao.verificarCodigoRecuperacion(correo, codigo);
            if (!codigoValido) {
                System.out.println("❌ Código inválido o expirado: " + codigo);
                request.setAttribute("error", "Código de verificación inválido o expirado");
                request.setAttribute("correoUsuario", correo);
                request.getRequestDispatcher("restablecerPassword.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ Código válido, procediendo a actualizar contraseña");
            
            // Usar directamente el ID del usuario obtenido por correo (más confiable)
            System.out.println("✅ Usando usuario ID: " + usuario.getIdUsuario());
            
            // Actualizar contraseña
            codigoDao.actualizarContrasena(usuario.getIdUsuario(), password);
            System.out.println("✅ Contraseña actualizada para usuario ID: " + usuario.getIdUsuario());
            
            // Eliminar código usado específicamente de recuperación
            codigoDao.eliminarCodigoRecuperacion(correo);
            System.out.println("✅ Código de recuperación eliminado tras uso exitoso");
            
            // Verificar si es una petición AJAX
            String requestedWith = request.getHeader("X-Requested-With");
            String accept = request.getHeader("Accept");
            
            if ("XMLHttpRequest".equals(requestedWith) || 
                (accept != null && accept.contains("application/json"))) {
                // Respuesta JSON para AJAX con redirección
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": true, \"message\": \"Contraseña restablecida exitosamente\", \"redirect\": \"passwordActualizada.jsp\"}");
            } else {
                // Redirección directa a la página de confirmación
                System.out.println("🔄 Redirigiendo a página de confirmación");
                response.sendRedirect("passwordActualizada.jsp");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error en RestablecerPasswordServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error interno del sistema. Inténtalo más tarde.");
            request.setAttribute("correoUsuario", correo);
            request.getRequestDispatcher("restablecerPassword.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String correo = request.getParameter("correo");
        if (correo != null && !correo.trim().isEmpty()) {
            request.setAttribute("correoUsuario", correo);
            request.getRequestDispatcher("restablecerPassword.jsp").forward(request, response);
        } else {
            response.sendRedirect("recuperarPassword.jsp");
        }
    }
    
    /**
     * Valida que la contraseña cumpla con los requisitos de seguridad
     */
    private boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasUpper = false;
        boolean hasLower = false;
        boolean hasDigit = false;
        boolean hasSpecial = false;
        
        String specialChars = "@$!%*?&";
        
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) {
                hasUpper = true;
            } else if (Character.isLowerCase(c)) {
                hasLower = true;
            } else if (Character.isDigit(c)) {
                hasDigit = true;
            } else if (specialChars.indexOf(c) >= 0) {
                hasSpecial = true;
            }
        }
        
        return hasUpper && hasLower && hasDigit && hasSpecial;
    }
    
    /**
     * Método helper para extraer el valor de un Part multipart
     */
    private String extractValue(Part part) throws IOException {
        if (part == null) {
            return null;
        }
        
        try (java.io.InputStream inputStream = part.getInputStream();
             java.util.Scanner scanner = new java.util.Scanner(inputStream, "UTF-8")) {
            
            return scanner.useDelimiter("\\A").hasNext() ? scanner.next().trim() : "";
        }
    }
}
