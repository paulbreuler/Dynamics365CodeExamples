"use strict";
var Sdk = window.Sdk || {};

var orgServicePath = "/XRMServices/2011/Organization.svc/web";

Sdk.getClientUrl = function () {
    var context;

    if (typeof GetGlobalContext != "undefined") {
        context = GetGlobalContext();
    } else {
        if (typeof Xrm != "undefined") {
            // Xrm.Page.context defined within the Xrm.Page object model for form scripts.
            context = Xrm.Page.context;
        } else {
            throw new Error("Context is not available.");
        }
    }
    return context.getClientUrl();
}

/**
 * @function Sdk.RetrieveAttributeChangeHistoryRequest
 * @description SOAP request for RetrieveAttributeChangeHistory through Dynamics 365 organzation web service
 */
Sdk.RetrieveAttributeChangeHistoryRequest = function () {
    var request = new XMLHttpRequest();

    request.open("POST", Sdk.getClientUrl() + orgServicePath, true)

    // Request Headers
    request.setRequestHeader("Accept", "application/xml, text/xml, */*");
    request.setRequestHeader("Content-Type", "text/xml; charset=utf-8");
    request.setRequestHeader("SOAPAction", "http://schemas.microsoft.com/xrm/2011/Contracts/Services/IOrganizationService/Execute");

    // Callback handlers
    var successCallback = null;
    var errorCallback = null;

    request.onreadystatechange = function () { Sdk.RetrieveAttributeChangeHistoryResponse(request, successCallback, errorCallback); };

    var requestBody = []
    requestBody.push("<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">");
    requestBody.push("<s:Body>");
    requestBody.push("<Execute xmlns=\"http://schemas.microsoft.com/xrm/2011/Contracts/Services\">");
    requestBody.push("<request i:type=\"c:RetrieveRecordChangeHistoryRequest\" xmlns:b=\"http://schemas.microsoft.com/xrm/2011/Contracts\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:c=\"http://schemas.microsoft.com/crm/2011/Contracts\">");
    requestBody.push("<b:Parameters xmlns:d=\"http://schemas.datacontract.org/2004/07/System.Collections.Generic\">");
    requestBody.push("<b:KeyValuePairOfstringanyType>");
    requestBody.push("<d:key>Target</d:key>");
    requestBody.push("<d:value i:type=\"b:EntityReference\">");
    requestBody.push("<b:Id>02c6367e-c4f4-e711-a952-000d3a1a9407</b:Id>"); // ID
    requestBody.push("<b:KeyAttributes xmlns:e=\"http://schemas.microsoft.com/xrm/7.1/Contracts\"/>");
    requestBody.push("<b:LogicalName>contact</b:LogicalName>"); // Entity logical Name
    requestBody.push("<b:Name i:nil=\"true\"/>");    
    requestBody.push("</d:value>");
    requestBody.push("</b:KeyValuePairOfstringanyType>");
    requestBody.push("</b:Parameters>");
    requestBody.push("<b:RequestId i:nil=\"true\"/>");
    requestBody.push("<b:RequestName>RetrieveRecordChangeHistory</b:RequestName>");
    requestBody.push("</request>");
    requestBody.push("</Execute>");
    requestBody.push("</s:Body>");
    requestBody.push("</s:Envelope>");

    request.send(requestBody.join(""));
}

/**
 * @function Sdk.RetrieveAttributeChangeHistoryResponse
 * @description Helper function to handle XMLHttpRequest call response.
 * @param {XMLHttpRequest} request - The XMLHttpRequest
 * @param {string} successCallback - The funtion to call on success
 * @param {object} errorCallback - The funtion to call on success
 */
Sdk.RetrieveAttributeChangeHistoryResponse = function (request, successCallback, errorCallback) {
    if (request.readyState == 4) {
        if (request.status == 200) {
            if (successCallback != null) {
                successCallback(request);
            }
            else {
                console.log(request.responseXML);
            }
        }
        else {
            console.log(Sdk._getError(request.responseXML));  
        }
    }
}

/**
 * @function Sdk._getError
 * @description Parses the fault returned in the event of an error.
 * @param {XML} faultXml - The responseXML property of the XMLHttpRequest response.
 * @returns faultstring from XML response
 */
Sdk._getError = function (faultXml) {
    var errorMessage = "Unknown Error in Sdk._getError: (Unable to parse faultXml)";
    
    if (typeof faultXml == "object") {
        try {			
               errorMessage = faultXml.getElementsByTagName("faultstring")["0"].textContent;
        }
        catch (e) { };
    }
    return new Error(errorMessage);
}