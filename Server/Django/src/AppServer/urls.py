from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'testUpload.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^admin/', include(admin.site.urls)),
	url(r'^upload/', 'disk.views.upload'),
    url(r'^getList/', 'disk.views.getList'),
    url(r'^download/', 'disk.views.download'),
)
