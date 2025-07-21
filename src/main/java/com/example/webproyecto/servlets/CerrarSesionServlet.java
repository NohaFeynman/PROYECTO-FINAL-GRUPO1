package com.example.webproyecto.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet(name = "CerrarSesionServlet", urlPatterns = {"/CerrarSesionServlet", "/LogoutServlet"})
public class CerrarSesionServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();  // 🔐 Invalida toda la sesión
        }

        response.sendRedirect("LoginServlet");  // 🔁 Redirige al servlet de login
    }
}

