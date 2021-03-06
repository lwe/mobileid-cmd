#!/bin/sh
# mobileid-radius.sh - 1.0
#
# Helper script called from freeradius to invoke mobile-sign with correct parameters
#
# Change Log:
#  1.0 13.10.2012: Initial version.
#
# Each of the attributes in the request will be available in an
# environment variable.  The name of the variable depends on the
# name of the attribute.  All letters are converted to upper case,
# and all hyphens '-' to underlines.
#
# For example, the User-Name attribute will be in the $USER_NAME
# environment variable.  If you want to see the list of all of
# the variables, try adding a line 'printenv > /tmp/exec-program-wait'
# to the script.  Then look in the file for a complete list of
# variables.
#
# The return value of the program run determines the result
# of the exec instance call as follows:
# (See doc/configurable_failover for details)
# < 0 : fail      the module failed
# = 0 : okthe module succeeded
# = 1 : reject    the module rejected the user
# = 2 : fail      the module failed
# = 3 : okthe module succeeded
# = 4 : handled   the module has done everything to handle the request
# = 5 : invalid   the user's configuration entry was invalid
# = 6 : userlock  the user was locked out
# = 7 : notfound  the user was not found
# = 8 : noop      the module did nothing
# = 9 : updated   the module updated information in the request
# > 9 : fail      the module failed

# Get current path
PWD=$(dirname $0)

# Remove quote and all spaces
CALLED_STATION_ID=`eval echo $CALLED_STATION_ID|sed -e "s/ //g"`
# Remove quote from others
X_MSS_LANGUAGE=`eval echo $X_MSS_LANGUAGE`
X_MSS_MESSAGE=`eval echo $X_MSS_MESSAGE`

# Call the MID SOAP bash script
if [ -e $PWD/mobileid-sign.sh ]; then
    $PWD/mobileid-sign.sh $CALLED_STATION_ID "$X_MSS_MESSAGE" $X_MSS_LANGUAGE
  else
    echo "MID SOAP bash script not found in $PWD"
fi

# Success and error handling according to freeradius rlm_exec
if [ "$?" = "0" ]; then exit 0 ; fi	# Success
if [ "$?" = "1" ]; then exit 1 ; fi	# MID response error
if [ "$?" = "2" ]; then exit 2 ; fi	# MID service error

exit 1					# By default the user is rejected
