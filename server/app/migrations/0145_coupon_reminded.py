# -*- coding: utf-8 -*-
# Generated by Django 1.9.6 on 2016-06-14 09:23
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0144_timeslot_reminded'),
    ]

    operations = [
        migrations.AddField(
            model_name='coupon',
            name='reminded',
            field=models.BooleanField(default=False),
        ),
    ]
