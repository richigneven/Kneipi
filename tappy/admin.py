from django.contrib import admin
from .models import Bar, Review

@admin.register(Bar)
class BarAdmin(admin.ModelAdmin):
    list_display = ('name', 'city', 'created_at')
    search_fields = ('name', 'city', 'tags')

@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('bar', 'rating', 'created_at')
    search_fields = ('bar__name',)
