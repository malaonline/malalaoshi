# -*- coding: utf-8 -*-
# Generated by Django 1.9.2 on 2016-03-21 08:40
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0121_auto_20160317_2102'),
    ]

    operations = [
        migrations.CreateModel(
            name='TeacherVistParent',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('web_visited', models.BooleanField(default=False)),
                ('parent', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='app.Parent')),
                ('teacher', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='app.Teacher')),
            ],
        ),
        migrations.AddField(
            model_name='comment',
            name='web_visited',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='timeslot',
            name='web_visited',
            field=models.BooleanField(default=False),
        ),
        migrations.AlterUniqueTogether(
            name='teachervistparent',
            unique_together=set([('teacher', 'parent')]),
        ),
    ]
