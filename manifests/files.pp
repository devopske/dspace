$files = hiera_hash('files',{})
create_resources ( 'fileddd', $files )
#profile::file{}
