from django.db import models

# Create your models here.
class User(models.Model):
	headImg = models.FileField(upload_to = './upload/')

	def __unicode__(self):
		return self.username
