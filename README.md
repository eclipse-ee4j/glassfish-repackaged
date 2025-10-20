# repackaged
Copies of third party open source projects that are used in the build of GlassFish, along with tools to build those projects. GlassFish depends on the versions of these projects that we build, not directly on binaries produced by the originating project.

# How to Release Derby

1. Check the derby.version in the POM. Don't override it on command line, it must be same as the redeployed artifact version - or a snapshot. Copy the derby.version to the bash property, see the example.

2. Example:
```
version=10.17.1.0
git checkout -b release
mvn release:prepare -DpushChanges=false -DdevelopmentVersion=10.17.1.0-SNAPSHOT -DreleaseVersion=${version} -Dtag=Derby-${version} -Dresume=false
git push eclipse Derby-${version}
```

3. Visit Eclipse CI and run the deployment for Derby and the tag: https://ci.eclipse.org/glassfish/view/Release/job/repackaged-deploy
4. Visit Maven Central Deployments: https://central.sonatype.com/publishing/deployments
5. Manually check that everything is as expected for the last time and press Drop or publish.
6. Wait until the package is distributed to Maven Central. Not that UI indexes are updated with large latency, but artifacts will be available sooner.
7. Finally push th branch and create a PR to master
```
git push eclipse release_derby
```
