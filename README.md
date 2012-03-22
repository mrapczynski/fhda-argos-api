## Introduction

Welcome to the project home of the example API implementation originally created for the [Foothill-De Anza College District](www.fhda.edu) for the implementing the [Evisions](www.evisions.com) Argos reporting platform.

Foothill-De Anza is a Banner school, and therefore everything about this project revolves around Banner integration. For a more agnostic approach using the Argos API, please see my [Java library](https://github.com/mrapczynski/Argos-API-for-Java) that I developed for use in any kind of application where Java is applied.

The goal of this project was to come up with a cross-platform, vendor agnostic approach to leverage Argos reports in all business areas. The Argos development environment is Windows only, and is meant to be accessed exclusively through IE using ActiveX. Since the FHDA user community is split roughly 50/50 around Windows and Mac, this would be a difficult requirement to meet. Mass virtualization would be a support nightmare.

The API functionality built into Argos is great, but like most product APIs it is headless with no UI. So this project uses the dynamic web capabilities provided by Banner and Oracle to create true web-only front-ends for virtually any kind of Argos report. The same thing can be accomplished with many other types of web middleware… JSPs, servlets, ASP.NET, Ruby, etc. For Banner schools it makes a lot of sense to stay near the provisions of Oracle, and therefore we built ours using the [PL/SQL Web Toolkit](http://docs.oracle.com/cd/B19306_01/appdev.102/b14251/adfns_web.htm). 

It is very common among Banner schools, especially those who have been on Banner over many versions, to have added extensive customizations, or re-appropriated various product features to serve specific business needs. There is **no expectation** this project will work for you out of the box. I provide it here to the Argos community as an **only an example implementation** to be dissected and adapted to meet your needs.

## How Does It Work?

The heart and soul of the project revolves around using metadata stored in Oracle database tables. By creating a single "base" record to describe the main attributes of a report, and then creating several child records in another table to describe each report parameter, a UI to execute the report can be constructed on the fly.

Applied use of PL/SQL queries generates a pretty HTML form for the user to enter parameter values. From there, they can select a download format as specified by the developer when creating the metadata records. After a moment of time passes for the report to execute, the web browser will return asking the user where to download the finished document. 

The Argos API is a simple "straight through" pipeline, but in this implementation we have purposely broken that pipeline into two discreet steps so that the UI can be made elegant and informative for the user. The goal from day one has been to create a fast, secure, and easy reporting solution without being chained to difficult platform requirements.

## Documentation

As part of the project implementation at Foothill-De Anza, a developer's guide was created, and is actively maintained for the IT staff. A modified *open source version* of this guide is provided as part of the project. It is kept in the root folder and named "Developer's Guide.pdf". It will be kept up to date as part of any changes or additions made to the implementation source code.

## What Is In The Folders?

Welcome to the project home of the example API implementation created by Foothill-De Anza (www.fhda.edu) for the Evisions Argos reporting package (www.evisions.com)

* **argosapi**: Contains images, JavaScript dependencies, and other assets to be used for the web front-end.

* **db_scripts**: Install and uninstall scripts for the tables and database objects

* **luminis_portlet**: For Sungard clients who have implemented the Luminis Platform v4 or higher, an example portlet showing integration with the Argos API database objects. 

* **sample_data**: Raw dump of example tables showing how Argos reports can be configured for execution via this API solution.

## License and Warranty

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.