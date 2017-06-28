# -*- coding: utf-8 -*-
# Generated by Django 1.9.8 on 2017-06-28 10:04
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0186_change_user_group'),
    ]

    operations = [
        migrations.CreateModel(
            name='SchoolIncomeRecordV2',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('students_count', models.PositiveSmallIntegerField()),
                ('shared_rate', models.PositiveSmallIntegerField()),
                ('status', models.CharField(choices=[('p', '待处理'), ('a', '已通过'), ('r', '被驳回')], default='p', max_length=2)),
                ('type', models.CharField(choices=[('1st', '首款'), ('2nd', '尾款')], max_length=4)),
                ('total_amount', models.PositiveIntegerField()),
                ('remark', models.CharField(blank=True, max_length=300, null=True)),
                ('income_time', models.DateTimeField()),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('live_class', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='app.LiveClass')),
                ('school_account', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='app.SchoolAccount')),
            ],
            options={
                'abstract': False,
            },
        ),
    ]