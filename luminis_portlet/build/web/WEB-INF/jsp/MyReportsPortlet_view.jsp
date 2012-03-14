<%@ page contentType="text/html" %>
<%@ page pageEncoding="UTF-8" %>
<%@ page import="edu.fhda.luminis.util.*, java.io.*, java.sql.*, java.util.*, javax.portlet.*, javax.sql.*, oracle.jdbc.pool.OracleDataSource" %>

<%
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
%>

<style type="text/css">
    td.argos-rpt-category { font-weight: bold; padding-left: 22px; background: url(/site/fatcow.16/folder_page.png) no-repeat left center; }
    td.argos-rpts-list a { display: inline-block; margin-left: 22px; padding-left: 22px; background: url(/site/fatcow.16/page_gear.png) no-repeat left center; line-height: 20px }
</style>

<div style="font-family:Helvetica,Verdana,Arial; font-size:12px;">
    <table>
    <%
    Iterator groupKeys = userReports.keySet().iterator();
    while(groupKeys.hasNext()) {
        String groupKey = (String) groupKeys.next();
        LinkedHashMap<String, String> groupReports = (LinkedHashMap<String, String>) userReports.get(groupKey);
    %>
        <tr><td class="argos-rpt-category"><%= groupTitles.get(groupKey) %></td></tr>
        <tr>
            <td class="argos-rpts-list">
                <%
                Iterator<String> reportKeys = groupReports.keySet().iterator();
                while(reportKeys.hasNext()) {
                    String reportName = reportKeys.next();
                    String reportTitle = groupReports.get(reportName);
                %>
                <a class="argoslink" href="<%= mpLaunchURL + reportName %>"><%= reportTitle %></a><br/>
                <%
                }
                %>
            </td>
        </tr>
    <%
    }
    %>
    </table>
</div>

<script type="text/javascript">
    refreshShadowboxes('a.argoslink');
</script>