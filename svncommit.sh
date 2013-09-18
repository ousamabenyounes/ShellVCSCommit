#!/bin/sh

# Print help message
usage () {
    echo "Usage: svncommit.sh -d -o -m"
    echo "  -d: PhpUnit CodeCoverage Html Report Directory ."
    echo "  -o: PhpUnit Options (--stop-on-error | --stop-on-failure ...)."
    echo "  -m: SVN log message"

    exit 1;
}

# Check previous command returned val
checkReturnedVal () {
    retval=$?
    if [ $retval -ne 0 ]; then
	echo "[Error] Exiting..."
	exit $retval
    else
	echo "[Success]\n"
    fi
}

PHPUNIT_COVERAGE_CMD=""
PHPUNIT_OPTIONS=""
SVN_LOG_MSG=""

# ------------------------------------------------------------------------------ #
# Parsing all parameters
while getopts ":d:o:m:" opt; do
  case "$opt" in
    d)  PHPUNIT_COVERAGE_DIR="--coverage-html $OPTARG";;
    o)  PHPUNIT_OPTIONS="$OPTARG";;
    m)  SVN_LOG_MSG="$OPTARG";;

    h)  # print usage
        usage
        exit 0
        ;;
    :)  echo "Error: -$option requires an argument"
        usage
        exit 1
        ;;
    ?)  echo "Error: unknown option -$option"
        usage
        exit 1
        ;;
  esac
done

if [ -z "$SVN_LOG_MSG" ]; then
    echo "[ERROR] Svn log message is mandatory..."
    exit 1
fi


# Launch all WebApiBundle Phpunit Tests
echo "[INFO] phpunit: Launching Tests"
echo "[CMD] cd /var/www/analytics/webApp/"
echo "[CMD] phpunit $PHPUNIT_COVERAGE_DIR $PHPUNIT_OPTIONS"
cd "/var/www/analytics/webApp/"
phpunit $PHPUNIT_COVERAGE_DIR $PHPUNIT_OPTIONS
checkReturnedVal


# SVN Update 
echo "[INFO] svn: Updating repository"
echo "[CMD] cd .."
echo "[CMD] svn update"
cd ..
svn update
checkReturnedVal

# Automatically fix source code presentation (PSR1 PSR2...)
echo "[INFO] php-cs-fixer: Fixing PHP PSR "
echo "[CMD] php-cs-fixer fix src/MMC/Analytics/Api/WebApiBundle"
php-cs-fixer fix src/MMC/Analytics/Api/WebApiBundle 
checkReturnedVal

result=`svn status -q`
if [ -z "$result" ]; then
    echo "[INFO] SVN => No changes"
else
    echo "[INFO] SVN => Changes found"
fi

# send commit to the repository
echo "[INFO] svn: Commit changes"
echo "[CMD] cd /var/www/analytics"
echo "[CMD] svn commit -m\"$SVN_LOG_MSG\" "
cd "/var/www/analytics/"
svn commit -m"$SVN_LOG_MSG"
checkReturnedVal

exit 0