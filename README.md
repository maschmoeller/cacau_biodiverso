# The Cocoa Biodiverse Project

The CocoaBiodiverse – Recognising and Valuing Those Who Produce and Conserve Project (hereinafter CocoaBiodiverse Project) aims to enhance biodiversity conservation in the Atlantic Forest by promoting sustainable management of cocoa agroforestry systems (cabrucas) and conserving native forest remnants. The project integrates productive agroforestry landscapes with forest protection to halt and reverse biodiversity loss and ecosystem degradation in southern Bahia, Brazil. This project is located in southern Bahia, within the Atlantic Forest biome, within the Tropical forests/ sub-tropical lowland ecoregion.

The CocoaBiodiverse - Recognizing and valuing those who produce and conserve project is eligible in the Sustainable Development Verified Impact Standard (SD VISta) Program and Nature Framework (SDVM002) Methodology, according to the requirements set out in these documents.

The code, data, and accompanying Wiki pages in this GitHub Project aim to allow understanding and replication of all steps required for the calculation of Net Biodiversity Credits for the CocoaBiodiverse Project, following the requirements and methodology of the Verra Biodiversity Framework v1.1.

## Workflow Overview
The workflow is divided into two sections:

### Calculation of Crediting Baseline
Calculation of the Crediting Baseline can be replicated in R using the scripts Step E1 to Step E7. The output value of Step E7 represents the Crediting Baseline Parameter Value, which is then input into the workflow for the Quantification of Biodiversity Outcomes in Step 8.

### Quantification of Biodiversity Outcomes
All quantification calculations are performed automatically in the spreadsheet Analys_v2.xlsx, on the Net_Biodiversity_Outcomes tab, once the values for the parameters are provided on the other tabs.
Parameters to be provided are:
1) Project extent (Project_extent tab),
2) Reference Values for each Condition Indicator (Reference_values tab),
3) Measured Condition Indicator Values at each monitoring period (All_indicators tab),
4) Crediting Baseline Parameter (Baseline tab), and
5) Leakage (Net_Biodiversity_Outcomes tab).

Further description of the steps taken is provided on the Wiki page.


