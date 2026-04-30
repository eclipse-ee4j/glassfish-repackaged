# repackaged
Copies of third party open source projects that are used to build Eclipse GlassFish, along with tools to build those projects.
GlassFish depends on the versions of these projects that we build, not directly on binaries produced by the originating project.

# How to Release

All subdirectories follow the same pattern. In the following text we use Ant and intentionally incorrect version ids as an example.

1. Check versions of dependencies in the POM, update them and make necessary manual testing.
2. Create the release branch:
```
git checkout RELEASE_ANT
```
3. Run the script to prepare necessary changes. The script doesn't push anything outside your computer and will try to navigate you.
```
./release.sh ant 0.0.0 0.0.1-SNAPSHOT
```
4. Push branch and tag:
```
git push eclipse :RELEASE_ANT
git push eclipse :ant-1.10.17
```
5. Visit [Eclipse CI](https://ci.eclipse.org/glassfish/view/Release/job/repackaged-deploy) and run the deployment for Ant and the tag:
6. Visit [Maven Central Deployments](https://central.sonatype.com/publishing/deployments)
7. Manually check that everything is as expected for the last time and press Publish (or Drop to cancel the deployment).
8. Wait until the package is distributed to the Maven Central. Note that UI indexes are updated with large latency, but artifacts will be available sooner.
9. Finally create a PR to the master branch.
