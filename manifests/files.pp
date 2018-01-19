$files = hiera_hash('files',{})
create_resources ( 'dspace::pfile', $files )

