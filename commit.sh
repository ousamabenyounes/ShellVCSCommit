#!/bin/sh

# Print help message
usage () {
    echo "Usage: svncommit.sh -d -t -o -m"
    echo "  -d: PhpUnit CodeCoverage Html Report Directory ."
    echo "  -t: PhpUnit Test Suite Directory ."
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

PHPUNIT_HOME_DIR=""
PHPUNIT_COVERAGE_CMD=""
PHPUNIT_OPTIONS=""
SVN_LOG_MSG=""
PHPCS_REFORMAT_DIR=""
PROJECT_DIR=""

# ------------------------------------------------------------------------------ #
# Parsing all parameters
while getopts ":d:t:s:o:m:p:" opt; do
  case "$opt" in
    d)  PHPUNIT_COVERAGE_DIR="--coverage-html $OPTARG";;
    t)  PHPUNIT_HOME_DIR="$OPTARG";;
    s)  PHPCS_REFORMAT_DIR="$OPTARG";;
    p)  PROJECT_DIR="$OPTARG";;
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
echo "[CMD] cd $PHPUNIT_HOME_DIR"
echo "[CMD] phpunit $PHPUNIT_COVERAGE_DIR $PHPUNIT_OPTIONS"
cd $PHPUNIT_HOME_DIR
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
echo "[CMD] php-cs-fixer fix $PHPCS_REFORMAT_DIR"
php-cs-fixer fix $PHPCS_REFORMAT_DIR
checkReturnedVal

result=`svn status -q`
if [ -z "$result" ]; then
    echo "[INFO] SVN => No changes"
else
    # send commit to the repository                                                                                                                                                                         
    echo "[INFO] svn: Commit changes"
    echo "[CMD] cd $PROJECT_DIR"
    echo "[CMD] svn commit -m\"$SVN_LOG_MSG\" "
    cd $PROJECT_DIR
    svn commit -m"$SVN_LOG_MSG"
    checkReturnedVal
fi

exit 0
