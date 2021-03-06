FROM centos:centos8

ENV HORIZON_BASEDIR=/opt/horizon \
    LANG=en_US.UTF-8 \
    VERSION=stable/victoria

EXPOSE 80

RUN yum upgrade -y

RUN yum install epel-release -y && \
    yum install -y \
    httpd httpd-devel python3-pip python3-devel git-core gcc openssl-devel libffi-devel which pkg-config gettext redhat-rpm-config

# Libs infra
RUN pip3 install --upgrade pip && \
    pip3 install python-memcached && \
    pip3 install django-widget-tweaks && \
    pip3 install rcssmin && \
    pip3 install mod-wsgi

WORKDIR ${HORIZON_BASEDIR}

# Policies
RUN mkdir /etc/openstack-dashboard && chmod -R 755 /etc/openstack-dashboard

COPY policies/ /etc/openstack-dashboard/


# Build
RUN git clone --branch 18.6.1 --depth 1 https://github.com/klinux/horizon.git ${HORIZON_BASEDIR} && \
    pip3 install -c https://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?h=stable/victoria .

COPY local_settings.py ${HORIZON_BASEDIR}/openstack_dashboard/local/local_settings.py

# Modules
RUN pip3 install csscompressor && \
    pip3 install heat-dashboard==4.0.0 && \
    pip3 install python-heatclient==2.2.1 && \
    pip3 install designate-dashboard==11.0.0 && \
    pip3 install python-designateclient==4.1.0 && \
    pip3 install manila-ui==4.0.0 && \
    pip3 install python-manilaclient==2.3.0 && \
    pip3 install trove-dashboard==15.0.0 && \
    pip3 install cloudkitty-dashboard==11.0.0

# Modules settings
RUN cp /usr/local/lib/python3.6/site-packages/manila_ui/local/enabled/_[0-9]*.py /opt/horizon/openstack_dashboard/local/enabled/ && \
    cp /usr/local/lib/python3.6/site-packages/manila_ui/local/local_settings.d/_90_manila_*.py /opt/horizon/openstack_dashboard/local/local_settings.d/ && \
    cp /usr/local/lib/python3.6/site-packages/designatedashboard/enabled/_[1-9]*.py /opt/horizon/openstack_dashboard/local/enabled/ && \
    cp /usr/local/lib/python3.6/site-packages/heat_dashboard/enabled/_[0-9]*.py /opt/horizon/openstack_dashboard/local/enabled/ &&  \
    cp /usr/local/lib/python3.6/site-packages/trove_dashboard/enabled/_[0-9]*.py /opt/horizon/openstack_dashboard/local/enabled/ && \
    cp /usr/local/lib/python3.6/site-packages/cloudkittydashboard/enabled/_[0-9]*.py /opt/horizon/openstack_dashboard/local/enabled/

# Patchs
#RUN sed -i 's/return \[{\"net-id\"\:\ netid,\ \"v4-fixed-ip\"\:\ \"\"}/return\ \[{\"net-id\":\ netid}/g' /usr/local/lib/python3.6/site-packages/trove_dashboard/content/databases/workflows/create_instance.py

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

RUN yum remove -y httpd-devel python3-devel git-core gcc openssl-devel libffi-devel redhat-rpm-config

COPY apache/mod_deflate.conf /etc/httpd/conf.d/mod_deflate.conf

CMD /usr/sbin/httpd -DFOREGROUND
