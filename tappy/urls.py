from django.urls import path
from . import views

app_name = 'tappy'

urlpatterns = [
    path('', views.index, name='index'),
    path('bar/<int:pk>/', views.detail, name='detail'),
]
