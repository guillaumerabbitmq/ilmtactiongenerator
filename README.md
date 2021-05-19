# ilmtactiongenerator
ilmtactiongenerator is a simple perl script to help ILMT user to update the ILMT actions required to run pertinent Software Inventory in order to produce acurate PVU reports. The test I run were with Strawberry perl.

The perl script remove old actions before attempting to run new actions.
It is provided as is.
# Config file
An XML file is provide to setup common parameters of actions to be run during the Update process.
# Common config parameters:
 - Name or IP address of the Bigfix server: "server"
 - Port of the Bigfix server : "port"
 - Name of the user with rights to delete/run ILMT actions : "besuser"
 - The pasword of the user : "bespassword"

# Special and optionnal parameters (to be used with care !):
 - The pattern of all actions is defined within "actionsettingspattern"
 - Threshold of the Inventory action : "inventorycputhreshold"
 - Inventory period of time to start : "inventoryperiod"
 - Inventory special condition to run : "inventorywhose"
 - Inventory day of the week : "inventorydayofweek"

# How to run
perl IlmtActionGenerator.pl config IlmtActionGeneratorgm7.xml

Output:
IBM BigFix ILMT Actions Generator
Version 1.3

Site found:IBM License Reporting
No action to delete
Action created 'Upgrade to the latest version of IBM License Metric Tool (9.2.23.0)',ID 1622
Action ID 1602 deleted
Action created 'Update VM Manager Tool to version (9.2.23.0)',ID 1623
Action ID 1603 deleted
Action created 'Run Capacity Scan and Upload Results (9.2.23.0)',ID 1624
Action ID 1604 deleted
Action created 'Upload Software Scan Results (9.2.23.0)',ID 1625
Action ID 1605 deleted
Action created 'Schedule VM Manager Tool Scan Results Upload (9.2.23.0)',ID 1626
Action ID 1606 deleted
Action created 'Install or Upgrade Scanner (9.2.23.0)',ID 1627
Action ID 1607 deleted
Action created 'Initiate Software Scan (9.2.23.0)',ID 1628
