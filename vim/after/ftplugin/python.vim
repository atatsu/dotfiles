if getline(1) =~ 'from django.db import models'
    exec "Snippet addmodel class <{}>(models.Model):<CR><><CR><CR>def __unicode__(self):<CR>return "%s" % (<{}>,)"
    exec "Snippet mcf models.CharField(max_length=<{}>)<CR><{}>"
    exec "Snippet mff models.FileField(upload_to=<{}>)<CR><{}>"
    exec "Snippet mfpf models.FilePathField(path=<{}>, match="<{}>", recursive=<False>)<CR><{}>"
    exec "Snippet mfloat models.FloatField(max_digits=<{}>, decimal_places=<{}>)<CR><{}>"
    exec "Snippet mfk models.ForeignKey(<{}>)<CR><{}>"
    exec "Snippet m2m models.ManyToManyField(<{}>)<CR><{}>"
    exec "Snippet o2o models.OneToOneField(<{}>)<CR><{}>"
endif
