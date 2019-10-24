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
ENV LANG=C.UTF-8

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.29-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

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
RUN chmod u+x /usr/local/bin/oc && chmod u+x /usr/local/bin/kubectl
CMD ["/usr/local/bin/oc"]
