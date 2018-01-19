$files = hiera_hash('files',{})
create_resources ( 'dspace::pfiles', $files )

