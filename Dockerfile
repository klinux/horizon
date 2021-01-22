FROM centos:centos7

ENV HORIZON_BASEDIR=/opt/horizon \
    LANG=en_US.UTF-8 \
    VERSION=stable/stein

EXPOSE 80

RUN yum upgrade -y

RUN yum install epel-release -y && \
    yum install -y \
    httpd httpd-devel python3-pip python3-devel git-core gcc openssl-devel libffi-devel which pkg-config gettext

RUN pip3 install --upgrade pip && \
    pip3 install python-memcached && \
    pip3 install django-widget-tweaks && \
    pip3 install rcssmin && \
    pip3 install mod-wsgi

WORKDIR ${HORIZON_BASEDIR}

RUN echo 18

RUN git clone --branch 15.3.2 --depth 1 https://github.com/klinux/horizon.git ${HORIZON_BASEDIR} && \
    pip3 install -c https://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?h=stable/stein .

COPY local_settings.py ${HORIZON_BASEDIR}/openstack_dashboard/local/local_settings.py

RUN pip3 install csscompressor && \
    pip install django_compressor==2.4

RUN python3 manage.py compilemessages && \
    python3 manage.py collectstatic --noinput && \
    python3 manage.py compress --force && \
    python3 manage.py make_web_conf --wsgi

RUN rm -rf /etc/httpd/conf.d/* && \
    python3 manage.py make_web_conf --apache > /etc/httpd/conf.d/horizon.conf && \
    sed -i 's/<VirtualHost \*.*/<VirtualHost _default_:80>/g' /etc/httpd/conf.d/horizon.conf && \
    chown -R apache:apache ${HORIZON_BASEDIR} && \
    python3 -m compileall $HORIZON_BASEDIR && \
    sed -i '/ErrorLog/c\    ErrorLog \/dev\/stderr' /etc/httpd/conf/httpd.conf && \
    mod_wsgi-express install-module > /etc/httpd/conf.modules.d/10-wsgi.conf

RUN yum remove -y httpd-devel python3-devel git-core gcc openssl-devel libffi-devel

COPY apache/mod_deflate.conf /etc/httpd/conf.d/mod_deflate.conf

CMD /usr/sbin/httpd -DFOREGROUND
