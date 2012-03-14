package edu.fhda.luminis.argos;

import java.io.*;
import java.net.*;

import javax.naming.*;
import javax.portlet.GenericPortlet;
import javax.portlet.ActionRequest;
import javax.portlet.RenderRequest;
import javax.portlet.ActionResponse;
import javax.portlet.RenderResponse;
import javax.portlet.PortletException;
import javax.portlet.PortletRequestDispatcher;
import javax.sql.*;

import oracle.jdbc.pool.OracleDataSource;
import org.apache.commons.io.IOUtils;

/**
 * MyReportsPortlet Portlet Class
 */
public class MyReportsPortlet extends GenericPortlet {

    private Context initContext;
    private Context envContext;
    private DataSource dsBanner;
    private long lastRunTime = System.currentTimeMillis();
    private File deployedJSP = null;
    private InetAddress localMachine = null;

    private String jspPathArgos = "/opt/luminis/shared/channels/argos-v2/MyReportsPortlet_view.jsp";

    private File logFileRef = null;
    private PrintWriter logFileOut = null;

    public void init() {
        try {
            // Get information about this machine
            localMachine = InetAddress.getLocalHost();

            // Configure stream for log file
            logFileRef = new File("/opt/luminis/shared/channels/argos-v2/MyReportsPortlet_" + localMachine.getHostName() + ".log");
            logFileRef.delete();
            logFileRef.createNewFile();
            logFileOut = new PrintWriter(new BufferedWriter(new FileWriter(logFileRef)));
            this.getPortletContext().setAttribute("logstream", logFileOut);
            
            // Lookup a data source and cache it in the PortalContext for quick access
            initContext = new InitialContext();
            envContext = (Context) initContext.lookup("java:comp/env");
            dsBanner = (OracleDataSource) envContext.lookup("jdbc/Banner");
            this.getPortletContext().setAttribute("ds", dsBanner);

            // Set up references
            deployedJSP = new File(this.getPortletContext().getRealPath("/WEB-INF/jsp/MyReportsPortlet_view.jsp"));

            // If a distributed file is available - copy it in for startup
            File jspMyReports = new File(jspPathArgos);
            if(jspMyReports.exists()) {
                updateJSP(jspMyReports);
            }            
        }
        catch(Exception servletSetupError) {
            servletSetupError.printStackTrace(System.out);
        }
    }

    public void processAction(ActionRequest request, ActionResponse response) throws PortletException, IOException {
    }
    
    public void doView(RenderRequest request,RenderResponse response) throws PortletException,IOException {
        // Check our "distributed code" file - if it's newer, copy into webapp dynamically prior to execution
        File jspMyReports = new File(jspPathArgos);
        if(jspMyReports.exists()) {
            if(jspMyReports.lastModified() > lastRunTime) {
                updateJSP(jspMyReports);
            }
        }

        // Update the last run time
        this.updateRunTime(System.currentTimeMillis());

        // Configure response and delegate request to execute as JSP file
        response.setContentType("text/html");        
        PortletRequestDispatcher reqDispatcher = getPortletContext().getRequestDispatcher("/WEB-INF/jsp/MyReportsPortlet_view.jsp");
        reqDispatcher.include(request, response);
    }

    public synchronized void updateRunTime(long newVal) {
        this.lastRunTime = newVal;
    }

    public synchronized void updateJSP(File sourceFile) throws IOException {
        BufferedOutputStream distCodeOut = new BufferedOutputStream(new FileOutputStream(deployedJSP));
        IOUtils.copy(new FileInputStream(sourceFile), distCodeOut);
        distCodeOut.close();
    }
}