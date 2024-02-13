# List Local User and Groups

The powershell script lists local users, local groups and members for a list of remote servers supplied.




## Documentation

The script accepts the following arguments:

- -serverlist - Text file containing a list of server names, one per line
* -useroutputpath - File path to place the user csv files
+ -groupoutputpath - File path to place the group csv files

The script uses powershell remoting to make the connections to the remote computers and forces the use of the SSL connection. Ports required for connection to the remote computers are:

- HTTP – Port 5985
+ HTTPS – Port 5986