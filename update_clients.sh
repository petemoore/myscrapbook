#!/bin/bash -xv

function git_no_gpg_signing {
    git -c "commit.gpgsign=false" "${@}"
}

# say -v Daniel "let's go mr driver"
source ~/update_clients.env
if [ -z "${TASKCLUSTER_CLIENT_ID}" ] || [ -z "${TASKCLUSTER_ACCESS_TOKEN}" ] || [ -z "${TASKCLUSTER_ROOT_URL}" ]; then
    say -v Samantha "No credentials for me to use with taskcluster"
    exit 1
fi
export DEBUG=*
# taskcluster-client-java code generation broken, not a priority to fix, so commented out
# for repo in taskcluster-client-go taskcluster-client-java
for repo in taskcluster-client-go
do
    export GOPATH="$(mktemp -d -t update_clients.XXXXXXXXXX)"
    export PATH="${GOPATH}/bin:${PATH}"
    export TIMESTAMP="$(date +%s)"
    rm -rf "${GOPATH}"
    go get -t -d "github.com/taskcluster/${repo}/..."
    cd "${GOPATH}/src/github.com/taskcluster/${repo}"
    # this will fail if there are changes
    if ! ./build.sh; then
        # but is not the only reason it might fail, so let's see
        # if adding changes fixes it
        git_no_gpg_signing add .
        git_no_gpg_signing commit -m "Temporary commit that should not get pushed to github"
        # build again to make sure all is ok since git status should report no differences this time, so exit code is reliable
        # note we only push if this second build is successful
        if ./build.sh; then
            # build now passes, so finally let's update timestamps by rebuilding without -d
            say -v Samantha "New successful changes found, building again to pick up new date"
            if ./build.sh -d; then
                # remove last temporary commit from lines above
                git_no_gpg_signing reset 'HEAD~1'
                git_no_gpg_signing add .
                git_no_gpg_signing commit -m "Regenerated library to pick up latest schema changes"
                if git_no_gpg_signing push "git@github.com:taskcluster/${repo}.git" master; then
                    say -v Samantha "New changes pushed, yahoo"
                    if [ "${repo}" == 'taskcluster-client-java' ]; then
                        version="$(cat pom.xml | sed -n '1,/<version>/s/.*<version>\([0-9\.]*\)<\/version>.*/\1/p')"
                        mvn javadoc:javadoc
                        git_no_gpg_signing checkout gh-pages
                        rm -rf apidocs
                        mv target/site/apidocs .
                        git_no_gpg_signing add apidocs
                        git_no_gpg_signing commit -m "Regenerated javadocs after api update(s)"
                        if git_no_gpg_signing push "git@github.com:taskcluster/${repo}.git" gh-pages:gh-pages; then
                            say -v Samantha "New javadocs published"
                        else
                            say -v Samantha "Could not publish updated javadocs"
                        fi
                        git_no_gpg_signing reset master
                        git_no_gpg_signing checkout -f master
                        git_no_gpg_signing clean -fd
                        if mvn deploy -P release; then
                            say -v Samantha "Published java client version ${version} to maven central"
                        else
                            say -v Samantha "Could not publish java client version ${version} to maven central"
                        fi
                        if git_no_gpg_signing tag -m "Released version ${version}" "v${version}"; then
                            say -v Samantha "Tagged locally"
                            if git_no_gpg_signing push "git@github.com:taskcluster/${repo}.git" "refs/tags/v${version}:refs/tags/v${version}"; then
                                say -v Samantha "Pushed tag v${version}"
                                oldLastDigit="$(echo "${version}" | sed 's/.*\.//')"
                                newLastDigit=$((oldLastDigit + 1))
                                newVersion="$(echo "${version}" | sed "s/[^\\.]*\$/${newLastDigit}/")"
                                cp pom.xml pom.xml.temp
                                cat pom.xml.temp | sed '1,/<version>/s/\(<version>\)\([0-9\.]*\)\(<\/version>\)/\1'"${newVersion}"'\3/' > pom.xml
                                rm pom.xml.temp
                                git_no_gpg_signing add pom.xml
                                message="Bumped version from ${version} to ${newVersion} in preparation for a future release"
                                git_no_gpg_signing commit -m "${message}"
                                if [ "$(git log --grep "${message}" | wc -l)" -gt 0 ]; then
                                    say -v Samantha "Bumped version from ${version} to ${newVersion} for future release"
                                else
                                    say -v Samantha "git commit seemed to fail for the version bump from ${version} to ${newVersion}"
                                fi

                                if git_no_gpg_signing push "git@github.com:taskcluster/${repo}.git" master; then
                                    say -v Samantha "Pushed new version number to github"
                                else
                                    say -v Samantha "Could not push new version number to github"
                                fi
                            else
                                say -v Samantha "Problem pushing tag v${version}"
                            fi
                        else
                            say -v Samantha "Could not tag java client with version ${version} locally"
                            say -v Samantha "Therefore can also not push tag"
                        fi
                    fi
                else
                    say -v Samantha "New changes, but I can't push them"
                fi
            else
                say -v Samantha "Build without minus d failed, this is a serious problem"
            fi
        else
            say -v Samantha "Can't auto rebuild, something is seriously wrong"
            git_no_gpg_signing status
            git_no_gpg_signing diff
        fi
    else
        # say -v Samantha "${repo} ok"
		true
    fi
    cd
    rm -rf "${GOPATH}"
    echo
    echo =========================================
    echo
done
