#coding=utf-8
from django.shortcuts import render,render_to_response
from django import forms
from django.http import HttpResponse
from disk.models import User
import os
import json

# Create your views here.

class UserForm(forms.Form):
	headImg = forms.FileField()

def upload(request):
	if request.method == "POST":
		uf = UserForm(request.POST,request.FILES)
		if uf.is_valid():
			# 获取表单信息
			headImg = uf.cleaned_data['headImg']
			# 写入数据库
			path = os.getcwd()
			filePath = os.path.join(path, 'upload')
			for file in os.listdir(filePath):
				if file == headImg.name:
					return HttpResponse('upload ok!')

			user = User()
			user.headImg = headImg
			user.save()
			return HttpResponse('upload ok!')
	else:
		uf = UserForm()
	return render_to_response('register.html',{'uf':uf})
	
def getList(request):
	if request.method == "GET":
		path = os.getcwd()
		filePath = os.path.join(path, 'upload')
		arr = []
		for file in os.listdir(filePath):
			if file.startswith('.'):
				continue
			arr.append(file)
		response_data = {}
		response_data['result'] = 'success'
		response_data['files'] = arr
		return HttpResponse(json.dumps(response_data), content_type="application/json")
		
def download(request):
	str = request.REQUEST.get('filename','xxx')
	path = os.getcwd()
	filePath = os.path.join(path, 'upload', str)
	if os.path.isfile(filePath):
		with open(filePath) as f:
			stream = f.read()
		return HttpResponse(stream)
	else:
		return HttpResponse('no file', status=404)
