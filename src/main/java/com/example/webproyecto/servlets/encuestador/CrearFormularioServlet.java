package com.example.webproyecto.servlets.encuestador;

import com.example.webproyecto.beans.Formulario;
import com.example.webproyecto.daos.encuestador.FormularioDao;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.Date;

@WebServlet(name = "CrearFormularioServlet", value = "/CrearFormularioServlet")
public class CrearFormularioServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        Object idCoordinadorObj = (session != null) ? session.getAttribute("idUsuario") : null;
        Object idCarpetaObj = (session != null) ? session.getAttribute("idCarpeta") : null;

        if (session == null || idCoordinadorObj == null || idCarpetaObj == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int idCoordinador = (idCoordinadorObj instanceof Integer) ? (Integer) idCoordinadorObj : Integer.parseInt(idCoordinadorObj.toString());
        int idCarpeta = (idCarpetaObj instanceof Integer) ? (Integer) idCarpetaObj : Integer.parseInt(idCarpetaObj.toString());

        String titulo = request.getParameter("titulo");
        String descripcion = request.getParameter("descripcion");
        boolean activo = true; // o según tu lógica

        Formulario formulario = new Formulario();
        formulario.setTitulo(titulo);
        formulario.setDescripcion(descripcion);
        formulario.setFechaCreacion(new java.util.Date());
        formulario.setIdCoordinador(idCoordinador);
        formulario.setIdCarpeta(idCarpeta);
        formulario.setActivo(activo);

        FormularioDao dao = new FormularioDao();
        try {
            dao.insertarFormulario(formulario);
            response.sendRedirect("exito.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
