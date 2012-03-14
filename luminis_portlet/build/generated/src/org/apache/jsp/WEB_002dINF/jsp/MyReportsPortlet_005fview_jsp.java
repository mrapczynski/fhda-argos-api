package org.apache.jsp.WEB_002dINF.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import edu.fhda.luminis.util.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import javax.portlet.*;
import javax.sql.*;
import oracle.jdbc.pool.OracleDataSource;

public final class MyReportsPortlet_005fview_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {

  private static final JspFactory _jspxFactory = JspFactory.getDefaultFactory();

  private static java.util.Vector _jspx_dependants;

  private org.apache.jasper.runtime.ResourceInjector _jspx_resourceInjector;

  public Object getDependants() {
    return _jspx_dependants;
  }

  public void _jspService(HttpServletRequest request, HttpServletResponse response)
        throws java.io.IOException, ServletException {

    PageContext pageContext = null;
    HttpSession session = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;


    try {
      response.setContentType("text/html;charset=UTF-8");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;
      _jspx_resourceInjector = (org.apache.jasper.runtime.ResourceInjector) application.getAttribute("com.sun.appserv.jsp.resource.injector");

      out.write("\n");
      out.write("\n");
      out.write("\n");
      out.write("\n");

    // Get the portlet objects
    PortletRequest portletRequest = (PortletRequest) request.getAttribute("javax.portlet.request");
    PortletConfig portletConfig = (PortletConfig) request.getAttribute("javax.portlet.config");
    PrintWriter portletLog = (PrintWriter) portletConfig.getPortletContext().getAttribute("logstream");

    // Variables
    OracleDataSource dbPool = (OracleDataSource) portletConfig.getPortletContext().getAttribute("ds");
    String instanceName = DatabaseUtils.getOracleSIDFromURL(dbPool.getURL());
    Connection dbBanner = null;
    PreparedStatement psArgosReportCategories = null;
    PreparedStatement psArgosReports = null;

    LinkedHashMap<String, String> groupTitles = new LinkedHashMap<String, String>();
    LinkedHashMap<String, HashMap> userReports = new LinkedHashMap<String, HashMap>();

    String mpLaunchURL = "/cp/ip/login?sys=sctssb&url=https%3A%2F%2Fbanssb.fhda.edu%2F" + instanceName + "%2Fargos_web.P_RenderLuminisAPIForm?pi_reportname=";

    // Get the user identity if possible (5/3/11: identites checked from lumtest)
    String userID = IdentityUtils.lookupSpridenID(portletRequest.getRemoteUser(), (instanceName.equalsIgnoreCase("PROD")) ? "10.201.2.13" : "10.201.2.81");

    try {
        // Get a connection to Banner
        dbBanner = dbPool.getConnection();

        // Create prepared statements to query for authorized Argos reports
        // Categories granted to user
        psArgosReportCategories = dbBanner.prepareStatement("select distinct report_role, group_desc from argos_user_reports where cwid = ? order by group_desc");
        psArgosReportCategories.setString(1, userID);

        // Reports in each category that user may execute
        psArgosReports = dbBanner.prepareStatement("select report_name, report_title from argos_user_reports where cwid = ? and report_role = ? order by report_title");
        psArgosReports.setString(1, userID);

        // Execute!
        ResultSet rsCategories = psArgosReportCategories.executeQuery();
        while(rsCategories.next()) {
            // Create a collection of reports for this category
            LinkedHashMap<String, String> newReportSet = new LinkedHashMap<String, String>();

            // Query and add the reports
            psArgosReports.setString(2, rsCategories.getString(1));
            ResultSet rsReports = psArgosReports.executeQuery();
            while(rsReports.next()) {
                newReportSet.put(rsReports.getString(1), rsReports.getString(2));
            }
            rsReports.close();

            // Add to master collection
            userReports.put(rsCategories.getString(1), newReportSet);

            // Add group to title collection
            groupTitles.put(rsCategories.getString(1), rsCategories.getString(2));
        }
    }
    catch (Exception jspRenderError) {
        jspRenderError.printStackTrace(portletLog);
        portletLog.flush();
    }
    finally {
        try {
            // Close database resources
            psArgosReports.close();
            psArgosReportCategories.close();
            dbBanner.close();
        }
        catch (Exception cleanupError) {
            // Ignore this code block - we do not care if clean-up fails
        }
    }

      out.write("\n");
      out.write("\n");
      out.write("<style type=\"text/css\">\n");
      out.write("    td.argos-rpt-category { font-weight: bold; padding-left: 22px; background: url(/site/fatcow.16/folder_page.png) no-repeat left center; }\n");
      out.write("    td.argos-rpts-list a { display: inline-block; margin-left: 22px; padding-left: 22px; background: url(/site/fatcow.16/page_gear.png) no-repeat left center; line-height: 20px }\n");
      out.write("</style>\n");
      out.write("\n");
      out.write("<div style=\"font-family:Helvetica,Verdana,Arial; font-size:12px;\">\n");
      out.write("    <table>\n");
      out.write("    ");

    Iterator groupKeys = userReports.keySet().iterator();
    while(groupKeys.hasNext()) {
        String groupKey = (String) groupKeys.next();
        LinkedHashMap<String, String> groupReports = (LinkedHashMap<String, String>) userReports.get(groupKey);
    
      out.write("\n");
      out.write("        <tr><td class=\"argos-rpt-category\">");
      out.print( groupTitles.get(groupKey) );
      out.write("</td></tr>\n");
      out.write("        <tr>\n");
      out.write("            <td class=\"argos-rpts-list\">\n");
      out.write("                ");

                Iterator<String> reportKeys = groupReports.keySet().iterator();
                while(reportKeys.hasNext()) {
                    String reportName = reportKeys.next();
                    String reportTitle = groupReports.get(reportName);
                
      out.write("\n");
      out.write("                <a class=\"argoslink\" href=\"");
      out.print( mpLaunchURL + reportName );
      out.write('"');
      out.write('>');
      out.print( reportTitle );
      out.write("</a><br/>\n");
      out.write("                ");

                }
                
      out.write("\n");
      out.write("            </td>\n");
      out.write("        </tr>\n");
      out.write("    ");

    }
    
      out.write("\n");
      out.write("    </table>\n");
      out.write("</div>\n");
      out.write("\n");
      out.write("<script type=\"text/javascript\">\n");
      out.write("    refreshShadowboxes('a.argoslink');\n");
      out.write("</script>");
    } catch (Throwable t) {
      if (!(t instanceof SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          out.clearBuffer();
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
