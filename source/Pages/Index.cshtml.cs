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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Primitives;
using System;
using System.Collections.Generic;
using System.Linq;
#endregion

namespace SyntheticApi.Pages
{
    public class IndexModel : PageModel
    {
        #region Private Fields
        private readonly ILogger<IndexModel> _logger; 
        #endregion

        #region Public Constructors
        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }
        #endregion

        #region Public Methods
        public void OnGet()
        {

        }

        [BindProperty(SupportsGet = true)]
        public IList<KeyValuePair<string, StringValues>> Headers
        {
            get
            {
                return Request.Headers.ToList();
            }
            set
            { }
        }

        [BindProperty(SupportsGet = true)]
        public string MachineName
        {
            get
            {
                return Environment.MachineName;
            }
            set
            { }
        }

        [BindProperty(SupportsGet = true)]
        public string IsHttps
        {
            get
            {
                return Request.IsHttps.ToString();
            }
            set
            { }
        }

        [BindProperty(SupportsGet = true)]
        public string Path
        {
            get
            {
                return Request.Path;
            }
            set
            { }
        }
        #endregion
    }
}
