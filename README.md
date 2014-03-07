ShellVCSCommit
==============

This shell script launches some usefull commands before committing your GIT/SVN/Mercurial changes:

1) First it launches your phpunit tests suite: 
- You can specify your CodeCoverage Directory (-d option)
- You can add phpunit specific options (-o option)

2) an svn update command is sent

3) Then this script executes php-cs-fixer to reformat your source code
- You can specify the source directory you want to reformat before commit

4) Final main commit


### Requirements

PhpUnit:

    $ pear config-set auto_discover 1
    $ pear install pear.phpunit.de/PHPUnit

PHP_CodeSniffer:

    $ pear install PHP_CodeSniffer

php-cs-fixer:

    $ sudo curl http://cs.sensiolabs.org/get/php-cs-fixer.phar -o /usr/local/bin/php-cs-fixer
    $ sudo chmod a+x /usr/local/bin/php-cs-fixer



