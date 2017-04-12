#!/usr/bin/env bash

#
# create a partial mirror (don't need all the archives from previous versions)
#
# see e.g. http://cran.r-project.org/doc/manuals/R-admin.html/

export RSYNC_PROXY={PROXY STUFF}

DOW=`date '+%s'`
LOGFILE="/var/log/cran-rsync.log.${DOW}"
REPO_PATH="/repos/cran"

# use while loop to ensure it completes successfully
# especially if a connection is reset
#
# R = use relative path names, e.g. bin/windows/contrib/3.1
# r = recurse into directories
# t = preserve modification times
# l = copy symlinks as symlinks
# z = compress file data during transfer
# v = verbose output
# h = human readable format
# --partial = keep partially transferred files (esp if conn is reset)
# --progress = show progress during transfer
# --delete = remove what's removed on the remote
# --log-file=FILE = log to specificed file
run_rsync() {
	RC=1
		while [ $RC -gt 0 ]
		do
        # $1 is the source location 
        rsync -Rdtlzh --partial --delete --progress --stats --log-file=${LOGFILE} ${1} ${REPO_PATH}
        RC=$?
			echo "`/bin/date '+%Y/%m/%d %H:%M:%S'` Rsync exit code was ${RC}." >> ${LOGFILE}
		done
}

copy_files() {
    if [ -d ${1} ] 
    then
        echo "`/bin/date '+%Y/%m/%d %H:%M:%S'` Copying from ${1} to ${2}"
        cp ${1}/* ${2}
    fi
}

# Checks to see if the rsync job is running. If not, it runs. This prevents the jobs from stepping on each other.
if ! ps -ef | grep -v grep | grep rsync | grep -q CRAN
then

	echo "`/bin/date '+%Y/%m/%d %H:%M:%S'` Starting cran-rsync.sh." >> ${LOGFILE}
	# mirror windows 3.2,3.3 
	run_rsync "cran.r-project.org::CRAN/bin/windows/contrib/3.2/"
	run_rsync "cran.r-project.org::CRAN/bin/windows/contrib/3.3/"

	# mirror mac 3.1, 3.2
	run_rsync "cran.r-project.org::CRAN/bin/macosx/contrib/3.1/"
	run_rsync "cran.r-project.org::CRAN/bin/macosx/contrib/3.2/"

	run_rsync "cran.r-project.org::CRAN/bin/macosx/mavericks/contrib/3.1/"
	run_rsync "cran.r-project.org::CRAN/bin/macosx/mavericks/contrib/3.2/"
	run_rsync "cran.r-project.org::CRAN/bin/macosx/mavericks/contrib/3.3/"

	# mirror current sources only, no archives
	run_rsync "cran.r-project.org::CRAN/src/contrib/*"

	echo "`/bin/date '+%Y/%m/%d %H:%M:%S'` Finished running the run_rsync" >> ${LOGFILE}
	# copy non-cran files over instead of excluding them
	WIN_PATH=${REPO_PATH}/bin/windows
	MAC_PATH=${REPO_PATH}/bin/macosx
	SRC_PATH=${REPO_PATH}/src

	copy_files ${WIN_PATH}/github/3.2 ${WIN_PATH}/contrib/3.2
	copy_files ${WIN_PATH}/github/3.3 ${WIN_PATH}/contrib/3.3

	copy_files ${MAC_PATH}/github/3.1 ${MAC_PATH}/contrib/3.1
	copy_files ${MAC_PATH}/github/3.2 ${MAC_PATH}/contrib/3.2

	copy_files ${SRC_PATH}/github ${SRC_PATH}/contrib
	echo "`/bin/date '+%Y/%m/%d %H:%M:%S'` Finished all of the copy_files " >> ${LOGFILE}

	# re-create indexes - seen issues with external
	create-index.R
	RC=$?
	echo "`/bin/date '+%Y/%m/%d %H:%M:%S'` Finished running create-index.R. Exit code was ${RC}." >> ${LOGFILE}

	# create json for web ui to list packages 
	create-json.R
	RC=$?
	echo "`/bin/date '+%Y/%m/%d %H:%M:%S'` Finished running create-json.R. Exit code was ${RC}." >> ${LOGFILE}
	gzip -f ${LOGFILE}

else
	echo "`/bin/date '+%Y/%m/%d %H:%M:%S'`  cran-rsync.sh already running. Not starting ${RC}." >> ${LOGFILE}
	MSG="cran-rsync.sh already running.  Not starting"
	echo ${MSG} | mutt -s "cran-rsync.sh" mmm13@gmail.com
fi
