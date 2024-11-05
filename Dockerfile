FROM registry.access.redhat.com/ubi9/ubi:latest AS base


RUN printf "[buildkite-agent]\n\
name = Buildkite Pty Ltd\n\
baseurl = https://yum.buildkite.com/buildkite-agent/stable/x86_64/\n\
enabled=1\n\
gpgcheck=0\n\
priority=1" > /etc/yum.repos.d/buildkite-agent.repo && \
    dnf update -y && \
    dnf install -y buildah buildkite-agent && \
    dnf clean all

COPY entrypoint.sh /entrypoint.sh


WORKDIR /workspace

# Add buildkite-agent user to group 0 for Openshift
RUN umask 002 && \
    usermod --gid 0 buildkite-agent && \
    chmod g+rwx $HOME /workspace

 RUN touch /etc/subgid /etc/subuid && \
 chmod g=u /etc/subgid /etc/subuid /etc/passwd && \
 echo buildkite-agent:10000:65536 > /etc/subuid && \
 echo buildkite-agent:10000:65536 > /etc/subgid

USER buildkite-agent

VOLUME /buildkite
ENTRYPOINT ["sh"]
CMD ["-c", "entrypoint.sh", "buildkite-agent start"]