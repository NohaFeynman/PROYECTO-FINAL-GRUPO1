package com.example.webproyecto.servlets;

import com.example.webproyecto.beans.Usuario;
import com.example.webproyecto.daos.CredencialDao;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String correo = request.getParameter("correo");
        String contrasenha = request.getParameter("password"); // Corregido: el campo se llama "password" en el formulario

        System.out.println("🔐 LoginServlet - Intento de login:");
        System.out.println("   - Correo: " + (correo != null ? correo : "null"));
        System.out.println("   - Password: " + (contrasenha != null ? "***" : "null"));

        // Validar que los parámetros no sean null o vacíos
        if (correo == null || correo.trim().isEmpty() || contrasenha == null || contrasenha.trim().isEmpty()) {
            System.out.println("❌ Campos vacíos detectados");
            response.sendRedirect("login.jsp?error=campos-vacios");
            return;
        }

        CredencialDao dao = new CredencialDao();
        Usuario usuario = dao.validarLogin(correo.trim(), contrasenha);

        if (usuario != null) {
            if (usuario.getIdEstado() != 2) {
                System.out.println("⛔ Usuario desactivado. No puede iniciar sesión.");
                response.sendRedirect("login.jsp?error=desactivado");
                return;
            }

            System.out.println("✅ Login exitoso para usuario: " + usuario.getNombre() + " (ID: " + usuario.getIdUsuario() + ")");
            
            HttpSession session = request.getSession();
            session.setAttribute("idUsuario", usuario.getIdUsuario());
            session.setAttribute("idrol", usuario.getIdRol());
            session.setAttribute("nombre", usuario.getNombre());
            session.setAttribute("apellidopaterno", usuario.getApellidopaterno());
            session.setAttribute("apellidomaterno", usuario.getApellidomaterno());
            session.setAttribute("idZonaTrabajo", usuario.getIdZonaTrabajo());

            String rol = switch (usuario.getIdRol()) {
                case 1 -> "administrador";
                case 2 -> "coordinador";
                case 3 -> "encuestador";
                default -> "desconocido";
            };

            session.setAttribute("rol", rol);
            System.out.println("📋 Rol asignado: " + rol);

            switch (rol) {
                case "administrador" -> {
                    System.out.println("🔄 Redirigiendo a dashboard de administrador");
                    response.sendRedirect("InicioAdminServlet");
                }
                case "coordinador" -> {
                    System.out.println("🔄 Redirigiendo a dashboard de coordinador");
                    response.sendRedirect("InicioCoordinadorServlet");
                }
                case "encuestador" -> {
                    System.out.println("🔄 Redirigiendo a dashboard de encuestador");
                    response.sendRedirect("InicioEncuestadorServlet");
                }
                default -> {
                    System.out.println("❌ Rol desconocido: " + usuario.getIdRol());
                    session.invalidate();
                    response.sendRedirect("login.jsp?error=rol");
                }
            }

        } else {
            System.out.println("❌ Login fallido para correo: " + correo);
            System.out.println("   - Posibles causas:");
            System.out.println("     1. Correo no existe en la base de datos");
            System.out.println("     2. Contraseña incorrecta");
            System.out.println("     3. Usuario no está activo/verificado");
            
            // Verificar si el correo existe para dar más información (opcional)
            boolean correoExiste = dao.existeCorreo(correo.trim());
            System.out.println("   - Correo existe en BD: " + correoExiste);
            
            // Siempre mostrar el mismo mensaje por seguridad
            response.sendRedirect("login.jsp?error=1");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("🔍 LoginServlet - doGet iniciado");
        HttpSession session = request.getSession(false);

        if (session != null && session.getAttribute("idUsuario") != null) {
            String rol = (String) session.getAttribute("rol");
            System.out.println("✅ Usuario ya logueado con rol: " + rol);

            switch (rol) {
                case "administrador" -> {
                    System.out.println("🔄 Redirigiendo usuario logueado a dashboard de administrador");
                    response.sendRedirect("InicioAdminServlet");
                }
                case "coordinador" -> {
                    System.out.println("🔄 Redirigiendo usuario logueado a dashboard de coordinador");
                    response.sendRedirect("InicioCoordinadorServlet");
                }
                case "encuestador" -> {
                    System.out.println("🔄 Redirigiendo usuario logueado a dashboard de encuestador");
                    response.sendRedirect("InicioEncuestadorServlet");
                }
                default -> {
                    System.out.println("❌ Rol inválido en sesión: " + rol);
                    session.invalidate();
                    response.sendRedirect("login.jsp?error=rol");
                }
            }
        } else {
            System.out.println("📄 Mostrando página de login");
            // Preservar el parámetro de error si existe
            String errorParam = request.getParameter("error");
            if (errorParam != null) {
                response.sendRedirect("login.jsp?error=" + errorParam);
            } else {
                response.sendRedirect("login.jsp");
            }
        }
    }
}
