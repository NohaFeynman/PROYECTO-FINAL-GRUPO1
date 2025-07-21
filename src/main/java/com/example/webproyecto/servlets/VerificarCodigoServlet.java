package com.example.webproyecto.servlets;

import com.example.webproyecto.beans.Usuario;
import com.example.webproyecto.daos.CodigoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "VerificarCodigoServlet", urlPatterns = {"/verificarCodigo"})
public class VerificarCodigoServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String correo = request.getParameter("correo");
        
        // Verificar si hay un correo en sesión (viene del registro o reload)
        String correoSesion = (String) request.getSession().getAttribute("correoVerificacion");
        
        if (correoSesion != null) {
            // Usuario en sesión - esto es un reload de página, NO reenviar código
            System.out.println("🔄 Reload de página detectado para correo: " + correoSesion);
            
            // Solo mostrar la página sin reenviar código
            request.setAttribute("correo", correoSesion);
            request.setAttribute("esReload", true); // Indicador para el JSP
            request.getRequestDispatcher("verificarCodigo.jsp").forward(request, response);
            return;
        }
        
        if (correo != null && !correo.trim().isEmpty()) {
            // Acceso directo con correo - configurar atributos para JSP
            request.setAttribute("correo", correo);
            request.setAttribute("iniciarTimer", true);
            request.getRequestDispatcher("verificarCodigo.jsp").forward(request, response);
        } else {
            // Sin correo y sin sesión, redirigir al registro
            response.sendRedirect("registro");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String codigo = request.getParameter("codigo");
        
        // Validaciones básicas
        if (codigo == null || codigo.trim().isEmpty()) {
            request.setAttribute("error", "El código de verificación es requerido");
            request.getRequestDispatcher("verificarCodigo.jsp").forward(request, response);
            return;
        }

        CodigoDao codigoDao = new CodigoDao();

        try {
            // Verificar el código sin necesidad del correo
            String correo = codigoDao.getCorreoByCode(codigo);
            
            if (correo != null && codigoDao.verificarCodigo(correo, codigo)) {
                // 1. Obtener el usuario por correo
                Usuario usuario = codigoDao.getUsuarioByCorreo(correo);
                if (usuario != null) {
                    System.out.println("✅ Usuario encontrado: " + usuario.getIdUsuario());
                    
                    // 2. Marcar como verificado
                    boolean usuarioActivado = codigoDao.marcarUsuarioComoVerificado(usuario.getIdUsuario());
                    System.out.println("✅ Usuario marcado como verificado: " + usuarioActivado);
                    
                    // 3. Eliminar código usado
                    codigoDao.eliminarCodigo(correo);
                    System.out.println("✅ Código eliminado para correo: " + correo);
                    
                    // 4. Limpiar sesión de verificación y proceso de registro
                    request.getSession().removeAttribute("correoVerificacion");
                    request.getSession().removeAttribute("registroEnProceso");
                    request.getSession().setAttribute("usuario", usuario);
                    request.setAttribute("correo", correo);
                    
                    System.out.println("🧹 Sesión limpiada - proceso de verificación completado");
                    
                    // 5. Redirigir a página de éxito
                    request.getRequestDispatcher("registroExitoso.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Error al activar la cuenta. Inténtalo nuevamente.");
                    request.getRequestDispatcher("verificarCodigo.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Código inválido o expirado");
                request.getRequestDispatcher("verificarCodigo.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error interno del servidor");
            request.getRequestDispatcher("verificarCodigo.jsp").forward(request, response);
        }
    }
}
