# -*- coding: utf-8 -*-
# Generated by Django 1.9.4 on 2016-03-15 09:47
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0116_tag'),
    ]

    operations = [
        migrations.AlterField(
            model_name='school',
            name='latitude',
            field=models.FloatField(),
        ),
        migrations.AlterField(
            model_name='school',
            name='longitude',
            field=models.FloatField(),
        ),
    ]
