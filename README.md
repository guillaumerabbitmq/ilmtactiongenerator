# ilmtactiongenerator
ilmtactiongenerator is a simple perl script to help ILMT user to update the ILMT actions required to run pertinent Software Inventory in order to produce acurate PVU reports.

The perl script remove old actions before attempting to run new actions.
It is provided as is.
# Config file
An XML file is provide to setup common parameters of actions to be run during the Update process.
Common config parameters:
 - Name or IP address of the Bigfix server: <server>gm90</server>
 - Port of the Bigfix server : <port>52311</port>
 - Name of the user with rights to delete/run ILMT actions : <besuser>IEMAdmin</besuser>
 - The pasword of the user : <bespassword>passwordOfTheUser</bespassword>

Special parameters (to be used with care !):
The pattern of all actions is defined within <actionsettingspattern>
  Threshold of the Inventory action : <inventorycputhreshold>  
  Inventory period of time to start : inventoryperiod
  Inventory special condition to run : inventorywhose
  Inventory day of the week : inventorydayofweek
