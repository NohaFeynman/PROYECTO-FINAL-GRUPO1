package com.example.webproyecto.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.beans.Usuario;

import java.io.IOException;

@WebFilter("/*") // Se aplica a todo
public class LoginFilter implements Filter {

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);
        boolean loggedIn = session != null && session.getAttribute("idUsuario") != null;

        // Si el usuario está logueado, verificar que siga activo en la base de datos
        if (loggedIn) {
            try {
                Integer idUsuario = (Integer) session.getAttribute("idUsuario");
                UsuarioDao usuarioDao = new UsuarioDao();
                Usuario usuario = usuarioDao.obtenerUsuarioPorId(idUsuario);
                
                // Si el usuario no existe o está inactivo, invalidar sesión
                if (usuario == null || usuario.getIdEstado() != 2) {
                    System.out.println("⚠️ Usuario inactivo o eliminado. Cerrando sesión: " + idUsuario);
                    session.invalidate();
                    response.sendRedirect("LoginServlet?error=cuenta-desactivada");
                    return;
                }
            } catch (Exception e) {
                System.out.println("❌ Error al verificar estado del usuario: " + e.getMessage());
                // En caso de error de BD, mantener la sesión pero registrar el error
            }
        }

        boolean isLoginPage = uri.contains("login.jsp");
        boolean isLoginServlet = uri.endsWith("LoginServlet");
        boolean isRoot = uri.equals(request.getContextPath() + "/");

        if (loggedIn && (isLoginPage || isLoginServlet || isRoot)) {

            String rol = (String) session.getAttribute("rol");
            switch (rol) {
                case "administrador" -> response.sendRedirect("InicioAdminServlet");
                case "coordinador" -> response.sendRedirect("InicioCoordinadorServlet");
                case "encuestador" -> response.sendRedirect("InicioEncuestadorServlet");
                default -> {
                    session.invalidate();
                    response.sendRedirect("login.jsp?error=rol");
                }
            }
            return;
        }

        // Si no está logueado y trata de entrar a algo privado
        boolean recursoProtegido =
                uri.contains("/Inicio") ||
                        uri.contains("/formularioRespuesta") ||
                        uri.contains("/verPerfil") ||
                        uri.contains("/FormulariosAsignados") ||
                        uri.contains("/historialFormularios");

        if (!loggedIn && recursoProtegido) {
            System.out.println("🚫 Acceso denegado a recurso protegido: " + uri);
            response.sendRedirect("LoginServlet?error=sesion-expirada");
            return;
        }

        // Dejar pasar la petición
        chain.doFilter(request, response);
    }
}

