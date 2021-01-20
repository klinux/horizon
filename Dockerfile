FROM centos:centos7

ENV HORIZON_BASEDIR=/opt/horizon \
    LANG=en_US.UTF-8 \
    VERSION=stable/stein

EXPOSE 80

RUN \
  yum upgrade -y && \
  yum install epel-release -y && \
  yum install -y \
    httpd httpd-devel python-pip python-devel git-core gcc openssl-devel libffi-devel which pkg-config gettext

RUN pip install --upgrade pip && \
    pip install python-memcached && \
    pip install django-widget-tweaks && \
    pip install mod-wsgi

WORKDIR ${HORIZON_BASEDIR}

RUN echo ls 5

RUN git clone --branch $VERSION --depth 1 https://github.com/klinux/horizon.git ${HORIZON_BASEDIR} && \
    pip install -I -c https://releases.openstack.org/constraints/upper/stein \
    -r requirements.txt

COPY local_settings.py ${HORIZON_BASEDIR}/openstack_dashboard/local/local_settings.py

RUN python manage.py compilemessages && \
    python manage.py collectstatic --noinput && \
    python manage.py compress && \
    python manage.py make_web_conf --wsgi

RUN rm -rf /etc/httpd/conf.d/* && \
    python -m compileall $HORIZON_BASEDIR && \
    sed -i '/ErrorLog/c\    ErrorLog \/dev\/stderr' /etc/httpd/conf/httpd.conf && \
    mod_wsgi-express install-module > /etc/httpd/conf.modules.d/10-wsgi.conf

COPY wsgi.conf /etc/httpd/conf.d/horizon.conf

RUN yum remove -y httpd-devel python-devel git-core gcc openssl-devel libffi-devel

CMD /usr/sbin/httpd -DFOREGROUND
