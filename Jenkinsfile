/*
 * Copyright (c) 2022, 2023 Contributors to the Eclipse Foundation
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v. 2.0, which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * This Source Code may also be made available under the following Secondary
 * Licenses when the conditions for such availability set forth in the
 * Eclipse Public License v. 2.0 are satisfied: GNU General Public License,
 * version 2 with the GNU Classpath Exception, which is available at
 * https://www.gnu.org/software/classpath/license.html.
 *
 * SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
 */

pipeline {
  options {
    // keep at most 50 builds
    buildDiscarder(logRotator(numToKeepStr: '50'))
    // abort pipeline if previous stage is unstable
    skipStagesAfterUnstable()
    // show timestamps in logs
    timestamps()
    // global timeout, abort after 6 hours
    timeout(time: 20, unit: 'MINUTES')
  }
  agent {
    kubernetes {
      inheritFrom "basic"
      yaml """
apiVersion: v1
kind: Pod
metadata:
spec:
  containers:
  - name: maven
    image: maven:3.9.0-eclipse-temurin-17
    command:
    - cat
    tty: true
    env:
    - name: "HOME"
      value: "/home/jenkins"
    - name: "MAVEN_OPTS"
      value: "-Duser.home=/home/jenkins -Xmx2500m -Xss768k -XX:+UseG1GC -XX:+UseStringDeduplication"
    volumeMounts:
    - name: maven-repo-shared-storage
      mountPath: "/home/jenkins/.m2/repository"
    - name: maven-repo-local-storage
      mountPath: "/home/jenkins/.m2/repository/org/glassfish/external"
    resources:
      limits:
        memory: "8Gi"
        cpu: "4000m"
      requests:
        memory: "8Gi"
        cpu: "4000m"
  volumes:
    - name: maven-repo-shared-storage
      persistentVolumeClaim:
        claimName: glassfish-maven-repo-storage
    - name: maven-repo-local-storage
      emptyDir: {}
"""
    }
  }

  stages {
    stage('build') {
      steps {
        container('maven') {
          timeout(time: 10, unit: 'MINUTES') {
            sh '''
              find . -maxdepth 2 -name pom.xml -exec bash -c 'mvn clean install -Pstaging -f "$1"' - {} \\;
            '''
            junit testResults: '**/target/surefire-reports/*.xml', allowEmptyResults: true
          }
        }
      }
    }
  }
}
