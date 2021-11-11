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
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
#endregion

namespace SyntheticApi
{
    public class Startup
    {
        #region Public Constructor
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }
        #endregion

        #region Public Properties
        public IConfiguration Configuration { get; }
        #endregion

        #region Public Methods
        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();
            services.AddApplicationInsightsTelemetry();
            services.AddRazorPages();

            // Register the Swagger generator, defining 1 or more Swagger documents
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Version = "v1",
                    Title = "Performance Test Backend API",
                    Description = "This is a simple ASP.NET Core Web API.",
                    TermsOfService = new Uri("https://www.apache.org/licenses/LICENSE-2.0"),
                    Contact = new OpenApiContact
                    {
                        Name = "Paolo Salvatori",
                        Email = "paolos@microsoft.com",
                        Url = new Uri("https://github.com/paolosalvatori"),
                    },
                    License = new OpenApiLicense
                    {
                        Name = "Use under Apache License 2.0",
                        Url = new Uri("https://www.apache.org/licenses/LICENSE-2.0"),
                    }
                });
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger();

            //// Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.), specifying the Swagger JSON endpoint.
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "Performance Test Backend API V1");
            });

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();
            app.UseRouting();
            app.UseAuthorization();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapRazorPages();
                endpoints.MapControllers();
            });
        }
        #endregion
    }
}