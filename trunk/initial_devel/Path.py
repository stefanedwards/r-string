###
# Module File
# Describes a filename path, adding shortcut functions to all the neat
# os.path functions.
# Date: September 2012
# Version 2
# Author: Stefan McKinnon Edwards <stefan.hoj-edwards@agrsci.dk>
###
from __future__ import print_function
import os.path as op
import bz2
import gzip

class Path(str):
    '''
    Class representing a path.
    Works on strings, note bytes.
    '''
    def __new__(cls, value):
      if value is None:
        return None
      return str.__new__(cls, value)
    
    def open(self, mode='r'):
        ''' Based on file extensions, opens the pathname with either bz2, gzip
        or normal open.
        
        '''
        if self.lower().endswith('.bz2'):
            return bz2.BZ2File(self, mode=mode)
        elif self.lower().endswith('.gz'):
            return gzip.GzipFile(self, mode=mode)
        else:
            return open(self, mode=mode)

        def pformat(self, *args, **kwargs):
          ''' Same as str.format, but returns a Path object. '''
          return Path(self.format(*args, **kwargs))

    @property
    def stripext(self):
        ''' Returns path without extension. See splitext. '''
        return self.splitext()[0]
    @property
    def ext(self):
        ''' Returns extension without leading period. '''
        return self.splitext()[1].lstrip('.')
    def append(self, val, *args):
        ''' Adds a path to the end of the current path. '''
        return Path(op.join(self, val, *args))

    ## Imported from os.path
    @property
    def abspath(self):
        ''' Returns absolute path, taking current working dir into account. '''
        return Path(op.abspath(str(self)))
    @property
    def dirname(self):
        ''' Returns directory part of Path. '''
        return Path(op.dirname(str(self)))
    @property    
    def basename(self):
        ''' Returns basename part of Path. '''
        return Path(op.basename(str(self)))
    @property
    def exists(self):
        ''' True if Path is an existing file or directory. '''
        return op.exists(str(self))
    @property
    def expanduser(self):
        ''' Returns a copy with "~" expansion done. '''
        return op.expanduser(str(self))
    @property
    def expandvars(self):
        '''
        Returns string that is a copy of path with environment vars `$name`,
        `${name}` or `%name%` expanded.
        
        '''
        return op.expandvars(str(self))
    @property
    def atime(self):    # Formerly getatime
        '''
        Returns last access time of Path (integer number of seconds since
        epoch).
        
        '''
        return op.getatime(str(self))
    @property
    def ctime(self):    # Formerly getctime
        '''
        Returns the metadata change time of Path (integer number of seconds
        since epoch).
        
        '''
        return op.getctime(str(self))
    @property
    def mtime(self):    # Formerly getmtime
        '''
        Returns last modification time of Path (integer number of seconds
        since epoch).
        
        '''
        return op.getmtime(str(self))
    @property
    def size(self):     # Formerly getsize
        '''
        Returns the size in bytes of Path. Throws os.error if file inexistent
        or inaccessible.
        
        '''
        return op.getsize(str(self))
    @property
    def isabs(self):
        ''' True if Path is absolute. '''
        return op.isabs(str(self))
    @property
    def isdir(self):
        ''' True if Path is a directory. '''
        return op.isdir(str(self))
    @property
    def isfile(self):
        ''' True if Paths is a _regular_ file. '''
        return op.isfile(str(self))
    @property
    def islink(self):
        ''' True if Path is a symbolik link. '''
        return op.islink(str(self))
    @property
    def ismount(self):
        ''' True if Path is a mount point [ True for all dirs on Windows. ] '''
        return op.ismount(str(self))

    def join(self, *args):
        '''
        Just as os.path.join, with the object itself as the first component.
        Joins one or more path components intelligently; 
        i.e. if any component is an absolute path, than all components prior 
        to it is discarded.
        
        NB! This method has serverly changed behaviour compared to that for 
            Python 2.7!!!        
        '''
        
        return Path(op.join(str(self), *args))
    @property
    def lexists(self):
        '''
        True if the Path is a existing file, even if is might be a symbolic
        link.
        
        '''
        return op.lexists(str(self))
    @property
    def normcase(self):
        ''' Normalizes case of Path. No effect under Posix. '''
        return Path(op.normcase(str(self)))
    @property
    def normpath(self):
        ''' Normalizes path, eliminating double slashes, etc. '''
        return Path(op.normpath(str(self)))
    @property
    def realpath(self):
        '''
        Returns the canonical path, eliminating any symbolic links encountered
        in the path.
        
        '''
        return Path(op.realpath(str(self)))
    def relpath(self, start='.'):
        '''
        Returns a relative filepath to Path, from `start` or current working
        directory.
        
        '''
        return Path(op.relpath(str(self), str(start)))
    # samefile, sameopenfile and samestat referes to file-pointers, not paths.
    def split(self):
        '''
        Splits Path into (head, tail) where tail is last pathname component and
        head is everything leading up to that. <=> (dirname, basename).
        
        '''
        res = op.split(str(self))
        return Path(res[0]), Path(res[1])
    def splitdrive(self):
        ''' Splits Path into a pair ('drive:', tail) [Windows]. '''
        res = op.splitdrive(str(self))
        return res[0], Path(res[1])
    def splitext(self):
        '''
        Splits into (root, ext) where last component of root contains no
        periods, and ext is empty or starts with a period.
        
        '''
        res = op.splitext(str(self))
        return Path(res[0]), res[1]
    def walk(self, visit, arg):
        '''
        Calls the function visit with arguments (arg, dirname, names) for each
        directory recursively in the directory tree rooted at p (including p
        itself if it's a dir). The argument dirname specifies the visited
        directory, the argument names lists the files in the directory. The
        visit function may modify names to influence the set of directories
        visited below dirname, e.g. to avoid visiting certain parts of the tree.
        See also os.walk() for an alternative.
        
        '''
        return op.walk(str(self), visit, arg)
        
