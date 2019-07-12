#!/bin/bash

old_version="${1}"

if [ -z "${old_version}" ]; then
  echo "Please specify old version, e.g. ${0} 15.1.0" >&2
  exit 64
fi

function process {
  while read line; do
    curl "https://bugzilla.mozilla.org/show_bug.cgi?id=${line}" 2>/dev/null | sed -n 's/.*BUGZILLA.bug_title = '\''//p' | sed 's/'\'';$//' | sed "s/\\\\//g"
  done | while read bugnumber title; do
  echo "* [Bug ${bugnumber} ${title}](https://bugzil.la/${bugnumber})"
  done
}

GW_CHECKOUT="$(mktemp -d -t gw-checkout.XXXXXXXXXX)"
cd "${GW_CHECKOUT}"
git clone https://github.com/taskcluster/generic-worker
cd generic-worker
git tag -l | grep '^v' > ../tags
git tag -l | sed -n 's/^v/v /p' | sed 's/alpha/ alpha /g' | gsed 's/\<[0-9]\>/0&/g' | sed 's/ //g' > ../padded-tags
tag_count=$(cat ../tags | wc -l)
for ((i=1;i<=$tag_count;i++));
do
  tag=$(sed -n "${i}p" ../tags)
  padded_tag=$(sed -n "${i}p" ../padded-tags)
  echo "${padded_tag} ${tag}"
done | sort -u | sed -n "/ v${old_version//./\\.}\$/,\$p" > ../sorted-tags

while read x tag; do
  if [ -n "${previous_tag}" ]; then
    git log ${previous_tag}..${tag} | sed -n 's/.*[Bb][Uu][Gg] *\([1-9][0-9][0-9][0-9][0-9][0-9]*\).*/\1/p' | sort -u > ../${tag}
	bug_count=$(cat ../${tag} | wc -l)
    if [ ${bug_count} -gt 0 ]; then
      {
      echo
      title="In ${tag} since ${previous_tag}"
      echo "${title}"
      echo "${title//?/=}"
	  echo
      cat ../${tag} | process
      } > ../${tag}-text
    fi
  fi
  previous_tag=${tag}
done < ../sorted-tags

tail -r ../sorted-tags | while read x tag; do
  cat ../${tag}-text 2>/dev/null
done

rm -rf "${GW_CHECKOUT}"
