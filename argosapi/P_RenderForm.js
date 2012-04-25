$(document).ready(function() {
	debug('INFO', 'Argos API integration loaded');
	debug('INFO', 'Detecting bindings...');	
	$('select[binding]').each(function(idx, element) {
		debug('INFO', 'Creating a binding on select#' + element.name + ' to select#' + element.getAttribute('binding'));
		$('select[name="' + element.getAttribute("binding") + '"]').change(function() {			
			refreshDynamicList(element, this.value);
		});
		// Should we auto execute this binding definition?
		if(element.getAttribute('binding_auto') == 'Y') {
			debug('INFO', 'Auto-firing first run binding');
			refreshDynamicList(element, $('select[name="' + element.getAttribute("binding") + '"]').val());
		}
	});
	
	// Disable the ENTER key to prevent accidents
    $("#maps-api-form").keypress(function(eventObj) {
        if (eventObj.keyCode == 13) {
            return false;
		}
	});
	
	// Configure AJAX error handling to display the details
	$("#ErrorCurtain").ajaxError(function(event, request, settings) {
		$('#Curtain').fadeOut(150);		
		$(this).fadeIn(150);
	});
});

function debug(type, message) {
	// If a console object is available, log this message to it
	if(window.console && type) {
		console.log('[' + type + '] ' + message);
	}
	else if(window.console) {
		console.log(message);
	}
}

function executeReport(rptformat) {
	var validationSuccessful = true;
	// Validate that all fields have some kind of a value
	$('input[type="text"], select').each(function(idx, element) {
		if(element.getAttribute('required') === 'Y') {
			if(element.value.length < 1 || element.value === null) {
				// If this branch is reached, then a required value is missing
				$('#ValidationMsg').html('The field <b>' + element.getAttribute('fieldlabel') + '</b> is required, and cannot be empty or unselected');			
				$('#ValidationCurtain').fadeIn(150);
				validationSuccessful = false;
				return false;				
			}
		}
	});
	
	// Were all required values supplied? If not, exit function
	if(!(validationSuccessful)) {
		return;
	}
	
	// Validate input fields if a regular expression is provided	
	$('input[type="text"]').each(function(idx, element) {
		// Is a regular expression provided? If not skip, this element
		if(element.getAttribute('regex').length < 1) {
			return true;
		}
		
		// Compile a new regex object
		var fieldRegex = new RegExp(element.getAttribute('regex'));
		
		// Validate
		if(!(fieldRegex.test(element.value))) {
			// If this branch is reached - valiadation failed
			// Alert the user
			$('#ValidationMsg').html(element.getAttribute('regex_err'));			
			$('#ValidationCurtain').fadeIn(150);
			validationSuccessful = false;
			return false;
		}
	});
	
	// Did validation above pass?
	if(validationSuccessful) {
		// Configure report format
		$('#maps-api-form input[name="reportformat"]').val(rptformat);
		
		// Send an execution order, and then download the finished file
		$('#Curtain').fadeIn(150);
		$.post('argos_web_v2.P_ExecuteReport', {'req': decodeURIComponent($('#maps-api-form').formSerialize()), 'api_name': argos.reportName}, function(report_url) {
			var downloadSvc = 'argos_web_v2.P_FetchReport?req=%REQ%&report_filename=%FILENAME%&format=%FMT%';
			downloadSvc = downloadSvc.replace('%REQ%', encodeURIComponent(report_url));
			downloadSvc = downloadSvc.replace('%FILENAME%', encodeURIComponent(argos.reportName));
			downloadSvc = downloadSvc.replace('%FMT%', encodeURIComponent(rptformat));
			
			// Detect iOS devices and open document using a new window/tab
			// All other devices/platforms open inline
			if((navigator.userAgent.match(/iPhone/i)) || (navigator.userAgent.match(/iPod/i)) || (navigator.userAgent.match(/iPad/i))) {
				debug('INFO', 'iOS Device Detected'); 				
				/*
				 * We have to open the PDF in a seperate window or otherwise it is disruptive to the end user using their iOS device.
				 * Mobile Safari security dictates that window.open(...) will not work outside of a user triggered event.
				 * When an "iDevice" is detected, we use a special curtain to ask the user to download their PDF, and configure the link
				 * that appears so their touch event triggers a new window.
				 */
				$('#Curtain').fadeOut(150);
				$('#ReadyCurtain_Href').attr('href', downloadSvc);
				$('#ReadyCurtain').fadeIn(150);
			}
			else {
				window.location = downloadSvc;
				$('#Curtain').fadeOut(150);
			}			
		});		
	}
}

function refreshDynamicList(select_element, dyn_value) {
	// Obtain a refreshed value list
	$.post('argos_web_v2.P_RefreshDynamicList', {rpt: argos.reportName, field: select_element.name, dynamic_val: dyn_value}, function(bannerResult) {
		// Update the HTML
		$(select_element).html(bannerResult);
		
		// Reset any widgets bound this element
		var boundElement = $('select[binding="' + select_element.name + '"]').html('<option>' + boundElement.attr('initmsg') + '</option>');
	});	
}

function reportReadyEvent(iframe_element) {
	console.dir(iframe_element);
}