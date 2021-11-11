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
using System.Threading;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using SyntheticApi.Models;
#endregion

namespace SyntheticApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TestObjectsController : ControllerBase
    {
        // GET api/values/5
        [Produces("application/json")]
        [HttpGet("{id}")]
        public ActionResult<TestObject> Get([FromHeader(Name = "DelayTime")]int delayTime, [FromHeader(Name = "TextSize")]int textSize, int id)
        {
            // Parse DelayTime header
            if (delayTime > 0)
            {
                Thread.Sleep(delayTime);
            }

            string textString = string.Empty;

            if (textSize > 0)
            {
                textString = new string('*', textSize);
            }

            // Create TestObject
            var testObject = new TestObject
            {
                id = id,
                text = textString
            };

            var sb = new System.Text.StringBuilder();
            sb.Append(Request.Scheme).Append("://").Append(Request.Host).Append(Request.Path);
            testObject.sourceInformation = sb.ToString();

            return testObject;
        }

        // POST api/values
        [Consumes("application/json")]
        [HttpPost]
        public void Post([FromHeader(Name = "DelayTime")]int delayTime,[FromBody] TestObject testObject)
        {
            // Parse DelayTime header
            if (delayTime > 0)
            {
                Thread.Sleep(delayTime);
            }
        }
    }
}
