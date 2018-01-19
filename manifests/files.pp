$files = hiera_hash('files',{})
create_resources ( 'profile::file', $files )
profile::file{}
