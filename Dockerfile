FROM jenkins/jnlp-slave:alpine

ENV JENKINS_AGENT_WORKDIR /var/jenkins

USER root

RUN apk update && \
    apk upgrade && \
    apk add openssl curl ca-certificates 
RUN apk add --no-cache docker \
            bash \
            git \
            unzip && \
    rm -rf /var/cache/apk/* 


# RUN set -x \
# # create nginx user/group first, to be consistent throughout docker variants
#     && addgroup -g 101 -S jenkins \
#     && adduser -S -D -H -u 101 -h /var/cache/jenkins -s /sbin/nologin -G jenkins -g jenkins jenkins
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 

RUN curl https://artifacts-openshift-release-3-11.svc.ci.openshift.org/zips/openshift-origin-client-tools-v3.11.0-bd0bee4-337-linux-64bit.tar.gz -o /tmp/openshift-origin-client-tools-v3.11.0-bd0bee4-337-linux-64bit.tar.gz 
RUN cd /tmp/ && tar -xzf /tmp/openshift-origin-client-tools-v3.11.0-bd0bee4-337-linux-64bit.tar.gz && \
    mv /tmp/openshift-origin-client-tools-v3.11.0-bd0bee4-337-linux-64bit/oc /tmp/openshift-origin-client-tools-v3.11.0-bd0bee4-337-linux-64bit/kubectl /usr/local/bin/ && \
    rm -rf /tmp/openshift-origin-client*
# RUN mv /tmp/openshift-origin-client-tools-v3.11.0-bd0bee4-337-linux-64bit/oc /tmp/openshift-origin-client-tools-v3.11.0-bd0bee4-337-linux-64bit/kubectl /usr/local/bin/
# RUN curl https://artifacts-openshift-release-3-11.svc.ci.openshift.org/zips/openshift-origin-client-tools-v3.11.0-bd0bee4-337-linux-64bit.tar.gz | tar -zx 
RUN ls -la /tmp/
RUN ls -la /usr/local/bin/
# RUN chmod u+x /usr/local/bin/oc && chmod u+x /usr/local/bin/kubectl
