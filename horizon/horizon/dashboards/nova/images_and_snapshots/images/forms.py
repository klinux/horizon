# vim: tabstop=4 shiftwidth=4 softtabstop=4

# Copyright 2011 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
#
# Copyright 2011 Nebula, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

"""
Views for managing Nova images.
"""

import logging

from django import shortcuts
from django.contrib import messages
from django.core.urlresolvers import reverse
from django.utils.text import normalize_newlines
from django.utils.translation import ugettext as _
from glance.common import exception as glance_exception

from horizon import api
from horizon import exceptions
from horizon import forms

LOG = logging.getLogger(__name__)


class UpdateImageForm(forms.SelfHandlingForm):
    image_id = forms.CharField(widget=forms.HiddenInput())
    name = forms.CharField(max_length="25", label=_("Name"))
    kernel = forms.CharField(max_length="25", label=_("Kernel ID"),
                             required=False)
    ramdisk = forms.CharField(max_length="25", label=_("Ramdisk ID"),
                              required=False)
    architecture = forms.CharField(label=_("Architecture"), required=False)
    container_format = forms.CharField(label=_("Container Format"),
                                       required=False)
    disk_format = forms.CharField(label=_("Disk Format"))

    def handle(self, request, data):
        # TODO add public flag to image meta properties
        image_id = data['image_id']
        error_retrieving = _('Unable to retrieve image "%s".')
        error_updating = _('Unable to update image "%s".')

        try:
            image = api.image_get_meta(request, image_id)
        except:
            exceptions.handle(request, error_retrieving % image_id)

        meta = {'is_public': True,
                'disk_format': data['disk_format'],
                'container_format': data['container_format'],
                'name': data['name'],
                'properties': {}}
        if data['kernel']:
            meta['properties']['kernel_id'] = data['kernel']
        if data['ramdisk']:
            meta['properties']['ramdisk_id'] = data['ramdisk']
        if data['architecture']:
            meta['properties']['architecture'] = data['architecture']

        try:
            api.image_update(request, image_id, meta)
            messages.success(request, _('Image was successfully updated.'))
        except:
            exceptions.handle(request, error_updating % image_id)
        return shortcuts.redirect('horizon:nova:images_and_snapshots:index')


class LaunchForm(forms.SelfHandlingForm):
    name = forms.CharField(max_length=80, label=_("Server Name"))
    image_id = forms.CharField(widget=forms.HiddenInput())
    tenant_id = forms.CharField(widget=forms.HiddenInput())
    user_data = forms.CharField(widget=forms.Textarea,
                                label=_("User Data"),
                                required=False)
    flavor = forms.ChoiceField(label=_("Flavor"),
                               help_text=_("Size of image to launch."))
    keypair = forms.ChoiceField(label=_("Keypair"),
                                required=False,
                                help_text=_("Which keypair to use for "
                                            "authentication."))
    security_groups = forms.MultipleChoiceField(
                                label=_("Security Groups"),
                                required=True,
                                initial=["default"],
                                widget=forms.CheckboxSelectMultiple(),
                                help_text=_("Launch instance in these "
                                            "security groups."))

    def __init__(self, *args, **kwargs):
        flavor_list = kwargs.pop('flavor_list')
        keypair_list = kwargs.pop('keypair_list')
        security_group_list = kwargs.pop('security_group_list')
        super(LaunchForm, self).__init__(*args, **kwargs)
        self.fields['flavor'].choices = flavor_list
        self.fields['keypair'].choices = keypair_list
        self.fields['security_groups'].choices = security_group_list

    def handle(self, request, data):
        try:
            api.server_create(request,
                              data['name'],
                              data['image_id'],
                              data['flavor'],
                              data.get('keypair'),
                              normalize_newlines(data.get('user_data')),
                              data.get('security_groups'))
            messages.success(request,
                             _('Instance "%s" launched.') % data["name"])
        except:
            redirect = reverse("horizon:nova:images_and_snapshots:index")
            exceptions.handle(request,
                              _('Unable to launch instance: %(exc)s'),
                              redirect=redirect)
        return shortcuts.redirect('horizon:nova:instances_and_volumes:index')
