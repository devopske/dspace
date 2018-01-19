$files = hiera('files',{})
create_resources ( 'dspace::pfile', $files )

