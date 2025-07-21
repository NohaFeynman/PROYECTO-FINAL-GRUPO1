package com.example.webproyecto.servlets.administrador;

import com.example.webproyecto.beans.Usuario;
import com.example.webproyecto.daos.CodigoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "VerificarCoordinadorServlet", urlPatterns = {"/verificarCoordinador"})
public class VerificarCoordinadorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String correo = request.getParameter("correo");
        
        if (correo != null && !correo.trim().isEmpty()) {
            // Verificar que el usuario existe y es un coordinador
            CodigoDao codigoDao = new CodigoDao();
            Usuario usuario = codigoDao.getUsuarioByCorreo(correo);
            
            if (usuario != null) {
                // Configurar atributos para JSP
                request.setAttribute("correoUsuario", correo);
                request.setAttribute("iniciarTimer", true);
                request.setAttribute("esCoordinador", true);
                request.getRequestDispatcher("establecerContrasenaCoordinador.jsp").forward(request, response);
            } else {
                // Usuario no encontrado, redirigir con error
                response.sendRedirect("login.jsp?error=usuario_no_encontrado");
            }
        } else {
            // Sin correo, redirigir al login
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String correo = request.getParameter("correo");
        String codigo = request.getParameter("codigo");
        String contrasenha = request.getParameter("password");
        String confirmarContrasenha = request.getParameter("confirmPassword");

        // Validaciones básicas
        if (correo == null || correo.trim().isEmpty() || 
            codigo == null || codigo.trim().isEmpty() || 
            contrasenha == null || contrasenha.trim().isEmpty() || 
            confirmarContrasenha == null || confirmarContrasenha.trim().isEmpty()) {
            
            request.setAttribute("error", "Todos los campos son requeridos");
            request.setAttribute("correoUsuario", correo);
            request.setAttribute("iniciarTimer", true);
            request.setAttribute("esCoordinador", true);
            request.getRequestDispatcher("establecerContrasenaCoordinador.jsp").forward(request, response);
            return;
        }

        if (!contrasenha.equals(confirmarContrasenha)) {
            request.setAttribute("error", "Las contraseñas no coinciden");
            request.setAttribute("correoUsuario", correo);
            request.setAttribute("iniciarTimer", true);
            request.setAttribute("esCoordinador", true);
            request.getRequestDispatcher("establecerContrasenaCoordinador.jsp").forward(request, response);
            return;
        }

        // Validar fortaleza de contraseña (misma lógica que el registro)
        if (!isValidPassword(contrasenha)) {
            request.setAttribute("error", "La contraseña debe tener al menos 8 caracteres, incluyendo mayúsculas, minúsculas, números y caracteres especiales");
            request.setAttribute("correoUsuario", correo);
            request.setAttribute("iniciarTimer", true);
            request.setAttribute("esCoordinador", true);
            request.getRequestDispatcher("establecerContrasenaCoordinador.jsp").forward(request, response);
            return;
        }

        CodigoDao codigoDao = new CodigoDao();
        
        try {
            // Verificar el código usando los métodos existentes
            if (codigoDao.verificarCodigo(correo, codigo)) {
                // 1. Obtener usuario y actualizar contraseña
                Usuario usuario = codigoDao.getUsuarioByCorreo(correo);
                if (usuario != null) {
                    System.out.println("✅ Coordinador encontrado: " + usuario.getIdUsuario());
                    
                    codigoDao.actualizarContrasena(usuario.getIdUsuario(), contrasenha);
                    System.out.println("✅ Contraseña actualizada para coordinador: " + usuario.getIdUsuario());
                    
                    // 2. Marcar como verificado (activar usuario)
                    boolean usuarioActivado = codigoDao.marcarUsuarioComoVerificado(usuario.getIdUsuario());
                    System.out.println("✅ Coordinador marcado como verificado: " + usuarioActivado);
                    
                    // 3. Eliminar código usado
                    codigoDao.eliminarCodigo(correo);
                    System.out.println("✅ Código eliminado para coordinador: " + correo);
                    
                    // 4. Mostrar pop-up de activación exitosa y luego redirigir
                    request.setAttribute("success", "Tu cuenta de coordinador interno ha sido activada exitosamente. ¡Bienvenido/a al equipo!");
                    request.setAttribute("correoUsuario", correo);
                    request.setAttribute("cuentaActivada", true);
                    request.getRequestDispatcher("establecerContrasenaCoordinador.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Error al encontrar el usuario. Contacta al administrador.");
                    request.setAttribute("correoUsuario", correo);
                    request.setAttribute("iniciarTimer", true);
                    request.setAttribute("esCoordinador", true);
                    request.getRequestDispatcher("establecerContrasenaCoordinador.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Código inválido o expirado");
                request.setAttribute("correoUsuario", correo);
                request.setAttribute("iniciarTimer", true);
                request.setAttribute("esCoordinador", true);
                request.getRequestDispatcher("establecerContrasenaCoordinador.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error interno del servidor");
            request.setAttribute("correoUsuario", correo);
            request.setAttribute("iniciarTimer", true);
            request.setAttribute("esCoordinador", true);
            request.getRequestDispatcher("establecerContrasenaCoordinador.jsp").forward(request, response);
        }
    }
    
    // Método de validación de contraseña (mismo que en otros servlets)
    private boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasUpper = false, hasLower = false, hasDigit = false, hasSpecial = false;
        
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpper = true;
            else if (Character.isLowerCase(c)) hasLower = true;
            else if (Character.isDigit(c)) hasDigit = true;
            else if (!Character.isLetterOrDigit(c)) hasSpecial = true;
        }
        
        return hasUpper && hasLower && hasDigit && hasSpecial;
    }
}
