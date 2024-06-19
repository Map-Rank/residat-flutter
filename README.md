<h1 style="display: flex; justify-content: space-between; align-items: center;">Welcome to residat-mobile-platform <img src="public/assets/images/Logos/logo-small.svg" alt="Image Description" height="70"></h1>

[![Version](https://img.shields.io/badge/version-0.0.1-blue.svg?cacheSeconds=2592000)](#)
[![License: AGPL](https://img.shields.io/badge/License-agpl-yellow.svg)](#)

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-brightgreen)
![Dependencies](https://img.shields.io/badge/dependencies-brightgreen)

RESIDAT is a digital platform for sharing place-based information on climate risks from spatial data and citizen science reports .This platform shall have five main components 
- Visualization of place-based climate risks
- information through dashboards 
- Hosting of published reports by community stakeholders 
- Chatroom for community climate realities
- Sending out mobile notifications by local and regional climate authoritative bodies.


Login             |  Dashboard
:-------------------------:|:-------------------------:
![Rectangle (2)](https://github.com/Map-Rank/residat-flutter/assets/38427386/c5a4e425-bc86-4f73-89d4-a10ba54e4d23)  |  ![Rectangle (1)](https://github.com/Map-Rank/residat-flutter/assets/38427386/d5f7a1d6-895a-4221-91d6-563ecf3c760f)





## Table of Contents 📚

1.  [Introduction](#introduction-🌟)
2.  [Context](#context-💡-)
3.  [Features](#features-✨)
4.  [Installation Instruction](#installation-instruction-)
5.  [Troubleshooting](#troubleshooting-)
6.  [Testing](#testing-)
7.  [Code of Conduct](#code-of-conduct-)
8.  [licence](#licence-)


## Introduction 🌟

 <a href="https://dev.residat.com/community">RESIDAT</a> is a digital platform designed to enhance community resilience by providing access to climate risk information in Cameroon. It leverages spatial data and citizen science reports to visualize climate risks through interactive GIS dashboards. The platform offers a suite of features including:

- Visualization Dashboards: Interactive maps and graphs for understanding local climate risks and stakeholder activities.
- Community Intelligence: A repository for stakeholders to publish, manage, and interact with climate adaptation reports.
- Community Chat Rooms: Spaces for real-time discussion and exchange of climate-related information and services..

 <a href="https://dev.residat.com/community">RESIDAT</a> serves as a critical tool for local and regional climate authoritative bodies to send out mobile notifications and engage communities in proactive climate risk management.

## Context 💡

 <a href="https://dev.residat.com/community">RESIDAT</a> was born from the necessity to mitigate climate risks for communities in Cameroon. It targets the heart of climate vulnerability by providing critical, actionable data through GIS visualizations and real-time reports. The platform's goal is to empower communities and authorities to make informed decisions, enabling proactive and collaborative efforts towards climate resilience. In the face of increasing climate challenges,  <a href="https://dev.residat.com/community">RESIDAT</a> stands as a beacon of innovation and solidarity.

### Vision Statement
"Residat envisions a resilient Cameroon where every community has the knowledge and tools to adapt to climate variability. Our vision is to become a leading platform in climate risk assessment and adaptation strategies, contributing to sustainable development and disaster risk reduction through innovative geospatial technologies."

### Mission Statement
"Our mission is to empower vulnerable communities in Cameroon by providing them with accurate, accessible, and actionable geospatial data on climate hazards. Through the integration of GIS, drone technology, and big data analytics, Residat aims to facilitate informed decision-making and proactive environmental management."

### Community Statement
"Residat is dedicated to fostering a collaborative environment where scientists, local authorities, developers, and community members come together to combat climate risks. We encourage the sharing of insights, the development of local solutions, and the creation of a united front against the adverse effects of climate change."

### Licensing Strategy
"To maximize impact and encourage innovation, Residat will operate under an AGPL License, promoting open-source collaboration. This approach will allow for the free use, modification, and distribution of our resources, ensuring they remain accessible for adaptation to other regions facing similar climate challenges."


## Features ✨

 <a href="https://dev.residat.com/community">RESIDAT</a> offers a powerful suite of features designed to provide stakeholders with comprehensive climate risk data and facilitate community engagement in climate resilience:

- Interactive GIS Dashboards: Leveraging cutting-edge GIS technology,  <a href="https://dev.residat.com/community">RESIDAT</a> provides dynamic maps and graphs that allow users to visualize and interact with climate risk data specific to their local communities.

- Community Intelligence Reports: A dedicated space for stakeholders to publish, manage, and interact with reports on climate adaptation efforts. These reports provide valuable insights into local initiatives and challenges.

- Real-Time Community Chat Rooms: These forums offer a space for stakeholders to discuss climate realities, share observations, and promote climate services, fostering a community-driven approach to climate resilience.

- Mobile Notifications: Integration with mobile platforms ensures that stakeholders receive timely updates and warnings about climate hazards, enabling swift and informed responses to emerging risks.

- Citizen Science Contributions: Encouraging local community members to contribute data and reports,  <a href="https://dev.residat.com/community">RESIDAT</a> amplifies the reach and accuracy of climate risk information through citizen science.

- Data-Driven Insights: By analyzing spatial data and user-contributed reports,  <a href="https://dev.residat.com/community">RESIDAT</a> provides actionable insights that support climate risk management and decision-making processes.

- Stakeholder Engagement Tools: Features designed to enhance collaboration among various actors, including local authorities, NGOs, businesses, and academia, to drive collective action in climate adaptation.


## Installation Instruction 
In order to run and use this project on your devices you need to fufill the prerequisites and dependencies required below.

### Prerequisites
- Get a powerful machine that will allow you to emulate an android, ios  device or both.( <a href="https://docs.flutter.dev/get-started/install/windows/mobile">Visit this link for more enhancement</a>)
- Set up Android Studio or VScode on your device
- "Fork" or Clone  this repository from the main page.

### Dependencies
- Once you have the project in your development environment, Get all the dependencies of the project by tapping the command: "flutter pub get" at the root of your project in your terminal.

## Troubleshooting
In case your flutter version is 3.16 or posterior to version 3.16, you might be facing issues with your graddle files and your project will not run. <a href ="https://stackoverflow.com/questions/78032396/applying-flutters-app-plugin-loader-gradle-plugin-imperatively-using-the-apply-s)">Follow this link to solve the issue</a>
After following the instructions on the link above you might need to delete the following from your graddle file because Gradle wrapper already has it:
task clean(type: Delete) { 
    delete rootProject.buildDir 
}

## Testing 🧪

Testing is a crucial aspect of the development process, ensuring that the code is robust and behaves as expected. In the Residat project, we employ Vitest for our testing framework, providing an efficient and feature-rich environment for both unit and integration testing. Below is a summary of the current test coverage and details about the testing setup and examples.


### Test Coverage Summary


## Code of Conduct 📜

### RESIDAT Contributor Code of Conduct

As contributors and maintainers of the RESIDAT project, we pledge to foster an open and welcoming environment for everyone. We are committed to making participation in our project and our community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, sex characteristics, gender identity and expression, level of experience, education, socio-economic status, nationality, personal appearance, race, religion, or sexual identity and orientation.

#### Our Principles
- **Collaborative Ethos**: We create an inclusive space for diverse backgrounds and experiences, fostering a unique vision and product that resonates with the RESIDAT platform users.
  
- **Harmony through Dialogue**: We promote progress through open discussions, encouraging all community members to share ideas and engage respectfully to achieve consensus and resolve issues.
  
- **Team Spirit**: Recognizing that we each represent a piece of the RESIDAT puzzle, we value your skills and ask that you respect and value the contributions of others.

#### Our Pledge
We accommodate and uphold diversity in all forms, ensuring that participation in our project and community is a harassment-free experience for everyone.

#### Behavior Standards
Positive environment-contributing behaviors include:
- Kind and considerate communication.
- Respect and acknowledgment of our diverse audience and community members.
- Refraining from insults, bigotry, and offensive language.
- Exercising empathy and understanding towards others.

Unacceptable behaviors include:
- Any form of harassment, either public or private.
- Abusive comments, trolling, and offensive rhetoric.
- Religious, political, and cultural attacks.
- Posting or sharing inappropriate content.
- Disclosing private information without consent.
- Any other behaviors considered inappropriate in a professional setting.

#### Our Responsibilities
The RESIDAT designated team is responsible for enforcing community standards and may take appropriate action against unacceptable behavior.

#### Scope
This Code of Conduct applies both within project spaces and public spaces when individuals represent the project or community.

#### Enforcement
Instances of unacceptable behavior can be reported to the designated team at support@mapnrank.com with a detailed description and any relevant evidence. All complaints will be reviewed, investigated, and result in a response deemed necessary and appropriate to the circumstances.

#### Violations
Violations of this Code of Conduct may result in expulsion from the community or other repercussions as deemed appropriate by the project maintainers.

By contributing to RESIDAT, you agree to abide by these principles and behaviors to ensure our community remains welcoming, inspiring, and constructive for all.


## License ⚖️
 
 * MapAndRank - Residat is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MapAndRank - Residat is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MapAndRank - Residat. If not, see <https://www.gnu.org/licenses/>.
