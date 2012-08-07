CREATE TABLE ARGOS_API_FORMS  ( 
	REPORT_NAME         	VARCHAR2(24 CHAR) NOT NULL,
	REPORT_TITLE        	VARCHAR2(64 CHAR) NOT NULL,
	REPORT_APIKEY       	VARCHAR2(512 CHAR) NOT NULL,
	REPORT_USERNAME     	VARCHAR2(24 CHAR) NULL,
	REPORT_PASSWORD     	VARCHAR2(24 CHAR) NULL,
	REPORT_DESC         	VARCHAR2(2048 CHAR) NULL,
	REPORT_CSV_FLAG     	VARCHAR2(1) DEFAULT 'N' NULL,
	REPORT_FILENAME     	VARCHAR2(48) NULL,
	REPORT_PDF_FLAG     	VARCHAR2(1) DEFAULT 'N' NULL,
	REPORT_XLS_FLAG     	VARCHAR2(1) DEFAULT 'N' NULL,
	REPORT_ROLE         	VARCHAR2(96) NULL,
	REPORT_JS_SCRIPT    	VARCHAR2(64) NULL,
	REPORT_CATEGORY     	VARCHAR2(96) NULL,
	REPORT_FORCE_VERSION	NUMBER NULL,
	RECORD_USERNAME     	VARCHAR2(24) DEFAULT user NULL,
	RECORD_ACTIVITY_DATE	DATE DEFAULT sysdate NULL,
	REPORT_ENABLE_PIDM  	VARCHAR2(1) DEFAULT 'N' NULL,
	REPORT_ENABLE_CWID  	VARCHAR2(1) DEFAULT 'N' NULL,
	constraint pk_argos_api_forms primary key (report_name)
)
/

CREATE TABLE ARGOS_API_FIELDS  ( 
	REPORT_NAME       	VARCHAR2(24 CHAR) NOT NULL,
	FIELD_SEQNO       	NUMBER(2,0) NOT NULL,
	FIELD_TYPE        	VARCHAR2(12 CHAR) NULL,
	FIELD_LABEL       	VARCHAR2(48 CHAR) NULL,
	FIELD_SQL         	VARCHAR2(1024 CHAR) NULL,
	FIELD_PARAM_NAME  	VARCHAR2(96 CHAR) NOT NULL,
	FIELD_COMMENTS    	VARCHAR2(256 CHAR) NULL,
	FIELD_REGEX       	VARCHAR2(128 CHAR) NULL,
	FIELD_DISABLED    	VARCHAR2(1) DEFAULT 'N' NOT NULL,
	FIELD_INIT        	VARCHAR2(1) DEFAULT 'Y' NOT NULL,
	FIELD_INITMSG     	VARCHAR2(128) NULL,
	FIELD_REQUIRED    	VARCHAR2(1) DEFAULT 'Y' NULL,
	FIELD_BINDING     	VARCHAR2(96) DEFAULT null NULL,
	FIELD_MULTIPLESEL 	VARCHAR2(96) DEFAULT 'Y' NULL,
	FIELD_REGEX_ERRMSG	VARCHAR2(512) NULL,
	FIELD_BINDING_TYPE	VARCHAR2(6) DEFAULT 'STR' NULL,
	FIELD_BINDING_AUTO	VARCHAR2(1) DEFAULT 'N' NULL,
	CONSTRAINT PK_ARGOS_API_FIELDS PRIMARY KEY(REPORT_NAME,FIELD_SEQNO,FIELD_PARAM_NAME)
	NOT DEFERRABLE
	 VALIDATE
)
/
ALTER TABLE ARGOS_API_FIELDS
	ADD (
		FOREIGN KEY(REPORT_NAME) REFERENCES ARGOS_API_FORMS(REPORT_NAME)
	)
/

CREATE TABLE ARGOS_API_OVERRIDES( 
	OVERRIDE_ID    	VARCHAR2(12) NOT NULL,
	OVERRIDE_REPORT	VARCHAR2(24) NOT NULL,
    constraint pk_argos_api_overrides primary key (override_id, override_report))
/

CREATE TABLE ARGOS_API_RPTSEC  ( 
	REPORT_NAME	VARCHAR2(24) NOT NULL,
	CLASS_NAME 	VARCHAR2(30) NOT NULL,
	CONSTRAINT PK_ARGOS_API_RPTSEC PRIMARY KEY(REPORT_NAME,CLASS_NAME)
)
/

CREATE TABLE ARGOS_API_REGEX  ( 
	TEMPLATE_NAME   	VARCHAR2(48) NOT NULL,
	TEMPLATE_PATTERN	VARCHAR2(128) NOT NULL,
	CONSTRAINT PK_ARGOS_API_REGEX PRIMARY KEY(TEMPLATE_NAME)
)
/

INSERT INTO ARGOS_API_REGEX(TEMPLATE_NAME, TEMPLATE_PATTERN)
  VALUES('ALPHA_ONLY', '^[A-Za-z]{1,}$')
/
INSERT INTO ARGOS_API_REGEX(TEMPLATE_NAME, TEMPLATE_PATTERN)
  VALUES('ALPHA_UPPER_ONLY', '^[A-Z]{1,}$')
/
INSERT INTO ARGOS_API_REGEX(TEMPLATE_NAME, TEMPLATE_PATTERN)
  VALUES('ALPHA_LOWER_ONLY', '^[a-z]{1,}$')
/
INSERT INTO ARGOS_API_REGEX(TEMPLATE_NAME, TEMPLATE_PATTERN)
  VALUES('NUMERIC_ONLY', '^[0-9]{1,}$')
/
INSERT INTO ARGOS_API_REGEX(TEMPLATE_NAME, TEMPLATE_PATTERN)
  VALUES('ALPHANUM_ONLY', '^[A-Za-z0-9]{1,}$')
/
INSERT INTO ARGOS_API_REGEX(TEMPLATE_NAME, TEMPLATE_PATTERN)
  VALUES('ALPHA_SEARCH', '(^[%]{1}[A-Za-z]{1,}$)|(^[A-Za-z]{1,}[%]{1}$)')
/
INSERT INTO ARGOS_API_REGEX(TEMPLATE_NAME, TEMPLATE_PATTERN)
  VALUES('DATE_SHORT', '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$')
/

CREATE TABLE ARGOS_API_METRICS  ( 
	REPORT_NAME      	VARCHAR2(24) NOT NULL,
	RUN_DATE         	DATE DEFAULT sysdate NULL,
	USER_AGENT_STRING	VARCHAR2(512) NOT NULL,
	QUERY_STRING     	CLOB NULL 
)
/

CREATE INDEX IDX_ARGOS_API_METRICS
	ON LUMINIS_WEB.ARGOS_API_METRICS(REPORT_NAME, RUN_DATE)
/

CREATE INDEX IDX_ARGOS_API
	ON LUMINIS_WEB.ARGOS_API_FORMS(REPORT_NAME, REPORT_TITLE, REPORT_CATEGORY, REPORT_ROLE)
/

CREATE TRIGGER T_FHDA_ARGOS_CLEAN_METRICS
AFTER
insert
ON argos_api_metrics
BEGIN    
    delete from argos_api_metrics where run_date < (sysdate - 365);
END;
/


CREATE TRIGGER T_FHDA_ARGOS_FORMS_AUDIT
BEFORE
update
ON argos_api_forms
FOR EACH ROW
BEGIN    
    :new.record_username := user;
    :new.record_activity_date := sysdate;
END;
/

create or replace type varchar2_list as table of varchar2(128)
/

CREATE OR REPLACE PACKAGE ARGOS_WEB_V2 as

    -- Constants
    maps_api_url        constant    varchar2(64) := 'YOUR_ARGOS_SERVER';
    maps_api_referrer   constant    varchar2(64) := 'VALID_MAPS_REFERRER';

    -- Core procedures
    procedure P_MyReports;
    procedure P_RenderForm(api_report varchar2 default null);
    procedure P_RefreshDynamicList(rpt varchar2, field varchar2, dynamic_val varchar2);

    -- General utility procedures and functions
    procedure P_WriteSubheading(text varchar2);
    procedure P_WriteFriendlyError;
    function F_GetCollectionSize(collection varchar2_list) return number;

    -- Widget rendering
    procedure P_RenderField(rec_field argos_api_fields%ROWTYPE);
    procedure P_RenderTextInput(field argos_api_fields%ROWTYPE);
    procedure P_RenderValueList(field argos_api_fields%ROWTYPE);
    procedure P_RenderBoolean(field argos_api_fields%ROWTYPE);
    function F_ProcessRegex(regex_pattern varchar2) return varchar2;

    -- HTTP API execution
    procedure P_ExecuteReport(req varchar2, api_name varchar2);
    procedure P_FetchReport(req varchar2, report_filename varchar2, format varchar2);

    -- Cursors 
    cursor crsr_myreports(user_pidm number) is
        select            
            nvl(report_category, 'Specialty') as category,
            report_name,
            report_title  
        from
            argos_api_forms,
            spriden,
            gobeacc    
        where
            -- Setup joins to SPRIDEN and GOBEACC    
            spriden_pidm = user_pidm
            and spriden_change_ind is null
            and gobeacc_pidm(+) = spriden_pidm
            and (
                (argos_web_v2.F_GetCollectionSize(
                    (
                        -- Group primary role and alternate roles into one collection
                        cast(multiset(select class_name from argos_api_rptsec where argos_api_rptsec.report_name = argos_api_forms.report_name) as varchar2_list)
                        multiset union
                        cast(multiset(select report_role from dual) as varchar2_list)
                    )
                    -- Compare with users assigned classes
                    multiset intersect
                    cast(multiset(select gurucls_class_code from bansecr.gurucls where gurucls_userid = gobeacc.gobeacc_username) as varchar2_list)
                    ) > 0)   
                -- Check for a valid override record
                or
                exists (select 1 from argos_api_overrides where override_report = argos_api_forms.report_name and override_id = spriden_id)
            )
        order by
            report_category asc;

    -- CRSR_REPORTFIELDS => Select all field records in sequence order for rendering
    cursor crsr_reportfields(api_report_name varchar2) is
        select * from argos_api_fields where argos_api_fields.report_name = api_report_name order by field_seqno asc;

    -- Types
    type argos_report_list is table of crsr_myreports%ROWTYPE index by pls_integer;
    type argos_fieldset is table of argos_api_fields%ROWTYPE index by pls_integer;
    type table_list_values is table of varchar2(128);

end argos_web_v2;
/
CREATE OR REPLACE PACKAGE BODY ARGOS_WEB_V2 as
    
    --------------------------------------------------------------------------------------------------------------------
    -- CORE PROCEDURES
    --------------------------------------------------------------------------------------------------------------------

    procedure P_MyReports as
        lv_identity         number;
        lv_reports          argos_report_list; 
        lv_categories       varchar2_list   := varchar2_list();
    begin
        -- Validate user access to this package
        if not twbkwbis.f_validuser(pidm => lv_identity, close_http_header => true, check_only => true) then
            return;
        end if;

        -- Query for reports accessible to the user
        open crsr_myreports(lv_identity);
        fetch crsr_myreports bulk collect into lv_reports;
        close crsr_myreports;

        -- Reduce report list into distinct categories
        for idx in lv_reports.first .. lv_reports.last loop
            if lv_reports(idx).category not member of lv_categories then
                lv_categories.extend;
                lv_categories(lv_categories.last) := lv_reports(idx).category;
            end if;
        end loop;

        -- Open application
        twbkwbis.P_OpenDoc(
            name => 'argos_web_v2.P_MyReports',
            header_text => '<br/><span style="color:#666666;font-size:13px;">Browse and execute Argos reports</span>'
        );

        -- Inject JavaScript
        htp.p('
        <script type="text/javascript" src="/argosapi/shadowbox/shadowbox.js"></script>
        <script type="text/javascript">
            Shadowbox.init({
                skipSetup: true
            });  
            console.log("Shadowbox Initialized");
        </script>
        ');

        -- Inject CSS
        htp.p('        
        <link rel="stylesheet" type="text/css" href="/argosapi/shadowbox/shadowbox.css" media="screen" />
        <style type="text/css">                  
            a.report-link:link { color: steelblue; }
            a.report-link:active { color: steelblue; }
            a.report-link:visited { color: steelblue; }
            a.report-link:hover { color: dodgerblue; }
            div.icon { padding-left: 22px; background-repeat: no-repeat; background-position: left center; }
            div.reports-list { line-height: 20px; }
            div.category-root { font-weight: bold; background-image: url(/argosapi/folder_page.png); }
            div.report { margin-left: 15px; background-image: url(/argosapi/page_gear.png); }                        
        </style>');
        htp.p('<p>');

        -- Group into DIV block
        htp.p('<div class="reports-list">');

        -- Iterate through report categories
        for idx in lv_categories.first .. lv_categories.last loop
            -- Print category
            htp.p('<div class="category-root icon">' || lv_categories(idx) || '</div>');

            -- Iterate through reports and locate only the reports for this category
            for idxb in lv_reports.first .. lv_reports.last loop
                if lv_reports(idxb).category = lv_categories(idx) then
                    htp.p('<div class="report icon"><a class="report-link" href="argos_web_v2.P_RenderForm?api_report=' || lv_reports(idxb).report_name || '">' || lv_reports(idxb).report_title || '</a></div>');
                end if;
            end loop;
        end loop;

        -- End DIV block
        htp.p('</div>');

        -- Script to process report links
        htp.p('
        <script type="text/javascript">
            Shadowbox.setup(''a.report-link'', {
                title: ''<img src="/argosapi/argos_logo_30h.png" />'',
                displayCounter: false,
                width: 800,
                height: 650,
                enableKeys: false,
                overlayOpacity: 0.75,
                fadeDuration: 0.2,
                resizeDuration: 0.2
            });
            console.log("Shadowbox Binding Completed");
        </script>
        ');

        -- Close application
        htp.p('<p>');
        twbkwbis.P_CloseDoc('1.0<br/>Created by Foothill-De Anza Community College District');
    end;

    --------------------------------------------------------------------------------------------------------------------

    procedure P_RenderForm(api_report varchar2 default null) as
        lv_identity             number;
        lv_identity_cwid        spriden.spriden_id%TYPE;
        rec_report              argos_api_forms%ROWTYPE;
        report_fields           argos_fieldset;
    begin
        -- Validate user access to this package
        if not twbkwbis.f_validuser(pidm => lv_identity, close_http_header => true, check_only => true) then
            return;
        end if;

        -- Get the user CWID
        select spriden_id into lv_identity_cwid from spriden where spriden_pidm = lv_identity and spriden_change_ind is null;

        -- Get the associated API definition
        select * into rec_report from argos_api_forms where report_name = api_report;

        -- Get the associated field definitions
        open crsr_reportfields(api_report);
        fetch crsr_reportfields bulk collect into report_fields;
        close crsr_reportfields;

        -- Set HTML5 strict doctype
        htp.p('<!DOCTYPE html>');

        -- BEGIN HTML
        htp.p('<html>');

        -- BEGIN page header
        htp.p('<head>');
            -- Configure dependencies (JS + CSS)
            htp.p('<script type="text/javascript" src="/argosapi/jquery-1.6.2.min.js"></script>');
            htp.p('<script type="text/javascript" src="/argosapi/jquery.base64.min.js"></script>');
            htp.p('<script type="text/javascript" src="/argosapi/jquery.form.js"></script>');
            htp.p('<script type="text/javascript" src="/argosapi/P_RenderForm.js"></script>');
            htp.p('<link href="/argosapi/P_RenderForm.css" rel="stylesheet" type="text/css" />');
            htp.p('<script type="text/javascript">');
                htp.p('var argos = {reportName: ''' || rec_report.report_name || '''};');
            htp.p('</script>');
        htp.p('</head>');
        -- END page header

        -- BEGIN page body
        htp.p('<body>');
            -- Create header
            htp.p('<div id="layout-header" class="layout-fixed-item">');
                htp.p('<img src="/argosapi/application_form.png" style="vertical-align: text-bottom;" />&nbsp; ');
                htp.p(rec_report.report_title);
            htp.p('</div>');

            -- Create body region
            htp.p('<div id="layout-body" class="layout-fixed-item">');
                -- Create padded container to preserve dimensions
                htp.p('<div id="layout-body-container">');
                    -- Report description      
                    htp.p(rec_report.report_desc);

                    -- Create FORM tag and required inputs
                    htp.p('<form id="maps-api-form">');
                    htp.p('<input type="hidden" name="report" value="' || rec_report.report_apikey || '" />');
                    htp.p('<input type="hidden" name="reportformat" value="pdf" />');  

                    -- Add personalization information
                    if rec_report.report_enable_cwid = 'Y' then
                        htp.p('<input type="hidden" name="UserCWID" value="' || lv_identity_cwid || '" />');
                    end if;

                    if rec_report.report_enable_pidm = 'Y' then
                        htp.p('<input type="hidden" name="UserPIDM" value="' || lv_identity || '" />');
                    end if;

                    -- Are there fields defined?                    
                    if report_fields.count > 0 then
                        -- Create the "Options" container
                        htp.p('<p>');                       
                        htp.p('<table id="tbl-report-opts" cellspacing="0" cellpadding="0">');
                            -- Header
                            htp.p('<tr>');
                                htp.p('<th>Options</th>');
                            htp.p('</tr>');

                            -- Iterate through the field objects and render the widgets
                            for idx in report_fields.first .. report_fields.last loop   
                                htp.p('<!-- ' || report_fields(idx).field_seqno || ': ' || report_fields(idx).field_param_name || '-->');
                                if report_fields(idx).field_disabled <> 'Y' then
                                    htp.p('<tr>');
                                        htp.p('<td>');
                                            P_RenderField(report_fields(idx));
                                        htp.p('</td>');
                                    htp.p('</tr>');
                                end if;
                            end loop;

                        htp.p('</table>');
                    end if;
                    htp.p('</form>');

                    -- Create helper IFRAME for managing downloads
                    htp.p('<iframe id="api-frame" style="display: none;"></iframe>');                    
                htp.p('</div>');
            htp.p('</div>');

            -- Create footer
            htp.p('<div id="layout-footer" class="layout-fixed-item">');
                -- Create row of buttons
                htp.p('<table id="format-buttons">');
                    htp.p('<tr>');
                        if rec_report.report_pdf_flag = 'Y' then
                            htp.p('<td class="format-pdf">');
                                htp.p('<a href="javascript:executeReport(''pdf'')">Download PDF</a>');
                            htp.p('</td>');
                        end if;

                        if rec_report.report_xls_flag = 'Y' then
                            htp.p('<td class="format-xls">');
                                htp.p('<a href="javascript:executeReport(''xls'')">Download Excel</a>');
                            htp.p('</td>');                            
                        end if;

                        if rec_report.report_csv_flag = 'Y' then
                            htp.p('<td class="format-csv">');
                                htp.p('<a href="javascript:executeReport(''csv'')">Download CSV</a>');
                            htp.p('</td>');                            
                        end if;
                    htp.p('</tr>');
                htp.p('</table>');
            htp.p('</div>');

            -- Create loading curtain
            htp.p('<table id="Curtain">');
                htp.p('<tr><td>');
                    htp.p('<b><img src="/argosapi/report-loader.gif" style="vertical-align:text-top;" /> &nbsp;&nbsp;Creating Report...</b>');
                    htp.p('<p>');
                    htp.p('<div style="position:relative;width:250px;left:50%;text-align:left;margin-left:-125px">');
                    htp.p('Depending on the report content, this may take a few seconds. Please wait patiently.');
                    htp.p('</div>');
                htp.p('</td></tr>');
            htp.p('</table>');

            -- Create ready curtain (for iOS/mobile devices only)
            htp.p('<table id="ReadyCurtain">');
                htp.p('<tr><td>');
                    htp.p('<img src="/argosapi/accept.png" style="vertical-align:text-top;" />');
                    htp.p('<br/><br/>');
                    htp.p('<a id="ReadyCurtain_Href" href="#" onclick="$(''#ReadyCurtain'').fadeOut(150);" target="_blank">Click to Download Report</a>');
                htp.p('</td></tr>');
            htp.p('</table>');

            -- Create error curtain
            htp.p('<table id="ErrorCurtain">');
                htp.p('<tr><td>');
                    htp.p('<b><img src="/argosapi/error.png" style="vertical-align:text-top;" /> &nbsp;&nbsp;Error!</b>');
                    htp.p('<p>');
                    htp.p('<div style="position:relative;width:500px;left:50%;text-align:left;margin-left:-250px">');
                    htp.p('A serious problem occurred while trying to execute this report. Please contact the report author for assistance.');
                    htp.p('</div>');
                htp.p('</td></tr>');
            htp.p('</table>');            

            -- Create curtain for validation errors
            htp.p('<table id="ValidationCurtain">');
                htp.p('<tr><td>');
                    htp.p('<b><img src="/argosapi/textfield_delete.png" style="vertical-align:text-top;" /> &nbsp;&nbsp;Found a problem!</b>');
                    htp.p('<p>');
                    htp.p('<div id="ValidationMsg" style="position:relative;width:500px;left:50%;text-align:left;margin-left:-250px">');
                    htp.p('Message.');
                    htp.p('</div>');
                    htp.p('<p>');
                    htp.p('<div style="position:relative;width:500px;left:50%;text-align:left;margin-left:-250px">');
                    htp.p('<button type="button" onclick="$(''#ValidationCurtain'').fadeOut(150);">Back to Form</button>');
                    htp.p('</div>');
                htp.p('</td></tr>');
            htp.p('</table>');  

        htp.p('</body>');
        -- END page body

        -- END HTML
        htp.p('</html>');
    exception
        when others then
            P_WriteFriendlyError;
    end;

    --------------------------------------------------------------------------------------------------------------------

    procedure P_RefreshDynamicList(rpt varchar2, field varchar2, dynamic_val varchar2) as
        lv_identity         number;
        rec_field           argos_api_fields%ROWTYPE;

        -- Dynamic SQL execution        
        value_list  table_list_values;
        label_list  table_list_values;
    begin
        -- Validate user access to this package
        if not twbkwbis.f_validuser(pidm => lv_identity, close_http_header => true, check_only => true) then
            return;
        end if;

        -- Get the field record
        select * into rec_field from argos_api_fields where report_name = rpt and field_param_name = field;

        -- Execute the SQL with the bound variable
        execute immediate rec_field.field_sql bulk collect into value_list, label_list using dynamic_val;

        -- Write back option list (w/ optional initial message)
        if rec_field.field_initmsg is not null then
            htp.p('<option value="">' || rec_field.field_initmsg || '</option>');
        end if;        
           
        if value_list.count > 0 then
            for idx in value_list.first .. value_list.last loop
                if idx = value_list.first then
                    htp.p('<option value="' || value_list(idx) || '">' || value_list(idx) || ' - ' || label_list(idx) || '</option>');
                else 
                    htp.p('<option value="' || value_list(idx) || '">' || value_list(idx) || ' - ' || label_list(idx) || '</option>');
                end if;
            end loop;
        end if;
    exception
        when others then
            P_WriteFriendlyError;
    end;

    --------------------------------------------------------------------------------------------------------------------
    -- GENERAL UTILITY PROCEDURES AND FUNCTIONS
    --------------------------------------------------------------------------------------------------------------------

    procedure P_WriteSubheading(text varchar2) as
    begin
        htp.p('<span class="text-subheading">');
            htp.p(text || '<br/>');
        htp.p('</span>');
    end;

    procedure P_WriteFriendlyError as
    begin
        -- Create a "friendly" error message
        htp.p('<div id="util-error" style="padding:5px;border:1px solid #bebebe;background-color:#eaeaea;font-size:11px;font-family:sans-serif;">');
            htp.p('<img src="/argosapi/script_error.png" style="vertical-align:text-top" />');
            htp.p('<b>SQL Error</b><br/>');
            htp.p('<div style="font-family: monospace;margin-top:5px;">');
                htp.p(replace(dbms_utility.format_error_stack, chr(10), '<br/>'));
                htp.p(replace(dbms_utility.format_error_backtrace, chr(10), '<br/>'));
            htp.p('</div>');
        htp.p('</div>');
    end;

    function F_GetCollectionSize(collection varchar2_list) return number as
    begin
        return collection.count;
    end;

    --------------------------------------------------------------------------------------------------------------------
    -- WIDGET RENDERING PROCEDURES
    --------------------------------------------------------------------------------------------------------------------

    procedure P_RenderField(rec_field argos_api_fields%ROWTYPE) as
    begin
        -- Render the label and comments
        if rec_field.field_required = 'Y' then
            htp.p('<img src="/argosapi/bullet_red.png" style="vertical-align:text-top" /><b>' || rec_field.field_label || '</b><br/>');
        else
            htp.p('<img src="/argosapi/bullet_blue.png" style="vertical-align:text-top" /><b>' || rec_field.field_label || '</b><br/>');
        end if;
        
        -- Conditionally render comments
        if rec_field.field_comments is not null then
            htp.p('<i>' || rec_field.field_comments || '</i><br/>');
        end if;

        -- Based on the field type, defer to another procedure to render the widget
        if rec_field.field_type = 'INPUT' then
            P_RenderTextInput(rec_field);
        elsif rec_field.field_type = 'VALLIST' then
            P_RenderValueList(rec_field);
        elsif rec_field.field_type = 'BOOLEAN' then
            P_RenderBoolean(rec_field);
        end if;

        -- Space out with a paragraph
        htp.p('<p>');
    exception
        when others then
            htp.p(dbms_utility.format_error_stack);
            htp.p('<br/>');
            htp.p(dbms_utility.format_error_backtrace);
    end;

    --------------------------------------------------------------------------------------------------------------------
    
    procedure P_RenderTextInput(field argos_api_fields%ROWTYPE) as
    begin
        htp.p('<input type="text" name="' || field.field_param_name || '" value="" fieldlabel="' || replace(field.field_label, ':') || '" regex="' || F_ProcessRegex(field.field_regex) || '" regex_err="' || field.field_regex_errmsg || '" required="' || field.field_required ||'" />');        
    exception
        when others then
            htp.p(dbms_utility.format_error_stack);
            htp.p('<br/>');
            htp.p(dbms_utility.format_error_backtrace);
    end;

    --------------------------------------------------------------------------------------------------------------------

    procedure P_RenderValueList(field argos_api_fields%ROWTYPE) as
        -- Dynamic SQL execution        
        value_list  table_list_values;
        label_list  table_list_values;

        -- HTML select statement
        html_select varchar2(512) := '<select name="%NAME%" fieldlabel="%LABEL%" %MULTIPLESEL% required="%REQUIRED%" %BINDING% %BINDING_AUTO% initmsg="%INITMSG%">';
    begin
        -- Process HTML select statement based on field configuration
        html_select := replace(html_select, '%NAME%', field.field_param_name);

        -- Set up field label
        html_select := replace(html_select, '%LABEL%', replace(field.field_label, ':'));

        -- Accepts multiple selections?
        if field.field_multiplesel = 'Y' then
            html_select := replace(html_select, '%MULTIPLESEL%', 'size="5" multiple="multiple"');
        else
            html_select := replace(html_select, '%MULTIPLESEL% ');
        end if;

        -- Is required?
        html_select := replace(html_select, '%REQUIRED%', field.field_required);

        -- Has dynamic AJAX binding?
        if field.field_binding is not null then
            html_select := replace(html_select, '%BINDING%', 'binding="' || field.field_binding || '"');
        else
            html_select := replace(html_select, '%BINDING% ');
        end if;  

        -- Should the binding execute on first run?
        if field.field_binding_auto = 'Y' then
            html_select := replace(html_select, '%BINDING_AUTO%', 'binding_auto="Y"');
        else
            html_select := replace(html_select, '%BINDING_AUTO% ');
        end if; 

        -- Has an initial message?
        if field.field_initmsg is not null then
            html_select := replace(html_select, '%INITMSG%', field.field_initmsg);
        else
            html_select := replace(html_select, '%INITMSG%');
        end if;         

        htp.p(html_select);      

        -- If an SQL statement is available, and this widget is not event-bound then populate with results from the query          
        if field.field_sql is not null and field.field_binding is null then
            if field.field_initmsg is not null then
                htp.p('<option value="">' || field.field_initmsg || '</option>');
            end if;

            execute immediate field.field_sql bulk collect into value_list, label_list;
            for idx in value_list.first .. value_list.last loop
                if idx = value_list.first then
                    htp.p('<option value="' || value_list(idx) || '">' || value_list(idx) || ' - ' || label_list(idx) || '</option>');
                else 
                    htp.p('<option value="' || value_list(idx) || '">' || value_list(idx) || ' - ' || label_list(idx) || '</option>');
                end if;
            end loop;
        end if;
        htp.p('</select>');
    exception
        when others then
            htp.p(dbms_utility.format_error_stack);
            htp.p('<br/>');
            htp.p(dbms_utility.format_error_backtrace);
    end;

    --------------------------------------------------------------------------------------------------------------------

    procedure P_RenderBoolean(field argos_api_fields%ROWTYPE) as
    begin
        htp.p('<select name="' || field.field_param_name || '" fieldlabel="' || replace(field.field_label, ':') || '" style="width: 100px;">');
            htp.p('<option value="N">No</option>');
            htp.p('<option value="Y">Yes</option>');
        htp.p('</select');
    exception
        when others then
            htp.p(dbms_utility.format_error_stack);
            htp.p('<br/>');
            htp.p(dbms_utility.format_error_backtrace);
    end;

    --------------------------------------------------------------------------------------------------------------------

    function F_ProcessRegex(regex_pattern varchar2) return varchar2 as        
        lv_template     varchar2(128);
    begin
        -- Is this a template?
        if regex_pattern like '<<%>>' then
            -- Search for a pattern based on the template name
            select template_pattern into lv_template from argos_api_regex where template_name = replace(replace(regex_pattern, '<<'), '>>');

            -- Return
            return lv_template;
        end if;

        -- If no template processing, then pass it through
        return regex_pattern;
    exception
        when others then
            return null;
    end;

    --------------------------------------------------------------------------------------------------------------------

    procedure P_ExecuteReport(req varchar2, api_name varchar2) as
        lv_http_req		utl_http.req;
        lv_http_resp	utl_http.resp;  
        lv_argos_url    varchar2(1024);
        lv_identity     number;
    begin
        -- Validate baseline security to access this package
        if not twbkwbis.f_validuser(pidm => lv_identity, close_http_header => false, check_only => true) then
          owa_util.status_line(401, null, true);
        end if;

        -- Create and configure HTTP request
        lv_http_req := utl_http.begin_request(maps_api_url, 'POST');
        utl_http.set_header(lv_http_req, 'Transfer-Encoding', 'chunked');
        utl_http.set_header(lv_http_req, 'Content-Type', 'application/x-www-form-urlencoded');
        utl_http.set_header(lv_http_req, 'Cache-Control', 'no-cache');        
        utl_http.set_header(lv_http_req, 'Referer', maps_api_referrer);

        -- Configure UTL_HTTP
        utl_http.set_detailed_excp_support(true);
        utl_http.set_transfer_timeout(lv_http_req, 120);
        utl_http.set_follow_redirect(lv_http_req, 0);

        -- Apply request parameters to body
        utl_http.write_text(lv_http_req, req);

        -- Execute and return response
        lv_http_resp := utl_http.get_response(lv_http_req);       

        -- If HTTP status 302 is returned, then a report was likely generated
        if lv_http_resp.status_code = 302 then
            owa_util.status_line(200, null, true);
            utl_http.get_header_by_name(lv_http_resp, 'Location', lv_argos_url);
            htp.p(lv_argos_url);
            --dbms_output.put_line(lv_argos_url);
        -- If not, then something went wrong
        else
            -- Pass the HTTP status code through
            owa_util.status_line(lv_http_resp.status_code, null, true);

            -- Return the message from the Argos service back to the user
            begin
                loop
                    utl_http.read_line(lv_http_resp, lv_argos_url, true);
                    htp.p(lv_argos_url);
                end loop;
            exception
                when others then null;
            end;
        end if;

        -- Complete HTTP request
        utl_http.end_response(lv_http_resp);        

        -- Log to metrics table
        insert into argos_api_metrics
        (report_name, query_string, user_agent_string)
        values
        (api_name, req, owa_util.get_cgi_env('HTTP_USER_AGENT'));

    exception
        when others then
            owa_util.status_line(500, null, true);
            htp.p(dbms_utility.format_error_stack);
            htp.p('<br/>');
            htp.p(dbms_utility.format_error_backtrace);
    end;

    --------------------------------------------------------------------------------------------------------------------

    procedure P_FetchReport(req varchar2, report_filename varchar2, format varchar2) as        
        lv_http_req         utl_http.req;
        lv_http_resp        utl_http.resp;  
        lv_resp_length      varchar2(24);
        lv_binary_report    blob;  
        lv_raw              raw(32767);     
        lv_actual_filename  varchar2(96) := lower(report_filename) || '_' || to_char(sysdate, 'MMDDYYYY_HH12MIAM') || '.' || lower(format);
        lv_identity         number;
    begin        
        -- Validate baseline security to access this package
        if not twbkwbis.f_validuser(pidm => lv_identity, close_http_header => false, check_only => true) then
          owa_util.status_line(401, null, true);
        end if;             

        -- Create and configure HTTP request
        lv_http_req := utl_http.begin_request(trim(both chr(10) from req), 'GET');                           
        utl_http.set_header(lv_http_req, 'Referer', maps_api_referrer);                

        -- Execute request, and read in finished file
        dbms_lob.createtemporary(lv_binary_report, false);
        lv_http_resp := utl_http.get_response(lv_http_req);              
        begin
            loop
                utl_http.read_raw(lv_http_resp, lv_raw, 32766);                           
                dbms_lob.writeappend (lv_binary_report, utl_raw.length(lv_raw), lv_raw);
            end loop;
        exception
            when utl_http.end_of_body then
                utl_http.end_response(lv_http_resp);
        end;        
              
        -- Choose an response type based on the report requested            
        if dbms_lob.getlength(lv_binary_report) > 0 then                
            htp.p('Content-Length: ' || dbms_lob.getlength(lv_binary_report));
            if format in ('pdf', 'xls') then            
                htp.p('Content-Type: application/octet-stream');                 
                
            elsif format in ('csv') then
                htp.p('Content-Type: application/csv');                 
            end if;
            htp.p('Content-Disposition: attachment; filename=' || lv_actual_filename);

            -- Return the finished file!
            owa_util.http_header_close;
            wpg_docload.download_file(lv_binary_report);
        else
            owa_util.status_line(500, 'Zero bytes returned from Argos server', true);
        end if;
                      
        dbms_lob.freetemporary(lv_binary_report);
    exception
        when others then
            htp.p('<div style="font-family:Helvetica,Verdana,Arial;font-size:12px;">');
            htp.p('<b>Failed to Download Report from Argos</b>');
            htp.p('<p>');
            htp.p('URL = ' || req);
            htp.p('<p>');
            htp.p(dbms_utility.format_error_stack);
            htp.p('<p>');
            htp.p(dbms_utility.format_error_backtrace);
            htp.p('</div>');
    end;

end argos_web_v2;
/