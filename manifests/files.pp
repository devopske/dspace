#hiera_include('classes')
$files = hiera('files',{})
notify { "The Hash values are: ${files}": }
create_resources ( 'dspace::pfile', $files )

