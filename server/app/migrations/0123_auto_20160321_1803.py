# -*- coding: utf-8 -*-
# Generated by Django 1.9.2 on 2016-03-21 10:03
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0122_auto_20160321_1640'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='teachervistparent',
            unique_together=set([]),
        ),
        migrations.RemoveField(
            model_name='teachervistparent',
            name='parent',
        ),
        migrations.RemoveField(
            model_name='teachervistparent',
            name='teacher',
        ),
        migrations.DeleteModel(
            name='TeacherVistParent',
        ),
    ]
