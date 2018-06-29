using System;
using System.Threading;
using System.Threading.Tasks;
using Xrm.Tools.WebAPI;
using Microsoft.IdentityModel.Clients.ActiveDirectory;

/*
    This is a simple boiler plate to jumpstart development of a .NET core based Dynamics 365 CE app.
    Using https://github.com/davidyack/Xrm.Tools.CRMWebAPI, which supports JS, .NET, .NET Core 
    and .NET Standard projects, Nodejs, php and Python.
 */
namespace Dynamics365NetCoreConsoleAppTemplate
{
    class Program
    {
        static void Main(string[] args)
        {

            var response = GetAPI();
            response.Wait();

            CRMWebAPI api = response.Result;

            Task.Run(async () =>
            {
                Xrm.Tools.WebAPI.Results.CRMGetListResult<System.Dynamic.ExpandoObject> results = await GetAccounts(api);
                dynamic result = results.List[0];
                Console.WriteLine($"Name: {result.name}\nID: {result.accountid}");
            }).Wait();

        }


        // Authenticate via Azure AD and return CRMWepAPI.
        public static async Task<CRMWebAPI> GetAPI()
        {
            /*
            Must create an application user in CRM. First create a user in Azure AD, then 
            change the user view to Application User in CRM and click New. Paste in you 
            application ID and fill in the required fields. On save other fields are populated.
            Good reference: https://www.youtube.com/watch?v=Td7Bk3IXJ9s 
            */
            string authority = "https://login.microsoftonline.com/";
            string clientId = "<clientId>";
            string crmBaseUrl = "https://contoso.crm.dynamics.com";
            string clientSecret = "<clientSecret>";
            string tenantId = "<tenantId>";

            var clientcred = new ClientCredential(clientId, clientSecret);
            var authContext = new AuthenticationContext(authority + tenantId);
            var authenticationResult = await authContext.AcquireTokenAsync(crmBaseUrl, clientcred);

            /*
             Set API version to desired version. URL can be found in CRM under Settings > Customizations > Developer Resources
             Look for "Instance Web API"
             */
            return new CRMWebAPI(crmBaseUrl + "/api/data/v9.0/", authenticationResult.AccessToken);
        }

        // Retrieve all accounts
        public static async Task<Xrm.Tools.WebAPI.Results.CRMGetListResult<System.Dynamic.ExpandoObject>> GetAccounts(CRMWebAPI api)
        {
            var results = await api.GetList("accounts",
                     new Xrm.Tools.WebAPI.Requests.CRMGetListOptions() { TrackChanges = true, FormattedValues = true });

            return results;
        }
    }

}
