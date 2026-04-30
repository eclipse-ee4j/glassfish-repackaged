#!/bin/bash
set -e

directories='ant,derby,dbschema,schema2beans'
directory=$1
version=$2
nextVersion=$3

function existsInList() {
    VALUE=$1
    LIST=$2
    DELIMITER=','
    [[ "$LIST" =~ ($DELIMITER|^)$VALUE($DELIMITER|$) ]]
}

if [ -z "$directory" ] ; then
    echo "First argument must be one of: $directories"
    exit 1;
fi
if ! existsInList "$directory" "$directories" ; then
    echo "Subdirectory $directory is not supported by this script."
    exit 2;
fi

if [ -z "$version" ]; then
    echo "Second argument must be a version."
    echo "The current version of the project $directory is $(mvn help:evaluate -f $directory -Dexpression=project.version -q -DforceStdout)."
    exit 3;
fi

if [ -z "$nextVersion" ]; then
    echo "Third argument must be a next snapshot version."
    exit 4;
fi
if ! [[ $nextVersion == *-SNAPSHOT ]] then
    echo "The next version must be a SNAPSHOT"
    exit 5;
fi

currentBranch=$(git branch --show-current)
if [[ $currentBranch == "master" ]] then
    echo "Please checkout to a release branch serving just for the release. For example, run 'git checkout -b RELEASE_ANT'."
    exit 6;
fi

echo "Releasing $directory $version, the next version will be set to $nextVersion, the work will be done in a branch $currentBranch"
tag=$directory-$version

rm -f ./*/pom.xml.releaseBackup ./*/release.properties
mvn -f $directory release:prepare -DpushChanges=false -DdevelopmentVersion=$nextVersion -DreleaseVersion=$version -Dtag=$tag -Dresume=false
rm -f ./*/pom.xml.releaseBackup ./*/release.properties

echo "The release is ready, now push the $currentBranch and the tag $tag to the Eclipse's GitHub repository:"
echo "git push eclipse $currentBranch"
echo "git push eclipse $tag"
echo "Then visit https://ci.eclipse.org/glassfish/view/Release/job/repackaged-deploy/"
echo "and run the deployment of the $directory for tag named $tag."
echo "After the deployment and publishing create a pull request to the master branch using GitHub UI."
echo ""
echo "If you don't like the result and you did not publish artifacts to Maven Central yet, run these commands:"
echo "git reset --hard HEAD^^"
echo "git tag -d $tag"
echo ""
echo "If you already pushed the branch and the tag, but you still did not publish to Maven Central, you should also drop the remote branch:"
echo "git push eclipse :$currentBranch"
echo "git push eclipse :$tag"
echo ""
echo "If you already published everything, you can still delete the branch, but never delete tags!"
