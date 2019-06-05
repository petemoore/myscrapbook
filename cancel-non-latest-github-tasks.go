package main

import (
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/taskcluster/taskcluster-client-go/tcgithub"
	"github.com/taskcluster/taskcluster-client-go/tcqueue"
)

// Run this script like this:
//
//  go run cancel-non-latest-github-tasks.go <DIR>
//
// DIR should be a local git checkout of a github repo where there is a .taskcluster.yml
// integration. This script will cancel all tasks that are unscheduled/pending/running
// that are *NOT* associated with the latest commit.
//
// This is useful if you have pushed a new commit, and you don't care about tasks
// associated with previous commits.
func main() {
	dir := os.Args[1]
	myGithub := tcgithub.NewFromEnv()
	queue := tcqueue.NewFromEnv()
	data, err := exec.Command("git", "-C", dir, "log", "--pretty=format:%H").Output()
	if err != nil {
		log.Fatal(err)
	}
	for _, revision := range strings.Split(string(data), "\n")[1:] {
		ctGithubBuilds := ""
		for {
			b, err := myGithub.Builds(ctGithubBuilds, "20", "", "", revision)
			if err != nil {
				panic(err)
			}
			for _, build := range b.Builds {
				log.Printf("git commit %v: task group: https://tools.taskcluster.net/groups/%v", revision, build.TaskGroupID)
				ctListTaskGroup := ""
				for {
					ltgr, err := queue.ListTaskGroup(build.TaskGroupID, ctListTaskGroup, "")
					if err != nil {
						panic(err)
					}
					for _, task := range ltgr.Tasks {
						if task.Status.State != "completed" && task.Status.State != "failed" && task.Status.State != "exception" {
							log.Printf("Cancelling task %v...", task.Status.TaskID)
							tsr, err := queue.CancelTask(task.Status.TaskID)
							if err != nil {
								panic(err)
							}
							log.Printf("State: %v", tsr.Status.State)
						}
					}
					ctListTaskGroup = ltgr.ContinuationToken
					if ctListTaskGroup == "" {
						break
					}
				}
			}
			ctGithubBuilds = b.ContinuationToken
			if ctGithubBuilds == "" {
				break
			}
		}
	}
}
