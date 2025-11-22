from django.shortcuts import render, get_object_or_404
from .models import Bar

def index(request):
    q = request.GET.get('q', '')
    if q:
        bars = Bar.objects.filter(name__icontains=q)[:50]
    else:
        bars = Bar.objects.all()[:50]
    return render(request, 'index.html', {'bars': bars, 'q': q})

def detail(request, pk):
    bar = get_object_or_404(Bar, pk=pk)
    return render(request, 'detail.html', {'bar': bar})
