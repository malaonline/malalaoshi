# -*- coding: utf-8 -*-
# Generated by Django 1.9.6 on 2016-09-13 03:30
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0161_schoolmaster'),
    ]

    operations = [
        migrations.CreateModel(
            name='SchoolAccount',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('account_name', models.CharField(blank=True, max_length=100, null=True)),
                ('account_number', models.CharField(blank=True, max_length=100, null=True)),
                ('bank_name', models.CharField(blank=True, max_length=100, null=True)),
                ('bank_address', models.CharField(blank=True, max_length=200, null=True)),
                ('swift_code', models.CharField(blank=True, max_length=50, null=True)),
                ('school', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to='app.School')),
            ],
            options={
                'abstract': False,
            },
        ),
    ]
