# clean-m4a
A shell script using MP4Box (gpac) and libmp4v2 to completely purge watermarking from iTunes m4a files.
Warning: Converted files can not be played gapless any more. While this is no problem for files or albums which don't play continously, for e.g. mixes some milliseconds of silence between track are audible.  


Usage: m4aclean [-r] file1 file2 ...

If a specified input is a directory, all m4a files in the directory are processed. 

-r|--recursive:     For each specified directory, recursively clean m4a files
-h|--help:          print usage information
