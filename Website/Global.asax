<%@ Application Language="C#" %>

<script RunAt="server">

    public override void Init()
    {
        base.Init();
    }
    
    public override string GetVaryByCustomString(HttpContext context, string arg)
    {
        if (arg == "authenticated")
        {
            HttpCookie cookie = context.Request.Cookies[FormsAuthentication.FormsCookieName];

            if (cookie != null)
                return cookie.Value;
        }

        return base.GetVaryByCustomString(context, arg);
    }

    public void Application_BeginRequest(object sender, EventArgs e)
    {
        /**********************************************************************
         * After upgrading to ASP.NET Razor 3 or ASP.NET MVC 5, the tilde(~) notation may no longer work 
         * correctly if you are using URL rewrites. The URL rewrite affects the tilde(~) notation in HTML elements 
         * such as <A/>, <SCRIPT/>, <LINK/>, and as a result the tilde no longer maps to the root directory.
         * For example, if you rewrite requests for asp.net/content to asp.net, the href attribute in 
         * <A href="~/content/"/> resolves to /content/content/ instead of /. To suppress this change, 
         * you can set the IIS_WasUrlRewritten context to false in each Web Page or in Application_BeginRequest 
         * in Global.asax. 
         * http://www.asp.net/visual-studio/overview/2012/aspnet-and-web-tools-20131-for-visual-studio-2012
         * http://madskristensen.net/post/url-rewrite-may-break-aspnet-razor-3
         */
        Context.Items["IIS_WasUrlRewritten"] = "false";
        System.Web.WebPages.WebPageHttpHandler.DisableWebPagesResponseHeader = true;

        var application = sender as HttpApplication;
        if (application != null && application.Context != null)
        {
            application.Context.Response.Headers.Remove("Server");
            // http://blogs.msdn.com/b/david.wang/archive/2006/03/29/silly-security-scans.aspx
            // http://stackoverflow.com/questions/3678222/why-cant-the-server-response-header-be-removed-via-web-config-in-iis7
            
        }
    }

    public void Application_OnError()
    {
        var request = HttpContext.Current.Request;
        var exception = Server.GetLastError() as HttpException;
        if (exception == null) return;
        
        //Prevents customError behavior when the request is determined to be an AJAX request.
        if (request["X-Requested-With"] == "XMLHttpRequest" || request.Headers["X-Requested-With"] == "XMLHttpRequest")
        {
            Server.ClearError();
            Response.ClearContent();
            Response.StatusCode = exception.GetHttpCode();
            Response.StatusDescription = exception.Message;
            Response.Write(string.Format("<html><body><h1>{0} {1}</h1></body></html>", exception.GetHttpCode(), exception.Message));
        }
    }
       
</script>
