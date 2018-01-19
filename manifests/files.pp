$files = hiera_hash('files',{})
create_resources ( 'file', $files )
#profile::file{}
