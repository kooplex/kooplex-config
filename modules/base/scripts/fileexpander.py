def _f(fn):
    fn = os.path.expanduser(fn)
    assert os.path.exists(fn), "File %s not found" % fn
    target = os.getenv('REPORT_TARGET')
    home = os.path.expanduser('~')
    fnreal = os.path.realpath(fn)
    folder, file = os.path.split(fnreal)
    if folder.startswith(home) and target is not None:
        folder = folder[len(home):]
        targetfolder = os.path.join(target, folder)
        distutils.dir_util.mkpath(targetfolder)
        distutils.file_util.copy_file(fnreal, targetfolder)
    return fnreal
