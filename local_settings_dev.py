import os
from django.utils.translation import ugettext_lazy as _
from openstack_dashboard import exceptions
from openstack_dashboard.settings import HORIZON_CONFIG


DEBUG = True
TEMPLATE_DEBUG = DEBUG
PROD = False
WEBROOT = '/'
#ALLOWED_HOSTS = ['*']
HOST_LOCAL = "192.168.0.100"

COMPRESS_ENABLED = False
COMPRESS_OFFLINE = False

AVAILABLE_THEMES = [
    ('default', 'Default', 'themes/default'),
    ('cloudwise', 'CloudWise', 'themes/cloudwise'),
]

OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
    "compute": 2,
}

LOCAL_PATH = '/tmp'

SESSION_ENGINE = 'django.contrib.sessions.backends.signed_cookies'

OPENSTACK_HOST = HOST_LOCAL
OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "member"
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True 

OPENSTACK_KEYSTONE_BACKEND = {
    'name': 'native',
    'can_edit_user': True,
    'can_edit_group': True,
    'can_edit_project': True,
    'can_edit_domain': True,
    'can_edit_role': True,
}
OPENSTACK_HYPERVISOR_FEATURES = {
    'can_set_mount_point': False,
    'can_set_password': False,
    'requires_keypair': False,
}

OPENSTACK_CINDER_FEATURES = {
    'enable_backup': False,
}

OPENSTACK_NEUTRON_NETWORK = {
    'enable_router': True,
    'enable_quotas': True,
    'enable_ipv6': True,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_firewall': True,
    'enable_vpn': True,
    'enable_fip_topology_check': True,
    # Neutron can be configured with a default Subnet Pool to be used for IPv4
    # subnet-allocation. Specify the label you wish to display in the Address
    # pool selector on the create subnet step if you want to use this feature.
    'default_ipv4_subnet_pool_label': None,
    # Neutron can be configured with a default Subnet Pool to be used for IPv6
    # subnet-allocation. Specify the label you wish to display in the Address
    # pool selector on the create subnet step if you want to use this feature.
    # You must set this to enable IPv6 Prefix Delegation in a PD-capable
    # environment.
    'default_ipv6_subnet_pool_label': None,
    # The profile_support option is used to detect if an external router can be
    # configured via the dashboard. When using specific plugins the
    # profile_support can be turned on if needed.
    'profile_support': None,
    #'profile_support': 'cisco',
    # Set which provider network types are supported. Only the network types
    # in this list will be available to choose from when creating a network.
    # Network types include local, flat, vlan, gre, and vxlan.
    'supported_provider_types': ['*'],
    # Set which VNIC types are supported for port binding. Only the VNIC
    # types in this list will be available to choose from when creating a
    # port.
    # VNIC types include 'normal', 'macvtap' and 'direct'.
    # Set to empty list or None to disable VNIC type selection.
    'supported_vnic_types': ['*']
}

OPENSTACK_IMAGE_BACKEND = {
    'image_formats': [
        ('', _('Select format')),
        ('aki', _('AKI - Amazon Kernel Image')),
        ('ami', _('AMI - Amazon Machine Image')),
        ('ari', _('ARI - Amazon Ramdisk Image')),
        ('docker', _('Docker')),
        ('iso', _('ISO - Optical Disk Image')),
        ('ova', _('OVA - Open Virtual Appliance')),
        ('qcow2', _('QCOW2 - QEMU Emulator')),
        ('raw', _('Raw')),
        ('vdi', _('VDI - Virtual Disk Image')),
        ('vhd', _('VHD - Virtual Hard Disk')),
        ('vhdx', _('VHDX - Large Virtual Hard Disk')),
        ('vmdk', _('VMDK - Virtual Machine Disk')),
    ],
}

IMAGE_CUSTOM_PROPERTY_TITLES = {
    "architecture": _("Architecture"),
    "kernel_id": _("Kernel ID"),
    "ramdisk_id": _("Ramdisk ID"),
    "image_state": _("Euca2ools state"),
    "project_id": _("Project ID"),
    "image_type": _("Image Type"),
}

IMAGE_RESERVED_CUSTOM_PROPERTIES = []

API_RESULT_LIMIT = 1000
API_RESULT_PAGE_SIZE = 20

SWIFT_FILE_TRANSFER_CHUNK_SIZE = 512 * 1024

DROPDOWN_MAX_ITEMS = 30

TIME_ZONE = "UTC"
