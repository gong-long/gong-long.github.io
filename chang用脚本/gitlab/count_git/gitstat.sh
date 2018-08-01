#!/bin/bash
#
# The MIT License (MIT)
# Copyright (c) 2017 fishcried(fishcried@163.com)
#
# /script/gitlab/gitstat.sh  --since=2018/07/29 --until=2018/07/30 -p /script/gitlab/qmzb


function usage {
	echo "$(basename $0) [options] dir"
	echo
	echo "OPTIONS:"
	echo "-s/--since=<YY/MM/DD>"
	echo "   More recent than a specific date."
	echo "-u/--until=<YY/MM/DD>"
	echo "   Older than a specific date."
	echo "-i/--input=<authors-list>"
	echo "   Authors list, must be absolute path"
	echo "--maxdepth=N"
	echo "   Default 1"
	echo "-p/--project=project-dir"
	echo "   Just for a project"
	echo "-h|--help"
	echo "   Show help message"
	echo
	echo "EX:"
	echo "$(basename $0)--since 2017/07/01 --until 2017/07/04 dirname"
	echo "$(basename $0)--since 2017/07/01 --until 2017/07/04 -i /etc/authors dirname"
}

function project_stat {
	local project=$1

	for email in $(git log --since="$since" --until="$until" --all --no-merges --pretty="%ae" 2>/dev/null |  sort | uniq)
	do
		if [ "x$AUTHOR_FILE" != "x" ]; then
			grep -q -w "$email" "$AUTHOR_FILE"
			if [ $? -ne 0 ]; then
				continue
			fi
		fi
		local author=${email%%@*}
		commits=$(git log --since="$since" --until="$until" --all --no-merges  --author="$email" --oneline | wc -l)

		git log --since="$since" --until="$until" --all --no-merges  --author="$email" --pretty=tformat: --numstat | sed '/^$/d' | \
		awk -v commits="$commits" -v project="$project" -v author="$author" '{add += $1; subs += $2} \
		END {printf "%s\t%s\t%s\t%s\t%s\n", author, add, subs, commits, project}'
	done
}

GIT_STATICS_PHASE1=/tmp/git_statics_phase1_$RANDOM
CONTRIBUTE_AUTHORS=/tmp/git_contribute_authors_$RANDOM
MAXDEPTH=1

trap "rm -rf $GIT_STATICS_PHASE1 $CONTRIBUTE_AUTHORS" INT

ARGS=$(getopt -a -o p:s:u:i:h -l help,input:,project:,since:,until:,maxdepth: -- "$@")
eval set --"${ARGS}"

while true
do
	case "$1" in
		-s|--since) since="$2 0:00"; shift 2;;
		-u|--until) until="$2 24:00"; shift 2;;
		-i|--input) AUTHOR_FILE="$2"; shift 2;;
		-p|--project) PROJECT="$2"; shift 2;;
		--maxdepth) MAXDEPTH="$2"; shift 2;;
		-h|--help) usage && exit 0;;
		--)shift; break;;
		*) echo $1; usage && exit 2;;
	esac
done


if [ "x$PROJECT" != "x" ];then
	[ $# -ne 0 ] && usage && exit 1
else
	if [ $# -ne 1 ];then
		usage
		exit 1
	else
		WORKSPACE="$1"
	fi
fi


if [ "x$PROJECT" != "x" ];then
    pushd $PROJECT 1>/dev/null
	project_stat $(basename $PROJECT) >> $GIT_STATICS_PHASE1
	popd 1>/dev/null
else
	for project in $(find $WORKSPACE -maxdepth "$MAXDEPTH" -name "[^.]*" -type d )
	do
		if [ ! -e "$project/.git" ] && [ ! -e "$project/objects" ];then
			continue
		fi

		pushd $project 1>/dev/null
		project_stat $(basename $project) >> $GIT_STATICS_PHASE1
		popd 1>/dev/null
	done
fi


if [ "x$AUTHOR_FILE" != "x" ]; then
	awk '{print $1}' $GIT_STATICS_PHASE1 | sort | uniq > $CONTRIBUTE_AUTHORS
	for author in $(cat $AUTHOR_FILE)
	do
		author=${author%%@*}
		grep -q -w "$author" $CONTRIBUTE_AUTHORS
		if [ $? -ne 0 ]; then
		echo -n
		echo -e "$author\t0\t0\t0\tNULL" >> $GIT_STATICS_PHASE1
		fi
	done
fi

echo -e "Author\tAdd\tDelete\tCommit\tProject"
sort $GIT_STATICS_PHASE1

rm -f $GIT_STATICS_PHASE1
rm -f $CONTRIBUTE_AUTHORS

