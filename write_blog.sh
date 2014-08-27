#!/bin/bash

cd "$(dirname "${0}")"

one_week_ago="$(date -v -1w +%Y-%m-%d)"
tomorrow="$(date -v +1d +%Y-%m-%d)"
curl -s 'https://bugzilla.mozilla.org/page.cgi?id=user_activity.html&action=run&who=pmoore%40mozilla.com&from=${one_week_ago}&to=${tomorrow}&sort=bug' > temp

cat temp | grep '\(href="show_bug\.cgi?id=\([0-9]*\)">\|<td>(new bug)\)' | sed 's/.*href="show_bug\.cgi?id=\([0-9]*\)">.*/\1/p' | sed 's/.*(new bug).*/%/' | while read line
do
    if [ "${line}" = '%' ]; then
        echo "${old_line}"
    fi
    old_line="${line}"
done | sort -run > new_bugs
cat temp | sed -n 's/.*href="show_bug\.cgi?id=\([0-9]*\)">.*/\1/p' | sort -run > all_bugs

diff new_bugs all_bugs | sed -n 's/^> //p' > updated_bugs

function process {
    while read line; do curl "https://bugzilla.mozilla.org/show_bug.cgi?id=${line}" 2>/dev/null | sed -n 's/.*document\.title = "//p' | sed 's/";$//' | sed "s/\\\\//g"; done | while read Bug NUM minus rest; do echo "<li><a href=\"https://bugzilla.mozilla.org/show_bug.cgi?id=${NUM}\" title=\"https://bugzilla.mozilla.org/show_bug.cgi?id=${NUM}\" target=\"_blank\">Bug ${NUM} &ndash; ${rest}</a></li>"; done
}

echo '<p><strong>Highlights from this week</strong></p>'
echo '<ul>'
echo '<li>xyz'
echo '</ul>'
echo '<p><strong>Goals for next week:</strong></p>'
echo '<ul>'
echo '<li>xyz'
echo '</ul>'
echo '<p><strong>Bugs I created this week:</strong></p>'
echo '<ul>'
cat new_bugs | process
echo '</ul>'
echo '<p><strong>Other bugs I updated this week:</strong></p>'
echo '<ul>'
cat updated_bugs | process
echo '</ul>'
