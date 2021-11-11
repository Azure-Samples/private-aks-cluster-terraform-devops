#region Copyright
//=======================================================================================
// Microsoft 
//
// This sample is supplemental to the technical guidance published on my personal
// blog at https://github.com/paolosalvatori. 
// 
// Author: Paolo Salvatori
//=======================================================================================
// Copyright (c) Microsoft Corporation. All rights reserved.
// 
// LICENSED UNDER THE APACHE LICENSE, VERSION 2.0 (THE "LICENSE"); YOU MAY NOT USE THESE 
// FILES EXCEPT IN COMPLIANCE WITH THE LICENSE. YOU MAY OBTAIN A COPY OF THE LICENSE AT 
// http://www.apache.org/licenses/LICENSE-2.0
// UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING, SOFTWARE DISTRIBUTED UNDER THE 
// LICENSE IS DISTRIBUTED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
// KIND, EITHER EXPRESS OR IMPLIED. SEE THE LICENSE FOR THE SPECIFIC LANGUAGE GOVERNING 
// PERMISSIONS AND LIMITATIONS UNDER THE LICENSE.
//=======================================================================================
#endregion

#region Using Directives
using System;
using System.Linq;
using System.Collections.Generic;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Primitives;
#endregion

namespace SyntheticApi.Models
{
    public class RequestData
    {
        #region Public Constructor
        public RequestData(HttpRequest request)
        {
            ContentType = request.ContentType;
            ContentLength = request.ContentLength;
            Headers = request.Headers.Select(h => h).ToList();
            Host = request.Host;
            IsHttps = request.IsHttps;
            MachineName = Environment.MachineName;
            Method = request.Method;
            Path = request.Path;
            PathBase = request.PathBase;
            Protocol = request.Protocol;
            QueryString = request.QueryString.ToString();
            Scheme = request.Scheme;
        }
        #endregion

        #region Public Properties
        // Gets the machine name
        public string MachineName { get; private set; }

        // Gets or sets the Host header.May include the port
        public HostString Host { get; private set; }

        // Returns true if the RequestScheme is https.
        public bool IsHttps { get; private set; }

        // Gets or sets the HTTP method.
        public string Method { get; private set; }

        // Gets or sets the request path from RequestPath
        public string Path { get; private set; }

        // Gets or sets the RequestPathBase
        public string PathBase { get; private set; }

        // Gets or sets the request protocol(e.g.HTTP/1.1)
        public string Protocol { get; private set; }

        // Gets or sets the raw query string used to create the query collection in Request.Query
        public string QueryString { get; private set; }

        // Gets or sets the HTTP request scheme
        public string Scheme { get; private set; }

        //Specifies the length, in bytes, of content sent by the client
        public long? ContentLength { get; private set; }

        // Gets or sets the MIME content type of the incoming request
        public string ContentType { get; private set; }

        // Gets the request headers
        public List<KeyValuePair<string, StringValues>> Headers { get; private set; }
        #endregion
    }
}
