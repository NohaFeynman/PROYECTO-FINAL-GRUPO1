package com.example.webproyecto.servlets.administrador;

import com.example.webproyecto.beans.Usuario;
import com.example.webproyecto.beans.Credencial;
import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.daos.CredencialDao;
import com.example.webproyecto.daos.administrador.AsignacionFormularioDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import com.example.webproyecto.beans.Distrito;
import com.example.webproyecto.daos.DistritoDao;
import com.example.webproyecto.beans.Zona;
import com.example.webproyecto.daos.encuestador.ZonaDao;
import com.example.webproyecto.beans.Formulario; // <--- ¡NUEVO! Importar el bean Formulario
import com.example.webproyecto.daos.encuestador.FormularioDao; // <--- ¡NUEVO! Importar FormularioDao (desde su paquete correcto)
import com.example.webproyecto.daos.CodigoDao;
import com.example.webproyecto.utils.CodeGenerator;
import com.example.webproyecto.utils.MailSender;

import java.sql.SQLException;

@WebServlet(name = "CrearCoordinadorServlet", value = "/CrearCoordinadorServlet")
public class CrearCoordinadorServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DistritoDao distritoDao = new DistritoDao();
        ZonaDao zonaDao = new ZonaDao();
        FormularioDao formularioDao = new FormularioDao();

        List<Distrito> listaDistritos = null;
        List<Zona> listaZonas = null;
        List<Formulario> listaFormularios = null;

        try {
            listaDistritos = distritoDao.listarDistritos();
            listaZonas = zonaDao.listarZonas();
            listaFormularios = formularioDao.listarFormularios();
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorCarga", "Error al cargar datos de distritos, zonas o formularios.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorCarga", "Ocurrió un error inesperado al cargar datos.");
        }

        request.setAttribute("distritos", listaDistritos);
        request.setAttribute("zonas", listaZonas);
        request.setAttribute("formularios", listaFormularios);

        request.getRequestDispatcher("admin/crearCoordinador.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String nombre = request.getParameter("nombre");
        String apellidopaterno = request.getParameter("apellidopaterno");
        String apellidomaterno = request.getParameter("apellidomaterno");
        String dni = request.getParameter("dni");
        String direccion = request.getParameter("direccion");
        String correo = request.getParameter("correo");
        String idDistrito = request.getParameter("idDistrito");
        String idDistritoTrabajo = request.getParameter("idDistritoTrabajo");
        String idZonaTrabajo = request.getParameter("idZonaTrabajo");
        String idFormularioAsignado = request.getParameter("idFormularioAsignado");
        int idEstado = 1; // Cambiado a 1 (Pendiente de verificación) en lugar de 2 (Activo)

        String fotoBase64 = null;

        UsuarioDao usuarioDao = new UsuarioDao();
        CredencialDao credencialDao = new CredencialDao();
        DistritoDao distritoDao = new DistritoDao();
        ZonaDao zonaDao = new ZonaDao();
        FormularioDao formularioDao = new FormularioDao(); // <--- ¡NUEVO! Instancia para el doPost

        try {
            int idDistritoInt = Integer.parseInt(idDistrito);
            Integer idDistritoTrabajoInt = null;
            if (idDistritoTrabajo != null && !idDistritoTrabajo.isEmpty()) {
                idDistritoTrabajoInt = Integer.parseInt(idDistritoTrabajo);
            }

            Integer idZonaTrabajoInt = null;
            if (idZonaTrabajo != null && !idZonaTrabajo.isEmpty()) {
                idZonaTrabajoInt = Integer.parseInt(idZonaTrabajo);
            }

            boolean existeDni = usuarioDao.existeDni(dni);
            boolean existeCorreo = credencialDao.existeCorreo(correo);

            if (existeDni || existeCorreo) {
                // Redirigir con parámetro para mostrar pop-up en el JSP y mantener datos
                StringBuilder url = new StringBuilder("CrearCoordinadorServlet?error=");
                String errorParam = existeDni ? "dni" : "correo";
                if (existeDni && existeCorreo) errorParam = "ambos";
                url.append(errorParam);
                // Mantener los datos válidos
                url.append("&nombre=").append(java.net.URLEncoder.encode(nombre, "UTF-8"));
                url.append("&apellidopaterno=").append(java.net.URLEncoder.encode(apellidopaterno, "UTF-8"));
                url.append("&apellidomaterno=").append(java.net.URLEncoder.encode(apellidomaterno, "UTF-8"));
                url.append("&direccion=").append(java.net.URLEncoder.encode(direccion, "UTF-8"));
                url.append("&idDistrito=").append(idDistrito != null ? idDistrito : "");
                url.append("&idDistritoTrabajo=").append(idDistritoTrabajo != null ? idDistritoTrabajo : "");
                url.append("&idZonaTrabajo=").append(idZonaTrabajo != null ? idZonaTrabajo : "");
                url.append("&idFormularioAsignado=").append(idFormularioAsignado != null ? idFormularioAsignado : "");
                url.append("&dni=").append(existeDni ? "" : (dni != null ? java.net.URLEncoder.encode(dni, "UTF-8") : ""));
                url.append("&correo=").append(existeCorreo ? "" : (correo != null ? java.net.URLEncoder.encode(correo, "UTF-8") : ""));
                response.sendRedirect(url.toString());
                return;
            }

            Usuario usuario = new Usuario();
            usuario.setNombre(nombre);
            usuario.setApellidopaterno(apellidopaterno);
            usuario.setApellidomaterno(apellidomaterno);
            usuario.setDni(dni);
            usuario.setDireccion(direccion);
            usuario.setIdDistrito(idDistritoInt);
            usuario.setIdDistritoTrabajo(idDistritoTrabajoInt);

            usuario.setIdRol(2); // Rol para Coordinador
            usuario.setIdEstado(idEstado);

            usuario.setIdZonaTrabajo(idZonaTrabajoInt);
            // Si deseas almacenar el formulario asignado directamente en Usuario,
            // debes añadir la propiedad idFormularioAsignado a tu bean Usuario.java
            // y a tu tabla de base de datos 'usuario'.
            // usuario.setIdFormularioAsignado(idFormularioAsignado); // Descomenta si aplica

            usuario.setFoto(fotoBase64); // Considera si 'fotoBase64' y 'nombrefoto' siempre serán null aquí

            boolean usuarioCreado = usuarioDao.insertarUsuario(usuario);

            if (usuarioCreado) {
                Credencial credencial = new Credencial();
                credencial.setCorreo(correo);
                credencial.setContrasenha(null); // No establecer contraseña aún
                credencial.setIdUsuario(usuario.getIdUsuario()); // Asegúrate de que este ID se obtenga después de insertar el usuario

                boolean credOk = credencialDao.insertarCredencial(credencial);

                if (credOk) {
                    // Generar código de verificación para el coordinador
                    String codigoVerificacion = CodeGenerator.generator();
                    CodigoDao codigoDao = new CodigoDao();
                    boolean codigoGuardado = codigoDao.guardarCodigo(correo, codigoVerificacion);

                    if (idFormularioAsignado != null && !idFormularioAsignado.isEmpty()) {
                        try {
                            int idFormularioInt = Integer.parseInt(idFormularioAsignado);
                            AsignacionFormularioDao asignacionFormularioDao = new AsignacionFormularioDao();
                            asignacionFormularioDao.insertarAsignacionFormulario(usuario.getIdUsuario(), idFormularioInt, "Activo");
                        } catch (Exception e) {
                            System.err.println("Error al asignar formulario al coordinador: " + e.getMessage());
                        }
                    }
                    if (codigoGuardado) {
                        // Obtener información de la zona para personalizar el correo
                        String zonaNombre = "la zona asignada";
                        if (idZonaTrabajoInt != null) {
                            try {
                                Zona zona = zonaDao.obtenerZonaPorId(idZonaTrabajoInt);
                                if (zona != null) {
                                    zonaNombre = zona.getNombreZona();
                                }
                            } catch (Exception e) {
                                System.err.println("Error al obtener zona: " + e.getMessage());
                            }
                        }

                        // Enviar correo de verificación con información específica para coordinadores
                        String asunto = "Bienvenido/a como Coordinador Interno - ONU Mujeres";
                        String mensaje = "¡Hola " + nombre + " " + apellidopaterno + "!\n\n" +
                                "¡Felicitaciones! Has sido asignado/a como Coordinador Interno en la plataforma de ONU Mujeres.\n\n" +
                                "Has sido asignado/a a: " + zonaNombre + "\n\n" +
                                "Para activar tu cuenta y establecer tu contraseña, necesitas verificar tu correo electrónico.\n\n" +
                                "Tu código de verificación es: " + codigoVerificacion + "\n\n" +
                                "Por favor, haz clic en el siguiente enlace para completar la configuración de tu cuenta:\n" +
                                request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() +
                                request.getContextPath() + "/verificarCoordinador?correo=" + java.net.URLEncoder.encode(correo, "UTF-8") + "\n\n" +
                                "IMPORTANTE: El código contiene números y letras (ejemplo: A1B2C3)\n\n" +
                                "Este código es válido por 5 minutos por seguridad.\n\n" +
                                "Como Coordinador Interno, tendrás acceso a funcionalidades especiales para gestionar encuestadores y supervisar el trabajo de campo.\n\n" +
                                "Si no esperabas este mensaje, puedes ignorarlo de forma segura.\n\n" +
                                "¡Bienvenido/a al equipo!\n\n" +
                                "Saludos,\n" +
                                "Equipo ONU Mujeres\n" +
                                "Defensora mundial de la igualdad de género";

                        try {
                            MailSender.sendEmail(correo, asunto, mensaje);
                            boolean correoEnviado = true; // MailSender.sendEmail es void, asumimos éxito si no hay excepción

                            if (correoEnviado) {
                                System.out.println("✅ Coordinador creado y código enviado a: " + correo);
                                System.out.println("🔐 Código de verificación: " + codigoVerificacion);
                                System.out.println("========================================");
                                System.out.println("🚀 CÓDIGO PARA COORDINADOR:");
                                System.out.println("📧 Correo: " + correo);
                                System.out.println("🔑 Código: " + codigoVerificacion);
                                System.out.println("🌐 Enlace: http://localhost:8080" + request.getContextPath() + "/verificarCoordinador?correo=" + java.net.URLEncoder.encode(correo, "UTF-8"));
                                System.out.println("⏰ Válido por: 5 minutos");
                                System.out.println("========================================");

                                // Redirigir con mensaje de éxito
                                response.sendRedirect("CrearCoordinadorServlet?success=true");
                            } else {
                                System.err.println("❌ Error al enviar correo de verificación");
                                response.sendRedirect("CrearCoordinadorServlet?success=true&correoEnviado=0");
                            }
                        } catch (Exception emailException) {
                            System.err.println("❌ Excepción al enviar correo: " + emailException.getMessage());
                            emailException.printStackTrace();
                            response.sendRedirect("CrearCoordinadorServlet?success=true&correoEnviado=0");
                        }
                    } else {
                        request.setAttribute("error", "Error al generar código de verificación.");
                        // Recargar listas en caso de error
                        request.setAttribute("distritos", distritoDao.listarDistritos());
                        request.setAttribute("zonas", zonaDao.listarZonas());
                        try {
                            request.setAttribute("formularios", formularioDao.listarFormularios());
                        } catch (SQLException ex) {
                            ex.printStackTrace();
                            request.setAttribute("errorFormularios", "Error al recargar formularios.");
                        }
                        request.getRequestDispatcher("admin/crearCoordinador.jsp").forward(request, response);
                    }
                } else {
                    request.setAttribute("error", "Error al guardar la credencial.");
                    // Recargar listas en caso de error
                    request.setAttribute("distritos", distritoDao.listarDistritos());
                    request.setAttribute("zonas", zonaDao.listarZonas());
                    try { // <--- ¡NUEVO! Recarga de formularios en caso de error
                        request.setAttribute("formularios", formularioDao.listarFormularios());
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                        request.setAttribute("errorFormularios", "Error al recargar formularios.");
                    }
                    request.getRequestDispatcher("admin/crearCoordinador.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Error al guardar el coordinador.");
                // Recargar listas en caso de error
                request.setAttribute("distritos", distritoDao.listarDistritos());
                request.setAttribute("zonas", zonaDao.listarZonas());
                try { // <--- ¡NUEVO! Recarga de formularios en caso de error
                    request.setAttribute("formularios", formularioDao.listarFormularios());
                } catch (SQLException ex) {
                    ex.printStackTrace();
                    request.setAttribute("errorFormularios", "Error al recargar formularios.");
                }
                request.getRequestDispatcher("admin/crearCoordinador.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error de base de datos durante la creación del coordinador: " + e.getMessage());
            try {
                request.setAttribute("distritos", distritoDao.listarDistritos());
                request.setAttribute("zonas", zonaDao.listarZonas());
                try { // <--- ¡NUEVO! Recarga de formularios en caso de error
                    request.setAttribute("formularios", formularioDao.listarFormularios());
                } catch (SQLException ex) {
                    ex.printStackTrace();
                    request.setAttribute("errorFormularios", "Error al recargar formularios.");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                request.setAttribute("error", request.getAttribute("error") + " Además, error al cargar datos de soporte.");
            }
            request.getRequestDispatcher("admin/crearCoordinador.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: Un ID numérico no es válido. Por favor, revise los campos de selección.");
            try {
                request.setAttribute("distritos", distritoDao.listarDistritos());
                request.setAttribute("zonas", zonaDao.listarZonas());
                try { // <--- ¡NUEVO! Recarga de formularios en caso de error
                    request.setAttribute("formularios", formularioDao.listarFormularios());
                } catch (SQLException ex) {
                    ex.printStackTrace();
                    request.setAttribute("errorFormularios", "Error al recargar formularios.");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                request.setAttribute("error", request.getAttribute("error") + " Además, error al cargar datos de soporte.");
            }
            request.getRequestDispatcher("admin/crearCoordinador.jsp").forward(request, response);
        }
    }
}
