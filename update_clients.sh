#!/bin/bash

say -v boing "let's go mr driver"
source ~/update_clients.env
export DEBUG=*
for repo in taskcluster-client-go taskcluster-client-java
do
    export GOPATH="$(mktemp -d -t update_clients.XXXXXXXXXX)"
    export PATH="${GOPATH}/bin:${PATH}"
    rm -rf "${GOPATH}"
    go get -t "github.com/taskcluster/${repo}"
    cd "${GOPATH}/src/github.com/taskcluster/${repo}"
    # this will fail if there are changes
    if ! ./build.sh; then
        # but is not the only reason it might fail, so let's see
        # if adding changes fixes it
        git add .
        git commit -m "Regenerated library to pick up latest schema changes"
        # build again to make sure all is ok since git status should report no differences this time, so exit code is reliable
        # note we only push if this second build is successful
        if ./build.sh; then
            if git push origin master; then
                say "New changes pushed, yahoo"
                if [ "${repo}" == 'taskcluster-client-java' ]; then
					version="$(cat pom.xml | sed -n '1,/<version>/s/.*<version>\([0-9\.]*\)<\/version>.*/\1/p')"
                    mvn javadoc:javadoc
                    git checkout gh-pages
                    rm -rf apidocs
                    mv target/site/apidocs .
                    git add apidocs
                    git commit -m "Regenerated javadocs after api update(s)"
                    if git push origin gh-pages:gh-pages; then
                        say "New javadocs published"
                    else
                        say "Could not publish updated javadocs"
                    fi
					git reset master
					git checkout -f master
					git clean -fd
					if mvn deploy -P release; then
					    say "Published java client version ${version} to maven central"
					else
						say "Could not publish java client version ${version} to maven central"
					fi
					if git tag -m "Released version ${version}" "v${version}"; then
					    say "Tagged locally"
						if git push origin "refs/tags/v${version}:refs/tags/v${version}"; then
							say "Pushed tag v${version}"
							oldLastDigit="$(echo "${version}" | sed 's/.*\.//')"
							newLastDigit=$((oldLastDigit + 1))
							newVersion="$(echo "${version}" | sed "s/[^\\.]*\$/${newLastDigit}/")"
							cp pom.xml pom.xml.temp
							cat pom.xml.temp | sed '1,/<version>/s/\(<version>\)\([0-9\.]*\)\(<\/version>\)/\1'"${newVersion}"'\3/' > pom.xml
							rm pom.xml.temp
							git add pom.xml
							message="Bumped version from ${version} to ${newVersion} in preparation for a future release"
							git commit -m "${message}"
							if [ "$(git log --grep "${message}" | wc -l)" -gt 0 ]; then
								say "Bumped version from ${version} to ${newVersion} for future release"
							else
								say "git commit seemed to fail for the version bump from ${version} to ${newVersion}"
							fi

							if git push origin master; then
								say "Pushed new version number to github"
							else
								say "Could not push new version number to github"
							fi
						else
							say "Problem pushing tag v${version}"
						fi
					else
						say "Could not tag java client with version ${version} locally"
						say "Therefore can also not push tag"
					fi
                fi
            else
                say "New changes, but I can't push them"
            fi
        else
            say "Can't auto rebuild, something is seriously wrong"
        fi
    else
        say "All ok"
    fi
    cd
    rm -rf "${GOPATH}"
    echo
    echo =========================================
    echo
done
