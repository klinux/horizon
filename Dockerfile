FROM centos:centos7

ENV HORIZON_BASEDIR=/opt/horizon \
    LANG=en_US.UTF-8 \
    VERSION=stable/stein

EXPOSE 80

RUN yum upgrade -y

RUN yum install epel-release -y && \
    yum install -y \
    httpd httpd-devel python3-pip python3-devel git-core gcc openssl-devel libffi-devel which pkg-config gettext

# Libs infra
RUN pip3 install --upgrade pip && \
    pip3 install python-memcached && \
    pip3 install django-widget-tweaks && \
    pip3 install rcssmin && \
    pip3 install mod-wsgi

WORKDIR ${HORIZON_BASEDIR}

# Policies
RUN mkdir /etc/openstack-dashboard && chmod -R 755 /etc/openstack-dashboard

COPY policies/keystone_policy.json /etc/openstack-dashboard/keystone_policy.json

# Build
RUN git clone --branch 15.3.2 --depth 1 https://github.com/klinux/horizon.git ${HORIZON_BASEDIR} && \
    pip3 install -c https://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?h=stable/stein .

COPY local_settings.py ${HORIZON_BASEDIR}/openstack_dashboard/local/local_settings.py

# Modules
RUN pip3 install django_compressor==2.4 && \
    pip3 install csscompressor && \
    pip3 install heat-dashboard==1.5.1 && \
    pip3 install python-heatclient==1.17.1 && \
    pip3 install designate-dashboard==8.0.0 && \
    pip3 install python-designateclient==2.11.0 && \
    pip3 install manila-ui==2.18.1 && \
    pip3 install python-manilaclient==1.27.0 && \
    pip3 install trove-dashboard

# Modules settings
RUN cp /usr/local/lib/python3.6/site-packages/manila_ui/local/enabled/_[0-9]*.py /opt/horizon/openstack_dashboard/local/enabled/ && \
    cp /usr/local/lib/python3.6/site-packages/manila_ui/local/local_settings.d/_90_manila_*.py /opt/horizon/openstack_dashboard/local/local_settings.d/ && \
    cp /usr/local/lib/python3.6/site-packages/designatedashboard/enabled/_[1-9]*.py /opt/horizon/openstack_dashboard/local/enabled/ && \
    cp /usr/local/lib/python3.6/site-packages/heat_dashboard/enabled/_[0-9]*.py /opt/horizon/openstack_dashboard/local/enabled/ &&  \
    cp /usr/local/lib/python3.6/site-packages/trove_dashboard/enabled/_[0-9]*.py /opt/horizon/openstack_dashboard/local/enabled/

RUN python3 manage.py compilemessages && \
    python3 manage.py collectstatic --noinput && \
    python3 manage.py compress --force && \
    python3 manage.py make_web_conf --wsgi

RUN rm -rf /etc/httpd/conf.d/* && \
    python3 manage.py make_web_conf --apache > /etc/httpd/conf.d/horizon.conf && \
    sed -i 's/<VirtualHost \*.*/<VirtualHost _default_:80>/g' /etc/httpd/conf.d/horizon.conf && \
    chown -R apache:apache ${HORIZON_BASEDIR} && \
    python3 -m compileall $HORIZON_BASEDIR && \
    sed -i '/ErrorLog/c\    ErrorLog \/dev\/stderr' /etc/httpd/conf.d/horizon.conf && \
    sed -i '/CustomLog/c\    CustomLog \/dev\/stdout combined' /etc/httpd/conf.d/horizon.conf && \
    sed -i '/ErrorLog/c\    ErrorLog \/dev\/stderr' /etc/httpd/conf/httpd.conf && \
    mod_wsgi-express install-module > /etc/httpd/conf.modules.d/10-wsgi.conf

RUN yum remove -y httpd-devel python3-devel git-core gcc openssl-devel libffi-devel

COPY apache/mod_deflate.conf /etc/httpd/conf.d/mod_deflate.conf

CMD /usr/sbin/httpd -DFOREGROUND
