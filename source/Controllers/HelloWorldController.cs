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
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Linq;
using System.Dynamic;
using System;
using SyntheticApi.Models;
#endregion

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace SyntheticApi.Controllers
{
    [Route("api/[controller]")]
    public class HelloWorldController : Controller
    {
        #region Private Instance Fields
        private readonly ILogger<HelloWorldController> logger;
        #endregion

        #region Public Constructors
        public HelloWorldController(ILogger<HelloWorldController> logger)
        {
            this.logger = logger;
        }
        #endregion

        #region Public Methods
        // GET api/SyntheticApi
        [HttpGet]
        [ProducesResponseType(typeof(RequestData), StatusCodes.Status200OK)]
        public IActionResult Get()
        {
            var stopwatch = new Stopwatch();

            try
            {
                stopwatch.Start();
                logger.LogInformation($"Received new request.");
                return Json(new RequestData(Request));
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred in the Get method of the SyntheticApiController class.");
                throw;
            }
            finally
            {
                stopwatch.Stop();
                logger.LogInformation($"Get method completed in {stopwatch.ElapsedMilliseconds} ms.");
            }
        }
        #endregion
    }
}
